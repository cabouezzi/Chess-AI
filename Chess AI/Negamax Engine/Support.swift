//
//  BBSupport.swift
//  Chess ML
//
//  Created by Chaniel Ezzi on 7/10/21.
//

import Foundation

struct BitboardFunctions {
    
    private static let files: [UInt64] = [
        0x0101010101010101,
        0x0101010101010101 << 1,
        0x0101010101010101 << 2,
        0x0101010101010101 << 3,
        0x0101010101010101 << 4,
        0x0101010101010101 << 5,
        0x0101010101010101 << 6,
        0x0101010101010101 << 7,
    ]
    
    private static let ranks: [UInt64] = [
        0b11111111,
        0b11111111 << 8,
        0b11111111 << 16,
        0b11111111 << 24,
        0b11111111 << 32,
        0b11111111 << 40,
        0b11111111 << 48,
        0b11111111 << 56,
    ]
    
    static func File (_ int: Int) -> UInt64 {
        guard int >= 0 && int <= 7 else { return 0 }
        return files[int]
    }
    
    static func Rank (_ int: Int) -> UInt64 {
        guard int >= 0 && int <= 7 else { return 0 }
        return ranks[int]
    }
    
    static func _Debug (_ bitboard: UInt64) {
        
        for rank in 0...7 {
            
            for file in 0...7 {
                
                let index = (7 - rank) * 8 + file
                
                //In order
                print((bitboard >> index & 1) != 0 ? "X " : "• ", terminator: "")
                
            }
            //New line
            print("")
            
        }
        
        print("~~~~~~~~~~~~~~~")
        
    }
    
}

extension FixedWidthInteger {
    
    //https://stackoverflow.com/a/60596872
    var bitSwapped: Self {
        var v = self
        var s = Self(v.bitWidth)
        precondition(s.nonzeroBitCount == 1, "Bit width must be a power of two")
        
        var mask = ~Self(0)
        repeat  {
            s = s >> 1
            mask ^= mask << s
            v = ((v >> s) & mask) | ((v << s) & ~mask)
        } while s > 1
        
        return v
    }
}

extension UInt64 {
    
    mutating func pop (at index: Int) {
        self &= ~(UInt64(1) << index)
    }
    
    mutating func set (at index: Int) {
        self |= Bitboard(1) << index
    }
    
    func isOn (at index: Int) -> Bool {
        return (self >> index) & 1 != 0
    }
    
    func flippedVertical () -> UInt64 {
        var bb: UInt64 = self
        let k1: UInt64 = (0x00FF00FF00FF00FF)
        let k2: UInt64 = (0x0000FFFF0000FFFF)
        
        bb = ((bb >>  8) & k1) | ((bb & k1) <<  8)
        bb = ((bb >> 16) & k2) | ((bb & k2) << 16)
        bb = ( bb >> 32)       | ( bb       << 32)
        
        return bb
    }
    
    func flippedHorizontal () -> UInt64 {
        var bb: UInt64 = self
        let k1: UInt64 = (0x5555555555555555)
        let k2: UInt64 = (0x3333333333333333)
        let k4: UInt64 = (0x0f0f0f0f0f0f0f0f)
        
        bb = ((bb >> 1) & k1) +  2*(bb & k1)
        bb = ((bb >> 2) & k2) +  4*(bb & k2)
        bb = ((bb >> 4) & k4) + 16*(bb & k4)
        
        return bb
    }
    
    func rotated180 () -> UInt64 {
        return self.flippedHorizontal().flippedVertical()
    }
    
    func rotated90CounterClockwise () -> UInt64 {
        var bb = self
        var t: UInt64
        
        let k1: UInt64 = (0xaa00aa00aa00aa00)
        let k2: UInt64 = (0xcccc0000cccc0000)
        let k4: UInt64 = (0xf0f0f0f00f0f0f0f)
        
        t  =        bb ^ (bb << 36)
        bb ^= k4 &  (t ^ (bb >> 36))
        t  =  k2 & (bb ^ (bb << 18))
        bb ^=        t ^ (t >> 18)
        t  =  k1 & (bb ^ (bb <<  9))
        bb ^=        t ^ (t >>  9)
        
        return bb.flippedVertical()
    }
    
    func rotated90Clockwise () -> UInt64 {
        return rotated90CounterClockwise().rotated180()
    }
    
    
    ///For diagonals only, really (not anti-diagonals)
    func rotated45Clockwise () -> UInt64 {
        var bb = self
        let k1: UInt64 = 0xAAAAAAAAAAAAAAAA
        let k2: UInt64 = 0xCCCCCCCCCCCCCCCC
        let k4: UInt64 = 0xF0F0F0F0F0F0F0F0
        
        bb ^= k1 & (bb ^ rotateRight(bb,  8))
        bb ^= k2 & (bb ^ rotateRight(bb, 16))
        bb ^= k4 & (bb ^ rotateRight(bb, 32))
        
        return bb
    }
    
    ///For anti-diagonals only, really
    func rotated45CounterClockwise () -> UInt64 {
        var bb = self
        let k1: UInt64 = 0x5555555555555555
        let k2: UInt64 = 0x3333333333333333
        let k4: UInt64 = 0x0f0f0f0f0f0f0f0f
        
        bb ^= k1 & (bb ^ rotateRight(bb,  8))
        bb ^= k2 & (bb ^ rotateRight(bb, 16))
        bb ^= k4 & (bb ^ rotateRight(bb, 32))
        
        return bb
    }
    
    private func rotateRight(_ x: UInt64, _ s: Int) -> UInt64 {
        return (x >> s) | (x << (64-s))
    }
    
}
