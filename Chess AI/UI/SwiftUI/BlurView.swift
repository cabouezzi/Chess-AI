//
//  BlurView.swift
//  Chess AI
//
//  Created by Chaniel Ezzi on 8/7/21.
//

import SwiftUI
import AppKit

struct BlurView: NSViewRepresentable {
    
    typealias NSViewType = NSVisualEffectView
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        
        let view = NSVisualEffectView()
        
        view.blendingMode = .behindWindow
        
        return view
        
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        
    }
    
}
