//
//  HumanPlayer.swift
//  Chess ML
//
//  Created by Chaniel Ezzi on 8/1/21.
//

import Foundation

class HumanPlayer: Player {
    
    var perspective: PieceColor
    var manager: GameManager
    
    init (perspective: PieceColor, manager: GameManager) {
        self.perspective = perspective
        self.manager = manager
    }
    
    deinit {
        
    }
    
    func NotifyTurn() {
        
    }
    
    func OfferDraw() {
        
    }
    
    
}
