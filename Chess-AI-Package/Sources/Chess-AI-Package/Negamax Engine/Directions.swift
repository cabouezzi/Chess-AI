//
// Directions.swift
//  Chess ML
//
//  Created by Chaniel Ezzi on 7/10/21.
//

import Foundation

struct Directions {
    
    static let Standard = Directions()
    
    private(set) var north = 8
    private(set) var south = -8
    private(set) var east = 1
    private(set) var west = -1
    
    private(set) var northEast = 9
    private(set) var southEast = -7
    private(set) var northWest = 7
    private(set) var southWest = -9
    
    var all: [Int] {
        return [north, south, east, west, northEast, northWest, southEast, southWest]
    }
    
    static private(set) var EdgeFromIndex: [Directions] = Initialize()
    
    private static func Initialize () -> [Directions] {
        
        var edges = [Directions](repeatElement(.Standard, count: 64))
        
        for index in 0...63 {
            
            
            let rank = index / 8
            let file = index % 8
            
            let north = 7 - rank
            let east = 7 - file
            
            let northEast = min(north, east)
            let northWest = min(north, file)
            let southEast = min(rank, east)
            let southWest = min(rank, file)
            
            edges[index] = Directions(north: north,
                                      south: rank,
                                      east: east,
                                      west: file,
                                      northEast: northEast,
                                      southEast: southEast,
                                      northWest: northWest,
                                      southWest: southWest)
            
        }
        
        return edges
        
    }
    
    
}
