import SwiftUI

struct PlanetQuizBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 10/255, green: 10/255, blue: 30/255),
                    Color(red: 20/255, green: 5/255, blue: 40/255),
                    Color(red: 15/255, green: 10/255, blue: 35/255)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            Canvas { context, size in
                for _ in 0..<120 {
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
        }
    }
}

struct PlanetQuizLoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                .scaleEffect(2)
            Text("Loading Quiz...")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
        }
    }
}
