//
//  BBFEN.swift
//  Chess ML
//
//  Created by Chaniel Ezzi on 7/10/21.
//

import Foundation

extension Board {

    static func SetFromFEN (_ board: Board, _ fen: String) {
        
        board.position.erase()
        
        let components = fen.components(separatedBy: " ")
        let position = components[0]
        let turn = components[1]
        let castling = components[2]
        let enPassant = components[3]
        
        var rank = 7
        var file = 0
        for char in position {
            
            if char == "/" {
                rank -= 1
                file = 0
                continue
            }
            
            if let num = char.wholeNumberValue {
                for _ in 1...num {
                    file += 1
                }
                continue
            }
            
            let color = char.isUppercase ? PieceColor.White : .Black
            let index = rank * 8 + file
            
            switch char.lowercased(){
            case "k":
                board.position.setPiece(.init(color, .King), at: index)
            case "q":
                board.position.setPiece(.init(color, .Queen), at: index)
            case "r":
                board.position.setPiece(.init(color, .Rook), at: index)
            case "b":
                board.position.setPiece(.init(color, .Bishop), at: index)
            case "n":
                board.position.setPiece(.init(color, .Knight), at: index)
            case "p":
                board.position.setPiece(.init(color, .Pawn), at: index)
            default: break
            }
            
            file += 1
            
        }
        
        switch turn.first! {
        case "w": board.state.isWhiteToMove = true
        case "b": board.state.isWhiteToMove = false
        default: break
        }
        
        board.state.castlingRights = 0
        if !castling.contains("-") {
            if castling.contains("K") {
                board.state.castlingRights |= 0b0001
            }
            if castling.contains("Q") {
                board.state.castlingRights |= 0b0010
            }
            if castling.contains("k") {
                board.state.castlingRights |= 0b0100
            }
            if castling.contains("q") {
                board.state.castlingRights |= 0b1000
            }
        }
        
        if !enPassant.contains("-") {
            //TODO: EP index from coordinate (e.g. e3)
        }
        
    }
    
    static func FENFromBoard (_ board: Board) -> String {
        var fen = ""
        
        fen.append(FENPositionSection(pos: board.position))
        
        fen.append(" ")
        fen.append(board.state.isWhiteToMove ? "w" : "b")
        
        fen.append(" ")
        if board.state.castlingRights == 0 {
            fen.append("-")
        }
        else {
            if board.state.castlingRights & 0b0001 != 0 {
                fen.append("K")
            }
            if board.state.castlingRights & 0b0010 != 0 {
                fen.append("Q")
            }
            if board.state.castlingRights & 0b0100 != 0 {
                fen.append("k")
            }
            if board.state.castlingRights & 0b1000 != 0 {
                fen.append("q")
            }
        }
        
        fen.append(" ")
        if let ep = board.state.enPassantIndex {
            fen.append(BoardRepresentation.CoordinatesOfIndex[Int(ep)])
        }
        else {
            fen.append("-")
        }
        
        fen.append(" ")
        
        var movesSincePawnPushOrCapture = 0
        var currentInfo: BoardState? = board.state

        while currentInfo != nil {

            guard let lastMove = currentInfo?.lastMovePlayed else { break }
            guard let lastPos = currentInfo?.lastPosition else { break }

            //Pawn moved
            if lastPos.squares[lastMove.startIndex]?.type == .Pawn {
                break
            }
            //Piece was captured
            if currentInfo!.capturedPiece != nil {
                break
            }

            currentInfo = currentInfo!.previous
            movesSincePawnPushOrCapture += 1

        }

        
        fen.append(String(describing: movesSincePawnPushOrCapture))
        
        fen.append(" ")
        fen.append("0")
        
        return fen
    }
    
    private static func FENPositionSection (pos: Position) -> String {
        var fen = ""
        
        var rank: Int = 7
        var file: Int = 0
        
        while rank >= 0 {
            var emptyCounter = 0
            while file <= 7 {
                
                let index = rank * 8 + file
                let sq = pos.squares[index]
                
                var char: Character
                
                switch sq?.type {
                
                case nil:
                    emptyCounter += 1
                    file += 1
                    continue
                    
                case .King:   char = "k"
                case .Pawn:   char = "p"
                case .Knight: char = "n"
                case .Bishop: char = "b"
                case .Rook:   char = "r"
                case .Queen:  char = "q"
                    
                }
                
                if emptyCounter != 0 {
                    fen.append(String(describing: emptyCounter))
                    emptyCounter = 0
                }
                
                if sq?.color == .White {
                    char = char.uppercased().first!
                }
                
                fen.append(char)
                
                file += 1
            }
            
            if emptyCounter != 0 {
                fen.append(String(describing: emptyCounter))
            }
            fen.append("/")
            
            rank -= 1
            file = 0
            
        }
        
        
        return fen
    }

}
