//
//  PGN.swift
//  Chess AI
//
//  Created by Chaniel Ezzi on 8/6/21.
//

import Foundation

extension Board {
    
    // Information on move notation: https://en.wikipedia.org/wiki/Algebraic_notation_(chess)
    static func BoardFromPGN (fen: String = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 0", pgn importedPGN: String) -> Board {
        
        let board = Board()
        let moveGenerator = MoveGenerator(board: board)
        
        var pgn = importedPGN
                    .replacingOccurrences(of: "\n", with: " ")
                    .replacingOccurrences(of: ".", with: ". ")
        
        // Remove game information
        while pgn.contains("[") && pgn.contains("]") {
            
            if let range = pgn.range(from: "[", to: "]") {
                pgn.removeSubrange(range)
                pgn = pgn.replacingOccurrences(of: "[]", with: "")
            }
            else { break }
            
        }
        
        // Remove comments
        while pgn.contains("{") && pgn.contains("}") {
            
            if let range = pgn.range(from: "{", to: "}") {
                pgn.removeSubrange(range)
                pgn = pgn.replacingOccurrences(of: "{}", with: "")
            }
            else { break }
            
        }
        
        // Remove extra information
        pgn = pgn.replacingOccurrences(of: ".", with: "")
        pgn = pgn.replacingOccurrences(of: "x", with: "")
        pgn = pgn.replacingOccurrences(of: "+", with: "")
        pgn = pgn.replacingOccurrences(of: "#", with: "")
        pgn = pgn.replacingOccurrences(of: "!", with: "")
        pgn = pgn.replacingOccurrences(of: "?", with: "")
        pgn = pgn.replacingOccurrences(of: "-", with: "")
        
        let algebraicMoves = pgn.components(separatedBy: " ")
            .filter({ !$0.isEmpty })
            .filter({ !$0.first!.isNumber })
            .filter({ !$0.allSatisfy({ $0.isNumber }) })
        
        // Score is filterd through removing "-" and removing all only-numbers.
        
        for _constNOTATION in algebraicMoves {
            var notation = _constNOTATION
            
            // Castles are special
            // "-" were removed
            if notation == "OO" {
                let move = moveGenerator.AllLegalMoves().first(where: { $0.tag == .KingSideCastle })!
                board.CommitMove(move)
                continue
            }
            
            if notation == "OOO" {
                let move = moveGenerator.AllLegalMoves().first(where: { $0.tag == .QueenSideCastle })!
                board.CommitMove(move)
                continue
            }
            
            
            var tag: Move.Tag = .Normal
            var shouldReadTag = false
            // Read promotion tag
            if notation.contains("=") {
                let range = notation.range(of: "=")!.upperBound...
                let promotionChar = notation[range]
                
                switch promotionChar {
                case "Q": tag = .PromoteToQueen
                case "R": tag = .PromoteToRook
                case "B": tag = .PromoteToBishop
                case "N": tag = .PromoteToKnight
                default: fatalError("Unrecognized piece sender tag")
                }
                
                // Remove tag
                notation.removeLast()
                notation.removeLast()
                
                shouldReadTag = true
                
            }
            
            // Normal now
                // Mark: I will never forgive apple for not making easier string parsing.
            
            // Target coordinate always last
            let lastIndex = notation.index(notation.startIndex, offsetBy: notation.count-1)
            let secondLastIndex = notation.index(before: lastIndex)
            let targetCoordinate = notation[secondLastIndex...lastIndex]
            
            guard let targetIndex = Notation.CoordinateFromIndex.firstIndex(of: String(targetCoordinate))
            else {
                fatalError("Unrecognized index for move notation \(targetCoordinate)")
            }
            
            // Sender type always first
            let sender: PieceType
            switch notation.first! {
            case "K": sender = .King
            case "Q": sender = .Queen
            case "R": sender = .Rook
            case "B": sender = .Bishop
            case "N": sender = .Knight
            default : sender = .Pawn
            }
            
            // If file and/or rank are provided
            var specifiedFile: Int = 0
            var specifiedRank: Int = 0
            var shouldMonitorFile = false
            var shouldMonitorRank = false
            
            if notation.count > 2 {
            
                let thirdLastIndex = notation.index(before: secondLastIndex)
                
                if notation[thirdLastIndex].isNumber {
                    
                    shouldMonitorRank = true
                    specifiedRank = notation[thirdLastIndex].wholeNumberValue! - 1
                    
                    if notation.count > 3 {
                        
                        let fourthLastIndex = notation.index(before: thirdLastIndex)
                        
                        if notation[fourthLastIndex].isLowercase {
                            shouldMonitorFile = true
                            specifiedFile = Notation.CoordinateFromIndex.firstIndex(where: { $0.contains(notation[fourthLastIndex] )})! % 8
                        }
                        
                    }
                    
                }
                else if notation[thirdLastIndex].isLowercase {
                    
                    shouldMonitorFile = true
                    specifiedFile = Notation.CoordinateFromIndex.firstIndex(where: { $0.contains(notation[thirdLastIndex] )})! % 8
                    
                }
                
            }
            
            
            guard let move = moveGenerator.AllLegalMoves().first(where: { legalMove in
                
                return  legalMove.targetIndex == targetIndex &&
                        board.position.squares[legalMove.startIndex]?.type == sender &&
                        (legalMove.tag == tag || !shouldReadTag) &&
                        (legalMove.startIndex % 8 == specifiedFile || !shouldMonitorFile) &&
                        (legalMove.startIndex / 8 == specifiedRank || !shouldMonitorRank)
            })
            else {
                board.position._Debug()
                print(notation)
                print(algebraicMoves)
                fatalError("PGN contains an illegal move.")
            }
            
            board.CommitMove(move)
            
        }
        
        return board
        
    }
    
    
    static func PGNFromMoveHistory (_ history: [Move], result: GameResult? = nil) -> String {
        
        let board = Board()
        let moveGenerator = MoveGenerator(board: board)
        
        var algebraicMoves: [String] = []
        
        for move in history {
            
            var symbol: String
            var shouldSpecifyFile: Bool = false
            var shouldSpecifyRank: Bool = false
            var targetCoord: String
            var isCapture: Bool = false
            var isCheck: Bool = false
            var isMate: Bool = false
            

            
            let piece = board.position.squares[move.startIndex]!
            var overlappingPieces: Bitboard = 0
            
            switch piece.type {
            case .King:     symbol = "K"
            case .Queen:    symbol = "Q"
            case .Rook:     symbol = "R"
            case .Bishop:   symbol = "B"
            case .Knight:   symbol = "N"
            case .Pawn:     symbol = ""
            }
            
            for i in 0..<board.position.squares.count where board.position.squares[i]?.type == piece.type {
                
                if i == move.startIndex { continue }
                
                if moveGenerator.LegalMoves(at: i).contains(where: { $0.targetIndex == move.targetIndex }) {
                    overlappingPieces.set(at: i)
                }
                
            }
            
            if overlappingPieces != 0 {
                
                overlappingPieces.loop { i in
                    
                    if (i / 8) == (move.startIndex / 8) {
                        shouldSpecifyFile = true
                    }
                    
                    if (i % 8) == (move.startIndex % 8) {
                        shouldSpecifyRank = true
                    }
                    
                }
                
            }
            
            targetCoord = Notation.CoordinateFromIndex[move.targetIndex]
            isCapture = board.position.squares[move.targetIndex] != nil || move.tag == .EnPassant
            
            board.CommitMove(move)
            
            if moveGenerator.AllLegalMoves().count == 0 {
                if moveGenerator.KingIsInCheck() {
                    isMate = true
                }
            }
            else if moveGenerator.KingIsInCheck() {
                isCheck = true
            }
            
            var holder = ""
            
            holder.append(symbol)
            
            if shouldSpecifyFile || (piece.type == .Pawn && isCapture) {
                holder.append(Notation.CoordinateFromIndex[move.startIndex].first!)
            }
            if shouldSpecifyRank {
                holder.append(Notation.CoordinateFromIndex[move.startIndex].last!)
            }
            if isCapture {
                holder.append("x")
            }
            
            holder.append(targetCoord)
            
            switch move.tag {
            case .KingSideCastle:
                // Override
                holder = "O-O"
            case .QueenSideCastle:
                // Override
                holder = "O-O-O"
            case .PromoteToQueen:
                holder.append("=Q")
            case .PromoteToRook:
                holder.append("=R")
            case .PromoteToBishop:
                holder.append("=B")
            case .PromoteToKnight:
                holder.append("=N")
            default: break
            }
            
            if isCheck {
                holder.append("+")
            }
            if isMate {
                holder.append("#")
            }
            
            algebraicMoves.append(holder)
            
        }
        
        var pgn = ""
        
        for i in 0..<algebraicMoves.count {
            
            if i.isMultiple(of: 2) {
                pgn += "\(i / 2 + 1). "
            }
            
            pgn += algebraicMoves[i] + " "
            
        }
        
        if let result = result {
            switch result {
            case .draw:
                pgn.append("1/2-1/2")
            case .whiteWon:
                pgn.append("1-0")
            case .blackWon:
                pgn.append("0-1")
            }
        }
        
        return pgn
        
    }
    
}

extension String {
    
    func range (from: String, to: String) -> Range<Index>? {
        
        guard let rangeFrom = range(of: from)?.upperBound else { return nil }
        guard let rangeTo = self[rangeFrom...].range(of: to)?.lowerBound else { return nil }
        return rangeFrom..<rangeTo
        
    }
    
}
