# Chess-AI
The original goal was to create a chess AI using machine learning, but given my unfamiliarity in both machine learning and chess AI, it felt right to create one more traditional, just for practice. Implementing machine learning is still a goal I have in mind.
<!-- ![alt text](http://url/to/img.png) -->
## Description
A macOS application of a traditional chess engine built in bitboards. Features include
- Negamax searching
- Alpha-Beta pruning
- Zobrist hashing
- Time-contrained iterative deepening option
- A rough implementation of transposition tables (still contains bugs)
- An opening book

As few engines out there are written in Swift, the [Chess Programming Wiki](https://www.chessprogramming.org) was a significant resource to provide approaches in creating a chess AI. After discovering the site, the speed of searching jumped from 500k nodes per second (NPS) to 2,000k NPS (performance test, bulk counting disabled, evaluation not included). While this number could improve, for example with multi-threading, my goal with the project (having fun!) was complete. 

## Playing
<sub>(Sorry for the UI not being complete. Didn't know I'd be sharing this.)</sub> <br />
#### Players
First, if you would like to modify game participants, go to /UI/SwiftUI/GameView and change players between ```.human ``` and ```.computer ``` as needed.
``` swift 
let Manager = GameManager(white: .human, black: .computer)
```
To flip the board, just click the flip button. To change the them of the board, open the right panel by clicking the button on the upper-right corner of the window. Available themes will appear. <br /> <br />
#### Import / Export
Currently, it is possible to export the game to [chess.com](chess.com) in Portable Game Notation (PGN) through the export button. Likewise, it is possible to import games, but the function is not attached to the UI. Under GameView, line 67, there is an import function. Add the following line, where ```<#PGNString#>``` is the imported PGN. After adding this line, the import button with work properly using the PGN inserted for ```<#PGNString#>```.
``` swift
func `import`() {
       
    Manager.ImportPGN(pgn: <#PGNString#> )
        
}
```
Since Forsyth–Edwards Notation (FEN) doesn't provide enough game information to feed into the ```GameManager```, FEN strings should be imported under /Negamax Engine/Board. In the body of ```init``` on line 17, change the content within ```Board.SetFromFen``` to the FEN you would like to import. For example, to import the FEN rnbq1k1r/pp1Pbppp/2p5/8/2B5/8/PPP1NnPP/RNBQK2R w KQ - 1 8, line 18
``` swift
Board.SetFromFEN(self, "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 0")
```
becomes 
``` swift
Board.SetFromFEN(self, "rnbq1k1r/pp1Pbppp/2p5/8/2B5/8/PPP1NnPP/RNBQK2R w KQ - 1 8")
```
#### Search Settings
There are three settings in which the engine can search moves: ```.fixedDepth(<#depth#>)```, ```.timeConstrained(time: <#seconds#>)```, and ```.timeConstrainedDepth(depth: <#target_depth#>, time: <#seconds#>)```, where all inputs should be positive integers. To change this, go to /UI/SwiftUI/Player/ComputerPlayer. On line 24, change the ```mode``` content in ```ChhanielsChessEngine``` to the desired setting. For example, to change the engine's setting to search to a fixed depth, the line will look like
``` swift 
self.engine = ChanielsChessEngine(testBoard, settings: .init(mode: .fixedDepth(5), usesTranspositionTable: true, usesOpeningBook: false))
```
