//
//  MoveArray.swift
//  Chess AI
//
//  Created by Chaniel Ezzi on 8/4/21.
//

import Foundation

//Recent optimization, prone to bugs
//^^^ In the works now
struct MoveArray: Sequence, IteratorProtocol {
    
    typealias Element = Move
    
    private(set) var count: Int
    private(set) var pointer: UnsafeMutablePointer<Move>
    
    init(count: Int) {
        
        self.count = count
        self.pointer = UnsafeMutablePointer<Move>.allocate(capacity: count)
        
    }
    
    mutating func append (_ move: Move) {
        self.pointer.advanced(by: 1).initialize(to: move)
    }
    
    mutating func insertMove (at index: Int, move: Move) {
        self.pointer[index] = move
    }
    
    mutating func next() -> Move? {
        return nil
    }
    
    
}
