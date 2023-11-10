//
//  BBAnalyzer.swift
//  Chess ML
//
//  Created by Chaniel Ezzi on 7/13/21.
//

import Foundation

class ChanielsChessEngine {
    
    private(set) var settings: SearchSettings
    
    private(set) var board: Board
    private(set) var moveGenerator: MoveGenerator
    private(set) var moveOrderer: MoveOrderer
    private(set) var evaluator: Evaluator
    
    let mateScore: Int = 999999
    
    //Measurements
    private var nodes: Int = 0
    private var prunes: Int = 0
    private var transpositions: Int = 0
    private var quiescienceDepthIncrease: Int = 0
    //Caches
    private var bestEval: Int = 0
    private var bestMove: Move?
    private var cancelSearch: Bool = false
    
    init (_ board: Board, settings: SearchSettings) {
        
        self.settings = settings
        
        self.board = board
        self.moveGenerator = MoveGenerator(board: board)
        self.moveOrderer = MoveOrderer(board: board)
        self.evaluator = Evaluator(board)
        
    }
    
    func ChangeSettings (_ settings: SearchSettings) {
        self.settings = settings
    }
    
    private let openingBook = Bundle.main.url(forResource: "OpeningGames.pgn", withExtension: nil) ?? nil
    private var isInOpening = true
    
    func BestMove () -> Move? {
        
        bestMove = nil
        
        if settings.usesOpeningBook && isInOpening {

            if let move = OpeningMove() {
                return move
            }
            else {
                isInOpening = false
                // print("Didn't find position in opening book")
            }

        }
        
        DoSearch()
        // print("Eval: \(Float(bestEval) / 50)")
        
        guard bestMove != nil else {
            
            let moves = moveGenerator.AllLegalMoves()
            
            if moves.count == 0 {
                // print("Move generator didn't generate any legal moves.")
                return nil
            }
            
            // print("Bug in the search engine. Using random move.")
            return moves.randomElement()
        }
        
        return bestMove
        
    }
    
    func OpeningMove () -> Move? {
        guard let openingBook = openingBook else { return nil }
        
        let parsedGames = PGNReader.parseCombinedPGN(openingBook)
        
        guard let gameLine = parsedGames?.first(where: { pgn in
            
            let pgnMoves = Board.BoardFromPGN(pgn: pgn).state.moveHistory
            let boardMoves = board.state.moveHistory
            
            guard pgnMoves.count > boardMoves.count
            else { return false }
            
            for i in 0..<boardMoves.count {
                
                guard i < pgnMoves.count
                else { return false }
                
                guard boardMoves[i] == pgnMoves[i]
                else { return false }
            }
            
            return true
            
        }) else { return nil }
        
        let lineMoves = Board.BoardFromPGN(pgn: gameLine).state.moveHistory
        
        // print("Found opening")
        // print(gameLine)
        
        return Array(lineMoves)[board.state.moveHistory.count]
        
    }
    
    func DoSearch () {
        
        // print("~~~~~~~~~~~~~~~~~~~~~~")
        
        cancelSearch = false
        nodes = 0
        prunes = 0
        transpositions = 0
        quiescienceDepthIncrease = 0
        
        switch settings.mode {
        
        case .fixedDepth(let depth):
            
            Search(depth: depth, ply: 0, alpha: -mateScore, beta: mateScore)
            
        case .timeConstrained(time: let time):
            
            DispatchQueue.main.async {
                Timer.scheduledTimer(withTimeInterval: time, repeats: false, block: { _ in self.cancelSearch = true } )
            }
            
            var bestIterationMove: Move?
            var bestIterationEval: Int = 0
            
            for depth in 0...Int.max {
                
                Search(depth: depth, ply: 0, alpha: -mateScore, beta: mateScore)
                
                if cancelSearch {
                    // print("Depth accomplished: \(depth - 1)")
                    break
                }
                else {
                    bestIterationMove = bestMove
                    bestIterationEval = bestEval
                }
                
            }
            
            bestMove = bestIterationMove
            bestEval = bestIterationEval
            
            cancelSearch = false
            
        case .timeConstrainedDepth(let targetDepth, time: let time):
            
            DispatchQueue.main.async {
                Timer.scheduledTimer(withTimeInterval: time, repeats: false, block: { _ in self.cancelSearch = true } )
            }
            
            var bestIterationMove: Move?
            var bestIterationEval: Int = 0
            
            for depth in 1...targetDepth {
                
                Search(depth: depth, ply: 0, alpha: -mateScore, beta: mateScore)
                
                if cancelSearch {
//                    // print("Depth accomplished: \(depth - 1)")
                    break
                }
                else {
                    bestIterationMove = bestMove
                    bestIterationEval = bestEval
                }
                
            }
            
            bestMove = bestIterationMove
            bestEval = bestIterationEval
            
        }
        
//        // print("Search \(bestEval)")
//        // print("Nodes searched: \(nodes)")
//        // print("Alpha/Beta prunes: \(prunes)")
//        // print("Transpositions: \(transpositions)")
//        // print("Quiescience increase: \(quiescienceDepthIncrease)")
//        // print("Time taken: \(CFAbsoluteTimeGetCurrent() - start), NPS: \((Double(nodes + prunes + transpositions) / (CFAbsoluteTimeGetCurrent() - start)))")
//        if let bm = bestMove {
//            // print(bm.description)
//        }
        
    }
    
    func DetectRepetition () -> Bool {
        // Repetition of moves returns draw
        // TODO: Optimize
        var reptition: Int = 0
        var currentInfo: BoardState? = board.state.previous
        var currentPos: Position? = board.state.lastPosition

        while currentInfo != nil && currentPos != nil {

            // If position and state is the same
            if board.state.CompareRepetitionParameters(currentInfo!) && currentPos!.bitboards == board.position.bitboards {

                reptition += 1

                // Repetition
                // Was made 1 instead of 3 because engine will shuffle anyway, until necessary to avoid.
                // Really only valid to keep as 3 if playing against a human player
                if reptition >= 1 {
                    return true
                }

            }

            currentPos = currentInfo!.lastPosition
            currentInfo = currentInfo!.previous

        }
        
        return false
        
    }
    
    @discardableResult
    func Search (depth: Int, ply: Int, alpha a: Int, beta: Int) -> Int {
        
        var alpha = a
        
        // From time constraint settings
        if cancelSearch { return 0 }
        
        // Return evalution when depth is reached
        if depth == 0 {
            nodes += 1
            return evaluator.Evaluation()
        }
        
        // Checks for transposition
        if let entry = TranspositionTable.GetEntry(key: board.zobristKey, depth: depth), settings.usesTranspositionTable {
            
            if ply == 0 {
                
                transpositions += 1
                
                bestMove = entry.move
                bestEval = entry.evaluation
                
                return entry.evaluation
                
            }
            
            if entry.evaluation >= beta {
                
                transpositions += 1
                
                return beta
            }
            
            else if entry.evaluation >= alpha {
                
                transpositions += 1
                
                return entry.evaluation
            }
            
        }
        
        // Check 3-fold repetition, where opponent can claim a draw
//        if DetectRepetition() {
//            return 0
//        }
        
        // Legacy search starts now
//        var alpha = alpha
        
        var moves = moveGenerator.AllLegalMoves()
        
        if moves.count == 0 {
            
            if moveGenerator.KingIsInCheck() {
                // Closest checkmate will score higher
                return -mateScore + ply
            }
            else {
                return 0
            }
            
        }
        
        moveOrderer.OrderMoves(moves: &moves)
        
        var ttMove: Move = .init(literalValue: 0)
        
        for move in moves {
            
            board.CommitMove(move)
            let eval = -Search(depth: depth - 1, ply: ply + 1, alpha: -beta, beta: -alpha)
            board.UndoMove(move)
            
            if eval >= beta {
                prunes += 1
                
                if ply == 0 {
                    bestEval = eval
                    bestMove = move
                }
                
                if settings.usesTranspositionTable {
                    TranspositionTable.StoreEntry(key: board.zobristKey, depth: depth, eval: beta, move: move)
                }
                
                // Opponents lower bound
                // Expect the opponent to make the better move (beta when beta < eval)
                return beta
            }
            
            if eval > alpha {
                alpha = eval
                
                if ply == 0 {
                    bestEval = eval
                    bestMove = move
                }
                
                ttMove = move
                
            }
//            else if bestMove == nil && ply == 0 {
//                bestMove = move
//            }
            
        }
        
        if ttMove.isValid && settings.usesTranspositionTable { TranspositionTable.StoreEntry(key: board.zobristKey, depth: depth, eval: alpha, move: ttMove) }
        
        return alpha
        
    }
    
    func QuiescienceSearch (ply: Int, alpha: Int, beta: Int) -> Int {
        
        let moves = moveGenerator.AllLegalMoves(capturesOnly: true)
        
        if moves.count == 0 {
            
            if ply > quiescienceDepthIncrease {
                quiescienceDepthIncrease = ply
            }
            
            nodes += 1
            return evaluator.Evaluation()
        }
        
        
        var eval = evaluator.Evaluation()
        var alpha = alpha
        
        if eval >= beta {
            prunes += 1
            return beta
        }
        if eval > alpha {
            alpha = eval
        }
        
        for move in moves {
            
            board.CommitMove(move)
            eval = -QuiescienceSearch(ply: ply + 1, alpha: -beta, beta: -alpha)
            board.UndoMove(move)
            
            if eval >= beta {
                prunes += 1
                return beta
            }
            if eval > alpha {
                alpha = eval
            }
            
        }
        
        return alpha
        
    }
    
}
