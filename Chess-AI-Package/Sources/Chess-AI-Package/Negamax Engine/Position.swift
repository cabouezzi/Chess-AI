//
//  Position.swift
//  Chess ML
//
//  Created by Chaniel Ezzi on 7/12/21.
//

import Foundation

typealias Bitboard = UInt64

struct Position {
    
    var zobristKey: UInt32 = 0

    private(set) var squares = [Piece?](repeating: nil, count: 64)
    private(set) var bitboards: [Bitboard] = [Bitboard](repeating: 0, count: 12)
    
    /*
     
     Bitboards are organized by piece (type and color) using the raw value of the
     piece type and an offset depending on black or white. For visualization, they
     are organized as follows:
     
         [0]  White King         [6]  Black King
         [1]  White Pawn         [7]  Black Pawn
         [2]  White Knight       [8]  Black Knight
         [3]  White Bishop       [9]  Black Bishop
         [4]  White Rook         [10] Black Rook
         [5]  White Queen        [11] Black Queen
     
     */

    var all: Bitboard { return self[.White] | self[.Black] }

    var pinners: Bitboard = 0
    var checkers: Bitboard = 0
    var pinnedPieces: Bitboard = 0
    
    var whiteAttackMask: Bitboard = 0
    var blackAttackMask: Bitboard = 0

    mutating func setPiece (_ piece: Piece, at index: Int) {
        squares[index] = piece
        self[piece].set(at: index)

    }

    mutating func pop (at index: Int) {
        
        //Pop bitboard with piece at that index
        if let piece = squares[index] {
            self[piece].pop(at: index)
        }
        
        //Update squares
        squares[index] = nil

    }

    mutating func moveContent (from start: Int, to target: Int) {

        guard let sender = squares[start] else {
            print("no sender")
            _Debug()
            print(Notation.CoordinateFromIndex[start], Notation.CoordinateFromIndex[target])
            print(start, target)
            fatalError()
        }

        let changes: Bitboard = (Bitboard(1) << start) | (Bitboard(1) << target)

        //Move piece
        self[sender] ^= changes

        //Handle capture
        if let capture = squares[target] {
            self[capture] ^= Bitboard(1) << target
        }

        //Update squares array
        squares[start] = nil
        squares[target] = sender

    }

    //By type and color
    subscript (piece: Piece) -> Bitboard {

        get {
            let offset = (piece.color == .White) ? 0 : 6
            return bitboards[Int(piece.type.rawValue) - 1 + offset]
        }
        set {
            let offset = (piece.color == .White) ? 0 : 6
            bitboards[Int(piece.type.rawValue) - 1 + offset] = newValue
        }

    }

    //By color
    subscript (c: PieceColor) -> Bitboard {
        return c == .White ? bitboards[0] | bitboards[1] | bitboards[2] | bitboards[3] | bitboards[4] | bitboards[5]
                           : bitboards[6] | bitboards[7] | bitboards[8] | bitboards[9] | bitboards[10] | bitboards[11]
    }

    //By type
    subscript (t: PieceType) -> Bitboard {
        return bitboards[Int(t.rawValue) - 1] | bitboards[Int(t.rawValue) + 5]
    }

    mutating func erase () {

        squares = [Piece?](repeating: nil, count: 64)

        for i in 0...bitboards.count-1 {
            bitboards[i] = 0
        }

    }

    func _Debug () {
        print("~~~~~~~~~~~~~~~")

        for rank in 0...7 {

            for file in 0...7 {

                let index = (7 - rank) * 8 + file
                let piece = squares[index]

                var char: Character
                switch piece?.type {
                case .King: char = "k"
                case .Pawn: char = "p"
                case .Knight: char = "n"
                case .Bishop: char = "b"
                case .Rook: char = "r"
                case .Queen: char = "q"
                case nil:
                    print("• ", terminator: "")
                    continue
                }

                if piece!.color == .White {
                    char = char.uppercased().first!
                }

                print("\(char) ", terminator: "")

            }
            print("")

        }

        print("~~~~~~~~~~~~~~~")
    }

}
