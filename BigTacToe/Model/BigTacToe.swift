//
//  BigTacToe.swift
//  BigTacToe
//
//  Created by Tyler Stickler on 12/3/18.
//  Copyright © 2018 Tyler Stickler. All rights reserved.
//

import Foundation

class BigTacToe {
    private var largeBoardState: [Int?]
    private var smallBoardsState: [[Int?]]
    public var playerOne: Player!
    public var playerTwo: Player!
    private var currentPlayer: Player!
    private var gameIsOver = false
    private let moveValidAnywhere = 10
    private var nextMoveSquare: Int!
    private var gameType: String!
    public let gameID: String?
    private var moveHistory: [Int]!
    private let winningBoardStates = [[0,1,2], [3,4,5], [6,7,8],
                                      [0,3,6], [1,4,7], [2,5,8],
                                      [0,4,8], [2,4,6]]
    private var firebase: Firebase!
    
    weak var delegate: BigTacToeDelegate?
    
    init(playerOne: Player, playerTwo: Player, gameType: String) {
        self.playerOne = playerOne
        self.playerTwo = playerTwo
        self.gameType = gameType
        currentPlayer = playerOne
        largeBoardState = [Int?](repeating: nil, count: 9)
        smallBoardsState = [[Int?]](repeating: [Int?](repeating: nil, count: 9), count: 9)
        nextMoveSquare = moveValidAnywhere
        moveHistory = [Int]()
        if gameType == "online" {
            // TODO: Could overwrite someone elses game, check with database to ensure it is a unique game
            gameID = "game-\(Int.random(in: 0...Int.max))"
            firebase = Firebase.init()
            firebase.updateGame(gameID: gameID!, playerOne: playerOne.playerName, playerTwo: playerTwo.playerName, currentPlayer: currentPlayer.playerName, lastMove: 0, moveHistory: moveHistory, gameOver: gameIsOver)
            firebase.updatePlayerGames(player: playerOne.playerName, gameID: gameID!)
            firebase.updatePlayerGames(player: playerTwo.playerName, gameID: gameID!)
        } else {
            gameID = nil
        }
    }
    
    init(playerOne: Player, playerTwo: Player, gameType: String, gameID: String, history: [Int]?) {
        self.playerOne = playerOne
        self.playerTwo = playerTwo
        self.gameType = gameType
        currentPlayer = playerOne
        largeBoardState = [Int?](repeating: nil, count: 9)
        smallBoardsState = [[Int?]](repeating: [Int?](repeating: nil, count: 9), count: 9)
        nextMoveSquare = moveValidAnywhere
        moveHistory = history
        
        if moveHistory == nil {
            moveHistory = [Int]()
        }
        
        if gameType == "online" {
            // TODO: Could overwrite someone elses game, check with database to ensure it is a unique game
            // gameID = "game-\(Int.random(in: 100000...999999))"
            self.gameID = gameID
            firebase = Firebase.init()
            firebase.updateGame(gameID: gameID, playerOne: playerOne.playerName, playerTwo: playerTwo.playerName, currentPlayer: currentPlayer.playerName, lastMove: 0, moveHistory: moveHistory, gameOver: gameIsOver)
        } else {
            self.gameID = nil
        }
    }
    
    func makeMoves() {
        for move in moveHistory {
            attemptMarkerPlacement(at: move)
        }
    }
    
    func attemptMarkerPlacement(at space: Int) {
        let spaceAsString = "\(space)"
        let largeBoardSquare = Int("\(spaceAsString[spaceAsString.startIndex])")! - 1
        let smallBoardSquare = Int("\(spaceAsString[spaceAsString.index(before: spaceAsString.endIndex)])")! - 1
        
        if isValidMove(largeSpot: largeBoardSquare, smallSpot: smallBoardSquare) {
            makeMove(largeSpot: largeBoardSquare, smallSpot: smallBoardSquare, player: currentPlayer.playerNumber)
            if !moveHistory.contains(space) {
                moveHistory.append(space)
            }
            let marker = currentPlayer.playerMarker!
            delegate?.placeMarker(playerMarker: marker, square: space)
            
            // Swap current player
            currentPlayer = currentPlayer.playerNumber == 1 ? playerTwo : playerOne
            if gameType == "online" {
                firebase.updateGame(gameID: gameID!, playerOne: playerOne.playerName, playerTwo: playerTwo.playerName, currentPlayer: currentPlayer.playerName, lastMove: space, moveHistory: moveHistory, gameOver: gameIsOver)
            }
        }
    }
    
    fileprivate func isValidMove(largeSpot largeBoardSquare: Int, smallSpot smallBoardSquare: Int) -> Bool {
        // 4 Conditions for move to be valid
        // ---------------------------------
        // 1. Selected space is empty
        // 2. Large space has not been won yet
        // 3. The game is not over
        // 4. The move is in the proper square or is anywhere on the board
        if smallBoardsState[largeBoardSquare][smallBoardSquare] == nil
            && largeBoardState[largeBoardSquare] == nil
            && !gameIsOver
            && (nextMoveSquare == largeBoardSquare || nextMoveSquare == moveValidAnywhere) {
            return true
        } else {
            // Move is not valid unless it passes all conditions above
            return false
        }
    }
    
    fileprivate func makeMove(largeSpot largeBoardSquare: Int, smallSpot smallBoardSquare: Int, player playerNumber: Int) {
        smallBoardsState[largeBoardSquare][smallBoardSquare] = playerNumber
        
        if checkMoveWonSquare(at: largeBoardSquare, player: playerNumber) {
            largeBoardState[largeBoardSquare] = playerNumber
            delegate?.largeSquareWon(playerMarker: currentPlayer.playerMarker, squareWon: largeBoardSquare)
            
            if checkMoveWonGame(player: playerNumber) {
                gameIsOver = true
                delegate?.gameOver(winner: currentPlayer)
            } else if checkMoveCats(withBoard: largeBoardState) {
                gameIsOver = true
                delegate?.gameOver(winner: nil)
            }
        }
        
        if checkMoveCats(withBoard: smallBoardsState[largeBoardSquare]) {
            largeBoardState[largeBoardSquare] = 3
        }
        
        nextMoveSquare = determineNextMoveSquare(smallSquare: smallBoardSquare)
        determineBarsToHighlight(around: nextMoveSquare)
    }
    
    fileprivate func checkMoveWonSquare(at square: Int, player playerNumber: Int) -> Bool {
        var squaresOwned = [Int]()
        for i in 0..<smallBoardsState[square].count {
            if let move = smallBoardsState[square][i], move == playerNumber {
                squaresOwned.append(i)
            }
        }
        
        var winningCombinationFound = false
        for winningCombination in winningBoardStates {
            for i in 0..<winningCombination.count {
                if !squaresOwned.contains(winningCombination[i]) {
                    break
                }
                
                if i == winningCombination.count - 1 {
                    winningCombinationFound = true
                }
            }
            
            if winningCombinationFound {
                print("Player \(playerNumber) won the square \(square) with winning combination \(winningCombination)")
                break
            }
        }
        
        return winningCombinationFound
    }
    
    fileprivate func checkMoveCats(withBoard board: [Int?]) -> Bool {
        for i in 0...8 {
            if board[i] == nil {
                return false
            }
        }
        
        return true
    }
    
    fileprivate func checkMoveWonGame(player playerNumber: Int) -> Bool {
        var squaresOwned = [Int]()
        for i in 0..<largeBoardState.count {
            if let move = largeBoardState[i], move == playerNumber {
                squaresOwned.append(i)
            }
        }
        
        var winningCombinationFound = false
        for winningCombination in winningBoardStates {
            for i in 0..<winningCombination.count {
                if !squaresOwned.contains(winningCombination[i]) {
                    break
                }
                
                if i == winningCombination.count - 1 {
                    winningCombinationFound = true
                }
            }
            
            if winningCombinationFound {
                print("Player \(playerNumber) won the game with winning combination \(winningCombination)")
                break
            }
        }
        
        return winningCombinationFound
    }
    
    fileprivate func determineNextMoveSquare(smallSquare: Int) -> Int {
        var nextSquare = smallSquare
        
        if largeBoardState[nextSquare] != nil {
            nextSquare = moveValidAnywhere
        }
        
        return nextSquare
    }
    
    fileprivate func determineBarsToHighlight(around square: Int) {
        var verticalBars = [Int]()
        var horizontalBars = [Int]()
        
        switch square {
        case 0:
            // Top Left Corner
            verticalBars = [0]
            horizontalBars = [0]
        case 1:
            // Top Middle
            verticalBars = [0, 3]
            horizontalBars = [1]
        case 2:
            // Top Right
            verticalBars = [3]
            horizontalBars = [2]
        case 3:
            // Left Middle
            verticalBars = [1]
            horizontalBars = [0, 3]
        case 4:
            // Center
            verticalBars = [1, 4]
            horizontalBars = [1, 4]
        case 5:
            // Right Middle
            verticalBars = [4]
            horizontalBars = [2, 5]
        case 6:
            // Bottom Left
            verticalBars = [2]
            horizontalBars = [3]
        case 7:
            // Bottom Middle
            verticalBars = [2, 5]
            horizontalBars = [4]
        case 8:
            // Bottom Right
            verticalBars = [5]
            horizontalBars = [5]
        default:
            // All squares valid
            verticalBars = [0, 1, 2, 3, 4, 5]
            horizontalBars = [0, 1, 2, 3, 4, 5]
        }
        
        delegate?.highlightBars(verticalBars: verticalBars, horizontalBars: horizontalBars)
    }
    
    func getCurrentPlayerName() -> String {
        return currentPlayer.playerName
    }
    
    func gameIsOnline() -> Bool {
        if gameType == "online" {
            return true
        } else {
            return false
        }
    }
}
