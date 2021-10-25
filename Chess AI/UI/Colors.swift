//
//  Colors.swift
//  Chess AI
//
//  Created by Chaniel Ezzi on 8/7/21.
//

import SwiftUI

extension Color {
    
    static var baige: Color = Color(hue: 40/359, saturation: 0.2, brightness: 0.98, opacity: 1)
    static var softPink: Color = Color(hue: 321/359, saturation: 0.21, brightness: 0.95)
    
}

extension BoardColorScheme {
    
    static var standard: BoardColorScheme = .init(light: Color(hue: 40/359, saturation: 0.2, brightness: 0.98),
                                                  dark: Color(hue: 31/359, saturation: 0.52, brightness: 0.6))
    
    static var pink: BoardColorScheme = .init(light: Color(hue: 307/359, saturation: 0.03, brightness: 0.97),
                                              dark: Color(hue: 321/359, saturation: 0.21, brightness: 0.95))
    
    static var green: BoardColorScheme = .init(light: .white,
                                               dark: Color(hue: 136/359, saturation: 0.45, brightness: 0.59))
    
    static var blue: BoardColorScheme = .init(light: .white,
                                              dark: Color(hue: 193/359, saturation: 0.37, brightness: 0.84))
    
    static var secondBlue: BoardColorScheme = .init(light: .white,
                                                    dark: Color(hue: 191/359, saturation: 0.52, brightness: 0.73))
    
}
