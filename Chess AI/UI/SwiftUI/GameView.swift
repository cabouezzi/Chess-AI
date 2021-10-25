//
//  ChessBoardView.swift
//  Chess ML
//
//  Created by Chaniel Ezzi on 7/2/21.
//

import SwiftUI
import SpriteKit

struct GameView: View {
    
    let Manager = GameManager(white: .human, black: .computer)
    
    @State var board: Board = Board()
    @State var whiteFacing = true
    
    var body: some View {
        
        VStack {
            
            Spacer()
            
            Manager.View()
                .aspectRatio(1, contentMode: .fit)
                .frame(minWidth: 300, minHeight: 300)
                .onAppear {
                    Manager.Start()
                }
            
            Spacer()
            
            HStack {
                
                Spacer()
                
                SpinButton(image: Image(systemName: "arrow.2.circlepath"), title: "Flip", action: flip)
                    .buttonStyle(TabButtonStyle())
                
//                 ImageAndLabelButton(image: Image(systemName: "waveform.path.ecg"), title: "Perft \(value)", action: perft)
//                     .buttonStyle(TabButtonStyle())
//
//                 ImageAndLabelButton(image: Image(systemName: "square.and.arrow.down"), title: "+", action: up)
//                     .buttonStyle(TabButtonStyle())
//
//                 ImageAndLabelButton(image: Image(systemName: "square.and.arrow.down"), title: "–", action: down)
                    .buttonStyle(TabButtonStyle())
                
                ImageAndLabelButton(image: Image(systemName: "arrowshape.turn.up.right.fill"), title: "Export", action: export)
                    .buttonStyle(TabButtonStyle())

                ImageAndLabelButton(image: Image(systemName: "square.and.arrow.down"), title: "Import", action: `import`)
                    .buttonStyle(TabButtonStyle())

                Spacer()
                
            }
            
            Spacer()
            
        }
        
    }
    
    @State var toggle = false
    
    func `import`() {
        
        
        
    }
    
    func export () {
        let fen = "https://www.chess.com/analysis?fen=" + Board.FENFromBoard(Manager.board)
        let fenURL = URL(string: fen.replacingOccurrences(of: " ", with: "%20"))!
        
        let pgn = "https://www.chess.com/analysis?pgn=" + Board.PGNFromMoveHistory(Manager.board.state.moveHistory)
        let pgnURL = URL(string: pgn.replacingOccurrences(of: " ", with: "%20"))!
        
        print(Board.PGNFromMoveHistory(Manager.board.state.moveHistory))
        NSWorkspace.shared.open(pgnURL)
        print(pgn)
    }
    
    @State var value = 4
    
    func up () {
        if value < 10 {
            value += 1
        }
    }
    
    func down () {
        if value > 1 {
            value -= 1
        }
    }
    
    func perft () {
        let que = DispatchQueue(label: "PERFT Que", qos: .userInteractive, attributes: .concurrent)
        que.async {
            let board = Board()
            board.position = Manager.board.position
            board.state = Manager.board.state
            ChanielsChessEngine(board, settings: .init(mode: .fixedDepth(value), usesTranspositionTable: false, usesOpeningBook: false)).DoPerft(depth: value)
        }
    }
        
    func flip () {
        
        Manager.View().flip()
        
    }
    
    
}


struct BoardView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            GameView()
        }
    }
}
