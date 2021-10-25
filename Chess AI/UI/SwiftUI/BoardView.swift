//
//  SKView.swift
//  Chess ML
//
//  Created by Chaniel Ezzi on 7/28/21.
//

import SwiftUI
import SpriteKit

struct BoardView: View {
    
    private let scene: BoardScene
    
    init (scene: BoardScene = BoardScene()) {
        self.scene = scene
        self.scene.isUserInteractionEnabled = true
        self.scene.backgroundColor = .clear
        self.scene.scaleMode = .aspectFit
    }
    
    var body: some View {
        
        SpriteView(scene: scene)
            .aspectRatio(1, contentMode: .fit)
            .clipShape(Rectangle())
        
    }
    
    func changeScheme (_ scheme: BoardColorScheme) {
        scene.changeScheme(scheme)
    }
    
    func flip () {
        scene.rootNode.zRotation += CGFloat.pi
        
        for n in scene.squares {
            n.overlayPiece.zRotation += CGFloat.pi
        }
        
    }
    
}

struct BoardColorScheme {
    
    private(set) var light: Color
    private(set) var dark: Color
    
}
