//
//  BoardScene.swift
//  Chess ML
//
//  Created by Chaniel Ezzi on 7/12/21.
//

import SpriteKit

class BoardScene: SKScene {
    
    weak var gameManager: GameManager?
    
    private(set) var board: Board
    private(set) var squares = [Square]()
    
    private(set) var colorScheme: BoardColorScheme
    
    let rootNode = SKNode()
    
    init(board: Board = Board(), colorScheme: BoardColorScheme = .standard) {
        self.board = board
        self.colorScheme = colorScheme
        
        super.init(size: .init(width: 50, height: 50))
        
        loadSquares()
        updateBoard()
        
        //Position 0 by default
        let pov = SKCameraNode()
        camera = pov
        addChild(pov)
        
        addChild(rootNode)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    func animateMove (_ move: Move, completion: @escaping () -> Void) {
        
        let senderSprite = squares[move.startIndex].overlayPiece!
        let destinationSquare = squares[move.targetIndex]
        
        let convertedPoint = destinationSquare.convert(.zero, to: senderSprite.parent!)
        
        let action = SKAction.move(to: convertedPoint, duration: 0.15)
        
        senderSprite.zPosition = 3
        
        senderSprite.run(action) {
            completion()
            senderSprite.position = .zero
            senderSprite.zPosition = 2
        }
        
    }
    
    func highlightMove (_ move: Move) {
        
        clearHighlightedSquares()
        
        highlightSquares(color: .yellow) { sq in
            sq.index == move.startIndex || sq.index == move.targetIndex
        }
        
    }
    
    private func loadSquares () {
        
        for y in 0...7 {
            for x in 0...7 {
                
                let squareSize = min(size.width, size.height) / 8
                
                //Size, position, index
                let square = Square(rectOf: .init(width: squareSize, height: squareSize))
                square.index = y * 8 + x
                
                square.fillColor = (x + y).isMultiple(of: 2) ? NSColor(colorScheme.dark) : NSColor(colorScheme.light)
                square.strokeColor = .clear
                
                square.position = .init(x: CGFloat(x) * squareSize, y: CGFloat(y) * squareSize)
                square.zPosition = 1
                
                //Shift to center
                square.position.x -= 7 * min(size.width, size.height) / 16
                square.position.y -= 7 * min(size.width, size.height) / 16
                
                //Init highlight node
                let highlight = SKShapeNode(path: square.path!)
                highlight.strokeColor = .clear
                highlight.fillColor = .clear
                highlight.alpha = 0.3
                square.highlightNode = highlight
                square.addChild(highlight)
                
                //Init piece node
                let squareOverlay = SKSpriteNode()
                squareOverlay.zPosition = 2
                squareOverlay.size = CGSize(width: squareSize, height: squareSize)
                square.overlayPiece = squareOverlay
                square.addChild(squareOverlay)
                
                squares.append(square)
                rootNode.addChild(square)
                
//                let label = SKLabelNode(text: BoardRepresentation.CoordinatesOfIndex[square.index])
//                square.addChild(label)
//                label.fontColor = .red
//                label.fontSize = squareSize / 2
//                label.zPosition = 10
                
            }
        }
        
    }
    
    func changeScheme (_ newScheme: BoardColorScheme) {
        
        colorScheme = newScheme
        
        for y in 0...7 {
            for x in 0...7 {
                
                let i = y * 8 + x
                squares[i].fillColor = (x + y).isMultiple(of: 2) ? NSColor(colorScheme.dark) : NSColor(colorScheme.light)
                
            }
        }
        
    }
    
    func setBoard (_ board: Board) {
        self.board = board
        updateBoard()
    }
    
    func updateBoard () {
        let pieces = board.position.squares
        
        for index in 0...63 {
            guard let piece = pieces[index]
            else {
                squares[index].overlayPiece.texture = nil
                continue
            }
            
            let imageName = "\(piece.color)_\(piece.type)"
            squares[index].overlayPiece.texture = SKTexture(imageNamed: imageName)
            
        }
        
    }
    
    func squareAtPoint (_ point: CGPoint) -> Square? {
        return nodes(at: point).first(where: { $0 is Square }) as? Square
    }
    
    //
    func highlightSquares (color: NSColor, where test: (Square) -> Bool) {
        for square in squares {
            if test(square) {
                square.highlightNode.fillColor = color
            }
        }
    }
    
    func clearHighlightedSquares () {
        for square in squares {
            square.highlightNode.fillColor = .clear
        }
    }
    
    func editSquares (block: (Square) -> Void) {
        for square in squares {
            block(square)
        }
    }
    
    //
    func linkPlayer (_ player: HumanPlayer) {
        
        switch player.perspective {
        case .White: shouldMonitorWhite = true
        case .Black: shouldMonitorBlack = true
        }
        
    }
    
    func unlinkPlayers () {
        shouldMonitorWhite = false
        shouldMonitorBlack = false
    }
    
    //
    private var shouldMonitorWhite = false
    private var shouldMonitorBlack = false
    private var startSquareCache: Square?
    
    func handleClick (_ point: CGPoint) {
        
        if (board.state.isWhiteToMove && shouldMonitorWhite) || (!board.state.isWhiteToMove && shouldMonitorBlack),
           let firstSquare = startSquareCache,
           let secondSquare = squareAtPoint(point), firstSquare != secondSquare,
           //Find from legal moves to get the correct tag
           let move = gameManager?.moveGenerator.LegalMoves(at: firstSquare.index).first(where: { $0.targetIndex == secondSquare.index })
           {
            
            gameManager?.SendMoveRequest(move)
            
            startSquareCache = nil
            clearHighlightedSquares()
            
        }
        //Square was selected, but is an illegal move
        else if startSquareCache != nil {
            
            startSquareCache = nil
            clearHighlightedSquares()
            
        }
        //If cache is nil
        else {
            
            guard let newSquare = squareAtPoint(point), board.position.squares[newSquare.index] != nil
            else { return }
            
            startSquareCache = newSquare
            startSquareCache?.highlightNode.fillColor = .yellow
            
            guard (board.state.isWhiteToMove && shouldMonitorWhite) || (!board.state.isWhiteToMove && shouldMonitorBlack),
                  let manager = gameManager
            else { return }
            
            highlightSquares(color: .cyan) { sq in
                manager.moveGenerator.LegalMoves(at: newSquare.index).contains(where: { $0.targetIndex == sq.index })
            }
            
        }
        
    }
    
    func handleDrag (_ currentPoint: CGPoint, _ BoardState: DragBoardState) {
        
        
        
    }
    
    
    
    
    
    enum DragBoardState {
        case none, began, dragging, ended
    }
    
    private var drag: DragBoardState = .none
    
    override func mouseDown(with event: NSEvent) {
        //Tap
        let location = event.location(in: self)
        handleClick(location)
        
        drag = .began
        
    }
    
    override func mouseDragged(with event: NSEvent) {
        
        //Drag
        let location = event.location(in: self)
        
        if drag == .none || drag == .ended {
            drag = .began
        }
        else {
            drag = .dragging
        }
        
        handleDrag(location, drag)
        
    }
    
    override func mouseUp(with event: NSEvent) {
        //Lift
        
        drag = .ended
        
    }
    
    
}


extension BoardScene {
    
    class Square: SKShapeNode {
        var index: Int!
        var overlayPiece: SKSpriteNode!
        var highlightNode: SKShapeNode!
    }
    
}
