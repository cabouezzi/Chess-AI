//
//  Zobrist.swift
//  Chess ML
//
//  Created by Chaniel Ezzi on 7/15/21.
//

import Foundation

typealias ZobristKey = UInt64

func random64 () -> UInt64 {
    UInt64.random(in: UInt64.min...UInt64.max)
}

//TODO: Custom random number generator
struct Zobrist {
    
    static let turnToMoveKey: ZobristKey = random64()
    // By file
    static let enPassantKeys: [ZobristKey] = RandomKeys8()
    
    static let whiteKingKey: [ZobristKey] = RandomKeys64()
    static let whiteQueenKey: [ZobristKey] = RandomKeys64()
    static let whiteRookKey: [ZobristKey] = RandomKeys64()
    static let whiteBishopKey: [ZobristKey] = RandomKeys64()
    static let whiteKnightKey: [ZobristKey] = RandomKeys64()
    static let whitePawnKey: [ZobristKey] = RandomKeys64()
    
    static let blackKingKey: [ZobristKey] = RandomKeys64()
    static let blackQueenKey: [ZobristKey] = RandomKeys64()
    static let blackRookKey: [ZobristKey] = RandomKeys64()
    static let blackBishopKey: [ZobristKey] = RandomKeys64()
    static let blackKnightKey: [ZobristKey] = RandomKeys64()
    static let blackPawnKey: [ZobristKey] = RandomKeys64()
    
    static private func RandomKeys8 () -> [ZobristKey] {
        
        var holder = [ZobristKey](repeating: 0, count: 64)
        
        for i in 0...7 {
            holder[i] = random64()
        }
        
        return holder
        
    }
    
    static private func RandomKeys64 () -> [ZobristKey] {
        
        var holder = [ZobristKey](repeating: 0, count: 64)
        
        for i in 0...63 {
            holder[i] = random64()
        }
        
        return holder
        
    }
    
    static func GetKeyForBoard (_ board: Board) -> ZobristKey {
        
        var key: ZobristKey = 0
        
        for i in 0...63 {
            
            guard let piece = board.position.squares[i] else { continue }
            
            key ^= Zobrist.GetKeyForPiece(piece: piece, index: i)
            
        }
        
        
        key ^= ZobristKey(board.state.castlingRights)
        
        if !board.state.isWhiteToMove {
            key ^= Zobrist.turnToMoveKey
        }
        if let ep = board.state.enPassantIndex {
            key ^= Zobrist.enPassantKeys[Int(ep) % 8]
        }
        
        return key
        
    }
    
    static func GetKeyForPiece (piece: Piece, index i: Int) -> ZobristKey {
        
        switch (piece.color, piece.type) {
        case (.White, .King):   return Zobrist.whiteKingKey[i]
        case (.White, .Queen):  return Zobrist.whiteQueenKey[i]
        case (.White, .Rook):   return Zobrist.whiteRookKey[i]
        case (.White, .Bishop): return Zobrist.whiteBishopKey[i]
        case (.White, .Knight): return Zobrist.whiteKnightKey[i]
        case (.White, .Pawn):   return Zobrist.whitePawnKey[i]
            
        case (.Black, .King):   return Zobrist.blackKingKey[i]
        case (.Black, .Queen):  return Zobrist.blackQueenKey[i]
        case (.Black, .Rook):   return Zobrist.blackRookKey[i]
        case (.Black, .Bishop): return Zobrist.blackBishopKey[i]
        case (.Black, .Knight): return Zobrist.blackKnightKey[i]
        case (.Black, .Pawn):   return Zobrist.blackPawnKey[i]
        }
        
    }
    
}
