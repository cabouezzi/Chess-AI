//
//  MovementSupport.swift
//  Chess ML
//
//  Created by Chaniel Ezzi on 7/20/21.
//

import Foundation

struct ConstantPieceMoveTable {
    
    static let KingAttacks = GetKingMoves()
    static let KnightAttacks = GetKnightMoves()
    
    private static func GetKingMoves () -> [Bitboard] {
        
        var km = [Bitboard](repeating: 0, count: 64)
        let dirs = Directions.Standard.all
        
        for index in 0...63 {
            
            for offset in dirs {
                let tIndex = index + offset
                
                guard tIndex >= 0 && tIndex <= 63
                else { continue }
                
                //Limits travel, prevents wrapping
                let rankDifference = (tIndex / 8) - (index / 8)
                let fileDifference = (tIndex % 8) - (index % 8)
                
                guard abs(rankDifference) + abs(fileDifference) <= 2
                else { continue }
                
                km[index] |= UInt64(1) << tIndex
                
            }
            
        }
        
        return km
        
    }
    
    private static func GetKnightMoves () -> [Bitboard] {
        
        var nm = [Bitboard](repeating: 0, count: 64)
        let dirs = [15, 17, -6, 10, -10, 6, -17, -15]
        
        for index in 0...63 {
            
            for offset in dirs {
                let tIndex = index + offset
                
                guard tIndex >= 0 && tIndex <= 63
                else { continue }
                
                //Knight moves max of 3 moves, prevents wrapping
                let rankDifference = (tIndex / 8) - (index / 8)
                let fileDifference = (tIndex % 8) - (index % 8)
                
                guard abs(rankDifference) + abs(fileDifference) == 3
                else { continue }
                
                nm[index] |= UInt64(1) << tIndex
                
            }
        }
        
        return nm
        
    }
    
}

///Sliding attack rays organized by index, bitboard *excluding* the attacker's index.
struct SlidingAttacks {
    
    static private(set) var RankRays = Initalize().RankRays
    static private(set) var FileRays = Initalize().FileRays
    static private(set) var DiagonalRays = Initalize().DiagonalRays
    static private(set) var AntiDiagonalRays = Initalize().AntiDiagonalRays
    
    
    
    private static func Initalize() -> (RankRays: [UInt64], FileRays: [UInt64], DiagonalRays: [UInt64], AntiDiagonalRays: [UInt64]){
        
        var ranks = [UInt64](repeating: 0, count: 64)
        var files = [UInt64](repeating: 0, count: 64)
        var diags = [UInt64](repeating: 0, count: 64)
        var antidiags = [UInt64](repeating: 0, count: 64)
        
        for index in 0...63 {
            
            /*
             
             0x0101010101010100:
             
                     1 • • • • • • •
                     1 • • • • • • •
                     1 • • • • • • •
                     1 • • • • • • •
                     1 • • • • • • •
                     1 • • • • • • •
                     1 • • • • • • •
                     O • • • • • • •
                
             0x8040201008040200:
             
                     • • • • • • • 1
                     • • • • • • 1 •
                     • • • • • 1 • •
                     • • • • 1 • • •
                     • • • 1 • • • •
                     • • 1 • • • • •
                     • 1 • • • • • •
                     O • • • • • • •
             */
            
            ranks[index] = 0b11111111 << (index & 56)
            files[index] = 0x0101010101010101 << (index & 7)
            
            let mainDiag: UInt64 = 0x8040201008040201
            let diag = 8 * (index & 7) - (index & 56)
            let north = -diag & ( diag >> 31)
            let south =  diag & (-diag >> 31)
            
            diags[index] = (mainDiag >> south) << north
            
            let mainAntiDiag: UInt64 = 0x0102040810204080
            let antiDiag = 56 - 8 * (index & 7) - (index & 56)
            let antiNorth = -antiDiag & ( antiDiag >> 31)
            let antiSouth =  antiDiag & (-antiDiag >> 31)
            
            antidiags[index] = (mainAntiDiag >> antiSouth) << antiNorth
            
            //Exclude "attacker"
            ranks[index] &= ~(Bitboard(1) << index)
            files[index] &= ~(Bitboard(1) << index)
            diags[index] &= ~(Bitboard(1) << index)
            antidiags[index] &= ~(Bitboard(1) << index)
            
        }
        
        return (ranks, files, diags, antidiags)
        
    }
    
}
