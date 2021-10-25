//
//  PGNReader.swift
//  Chess AI
//
//  Created by Chaniel Ezzi on 8/6/21.
//

import Foundation

struct PGNReader {
    
    ///Returns a set of strings containing the moves played. Does *not* include game information such as who played, where it was played, result, etc.
    static func parseCombinedPGN (_ url: URL) -> Set<String>? {
        
        guard var pgn = try? String(contentsOfFile: url.path, encoding: .ascii) else {
            print("Can't read pgn")
            return nil
        }
        
        // Small tweak to make sure our way of separating games will always work
        pgn = pgn.replacingOccurrences(of: "...", with: "---").replacingOccurrences(of: ".", with: ". ")

        
        let lines = pgn.components(separatedBy: "\n")
        let undividedGameLines = lines.filter({ $0.first != "[" }).map({ $0.replacingOccurrences(of: "\r", with: "") }).filter({ !$0.isEmpty })
        let splitGames = undividedGameLines.joined(separator: " ").components(separatedBy: " 1. ")
        
        return Set(splitGames)
        
    }
    
}
