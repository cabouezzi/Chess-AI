//
//  TabToggleButtonStyle.swift
//  Chess AI
//
//  Created by Chaniel Ezzi on 8/7/21.
//

import SwiftUI

struct TabToggleStyle: ToggleStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        
        return
            configuration.label
            
            .padding(3)
            
            .foregroundColor(configuration.isOn ? .primary : .secondary)
            .background(Color.primary.opacity(configuration.isOn ? 0.15 : 0))
            
            .font(.system(size: 20, weight: configuration.isOn ? .regular : .light))
            
            .scaledToFill()
            .cornerRadius(7)
        
            .onTapGesture {
                withAnimation(.easeInOut.speed(1)) {
                    configuration.isOn.toggle()
                }
            }
        
    }
    
}
