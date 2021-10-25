//
//  Redesign.swift
//  Chess ML
//
//  Created by Chaniel Ezzi on 7/10/21.
//

import Foundation

class Board {
    
    var zobristKey: ZobristKey = 0
    
    var position = Position()
    var state: BoardState = BoardState(isWhiteToMove: true, castlingRights: 0b1111, fiftyMoveRule: 0)
    
    init() {
       Board.SetFromFEN(self, "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 0")
//        Board.SetFromFEN(self, "r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq - 0 0")
//        Board.SetFromFEN(self, "rnbq1k1r/pp1Pbppp/2p5/8/2B5/8/PPP1NnPP/RNBQK2R w KQ - 1 8")
//         Board.SetFromFEN(self, "8/k7/3p4/p2P1p2/P2P1P2/8/8/K7 w - - ")
//        Board.SetFromFEN(self, "6kr/8/5K2/8/8/8/8/8 w - - 0 1")
        
        zobristKey = Zobrist.GetKeyForBoard(self)
        
    }
    
    var whiteIsCastled: Bool = false
    var blackIsCastled: Bool = false
    
    func CommitMove (_ move: Move) {
        
        let newWhiteToMove = !state.isWhiteToMove
        var newCastlingRights = state.castlingRights
        let newFiftyCounter = state.fiftyMoveRule
        var newEPIndex: UInt8? = nil
        let capturedPiece = position.squares[move.targetIndex]
        let prevPos = position
        
        guard let sender = position.squares[move.startIndex]
        else {
            position._Debug()
            print(Notation.CoordinateFromIndex[move.startIndex], Notation.CoordinateFromIndex[move.targetIndex])
            fatalError("No piece at target")
        }
        
        position.moveContent(from: move.startIndex, to: move.targetIndex)
        
        switch move.tag {
        
        case .Normal: break
            
        case .KingSideCastle:
            sender.color == .White ? (whiteIsCastled = true) : (blackIsCastled = true)
            position.moveContent(from: move.startIndex + 3, to: move.targetIndex - 1)
            newCastlingRights &= sender.color == .White ? 0b1100 : 0b0011
            
        case .QueenSideCastle:
            sender.color == .White ? (whiteIsCastled = true) : (blackIsCastled = true)
            position.moveContent(from: move.startIndex - 4, to: move.targetIndex + 1)
            newCastlingRights &= sender.color == .White ? 0b1100 : 0b0011
            
        case .DoublePawnMove:
            newEPIndex = UInt8(move.targetIndex)
            
        case .EnPassant:
            guard let ep = state.enPassantIndex else { fatalError("What.") }
            position.pop(at: Int(ep))
            
        case .PromoteToQueen:
            position.pop(at: move.targetIndex)
            position.setPiece(Piece(sender.color, .Queen), at: move.targetIndex)
            
        case .PromoteToRook:
            position.pop(at: move.targetIndex)
            position.setPiece(Piece(sender.color, .Rook), at: move.targetIndex)
            
        case .PromoteToBishop:
            position.pop(at: move.targetIndex)
            position.setPiece(Piece(sender.color, .Bishop), at: move.targetIndex)
            
        case .PromoteToKnight:
            position.pop(at: move.targetIndex)
            position.setPiece(Piece(sender.color, .Knight), at: move.targetIndex)
            
        }
        
        if newCastlingRights != 0 {
            
            if sender.type == .King {
                newCastlingRights &= (sender.color == .White ? 0b1100 : 0b0011)
            }
            //White Kingside
            if move.startIndex == 7 || move.targetIndex == 7 {
                newCastlingRights &= 0b1110
            }
            //White Queenside
            if move.startIndex == 0 || move.targetIndex == 0 {
                newCastlingRights &= 0b1101
            }
            //Black Kingside
            if move.startIndex == 63 || move.targetIndex == 63 {
                newCastlingRights &= 0b1011
            }
            //Black Queenside
            if move.startIndex == 56 || move.targetIndex == 56 {
                newCastlingRights &= 0b0111
            }
            
        }
        
        
        
        //
        zobristKey ^= Zobrist.GetKeyForPiece(piece: sender, index: move.startIndex)
        zobristKey ^= Zobrist.GetKeyForPiece(piece: sender, index: move.targetIndex)
        zobristKey ^= Zobrist.turnToMoveKey

        if let capturedPiece = capturedPiece {
            zobristKey ^= Zobrist.GetKeyForPiece(piece: capturedPiece, index: move.targetIndex)
        }
        if let currentEp = state.enPassantIndex {
            zobristKey ^= Zobrist.enPassantKeys[Int(currentEp) % 8]
        }
        if let newEp = newEPIndex {
            zobristKey ^= Zobrist.enPassantKeys[Int(newEp) % 8]
        }
        //
        
        
        
        let newBoardState = BoardState(isWhiteToMove: newWhiteToMove,
                               castlingRights: newCastlingRights,
                               fiftyMoveRule: newFiftyCounter,
                               enPassantIndex: newEPIndex,
                               capturedPiece: capturedPiece,
                               previous: state)
        
        newBoardState.lastMovePlayed = move
        newBoardState.lastPosition = prevPos
        
        state = newBoardState
        
    }
    
    func UndoMove (_ move: Move) {
        
        guard state.previous != nil else {
            print("Couldn't find last board state.")
            return
        }
        
        guard let sender = position.squares[move.targetIndex] else {
            position._Debug()
            print(Notation.CoordinateFromIndex[move.startIndex], Notation.CoordinateFromIndex[move.targetIndex])
            fatalError("No piece at target in undoing move")
        }
        
        
        //
        zobristKey ^= Zobrist.GetKeyForPiece(piece: sender, index: move.startIndex)
        zobristKey ^= Zobrist.GetKeyForPiece(piece: sender, index: move.targetIndex)
        zobristKey ^= Zobrist.turnToMoveKey

        if let oldEp = state.previous!.enPassantIndex {
            zobristKey ^= Zobrist.enPassantKeys[Int(oldEp) % 8]
        }
        if let currentEp = state.enPassantIndex {
            zobristKey ^= Zobrist.enPassantKeys[Int(currentEp) % 8]
        }
        if let capturedPiece = state.capturedPiece {
            zobristKey ^= Zobrist.GetKeyForPiece(piece: capturedPiece, index: move.targetIndex)
        }
        //
        
        
        position.moveContent(from: move.targetIndex, to: move.startIndex)
        
        // I know, already unwrapped in zobrist but w/e
        if let capturedPiece = state.capturedPiece {
            position.setPiece(capturedPiece, at: move.targetIndex)
        }
        
        switch move.tag {
        
        case .EnPassant:
            position.setPiece(Piece(state.isWhiteToMove ? .White : .Black, .Pawn), at: Int(state.previous!.enPassantIndex!))
            
        case .KingSideCastle:
            position.moveContent(from: move.targetIndex - 1, to: move.startIndex + 3)
            
        case .QueenSideCastle:
            position.moveContent(from: move.targetIndex + 1, to: move.startIndex - 4)
            
        default:
            if move.tag.isPromotion {
                position.pop(at: move.startIndex)
                position.setPiece(Piece(state.isWhiteToMove ? .Black : .White, .Pawn), at: move.startIndex)
            }
            
        }
        
        state = state.previous!
        
        return;
        
    }
    
    
    
}
