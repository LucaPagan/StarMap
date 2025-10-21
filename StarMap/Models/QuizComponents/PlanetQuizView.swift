import SwiftUI

enum QuizScope: String, CaseIterable, Identifiable {
    case planet
    case universe
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .planet:
            return "Questions about this world specifically."
        case .universe:
            return "General knowledge across the cosmos."
        }
    }
}

struct PlanetQuizView: View {
    let planet: PlanetInfo?
    let onComplete: () -> Void
    let availableScopes: [QuizScope]
    let xpCalculator: XPCalculator
    @State internal var currentQ = 0
    @State internal var selectedAns: String? = nil
    @State internal var submittedAns: String? = nil
    @State internal var isAnswered = false
    @State internal var score = 0
    @State internal var correctAnswers = 0
    @State internal var showResult = false
    @State internal var questions: [QuizQuestion] = []
    @State internal var selectedScope: QuizScope
    @State internal var showProgressRestored = false
    @Environment(\.presentationMode) var presentationMode
    
    // Quiz progress persistence
    @AppStorage("planetQuiz_savedProgress_default") internal var savedProgress: String = ""
    @AppStorage("planetQuiz_savedScore_default") internal var savedScore: Int = 0
    @AppStorage("planetQuiz_savedCorrectAnswers_default") internal var savedCorrectAnswers: Int = 0
    
    // Callback to close all quiz views and return to StarMap
    var onStartARDiscovery: (() -> Void)?
    
    // Computed property for storage key based on planet name
    private var progressKey: String {
        if let planetName = planet?.name {
            return "quizProgress_\(planetName)_\(selectedScope.rawValue)"
        }
        return "quizProgress_universe"
    }
    
    init(
        planet: PlanetInfo?,
        availableScopes: [QuizScope] = [.planet, .universe],
        defaultScope: QuizScope? = nil,
        xpCalculator: XPCalculator,
        onComplete: @escaping () -> Void = {},
        onStartARDiscovery: (() -> Void)? = nil
    ) {
        self.planet = planet
        self.onComplete = onComplete
        self.onStartARDiscovery = onStartARDiscovery
        self.xpCalculator = xpCalculator
        
        var filteredScopes = availableScopes.filter { scope in
            switch scope {
            case .planet:
                return planet != nil
            case .universe:
                return true
            }
        }
        if filteredScopes.isEmpty {
            filteredScopes = planet == nil ? [.universe] : [.planet]
        }
        self.availableScopes = filteredScopes
        
        let initialScope = defaultScope.flatMap { filteredScopes.contains($0) ? $0 : nil } ?? filteredScopes.first ?? .universe
        _selectedScope = State(initialValue: initialScope)
        
        // Initialize @AppStorage with dynamic key
        let storageKey: String
        if let planetName = planet?.name {
            storageKey = "quizProgress_\(planetName)_\(initialScope.rawValue)"
        } else {
            storageKey = "quizProgress_universe"
        }
        _savedProgress = AppStorage(wrappedValue: "", storageKey)
        _savedScore = AppStorage(wrappedValue: 0, "\(storageKey)_score")
        _savedCorrectAnswers = AppStorage(wrappedValue: 0, "\(storageKey)_correct")
    }
    
    var body: some View {
        ZStack {
            PlanetQuizBackground()
            
            ScrollView(showsIndicators: false) {
                Group {
                    if showResult {
                        resultView
                    } else if questions.isEmpty {
                        PlanetQuizLoadingView()
                    } else {
                        quizContentView
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear { prepareQuiz(for: selectedScope) }
        .onChange(of: selectedScope) { newScope in
            prepareQuiz(for: newScope)
        }
    }
    
    private var quizContentView: some View {
        VStack(spacing: 16) {
            restoredProgressBanner
            
            let q = questions[currentQ]
            
            PlanetQuizQuestionCard(
                question: q,
                index: currentQ,
                totalCount: questions.count,
                scope: selectedScope
            )
            
            VStack(spacing: 14) {
                ForEach(Array(q.options.enumerated()), id: \.offset) { index, option in
                    let state = answerVisualState(for: option, correctAnswer: q.correctAnswer)
                    
                    Button {
                        guard !isAnswered else { return }
                        selectedAns = selectedAns == option ? nil : option
                    } label: {
                        AnswerChoiceCard(
                            index: index + 1,
                            text: option,
                            state: state,
                            isLocked: isAnswered,
                            isSelected: selectedAns == option
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(isAnswered)
                }
            }
            
            Button(action: submitSelectedAnswer) {
                HStack(spacing: 12) {
                    Image(systemName: submitButtonIcon)
                        .font(.system(size: 18, weight: .medium))
                    Text(submitButtonTitle)
                        .font(.system(size: 16, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 28)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        colors: submitButtonColors,
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(isAnswered ? 0.3 : 0.2), lineWidth: 1.5)
                )
                .shadow(color: submitButtonColors.last?.opacity(0.6) ?? .clear, radius: 14, x: 0, y: 6)
            }
            .disabled(submitButtonDisabled)
            .opacity(submitButtonDisabled ? 0.6 : 1.0)
        }
    }
    
    private var resultView: some View {
        PlanetQuizResultView(
            mode: selectedScope == .planet ? .planet(name: planet?.name ?? "this planet") : .universe,
            performanceTitle: performanceTitle,
            summary: resultSummaryText,
            scoreBreakdown: scoreBreakdownText,
            detail: performanceDetail,
            onStartARDiscovery: planetDiscoveryAction,
            onRetry: selectedScope == .universe ? universeRetryAction : nil,
            onClose: { presentationMode.wrappedValue.dismiss() }
        )
    }
    
    private func submitSelectedAnswer() {
        guard !submitButtonDisabled, let selected = selectedAns else { return }
        submittedAns = selected
        isAnswered = true
        
        tallyCurrentAnswer()
        saveProgress()
        advanceAfterDelay()
    }
    
    private var submitButtonDisabled: Bool {
        selectedAns == nil || isAnswered
    }
    
    private var submitButtonTitle: String {
        switch (isAnswered, selectedAns) {
        case (true, _):
            return currentQ < questions.count - 1 ? "Preparing Next Question..." : "Calculating Results..."
        case (_, nil):
            return "Select an Answer"
        default:
            return "Tap to Submit"
        }
    }
    
    private var submitButtonIcon: String {
        switch (isAnswered, selectedAns) {
        case (true, _):
            return "hourglass.circle"
        case (_, nil):
            return "hand.tap"
        default:
            return "cursorarrow.click"
        }
    }
    
    private var submitButtonColors: [Color] {
        if submitButtonDisabled {
            return [Color.white.opacity(0.18), Color.white.opacity(0.1)]
        }
        return [
            Color(red: 88/255, green: 200/255, blue: 255/255),
            Color(red: 80/255, green: 120/255, blue: 255/255)
        ]
    }
    
    private var planetDiscoveryAction: (() -> Void)? {
        guard selectedScope == .planet else { return nil }
        return {
            if let onStartARDiscovery {
                onStartARDiscovery()
            } else {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    private var universeRetryAction: (() -> Void)? {
        guard selectedScope == .universe else { return nil }
        return {
            clearProgress()
            prepareQuiz(for: selectedScope)
        }
    }
    
    @ViewBuilder
    private var restoredProgressBanner: some View {
        if showProgressRestored {
            HStack {
                Image(systemName: "arrow.clockwise.circle.fill")
                    .foregroundColor(.green)
                Text("Progress restored: Question \(currentQ + 1)/\(questions.count)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.green.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.green.opacity(0.5), lineWidth: 1.5)
                    )
            )
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}

#Preview {
    PlanetQuizView(planet: PlanetInfo.sample.first, xpCalculator: XPCalculator())
}
