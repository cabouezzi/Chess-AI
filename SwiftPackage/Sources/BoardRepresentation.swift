//
//  BoardRepresentation.swift
//  Chess ML
//
//  Created by Chaniel Ezzi on 8/2/21.
//

import Foundation

class BoardRepresentation {
    
    static var CoordinatesOfIndex = CalculateCoordinates()
    
    static var CoordinateLetterFromFile = [
        0 : "a",
        1 : "b",
        2 : "c",
        3 : "d",
        4 : "e",
        5 : "f",
        6 : "g",
        7 : "h",
    ]
    
    static private func CalculateCoordinates () -> [String] {
        
        var holder = [String](repeating: "", count: 64)
        
        for i in 0...63 {
            
            let rank: Int = i / 8
            let file: Int = i % 8
            
            holder[i] = CoordinateLetterFromFile[file]! + String(describing: rank + 1)
            
        }
        
        return holder
        
    }
    
    
}
