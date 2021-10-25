//
//  RedesignedGenerator.swift
//  Chess AI
//
//  Created by Chaniel Ezzi on 8/19/21.
//

import Foundation

class RedesignedGenerator {
    
    let board: Board
    
    //One time thing this time, doesn't update on turn to move
    var friendly: PieceColor
    var enemy: PieceColor
    
    var allPieces: Bitboard {
        return board.position.all
    }
    
    var friendlyAttackMask: Bitboard = 0
    var enemyAttackMask: Bitboard = 0
    
    var legalMoves: [Move] = []
    
    init (_ board: Board) {
        self.board = board
        self.friendly = board.state.isWhiteToMove ? .White : .Black
        self.enemy = friendly.opposite
        
        BoardMadeMove()
        
    }
    
    func BoardMadeMove () {
        
        self.friendly = board.state.isWhiteToMove ? .White : .Black
        self.enemy = friendly.opposite
        
        CalculateAttackData()
        SetCheckers()
        SetLegalMoves()
        
    }
    
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    /*  MARK:                                             */
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    
    func SetLegalMoves () {
        
        legalMoves = []
        
        if KingIsInDoubleCheck() {
            legalMoves = KingMoves(at: board.position[Piece(friendly, .King)].ls1b()!)
            return
        }
        
        for i in 0..<64 {
            
            guard let piece = board.position.squares[i] else { continue }
            guard piece.color == friendly else { continue }
            
            switch piece.type {
            case .King:
                legalMoves += KingMoves(at: i)
            case .Pawn:
                legalMoves += PawnMoves(at: i)
            case .Knight:
                legalMoves += KnightMoves(at: i)
            case .Bishop, .Rook, .Queen:
                legalMoves += SlidingPieceMoves(at: i)
            }
            
        }
        
    }
    
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    /*  MARK: Attack Data                                 */
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    
    func CalculateAttackData () {
        
        friendlyAttackMask = 0
        enemyAttackMask = 0
        
        board.position[friendly].loop { i in
            
            switch board.position.squares[i]!.type {
            case .King: friendlyAttackMask |= KingMoveMask(at: i)
            case .Pawn: friendlyAttackMask |= PawnMoveMask(at: i)
            case .Knight: friendlyAttackMask |= KnightMoveMask(at: i)
            case .Bishop: friendlyAttackMask |= BishopMoveMask(at: i)
            case .Rook: friendlyAttackMask |= RookMoveMask(at: i)
            case .Queen: friendlyAttackMask |= QueenMoveMask(at: i)
            }
            
        }
        
        friendly = friendly.opposite
        enemy = friendly.opposite
        
        board.position[friendly].loop { i in
            
            switch board.position.squares[i]!.type {
            case .King: enemyAttackMask |= KingMoveMask(at: i)
            case .Pawn: enemyAttackMask |= PawnMoveMask(at: i)
            case .Knight: enemyAttackMask |= KnightMoveMask(at: i)
            case .Bishop: enemyAttackMask |= BishopMoveMask(at: i)
            case .Rook: enemyAttackMask |= RookMoveMask(at: i)
            case .Queen: enemyAttackMask |= QueenMoveMask(at: i)
            }
            
        }
        
        friendly = friendly.opposite
        enemy = friendly.opposite
        
    }
    
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    /*  MARK: Checking                                    */
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
        let diagTest = BishopMoveMask(at: kingIndex)
        let orthoTest = RookMoveMask(at: kingIndex)
        
        //If separated into Bishop–Rook–Queen, Queen's mask can overlap between diagonal and orthogonal rays
        if diagTest.isOn(at: checkerIndex) {
            
            var shared = diagTest & BishopMoveMask(at: checkerIndex)
            //Can capture, of course
            shared.set(at: checkerIndex)
            return shared
            
        }
        
        else if orthoTest.isOn(at: checkerIndex) {
            
            var shared = orthoTest & RookMoveMask(at: checkerIndex)
            //Can capture, of course
            shared.set(at: checkerIndex)
            return shared
            
        }
        
        
        return 0
        
    }
    
    func SetCheckers () {
        
        let kingIndex = board.position[Piece(friendly, .King)].ls1b()!
        
        let rookMask = RookMoveMask(at: kingIndex)
        let bishopMask = BishopMoveMask(at: kingIndex)
        let knightMask = KnightMoveMask(at: kingIndex)
        let pawnMask = PawnMoveMask(at: kingIndex)
        
        //
        let rookCheckers = rookMask & (board.position[Piece(enemy, .Rook)] | board.position[Piece(enemy, .Queen)])
        let bishopCheckers = bishopMask & (board.position[Piece(enemy, .Bishop)] | board.position[Piece(enemy, .Queen)])
        let knightCheckers = knightMask & board.position[Piece(enemy, .Knight)]
        let pawnCheckers = pawnMask & board.position[Piece(enemy, .Pawn)]
        
        board.position.checkers = rookCheckers | bishopCheckers | knightCheckers | pawnCheckers
        
    }
    
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    /*  MARK: Pinning                                     */
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    
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
    /*  MARK: Sliding Piece Moves                         */
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    
    func SlidingPieceMoves (at index: Int) -> [Move] {
        
        guard let pt = board.position.squares[index]?.type
        else { return [] }
        
        var bishopMask = BishopMoveMask(at: index) & ~board.position[friendly]
        var rookMask = RookMoveMask(at: index) & ~board.position[friendly]
        
        let pin = PinRay(from: index)
        
        if KingIsInCheck() && pin != nil {
            return []
        }
        
        if let pin = pin {
            bishopMask &= pin
            rookMask &= pin
        }
        else if KingIsInCheck() {
            let blockingMask = DefendingCheckMask()
            bishopMask &= blockingMask
            rookMask &= blockingMask
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
    
    func RookMoveMask (at index: Int) -> Bitboard {
        
        let psuedo = RankLine(at: index) | FileLine(at: index)
        
        if let pinned = PinRay(from: index) {
            return pinned & psuedo
        }
        
        return psuedo
        
    }
    
    func BishopMoveMask (at index: Int) -> Bitboard {
        
        let psuedo = DiagonalLine(at: index) | AntiDiagonalLine(at: index)
        
        if let pinned = PinRay(from: index) {
            return pinned & psuedo
        }
        
        return psuedo
        
    }
    
    func QueenMoveMask (at index: Int) -> Bitboard {
        
        if var pinned = PinRay(from: index) {
            pinned.pop(at: board.position[Piece(friendly, .King)].ls1b()!)
            return pinned
        }
        
        let psuedo = RankLine(at: index) | FileLine(at: index) | DiagonalLine(at: index) | AntiDiagonalLine(at: index)
        
        return psuedo & ~board.position[friendly]
        
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
    /*  MARK: King Stuff                                  */
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    
    func KingMoves (at index: Int) -> [Move] {
        
        var moves = [Move]()
        let mask = KingMoveMask(at: index) & ~enemyAttackMask
        
        mask.loop { target in
            moves.append(.init(startIndex: index, targetIndex: target, tag: .Normal))
        }
        
        if CanCastleKingside() {
            moves.append(.init(startIndex: index, targetIndex: index + 2, tag: .KingSideCastle))
        }
        if CanCastleQueenside() {
            moves.append(.init(startIndex: index, targetIndex: index - 2, tag: .QueenSideCastle))
        }
        
        return moves
        
    }
    
    func KingMoveMask (at index: Int) -> Bitboard {
        
        return ConstantPieceMoveTable.KingAttacks[index] & ~board.position[friendly]
        
    }
    
    func CanCastleKingside () -> Bool {
        
        guard !KingIsInCheck() else { return false }
        
        let rightsMask: UInt8 = friendly == .White ? 0b0001 : 0b0100
        
        guard board.state.castlingRights & rightsMask != 0 else { return false }
        
        let spaces: Bitboard = friendly == .White ? 0b01100000 : 0b01100000 << 56
        
        guard spaces & allPieces == 0 else { return false }
        guard spaces & enemyAttackMask == 0 else { return false }
        
        return true
        
    }
    
    func CanCastleQueenside () -> Bool {
        
        guard !KingIsInCheck() else { return false }
        
        let rightsMask: UInt8 = friendly == .White ? 0b0010 : 0b1000
        
        guard board.state.castlingRights & rightsMask != 0 else { return false }
        
        let clearSpaces: Bitboard = friendly == .White ? 0b00001110 : 0b00001110 << 56
        let moveSpaces:  Bitboard = friendly == .White ? 0b00001100 : 0b00001100 << 56
        
        guard clearSpaces & allPieces == 0 else { return false }
        guard moveSpaces & enemyAttackMask == 0 else { return false }
        
        return true
        
    }
    
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    /*  MARK: Knight Stuff                                */
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    
    func KnightMoves (at index: Int) -> [Move] {
        
        //Can't move if pinned
        if PinRay(from: index) != nil {
            return []
        }
        
        var mask = KnightMoveMask(at: index)
        
        if KingIsInCheck() {
            mask &= DefendingCheckMask()
        }
        
        var moves = [Move]()
        
        mask.loop { target in
            moves.append(.init(startIndex: index, targetIndex: target, tag: .Normal))
        }
        
        return moves
    }
    
    func KnightMoveMask (at index: Int) -> Bitboard {
        return ConstantPieceMoveTable.KnightAttacks[index] & ~board.position[friendly]
    }
    
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    /*  MARK: Pawn Stuff                                  */
    /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    
    func PawnMoves (at index: Int) -> [Move] {
        
        var mask = PawnMoveMask(at: index)
        
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
