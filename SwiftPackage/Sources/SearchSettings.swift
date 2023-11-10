//
//  SearchSettings.swift
//  Chess AI
//
//  Created by Chaniel Ezzi on 8/25/21.
//

import Foundation

extension ChanielsChessEngine {
    
    enum SearchMode {
        
        case fixedDepth (_ depth: Int)
        case timeConstrainedDepth (_ depth: Int, time: Double)
        case timeConstrained (time: Double)
        
    }
    
    struct SearchSettings {
        
        let mode: SearchMode
        let usesTranspositionTable: Bool
        let usesOpeningBook: Bool
        
    }
    
}
