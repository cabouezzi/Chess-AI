//
//  MoveGenerator.swift
//  Chess ML
//
//  Created by Chaniel Ezzi on 7/10/21.
//

import Foundation

class MoveGenerator {
    
    let directions = Directions.Standard
    
    var board: Board!
    var friendly: PieceColor!
    var enemy: PieceColor!
    
    var allPieces: Bitboard {
        return board.position.all
    }
    
    init (board: Board) {
        self.board = board
        friendly = board.state.isWhiteToMove ? .White : .Black
        enemy = friendly.opposite
    }
    
    func Reestablish () {
        friendly = board.state.isWhiteToMove ? .White : .Black
        enemy = friendly.opposite
        
        SetCheckers()
        
    }
    
    func AllLegalMoves (capturesOnly: Bool = false) -> [Move] {
        
        Reestablish()
        
        var moves = [Move]()
                
        board.position[friendly].loop { i in
            
            moves += LegalMoves(at: i, capturesOnly: capturesOnly)
            
        }
        
        return moves
        
    }
    
    func LegalMoves (at index: Int, capturesOnly: Bool = false) -> [Move] {
        
        guard let piece = board.position.squares[index] else { return [] }
        guard piece.color == (board.state.isWhiteToMove ? .White : .Black)
        else { return [] }
        
        if KingIsInDoubleCheck() && piece.type == .King {
            return KingMoves(at: index, capturesOnly: capturesOnly)
        }
        else if KingIsInDoubleCheck() {
            return []
        }
        
        switch piece.type {
        case .King:
            return KingMoves(at: index, capturesOnly: capturesOnly)
            
        case .Pawn:
            return PawnMoves(at: index, capturesOnly: capturesOnly)
            
        case .Knight:
            return KnightMoves(at: index, capturesOnly: capturesOnly)
            
        case .Bishop, .Rook, .Queen:
            return SlidingPieceMoves(at: index, capturesOnly: capturesOnly)
            
        }
        
    }
    
    func isOccupied (_ index: Int) -> Bool {
        
        return board.position.squares[index] != nil
        
    }
    
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    /*  MARK: CHECK HANDLING                              */
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    
    func KingIsInCheck () -> Bool {
        
        return board.position.checkers != 0
        
    }
    
    func KingIsInDoubleCheck () -> Bool {
        
        return board.position.checkers.nonzeroBitCount > 1
        
    }
    
    
    ///For pieces that aren't directly defending the king from check already, AKA pinned pieces.
    func DefendingCheckMask () -> Bitboard {
        
        guard KingIsInCheck()
        else { return ~0 }
        
        guard !KingIsInDoubleCheck()
        else { return 0 }
        
        let checkerIndex = board.position.checkers.ls1b()!
        let pt = board.position.squares[checkerIndex]!.type
        
        guard pt != .Knight && pt != .Pawn
        else { return Bitboard(1) << checkerIndex }
        
        //Get diagonal/orthogonal rays from king
        let kingIndex = board.position[Piece(friendly, .King)].ls1b()!
        let diagTest = BishopAttackMask(at: kingIndex, occupancy: allPieces)
        let orthoTest = RookAttackMask(at: kingIndex, occupancy: allPieces)
        
        //If separated into Bishop–Rook–Queen, Queen's mask can overlap between diagonal and orthogonal rays
        if diagTest.isOn(at: checkerIndex) {
            
            var shared = diagTest & BishopAttackMask(at: checkerIndex, occupancy: allPieces)
            //Can capture, of course
            shared.set(at: checkerIndex)
            return shared
            
        }
        
        else if orthoTest.isOn(at: checkerIndex) {
            
            var shared = orthoTest & RookAttackMask(at: checkerIndex, occupancy: allPieces)
            //Can capture, of course
            shared.set(at: checkerIndex)
            return shared
            
        }
        
        
        return 0
        
    }
    
    func SetCheckers () {
        
        let kingIndex = board.position[Piece(friendly, .King)].ls1b()!
        
        let rookMask = RookAttackMask(at: kingIndex, occupancy: allPieces)
        let bishopMask = BishopAttackMask(at: kingIndex, occupancy: allPieces)
        let knightMask = KnightAttackMask(at: kingIndex)
        let pawnMask = PawnAttackMask(at: kingIndex)
        
        //
        let rookCheckers = rookMask & (board.position[Piece(enemy, .Rook)] | board.position[Piece(enemy, .Queen)])
        let bishopCheckers = bishopMask & (board.position[Piece(enemy, .Bishop)] | board.position[Piece(enemy, .Queen)])
        let knightCheckers = knightMask & board.position[Piece(enemy, .Knight)]
        let pawnCheckers = pawnMask & board.position[Piece(enemy, .Pawn)]
        
        board.position.checkers = rookCheckers | bishopCheckers | knightCheckers | pawnCheckers
        
    }
    
    func SquareIsAttacked (_ index: Int, by color: PieceColor) -> Bool {
        
        let filtered = allPieces & ~board.position[Piece(color.opposite, .King)]
        
        let rookMask = RookAttackMask(at: index, occupancy: filtered)
        let bishopMask = BishopAttackMask(at: index, occupancy: filtered)
        let knightMask = KnightAttackMask(at: index)
        let pawnMask = PawnAttackMask(at: index)
        let kingMask = KingAttackMask(at: index)
        
        let rookAttackers = rookMask & (board.position[Piece(color, .Rook)] | board.position[Piece(enemy, .Queen)])
        let bishopAttackers = bishopMask & (board.position[Piece(color, .Bishop)] | board.position[Piece(enemy, .Queen)])
        let knightAttackers = knightMask & board.position[Piece(color, .Knight)]
        let pawnAttackers = pawnMask & board.position[Piece(color, .Pawn)]
        let king = kingMask & board.position[Piece(color, .King)]
        
        return (rookAttackers | bishopAttackers | knightAttackers | pawnAttackers | king) != 0
        
    }
    
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    /*  MARK: PIN HANDLING                                */
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    
//    func IsPinned (_ index: Int) -> Bool {
//        return board.position.pinnedPieces.isOn(at: index)
//    }
    
    ///Returns nil if not pinned at the given index.
    func PinRay (from index: Int) -> Bitboard? {
        
        let kingsIndex = board.position[Piece(friendly, .King)].ls1b()!
        
        let orthogonalPieces = board.position[Piece(enemy, .Rook)] | board.position[Piece(enemy, .Queen)]
        
        if RankLine(at: index).isOn(at: kingsIndex) && RankLine(at: index) & orthogonalPieces != 0 {
            return RankLine(at: index)
        }
        
        if FileLine(at: index).isOn(at: kingsIndex) && FileLine(at: index) & orthogonalPieces != 0 {
            return FileLine(at: index)
        }
        
        let diagonalPieces = board.position[Piece(enemy, .Bishop)] | board.position[Piece(enemy, .Queen)]
        
        if DiagonalLine(at: index).isOn(at: kingsIndex) && DiagonalLine(at: index) & diagonalPieces != 0 {
            return DiagonalLine(at: index)
        }
        
        if AntiDiagonalLine(at: index).isOn(at: kingsIndex) && AntiDiagonalLine(at: index) & diagonalPieces != 0 {
            return AntiDiagonalLine(at: index)
        }
        
        return nil
        
    }
    
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    /*  MARK: SLIDING PIECES                              */
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    
    func SlidingPieceMoves (at index: Int, capturesOnly: Bool) -> [Move] {
        
        guard let pt = board.position.squares[index]?.type
        else { return [] }
        
        var bishopMask = BishopAttackMask(at: index, occupancy: allPieces) & ~board.position[friendly]
        var rookMask = RookAttackMask(at: index, occupancy: allPieces) & ~board.position[friendly]
        
        if let pin = PinRay(from: index) {
            
            if KingIsInCheck() {
                return []
            }
            
            bishopMask &= pin
            rookMask &= pin
        }
        else if KingIsInCheck() {
            let blockingMask = DefendingCheckMask()
            bishopMask &= blockingMask
            rookMask &= blockingMask
        }
        
        
        if capturesOnly {
            let emask = board.position[enemy]
            bishopMask &= emask
            rookMask &= emask
        }
        
        
        switch pt {
        case .Bishop:
            
            var moves = [Move]()
            
            bishopMask.loop { target in
                moves.append(Move(startIndex: index, targetIndex: target, tag: .Normal))
            }
            
            return moves
            
        case .Rook:
            
            var moves = [Move]()
            
            rookMask.loop { target in
                moves.append(Move(startIndex: index, targetIndex: target, tag: .Normal))
            }
            
            return moves
            
        case .Queen:
            
            var moves = [Move]()
            
            (bishopMask | rookMask).loop { target in
                moves.append(Move(startIndex: index, targetIndex: target, tag: .Normal))
            }
            
            return moves
            
        default: return []
            
        }
        
    }
    
    func RookAttackMask (at index: Int, occupancy: Bitboard) -> Bitboard {
        
        //Bring each rank to 8 bits
        let rDrop = (index/8) * 8
        let rankOcc: UInt8 = UInt8((SlidingAttacks.RankRays[index] & occupancy) >> rDrop) & 0b11111111
        let slider: UInt8 = 1 << UInt8(index % 8)
        let droppedRank = (rankOcc &- 2 &* slider) ^ (rankOcc.bitSwapped &- 2 &* slider.bitSwapped).bitSwapped
        let rank = Bitboard(droppedRank) << rDrop
        
//        let fDrop = (7 - index % 8) * 8
//        let fileOcc: UInt8 = UInt8((SlidingAttacks.FileRays[index] & occupancy).rotated90Clockwise() >> fDrop)
//        let file: Bitboard = (Bitboard(OrthogonalOccupantFilter(occupants: fileOcc, slider: 1 << UInt8(index / 8) )) << fDrop).rotated90CounterClockwise()
        
        //https://www.chessprogramming.org/Hyperbola_Quintessence
        let sMask = Bitboard(1) << index

        var file, reverse: Bitboard

        file = occupancy & SlidingAttacks.FileRays[index]
        reverse = file.byteSwapped
        file &-= sMask
        reverse &-= sMask.byteSwapped
        file ^= reverse.byteSwapped
        file &= SlidingAttacks.FileRays[index]
        
        return rank | file
        
    }
    
    func BishopAttackMask (at index: Int, occupancy: Bitboard) -> Bitboard {
        
        let sMask = Bitboard(1) << index
        
        //Diag
        var diag, reverse: Bitboard
        
        diag = occupancy & SlidingAttacks.DiagonalRays[index]
        reverse = diag.byteSwapped
        diag &-= sMask
        reverse &-= sMask.byteSwapped
        diag ^= reverse.byteSwapped
        diag &= SlidingAttacks.DiagonalRays[index]
        
        //Anti Diag
        var antiDiag, antiReverse: UInt64
        
        antiDiag  = occupancy & SlidingAttacks.AntiDiagonalRays[index];
        antiReverse = antiDiag.byteSwapped;
        antiDiag &-= sMask
        antiReverse &-= sMask.byteSwapped
        antiDiag ^= antiReverse.byteSwapped
        antiDiag &= SlidingAttacks.AntiDiagonalRays[index]
        
        return diag | antiDiag
        
    }
    
    func QueenAttackMask (at index: Int, occupancy: Bitboard) -> Bitboard {
        
        return RookAttackMask(at: index, occupancy: occupancy) | BishopAttackMask(at: index, occupancy: occupancy)
        
    }
    
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    /*  MARK: Sliding Piece Attack Functions              */
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    
    func RankLine (at index: Int) -> Bitboard {
        let rDrop = (index/8) * 8
        let rankOcc: UInt8 = UInt8((SlidingAttacks.RankRays[index] & allPieces) >> rDrop) & 0b11111111
        let slider: UInt8 = 1 << UInt8(index % 8)
        let droppedRank = (rankOcc &- 2 &* slider) ^ (rankOcc.bitSwapped &- 2 &* slider.bitSwapped).bitSwapped
        let rank = Bitboard(droppedRank) << rDrop
        
        return rank
    }
    
    func FileLine (at index: Int) -> Bitboard {
        let sMask = Bitboard(1) << index

        var file, reverse: Bitboard

        file = allPieces & SlidingAttacks.FileRays[index]
        reverse = file.byteSwapped
        file &-= sMask
        reverse &-= sMask.byteSwapped
        file ^= reverse.byteSwapped
        file &= SlidingAttacks.FileRays[index]
        
        return file
    }
    
    func DiagonalLine (at index: Int) -> Bitboard {
        
        let sMask = Bitboard(1) << index
        
        //Diag
        var diag, reverse: Bitboard
        
        diag = allPieces & SlidingAttacks.DiagonalRays[index]
        reverse = diag.byteSwapped
        diag &-= sMask
        reverse &-= sMask.byteSwapped
        diag ^= reverse.byteSwapped
        diag &= SlidingAttacks.DiagonalRays[index]
        
        return diag
        
    }
    
    func AntiDiagonalLine (at index: Int) -> Bitboard {
        
        let sMask = Bitboard(1) << index
        
        //Anti Diag
        var antiDiag, antiReverse: UInt64
        
        antiDiag  = allPieces & SlidingAttacks.AntiDiagonalRays[index];
        antiReverse = antiDiag.byteSwapped;
        antiDiag &-= sMask
        antiReverse &-= sMask.byteSwapped
        antiDiag ^= antiReverse.byteSwapped
        antiDiag &= SlidingAttacks.AntiDiagonalRays[index]
        
        return antiDiag
        
    }
    
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    /*  MARK: KNIGHT                                      */
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    
    func KnightMoves (at index: Int, capturesOnly: Bool) -> [Move] {
        
        var moves = [Move]()
        
        guard PinRay(from: index) == nil
        else { return moves }
        
        var mask = KnightAttackMask(at: index) & ~board.position[friendly]
        
        if KingIsInCheck() {
            mask &= DefendingCheckMask()
        }
        
        if capturesOnly {
            mask &= board.position[enemy]
        }
        
        mask.loop { target in
            moves.append(Move(startIndex: index, targetIndex: target, tag: .Normal))
        }
        
        return moves
        
    }
    
    func KnightAttackMask (at index: Int) -> Bitboard {
        return ConstantPieceMoveTable.KnightAttacks[index]
    }
    
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    /*  MARK: KING                                        */
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    
    //TODO: ew
    func KingMoves (at index: Int, capturesOnly: Bool) -> [Move] {
        
        var moves = [Move]()
        
        var mask = KingAttackMask(at: index)
        
        if capturesOnly {
            mask &= board.position[enemy]
        }
        else {
            if CanCastleKingside() {
                moves.append(.init(startIndex: index, targetIndex: index + 2, tag: .KingSideCastle))
            }
            if CanCastleQueenside() {
                moves.append(.init(startIndex: index, targetIndex: index - 2, tag: .QueenSideCastle))
            }
        }
        
        mask.loop { i in
            
            guard !SquareIsAttacked(i, by: enemy)
            else { return }
            
            moves.append(Move(startIndex: index, targetIndex: i, tag: .Normal))
            
        }
        
        return moves
        
    }
    
    func KingAttackMask (at index: Int) -> Bitboard {
        return ConstantPieceMoveTable.KingAttacks[index] & ~board.position[friendly]
    }
    
    func CanCastleKingside () -> Bool {
        
        guard !KingIsInCheck() else { return false }
        
        let rightsMask: UInt8 = friendly == .White ? 0b0001 : 0b0100
        
        guard board.state.castlingRights & rightsMask != 0 else { return false }
        
        let spaces: Bitboard = friendly == .White ? 0b01100000 : 0b01100000 << 56
        
        guard spaces & allPieces == 0 else { return false }
        
        var safe: Bool = true
        spaces.loop { space in
            if SquareIsAttacked(space, by: enemy) { safe = false }
        }
        
        guard safe else { return false }
        
        return true
        
    }
    
    func CanCastleQueenside () -> Bool {
        
        guard !KingIsInCheck() else { return false }
        
        let rightsMask: UInt8 = friendly == .White ? 0b0010 : 0b1000
        
        guard board.state.castlingRights & rightsMask != 0 else { return false }
        
        let clearSpaces: Bitboard = friendly == .White ? 0b00001110 : 0b00001110 << 56
        let moveSpaces:  Bitboard = friendly == .White ? 0b00001100 : 0b00001100 << 56
        
        guard clearSpaces & allPieces == 0 else { return false }
        
        var safe: Bool = true
        moveSpaces.loop { space in
            if SquareIsAttacked(space, by: enemy) { safe = false }
        }
        
        guard safe else { return false }
        
        return true
        
    }
    
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    /*  MARK: PAWN                                        */
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    
    func PawnAttackMask (at index: Int) -> Bitboard {
        
        var mask: Bitboard = 0
        let eastAttack = friendly == .White ? directions.northEast : directions.southEast
        let westAttack = friendly == .White ? directions.northWest : directions.southWest
        
        //East side
        if !BitboardFunctions.File(7).isOn(at: index) {
            mask |= UInt64(1) << (index + eastAttack)
        }
        
        //West side
        if !BitboardFunctions.File(0).isOn(at: index) {
            mask |= UInt64(1) << (index + westAttack)
        }
        
        
        return mask
    }
    
    func PawnMoves (at index: Int, capturesOnly: Bool) -> [Move] {
        
        var mask = capturesOnly ? PawnAttackMask(at: index) & board.position[enemy] : PawnMoveMask(at: index)
        
        if KingIsInCheck() {
            mask &= DefendingCheckMask()
        }
        
        if let pin = PinRay(from: index) {
            mask &= pin
        }
        
        var moves = [Move]()
        
        let forward = friendly == .White ? 8 : -8
        let goal = friendly == .White ? 7 : 0
        
        mask.loop { target in
            
            if abs(target - index) == 16 {
                moves.append(.init(startIndex: index, targetIndex: target, tag: .DoublePawnMove))
                return
            }
            
            if let ep = board.state.enPassantIndex {
                if Int(ep) == target - forward {
                    moves.append(.init(startIndex: index, targetIndex: target, tag: .EnPassant))
                    return
                }
            }
            
            if target / 8 == goal {
                moves.append(Move(startIndex: index, targetIndex: target, tag: .PromoteToQueen))
                moves.append(Move(startIndex: index, targetIndex: target, tag: .PromoteToRook))
                moves.append(Move(startIndex: index, targetIndex: target, tag: .PromoteToBishop))
                moves.append(Move(startIndex: index, targetIndex: target, tag: .PromoteToKnight))
                return
            }
            
            moves.append(Move(startIndex: index, targetIndex: target, tag: .Normal))
            
        }
        
        return moves
        
    }
    
    func PawnMoveMask (at index: Int) -> Bitboard {
        
        var mask: Bitboard = 0
        
        let firstRank: Int = friendly == .White ? 1 : 6
        
        let forward: Int = friendly == .White ? 8 : -8
        let eastAttack: Int = index + forward + 1
        let westAttack: Int = index + forward - 1
        
        //Single
        if !allPieces.isOn(at: index + forward) {
            
            mask.set(at: index + forward)
            
            //Double
            if index / 8 == firstRank && !allPieces.isOn(at: index + forward + forward) {
                mask.set(at: index + forward + forward)
            }
            
        }
        
        // Not on west file
        if index % 8 != 0 {
            
            if board.position[enemy].isOn(at: westAttack) {
                mask.set(at: westAttack)
            }
            
            if let ep = board.state.enPassantIndex, ep == index - 1 {
                mask.set(at: westAttack)
            }
            
        }
        // Not on east file
        if index % 8 != 7 {
            
            if board.position[enemy].isOn(at: eastAttack) {
                mask.set(at: eastAttack)
            }
            
            if let ep = board.state.enPassantIndex, ep == index + 1 {
                mask.set(at: eastAttack)
            }
            
        }
        
        return mask
        
    }
    
    
}
