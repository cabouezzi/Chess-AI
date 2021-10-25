//
//  TabButton.swift
//  Chess AI
//
//  Created by Chaniel Ezzi on 8/6/21.
//

import SwiftUI

struct TabButtonStyle: ButtonStyle {
    
    @State private var foreground: Color = .secondary
    @State private var background: Color = .secondary.opacity(0)
    
    func makeBody(configuration: Configuration) -> some View {
        
        return
            configuration.label
            .frame(width: 50, height: 50)
            .padding(5)
            
            .animation(.easeInOut.speed(2), value: foreground)
            .background(background)
            .foregroundColor(foreground)
            .scaledToFill()
            .cornerRadius(10)
            
            .onChange(of: configuration.isPressed, perform: { value in
                withAnimation {
                    foreground = value ? .primary : .secondary
                    background = foreground.opacity(value ? 0.15 : 0)
                }
            })
        
    }
    
}

struct TabButtonStyle_Previews: PreviewProvider {
    
    static var previews: some View {
        GameView()
    }
    
    
}
