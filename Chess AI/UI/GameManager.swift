//
//  GameManager.swift
//  Chess ML
//
//  Created by Chaniel Ezzi on 7/9/21.
//

import SwiftUI

class GameManager {
    
    var board: Board
    let boardUI: BoardScene
    
    //
    private(set) var moveGenerator: MoveGenerator
    
    //
    private(set) var whitePlayer: Player!
    private(set) var blackPlayer: Player!
    
    init (white: PlayerType = .human, black: PlayerType = .computer) {
        board = Board()
        boardUI = BoardScene(board: board, colorScheme: .standard)
        
        moveGenerator = MoveGenerator(board: board)
        
        whitePlayer = MakePlayer(white, color: .White)
        blackPlayer = MakePlayer(black, color: .Black)
        
        boardUI.gameManager = self
        
    }
    
    func View () -> BoardView {
        return BoardView(scene: boardUI)
    }
    
    func ImportPGN (_ pgn: String) {
        self.board = Board.BoardFromPGN(pgn: pgn)
        self.boardUI.setBoard(board)
        self.moveGenerator = MoveGenerator(board: board)
    }
    
    func SendMoveRequest (_ move: Move) {
        
        board.CommitMove(move)
        
        boardUI.highlightMove(move)
        boardUI.animateMove(move) { [self] in
            
            boardUI.updateBoard()
            
            if GameEnded() {
//                NewGame(white: .computer, black: .computer)
            }
            else {
                board.state.isWhiteToMove ? whitePlayer.NotifyTurn() : blackPlayer.NotifyTurn()
            }
            
        }
        
    }
    
    func PlayerOfferedDraw (_ color: PieceColor) {
        
    }
    
    func PlayerResigned (_ color: PieceColor) {
        
    }
    
    enum PlayerType { case human, computer }
    func NewGame (white: PlayerType, black: PlayerType) {
        
        board = Board()
        boardUI.setBoard(board)
        
        moveGenerator = MoveGenerator(board: board)
        
        whitePlayer = MakePlayer(white, color: .White)
        blackPlayer = MakePlayer(black, color: .Black)
        
    }
    
    func Start () {
        board.state.isWhiteToMove ? whitePlayer.NotifyTurn() : blackPlayer.NotifyTurn()
    }
    
    func Abort () {
        
    }
    
    func MakePlayer (_ type: PlayerType, color: PieceColor) -> Player {
        
        switch type {
        case .computer:
            return ComputerPlayer(perspective: color, manager: self)
        case .human:
            let player = HumanPlayer(perspective: color, manager: self)
            boardUI.linkPlayer(player)
            return player
        }
        
    }
    
    func AbortCurrentGame () {
        
    }
    
    func GameEnded () -> Bool {
        
        var result: GameResult? = nil
        
        if moveGenerator.AllLegalMoves().count == 0 {
            
            //Checkmate
            if moveGenerator.KingIsInCheck() {
                result = board.state.isWhiteToMove ? .blackWon : .whiteWon
            }
            //Stalemate
            else {
                result = .draw
            }
            
        }
        else if board.position.all.nonzeroBitCount == 2 {
            result = .draw
        }
        //Fifty-move, 3-fold, etc.
        else {
            
        }
        
        var reptition: Int = 0
        var currentInfo: BoardState? = board.state.previous
        var currentPos: Position? = board.state.lastPosition
        
        while currentInfo != nil, currentPos != nil {
            
            // If position and state is the same
            if board.state.CompareRepetitionParameters(currentInfo!) && currentPos!.bitboards == board.position.bitboards {
                
                reptition += 1
                
                // Repetition
                if reptition >= 3 {
                    result = .draw
                    print("Repetition")
                    break
                }
                
            }
            
            currentPos = currentInfo!.lastPosition
            currentInfo = currentInfo!.previous

        }
        
        guard let result = result else { return false }
        HandleGameResult(result)
        return true
        
    }
    
    func HandleGameResult (_ result: GameResult) {
        print(result)
    }
    
}
