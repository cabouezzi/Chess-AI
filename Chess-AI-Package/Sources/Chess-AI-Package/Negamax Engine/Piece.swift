//
//  Piece.swift
//  Chess ML
//
//  Created by Chaniel Ezzi on 7/16/21.
//

import Foundation

enum PieceColor {
    case White, Black
    
    var opposite: PieceColor {
        return self == .White ? .Black : .White
    }
}

enum PieceType: UInt8 {
    
    //First 3 bits
    //000
    case King = 1
    case Pawn = 2
    case Knight = 3
    case Bishop = 4
    case Rook = 5
    case Queen = 6
    //case eligible8thPiece = 7
    
}

struct Piece {
    
    private(set) var value: UInt8
    
    init (_ color: PieceColor, _ type: PieceType) {
        self.value = (color == .White ? 0 : 8) | type.rawValue
    }
    
    init (literalValue: UInt8) {
        self.value = literalValue
    }
    
    static var none: Piece {
        return Piece(literalValue: 0)
    }
    
    var type: PieceType {
        return PieceType(rawValue: value & 7)!
    }
    
    var color: PieceColor {
        return (value & 8) == 0 ? .White : .Black
    }
    
}
