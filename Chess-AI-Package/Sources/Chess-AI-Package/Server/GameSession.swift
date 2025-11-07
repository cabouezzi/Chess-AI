//
//  GameSession.swift
//  Chess AI
//
//  Created by Chaniel Abou-Ezzi on 11/6/25.
//

import Vapor

class GameSession: GameManagerDelegate {
    let gameManager: GameManager
    let aiColor: PieceColor
    let websocket: WebSocket
    
    let engine: ChanielsChessEngine
    
    init(websocket: WebSocket, aiColor: PieceColor = .Black) {
        self.websocket = websocket
        self.aiColor = aiColor
        self.gameManager = GameManager()
        self.engine = ChanielsChessEngine(Board(), settings: .init(mode: .fixedDepth(6), usesTranspositionTable: false, usesOpeningBook: false))
        self.gameManager.delegate = self
        self.gameManager.newGame()
    }
    
    // MARK: - GameManagerDelegate
    
    func gameManagerDidBeginNewGame(_ manager: GameManager) {
        sendJSON([
            "type": "newGame",
            "board": Board.FENFromBoard(manager.board),
        ])
    }
    
    func gameManager(_ manager: GameManager, didMakeMove move: Move) {
        sendJSON([
            "type": "moveMade",
            "move": move.value, // convert Move to UInt16 for frontend
            "board": Board.FENFromBoard(manager.board),
        ])
    }
    
    func gameManager(_ manager: GameManager, didEndWith result: GameResult) {
        sendJSON([
            "type": "gameEnded",
            "result": "\(result)"
        ])
    }
    
    func gameManagerNeedsMove(_ manager: GameManager, color: PieceColor) {
        if color == aiColor {
            engine.board.position = manager.board.position
            engine.board.state = manager.board.state
            engine.board.zobristKey = manager.board.zobristKey
            guard let aiMove = engine.BestMove() else {
                // TODO: send error to client
                manager.newGame()
                return
            }
            print(manager.applyMove(aiMove))
            print("AI said \(aiMove.description)")
        } else {
            // Human turn → notify frontend
            sendJSON([
                "type": "yourTurn",
                "color": color == .White ? 0 : 1
            ])
        }
    }
    
    // MARK: - Helper
    
    private func sendJSON(_ dict: [String: Any]) {
        do {
            let data = try JSONSerialization.data(withJSONObject: dict, options: [])
            guard let jsonString = String(data: data, encoding: .utf8) else { return }
            websocket.send(jsonString)
        } catch {
            print("Failed to serialize JSON:", error)
        }
    }
}
