//
//  StarGenerator.swift
//  StarMap
//
//  Created by Francesco Albano on 08/10/25.
//

import SwiftUI

/// Generatore di stelle casuali (usato come fallback).
enum StarGenerator {
    
    /// Genera un array di stelle casuali distribuite uniformemente sulla sfera celeste.
    static func generateRandomStars(count: Int) -> [Star] {
        var stars: [Star] = []
        
        for _ in 0..<count {
            // Coordinate sferiche randomiche (distribuzione uniforme)
            let theta = Double.random(in: 0...(2 * .pi)) // Corrisponde all'Ascensione Retta
            let phi = acos(2 * Double.random(in: 0...1) - 1)   // Corrisponde alla Declinazione
            
            let ra = theta.toDegrees
            let dec = phi.toDegrees - 90.0
            
            // 👈 CORREZIONE: Converti le coordinate astronomiche (RA/Dec) in una posizione
            // cartesiana fissa, esattamente come facciamo per le stelle reali.
            let cartesian = equatorialToCartesian(ra: ra, dec: dec)
            let rotationAngle = Double.pi / 2
            let rotatedY = cartesian.y * cos(rotationAngle) - cartesian.z * sin(rotationAngle)
            let rotatedZ = cartesian.y * sin(rotationAngle) + cartesian.z * cos(rotationAngle)
            let position = CartesianCoordinates(x: cartesian.x, y: rotatedY, z: rotatedZ)
            
            // Proprietà stella
            let magnitude = pow(Double.random(in: 0...1), 2) * 6
            let brightness = Float(pow(2.512, -magnitude))
            let size = Float(2.0 + brightness * 8.0)
            
            // Tipo spettrale e colore
            let (color, spectralType) = generateSpectralProperties()
            
            // 👈 CORREZIONE: Usa il nuovo inizializzatore di `Star` con `position`.
            stars.append(Star(
                name: "Stella Casuale",
                position: position,
                brightness: brightness,
                size: size,
                color: color,
                spectralClass: spectralType
            ))
        }
        
        return stars
    }
    
    /// Converte coordinate astronomiche in cartesiane.
    private static func equatorialToCartesian(ra: Double, dec: Double) -> CartesianCoordinates {
        let raRad = ra.toRadians
        let decRad = dec.toRadians
        let x = cos(decRad) * cos(raRad)
        let y = cos(decRad) * sin(raRad)
        let z = sin(decRad)
        return CartesianCoordinates(x: x, y: y, z: z)
    }
    
    /// Genera proprietà spettrali basate su temperatura casuale.
    private static func generateSpectralProperties() -> ((r: Float, g: Float, b: Float), String) {
        let temperature = Double.random(in: 0...1)
        
        switch temperature {
        case 0..<0.1:   return ((r: 0.6, g: 0.7, b: 1.0), "O")
        case 0.1..<0.3: return ((r: 0.9, g: 0.95, b: 1.0), "A")
        case 0.3..<0.6: return ((r: 1.0, g: 1.0, b: 1.0), "F")
        case 0.6..<0.85:return ((r: 1.0, g: 0.95, b: 0.7), "G")
        default:        return ((r: 1.0, g: 0.7, b: 0.5), "M")
        }
    }
}

