//
//  Move.swift
//  Chess ML
//
//  Created by Chaniel Ezzi on 7/10/21.
//

import Foundation

struct Move: Hashable {
    
    private var value: ushort
    
    enum Tag: UInt8 {
        
        case Normal = 0
        case DoublePawnMove = 1
        case EnPassant = 2
        case KingSideCastle = 3
        case QueenSideCastle = 4
        case PromoteToQueen = 5
        case PromoteToRook = 6
        case PromoteToBishop = 7
        case PromoteToKnight = 8
        
        var isPromotion: Bool {
            return rawValue > 4
        }
        
    }
    
    static private let startBitMask: ushort =            0b0000000000111111
    static private let targetBitMask: ushort =           0b0000111111000000
    //Not used
    static private let promotionBitMask: ushort =        0b0001000000000000
    static private let doublePawnPushBitMask: ushort =   0b0010000000000000
    static private let enPassantBitMask: ushort =        0b0100000000000000
    static private let castleBitMask: ushort =           0b1000000000000000
    
    /*
     
                0000 0000 0011 1111  Start index
                0000 1111 1100 0000  Target index
                0001 0000 0000 0000  Promotion
                0010 0000 0000 0000  Pawn double-push flag
                0100 0000 0000 0000  En passant flag
                1000 0000 0000 0000  Castle flag
                ~options~
      0000 1111 0000 0000 0000 0000  Captured Piece
      1111 0000 0000 0000 0000 0000  Promotion Piece
     
     
     */
    
    init (literalValue: ushort) {
        self.value = literalValue
    }
    
    init (startIndex: Int, targetIndex: Int, tag: Tag) {
        guard startIndex != targetIndex
        else {
            self.value = 0
            return
        }
        
        self.value = ushort(startIndex) | ushort(targetIndex) << 6 | UInt16(tag.rawValue) << 12
    }
    
    var tag: Tag {
        return Tag.init(rawValue: UInt8(value >> 12))!
    }
    
    var startIndex: Int {
        return Int(value & Move.startBitMask)
    }
    
    var targetIndex: Int {
        return Int((value & Move.targetBitMask) >> 6)
    }
    
    var isValid: Bool {
        return value != 0
    }
    
    var description: String {
        var d = BoardRepresentation.CoordinatesOfIndex[startIndex] + BoardRepresentation.CoordinatesOfIndex[targetIndex]
        
        if tag.isPromotion {
            switch tag {
            case .PromoteToQueen: d += "q"
            case .PromoteToRook: d += "r"
            case .PromoteToBishop: d += "b"
            case .PromoteToKnight: d += "n"
            default: break
            }
        }
        
        return d
    }
}

extension Array where Element == Move {
    
    func _debug () {
        let array: [String] = self.map({ $0.description })
        print(array)
    }
    
}
