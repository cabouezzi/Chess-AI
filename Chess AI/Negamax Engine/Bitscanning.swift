//
//  Bitscanning.swift
//  Chess ML
//
//  Created by Chaniel Ezzi on 7/17/21.
//

import Foundation

extension Bitboard {
    
//    private static var IndexOfIsolatedBit: [UInt64 : Int] = GetIndicesOfIsolatedBits()
//
//    private static func GetIndicesOfIsolatedBits () -> [UInt64 : Int] {
//
//        var dict: [UInt64 : Int] = [:]
//
//        for i in 0...63 {
//            dict[Bitboard(1) << i] = i
//        }
//
//        return dict
//
//    }
    
    //https://www.chessprogramming.org/BitScan
    private static let isolatedBitIndex = [
            0,  1, 48,  2, 57, 49, 28,  3,
           61, 58, 50, 42, 38, 29, 17,  4,
           62, 55, 59, 36, 53, 51, 43, 22,
           45, 39, 33, 30, 24, 18, 12,  5,
           63, 47, 56, 27, 60, 41, 37, 16,
           54, 35, 52, 21, 44, 32, 23, 11,
           46, 26, 40, 15, 34, 20, 31, 10,
           25, 14, 19,  9, 13,  8,  7,  6
    ]
    
    private static let debruijn: Bitboard = 0x03f79d71b4cb0a89
    
    
    func ls1b () -> Int? {
        
        guard self != 0 else { return nil }
        
        if self.nonzeroBitCount == 1 {
            
            let i = (self &* Bitboard.debruijn) >> 58
            return Bitboard.isolatedBitIndex[Int(i)]
            
        }
        
        // Isolate bit
        let iso = Int64(truncatingIfNeeded: self) & -Int64(truncatingIfNeeded: self)
        let i = (Bitboard(iso) &* Bitboard.debruijn) >> 58
        return Bitboard.isolatedBitIndex[Int(i)]
        
    }
    
    //Useless
    func loop (block: (Int, Bool) -> Void) {
        for i in 0...63 {
            
            if (self >> i & 1) != 0 {
                block(i, true)
            }
            else {
                block(i, false)
            }
            
        }
        
    }
    
    func loop (block: (Int) -> Void) {
        
        var x = Bitboard(self)

        while x != 0 {
            block(x.ls1b()!)
            x &= x - 1
        }

        return
        
//        for i in 0...63 {
//
//            if (self >> i & 1) != 0 {
//                block(i)
//            }
//
//        }
        
    }

    func indices () -> [Int] {
        
        guard self != 0 else { return [] }
        var x = self
        var container: [Int] = []
        
        while x != 0 {
            container.append(x.ls1b()!)
            x &= x - 1
        }

        return container
        
//        var container: [Int] = []
//
//        var shift = 0
//        var bcount = 0
//
//        while bcount != self.nonzeroBitCount {
//
//            if self & (Bitboard(1) << shift) != 0 {
//                container.append(shift)
//                bcount += 1
//            }
//
//            shift += 1
//
//        }
//
//        return container
        
    }
    
}
