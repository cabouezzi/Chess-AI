//
//  Evaluation.swift
//  Chess AI
//
//  Created by Chaniel Ezzi on 8/19/21.
//

import Foundation

class Evaluator {
    
    static let pieceValues: [Int] = [9999, 10, 30, 30, 50, 90]
    
    let board: Board
    
    enum GamePhase {
        case opening, middle, end
    }
    
    var phase: GamePhase = .opening
    
    init (_ board: Board) {
        self.board = board
    }
    
    func DetermineGamePhase () {
        
        let total = CountMaterial()
        
        if total <= 180 {
            phase = .end
        }

    }
    
    func EndGameWeight () -> Float {
        
        let total: Float = Float(CountMaterial())
        
        let activationPoint: Float = 180
        
        // caps at 1.0
        let weight = (activationPoint - total) / activationPoint
        
        return max(0, weight)
    }
    
    func Evaluation () -> Int {
        
        return CompareMaterial()
        
        DetermineGamePhase()
        
        let material = CompareMaterial()
//        let activity = DetermineActivity()
        let pieceSquare = EvaluatePieceSquareTables()
        
        let egWeight = EndGameWeight() * 5
        
        let kingActivity = Float(EvaluateKingActivity()) * egWeight
        
        return (material * 10) + pieceSquare + Int(kingActivity)
        
    }
    
    func CountMaterial () -> Int {
        
        var total = 0
        
        for ptype in [PieceType.Pawn, .Knight, .Bishop, .Rook, .Queen] {
            total += board.position[ptype].nonzeroBitCount * Evaluator.pieceValues[Int(ptype.rawValue - 1)]
        }
        
        return total
        
    }
    
    func CompareMaterial () -> Int {
        
        var eval = 0
        
        for ptype in [PieceType.Pawn, .Knight, .Bishop, .Rook, .Queen] {
            let w = board.position[Piece(.White, ptype)].nonzeroBitCount
            let b = board.position[Piece(.Black, ptype)].nonzeroBitCount
            eval += (w-b) * Evaluator.pieceValues[Int(ptype.rawValue - 1)]
        }
        
        let f = board.state.isWhiteToMove ? 1 : -1
        return eval * f
        
    }
    
    func EvaluatePieceSquareTables () -> Int {
        
        var holder = 0
        
        let isWhite = board.state.isWhiteToMove
        let color = isWhite ? PieceColor.White : .Black
        
        holder += PieceSquareTable.Apply(table: PieceSquareTable.pawnMiddle, pieces: board.position[Piece(color, .Pawn)], isWhite: isWhite)
        holder += PieceSquareTable.Apply(table: PieceSquareTable.knight, pieces: board.position[Piece(color, .Knight)], isWhite: isWhite)
        holder += PieceSquareTable.Apply(table: PieceSquareTable.bishop, pieces: board.position[Piece(color, .Bishop)], isWhite: isWhite)
        holder += PieceSquareTable.Apply(table: PieceSquareTable.rook, pieces: board.position[Piece(color, .Rook)], isWhite: isWhite)
        holder += PieceSquareTable.Apply(table: PieceSquareTable.queen, pieces: board.position[Piece(color, .Queen)], isWhite: isWhite)
        holder += PieceSquareTable.Apply(table: phase == .end ? PieceSquareTable.kingEnd : PieceSquareTable.kingMiddle, pieces: board.position[Piece(color, .King)], isWhite: isWhite)
        
        return holder
        
    }
    
    func EvaluateKingActivity () -> Int {
        
        let wki = board.position[Piece(.White, .King)].ls1b()!
        let bki = board.position[Piece(.Black, .King)].ls1b()!
        
        let whitePressure = PieceSquareTable.distanceFromCenter[bki]
        let blackPressure = PieceSquareTable.distanceFromCenter[wki]
        
        let f = board.state.isWhiteToMove ? 1 : -1
        
        
        return f*(whitePressure - blackPressure)
        
    }
    
}
