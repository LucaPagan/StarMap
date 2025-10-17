import SwiftUI

/// A service for rendering celestial objects onto the screen.
struct SkyRenderer {

    /// Projects 3D Cartesian coordinates onto a 2D screen with perspective.
    static func project(
        coordinates: CartesianCoordinates,
        screenCenter: CGPoint,
        scale: Double
    ) -> CGPoint? {
        guard coordinates.isVisible else { return nil }
        let projectedX = screenCenter.x + (coordinates.x / coordinates.z) * scale
        let projectedY = screenCenter.y - (coordinates.y / coordinates.z) * scale
        return CGPoint(x: projectedX, y: projectedY)
    }

    /// Checks if a projected point is visible on the screen (with a buffer).
    static func isOnScreen(
        point: CGPoint,
        screenSize: CGSize,
        buffer: Double = AppConfig.renderingBuffer
    ) -> Bool {
        return point.x > -buffer &&
               point.x < screenSize.width + buffer &&
               point.y > -buffer &&
               point.y < screenSize.height + buffer
    }

    /// Draws a star with a realistic multi-layer glow effect.
    static func drawStar(
        on context: GraphicsContext,
        at position: CGPoint,
        size: Double,
        color: Color,
        brightness: CGFloat,
        showGlow: Bool
    ) {
        let finalColor = color.opacity(Double(brightness))

        if size >= AppConfig.detailedStarSizeThreshold && showGlow {
            // HIGH DETAIL
            var outerContext = context
            outerContext.addFilter(.blur(radius: size * 0.8))
            let outerGlowRect = CGRect(x: position.x - size * 2, y: position.y - size * 2, width: size * 4, height: size * 4)
            outerContext.fill(Circle().path(in: outerGlowRect), with: .color(finalColor.opacity(0.25)))

            var innerContext = context
            innerContext.addFilter(.blur(radius: size * 0.35))
            let innerGlowRect = CGRect(x: position.x - size * 1.2, y: position.y - size * 1.2, width: size * 2.4, height: size * 2.4)
            innerContext.fill(Circle().path(in: innerGlowRect), with: .color(finalColor.opacity(0.65)))

            let coreSize = size * 0.3
            let coreRect = CGRect(x: position.x - coreSize / 2, y: position.y - coreSize / 2, width: coreSize, height: coreSize)
            context.fill(Circle().path(in: coreRect), with: .color(.white.opacity(Double(brightness) * 0.95)))

        } else if size >= AppConfig.simpleStarSizeThreshold && showGlow {
            // MEDIUM DETAIL
            let glowRect = CGRect(x: position.x - size * 1.6, y: position.y - size * 1.6, width: size * 3.2, height: size * 3.2)
            context.fill(Circle().path(in: glowRect), with: .color(finalColor.opacity(0.35)))

            let coreSize = size * 0.3
            let coreRect = CGRect(x: position.x - coreSize / 2, y: position.y - coreSize / 2, width: coreSize, height: coreSize)
            context.fill(Circle().path(in: coreRect), with: .color(.white.opacity(Double(brightness) * 0.85)))

        } else {
            // LOW DETAIL
            let starRect = CGRect(x: position.x - size / 2, y: position.y - size / 2, width: size, height: size)
            context.fill(Circle().path(in: starRect), with: .color(finalColor))
        }
    }

    private static let planetImageMapping: [String: String] = [
        "Sun": "sun", "Moon": "moon", "Venus": "venus", "Jupiter": "jupiter",
        "Saturn": "saturn", "Mars": "mars", "Mercury": "mercury", "Uranus": "uranus",
        "Neptune": "neptune"
    ]

    static func drawPlanet(on context: GraphicsContext, at position: CGPoint, size: Double, planet: Planet) {
        let rect = CGRect(x: position.x - size / 2, y: position.y - size / 2, width: size, height: size)
        
        // This part is fine, as you might have images for planets
        if let imageName = planetImageMapping[planet.name], UIImage(named: imageName) != nil {
            context.draw(Image(imageName), in: rect)
        } else {
            context.fill(Circle().path(in: rect), with: .color(planet.primaryColor))
        }
    }
    static func drawNebula(on context: GraphicsContext, at position: CGPoint, size: Double, nebula: Nebula) {
        
        // 1. Definiamo il raggio del nostro "punto di nebbia".
        // È leggermente più grande della dimensione base per dargli un po' di area.
        let fogRadius = size * 1.5
        
        let fogRect = CGRect(
            x: position.x - fogRadius,
            y: position.y - fogRadius,
            width: fogRadius * 2,
            height: fogRadius * 2
        )
        
        // 2. Creiamo una copia del context per applicare una sfocatura morbida.
        // Una sfocatura moderata crea un bordo soffice senza essere troppo dispersiva.
        var blurredContext = context
        blurredContext.addFilter(.blur(radius: fogRadius * 0.6))
        
        // 3. Disegniamo un gradiente radiale con opacità molto bassa.
        // Questo è il cuore dell'effetto "nebbia".
        blurredContext.fill(
            Circle().path(in: fogRect),
            with: .radialGradient(
                Gradient(colors: [
                    nebula.primaryColor.opacity(0.25), // Opacità massima molto bassa al centro
                    nebula.primaryColor.opacity(0.0)    // Sfuma completamente a trasparente
                ]),
                center: position,
                startRadius: 0,
                endRadius: fogRadius
            )
        )
    }
}
