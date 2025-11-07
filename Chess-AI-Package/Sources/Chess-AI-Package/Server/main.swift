//
//  main.swift
//  ChessAIServer
//
//  Created by Chaniel Abou-Ezzi on 11/6/25.
//

import Vapor

// MARK: - App Setup
let env = try Environment.detect()
let app = try await Application.make(env)
defer { Task { try await app.asyncShutdown() } }

// MARK: - WebSocket endpoint
app.webSocket("game") { req, ws in
    // Each client gets its own GameSession
    let session = GameSession(websocket: ws, aiColor: .Black)
    
    // Handle messages from the client
    ws.onText { ws, text in
        Task {
            guard let data = text.data(using: .utf8),
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            else { return }
            
            if let moveValue = json["move"] as? UInt16 {
                let move = Move(literalValue: moveValue)
                // Apply human move
                if session.gameManager.applyMove(move) {
                    print("Move succeeded \(move.description)")
                } else {
                    print("Move failed \(move.description)")
                }
            } else if let command = json["command"] as? String, command == "newGame" {
                // Start a new game
                session.gameManager.newGame()
            }
        }
    }
    
    ws.onClose.whenComplete { _ in
        print("Client disconnected")
    }
}

// MARK: - Run App
try await app.execute()
