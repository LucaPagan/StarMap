import SwiftUI

struct PlanetDetailView: View {
    enum PlanetTab {
        case features, quiz
    }

    let planet: PlanetInfo
    let xpCalculator: XPCalculator
    var onComplete: () -> Void = {}
    var onPlanetQuizComplete: ((String) -> Void)? = nil
    var onStartARDiscovery: (() -> Void)? = nil

    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTab: PlanetTab = .features
    @State private var isRotating = false

    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                colors: [
                    Color(red: 10/255, green: 10/255, blue: 30/255),
                    Color(red: 20/255, green: 5/255, blue: 40/255),
                    Color(red: 15/255, green: 10/255, blue: 35/255)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Starfield Background
            Canvas { context, size in
                for _ in 0..<100 {
                    let x = CGFloat.random(in: 0...size.width)
                    let y = CGFloat.random(in: 0...size.height)
                    let starSize = CGFloat.random(in: 0.5...2)
                    let opacity = Double.random(in: 0.3...1)
                    let rect = CGRect(x: x, y: y, width: starSize, height: starSize)
                    let path = Circle().path(in: rect)
                    context.fill(path, with: .color(Color.white.opacity(opacity)))
                }
            }
            .ignoresSafeArea()

            VStack(spacing: 0) {
                headerView
                planetImageView
                tabButtons

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        switch selectedTab {
                        case .features:
                            PlanetInfoView(planet: planet)
                            PlanetFactsView(planet: planet)
                        case .quiz:
                            PlanetQuizView(
                                planet: planet,
                                availableScopes: [.planet],
                                defaultScope: .planet,
                                xpCalculator: xpCalculator,
                                onComplete: {
                                    onComplete()
                                    onPlanetQuizComplete?(planet.name)
                                },
                                onStartARDiscovery: onStartARDiscovery
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Child Views

    private var headerView: some View {
        HStack {
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
            }
            Spacer()
            Text(planet.name)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            Spacer()
            Color.clear.frame(width: 40, height: 40) // Placeholder for alignment
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }

    private var planetImageView: some View {
        Image(planet.imageName)
            .resizable()
            .scaledToFit()
            .frame(width: 200, height: 200)
            .rotationEffect(.degrees(isRotating ? 360 : 0))
            .shadow(color: Color.purple.opacity(0.6), radius: 25, x: 0, y: 0)
            .onAppear {
                withAnimation(Animation.linear(duration: 40).repeatForever(autoreverses: false)) {
                    isRotating = true
                }
            }
            .padding(.bottom, 20)
    }

    private var tabButtons: some View {
        HStack(spacing: 12) {
            ForEach([PlanetTab.features, .quiz], id: \.self) { tab in
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: iconForTab(tab))
                            .font(.system(size: 24))
                        Text(titleForTab(tab))
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(selectedTab == tab ? .white : .white.opacity(0.5))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(selectedTab == tab ? Color.blue.opacity(0.3) : Color.white.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
    }

    // MARK: - Helper Functions

    private func iconForTab(_ tab: PlanetTab) -> String {
        switch tab {
        case .features: return "info.circle.fill"
        case .quiz: return "brain.head.profile"
        }
    }

    private func titleForTab(_ tab: PlanetTab) -> String {
        switch tab {
        case .features: return "Features"
        case .quiz: return "Quiz"
        }
    }
}

#Preview {
    PlanetDetailView(planet: PlanetInfo.sample[0], xpCalculator: XPCalculator())
}