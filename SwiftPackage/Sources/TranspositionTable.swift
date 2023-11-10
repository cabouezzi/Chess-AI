//
//  BBTranspositionTable.swift
//  Chess ML
//
//  Created by Chaniel Ezzi on 7/12/21.
//

import Foundation

class TranspositionTable {
    
    struct Entry {
        
        ///The Zobrist Key of the board associated with this entry.
        let key: ZobristKey
        let depth: Int
        let evaluation: Int
        let move: Move
        
    }
    
    static private var table: [ZobristKey : Entry] = [:]
    
    static func GetEntry (key: ZobristKey, depth: Int) -> Entry? {
        
        if let entry = table[key] {
            
            if entry.depth >= depth {
                return entry
            }
            
        }
        
        return nil
        
    }
    
    static func StoreEntry (key: ZobristKey, depth: Int, eval: Int, move: Move ) {
        
        if let existing = table[key] {
            
            if depth >= existing.depth {
                table[key] = Entry(key: key, depth: depth, evaluation: eval, move: move)
            }
            
        }
        else {
            table[key] = Entry(key: key, depth: depth, evaluation: eval, move: move)
        }
        
    }
    
}
