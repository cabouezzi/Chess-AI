//
//  Perft.swift
//  Chess AI
//
//  Created by Chaniel Ezzi on 8/25/21.
//

import Foundation

extension ChanielsChessEngine {
    
    func DoPerft (depth: Int) {
        
        var numNodes: Int = 0
        
        let start = CFAbsoluteTimeGetCurrent()
        
        for firstMove in moveGenerator.AllLegalMoves() {
            
            board.CommitMove(firstMove)
            
            let search = PerftSearch(depth: depth - 1)
            numNodes += search
            
//            print(firstMove.description, ": ", search)
            
            board.UndoMove(firstMove)
            
        }
        
        let timeTook = CFAbsoluteTimeGetCurrent() - start
        
        print("Nodes counted \(numNodes), Time \(timeTook), NPS \(Double(numNodes) / timeTook)")
        
    }
    
    private func PerftSearch (depth: Int, root: Int = 0) -> Int {
        
        if depth == 0 {
            return 1
        }
        
        var nodes = 0
        
        for move in moveGenerator.AllLegalMoves() {
            
            board.CommitMove(move)
            nodes += PerftSearch(depth: depth - 1, root: root + 1)
            board.UndoMove(move)
            
        }
        
        return nodes
        
    }
    
}
