//
//  ComputerPlayer.swift
//  Chess ML
//
//  Created by Chaniel Ezzi on 8/1/21.
//

import Foundation

class ComputerPlayer: Player {
    
    var perspective: PieceColor
    var manager: GameManager
    
    let testBoard: Board
    let engine: ChanielsChessEngine
    let dedicatedQue = DispatchQueue(label: UUID().uuidString, qos: .userInteractive)
    
    init (perspective: PieceColor, manager: GameManager) {
        self.perspective = perspective
        self.manager = manager
        
        self.testBoard = Board()
        self.engine = ChanielsChessEngine(testBoard, settings: .init(mode: .fixedDepth(6), usesTranspositionTable: true, usesOpeningBook: false))
        
        testBoard.position = manager.board.position
        testBoard.state = manager.board.state
    }
    
    func NotifyTurn() {
        
        testBoard.position = manager.board.position
        testBoard.state = manager.board.state
        testBoard.zobristKey = manager.board.zobristKey
        
        dedicatedQue.async {

            guard let move = self.engine.BestMove() else {
                print("Engine couldn't find a move")
                return
            }
            
            DispatchQueue.main.sync {
                self.manager.SendMoveRequest(move)
            }

        }
        
        
    }
    
    func OfferDraw() {
        
    }
    
    
}
