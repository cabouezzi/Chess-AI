//
//  BoardState.swift
//  Chess ML
//
//  Created by Chaniel Ezzi on 7/17/21.
//

import Foundation

class BoardState {
    
    
    private var value: UInt16
    
    /*
     
     0000 0000 0000 1111   Castling rights
     0000 0000 1111 0000   Captured piece
     0011 1111 0000 0000   Fifty move counter
     0100 0000 0000 0000
     1000 0000 0000 0000   Turn to move
     
    */
    
    var isWhiteToMove: Bool {
        get { value & 32768 != 0 }
        set {
            if newValue { value |= 32768 }
            else { value &= ~32768 }
        }
    }
    
    var castlingRights: UInt8 {
        get { UInt8(value & 0b1111) }
        set {
            value &= ~0b1111
            value |= UInt16(newValue & 0b1111)
        }
    }
    var capturedPiece: Piece? {
        get {
            let v = value & 0b11110000
            if v == 0 { return nil }
            else { return .init(literalValue: UInt8(v >> 4)) }
        }
        set {
            value &= ~0b11110000
            if let piece = newValue {
                value |= UInt16(piece.value) << 4
            }
        }
    }
    var fiftyMoveRule: UInt8 {
        get {
            return UInt8((value & 0b111100000000) >> 8)
        }
        set {
            value &= ~0b111100000000
            value |= UInt16(newValue) << 8
        }
    }

    var enPassantIndex: UInt8? // 6 bits

    private(set) var previous: BoardState?
    var lastMovePlayed: Move? = nil // 16 bits
    var lastPosition: Position? = nil

    init (isWhiteToMove: Bool,
          castlingRights: UInt8,
          fiftyMoveRule: UInt8,
          enPassantIndex: UInt8? = nil,
          capturedPiece: Piece? = nil,
          previous: BoardState? = nil) {
        
        self.value = 0

        self.isWhiteToMove = isWhiteToMove
        self.castlingRights = castlingRights
        self.fiftyMoveRule = fiftyMoveRule
        self.enPassantIndex = enPassantIndex
        self.capturedPiece = capturedPiece
        self.previous = previous

    }
    
    ///Doesn't include position.
    func CompareRepetitionParameters (_ other: BoardState) -> Bool {
        
        return isWhiteToMove == other.isWhiteToMove && castlingRights == other.castlingRights && enPassantIndex == other.enPassantIndex
        
        
    }
    
    func Iterate (_ block: (BoardState) -> Void) {
        
        var current: BoardState? = self

        while current != nil {
            
            block(current!)
            current = current!.previous

        }
        
    }
    
    var moveHistory: [Move] {
        
        var history = [Move]()
        
        Iterate {
            if let move = $0.lastMovePlayed {
                history.append(move)
            }
        }
        
        return history.reversed()
        
    }

}


//struct BoardState {
//    var isWhiteToMove: Bool // 1 bit
//    var castlingRights: UInt8 // 4 bits
//    var fiftyMoveRule: UInt8 // 6 bits
//    var threeFoldRepetition: UInt8 // 2 bits
//
//    var enPassantIndex: UInt8? // 6 bits
//    var capturedPiece: Piece? // 4 bits
//
//    var previous: Reference<BoardState>?
//    var previousMove: Move? = nil
//    var previousPos: Position? = nil
//}

struct Reference<T> {

    private var pointer: UnsafePointer<T>!
    var value: T? { return pointer.pointee }

    init(_ value: inout T) {
        withUnsafePointer(to: &value, { self.pointer = $0 })
    }

}

