//
//  MoveOrdering.swift
//  Chess ML
//
//  Created by Chaniel Ezzi on 7/16/21.
//

import Foundation

class MoveOrderer {
    
    var board: Board
    var moveGenerator: MoveGenerator
    
    let captureWeight = 1
    let pieceSquareWeight = 1
    let promotionWeight = 2
    let castleWeight = 5
    
    
    init (board: Board) {
        self.board = board
        self.moveGenerator = MoveGenerator(board: board)
    }
    
    
    // TODO: Only sort the first 50 best moves
    func OrderMoves (moves: inout [Move]) {
        
        moves.sort(by: { MoveRating($0) > MoveRating($1) })
        
    }
    
    func MoveRating (_ move: Move) -> Int  {
        
        if TranspositionTable.GetEntry(key: board.zobristKey, depth: 4) != nil {
            return 999999
        }
        
        var rating = 0
        
        if let sender = board.position.squares[move.startIndex], let capture = board.position.squares[move.targetIndex] {
            
            let vd = 11*Evaluator.pieceValues[Int(capture.type.rawValue) - 1] - Evaluator.pieceValues[Int(sender.type.rawValue) - 1]
            rating += vd * captureWeight
            
            
            
//            let isWhite = board.state.isWhiteToMove
//
//            switch sender.type {
//            case .King:
//                rating += PieceSquareTable.Apply(table: PieceSquareTable.kingMiddle, pieces: board.position[sender], isWhite: isWhite) * Evaluator.pieceValues[0] * pieceSquareWeight
//            case .Pawn:
//                rating += PieceSquareTable.Apply(table: PieceSquareTable.pawnMiddle, pieces: board.position[sender], isWhite: isWhite) * Evaluator.pieceValues[1] * pieceSquareWeight
//            case .Knight:
//                rating += PieceSquareTable.Apply(table: PieceSquareTable.knight, pieces: board.position[sender], isWhite: isWhite) * Evaluator.pieceValues[2] * pieceSquareWeight
//            case .Bishop:
//                rating += PieceSquareTable.Apply(table: PieceSquareTable.bishop, pieces: board.position[sender], isWhite: isWhite) * Evaluator.pieceValues[3] * pieceSquareWeight
//            case .Rook:
//                rating += PieceSquareTable.Apply(table: PieceSquareTable.rook, pieces: board.position[sender], isWhite: isWhite) * Evaluator.pieceValues[4] * pieceSquareWeight
//            case .Queen:
//                rating += PieceSquareTable.Apply(table: PieceSquareTable.queen, pieces: board.position[sender], isWhite: isWhite) * Evaluator.pieceValues[5] * pieceSquareWeight
//            }
            
        }
        
        if move.tag.isPromotion {
            
            if move.tag == .PromoteToQueen {
                rating += 3 * promotionWeight
            }
            else if move.tag == .PromoteToRook {
                rating += 2 * promotionWeight
            }
            // Bishop/Knight
            else {
                rating += promotionWeight
            }
            
        }
        
        //if square is attacked by pawn
        
        
        //castling
        if move.tag == .KingSideCastle || move.tag == .QueenSideCastle {
            rating += castleWeight
        }
        
        
        return rating
        
    }
    
}
