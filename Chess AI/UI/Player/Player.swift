//
//  Player.swift
//  Chess ML
//
//  Created by Chaniel Ezzi on 7/9/21.
//

import Foundation


protocol Player: AnyObject {
    
    var perspective: PieceColor { get }
    var manager: GameManager { get }
    
    func NotifyTurn ()
    func OfferDraw ()
    
}
