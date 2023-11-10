//
//  main.swift
//  Chess AI
//
//  Created by Chaniel Ezzi on 11/9/23.
//

import Foundation

var args = CommandLine.arguments

let engine = ChanielsChessEngine(Board(), settings: .init(mode: .fixedDepth(6), usesTranspositionTable: false, usesOpeningBook: false))
args.removeFirst()
let fen = args.joined(separator: " ")
Board.SetFromFEN(engine.board, fen)
print(engine.BestMove()?.description ?? "0000", terminator: "")
