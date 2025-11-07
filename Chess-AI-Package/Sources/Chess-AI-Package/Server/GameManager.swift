//
//  GameManager.swift
//  Chess AI
//
//  Created by Chaniel Abou-Ezzi on 11/6/25.
//

import Foundation

enum GameResult: Codable {
    case draw
    case whiteWon
    case blackWon
}

// MARK: - Delegate Protocol
protocol GameManagerDelegate: AnyObject {
    /// Called whenever a new game begins
    func gameManagerDidBeginNewGame(_ manager: GameManager)
    
    /// Called whenever a move is applied
    func gameManager(_ manager: GameManager, didMakeMove move: Move)
    
    /// Called when the game ends
    func gameManager(_ manager: GameManager, didEndWith result: GameResult)
    
    /// Called when the server/client needs to supply the next move
    func gameManagerNeedsMove(_ manager: GameManager, color: PieceColor)
}

// MARK: - GameManager
class GameManager {
    
    private(set) var board: Board
    private var moveGenerator: MoveGenerator
    
    weak var delegate: GameManagerDelegate?
    
    init() {
        board = Board()
        moveGenerator = MoveGenerator(board: board)
    }
    
    // MARK: Public
    
    /// Starts a new game
    func newGame() {
        board = Board()
        moveGenerator = MoveGenerator(board: board)
        delegate?.gameManagerDidBeginNewGame(self)
        requestNextMoveIfNeeded()
    }
    
    /// Apply a move (sent by client or AI). Move is UInt16 packed.
    func applyMove(_ move: Move) -> Bool {
        guard let move = findLegalMove(move) else {
            return false
        }
        
        board.CommitMove(move)
        delegate?.gameManager(self, didMakeMove: move)
        
        if !checkGameEnded() {
            requestNextMoveIfNeeded()
        }
        
        return true
    }
    
    // MARK: Private
    
    /// Ask delegate for next move if it's that player's turn
    private func requestNextMoveIfNeeded() {
        let colorToMove = board.state.isWhiteToMove ? PieceColor.White : PieceColor.Black
        delegate?.gameManagerNeedsMove(self, color: colorToMove)
    }
    
    /// Check if game is over
    private func checkGameEnded() -> Bool {
        var result: GameResult? = nil
        
        if moveGenerator.AllLegalMoves().isEmpty {
            result = board.state.isWhiteToMove ? .blackWon : .whiteWon
        } else if board.position.all.nonzeroBitCount == 2 {
            result = .draw
        }
        
        if let result = result {
            delegate?.gameManager(self, didEndWith: result)
            return true
        }
        
        return false
    }
    
    /// Check if the move is legal
    private func findLegalMove(_ move: Move) -> Move? {
        let legalMoves = moveGenerator.AllLegalMoves()
        return legalMoves.first(where: { $0.startIndex == move.startIndex && $0.targetIndex == move.targetIndex })
    }
}
