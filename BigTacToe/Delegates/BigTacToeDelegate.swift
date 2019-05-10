//
//  BigTacToeProtocol.swift
//  BigTacToe
//
//  Created by Tyler Stickler on 12/5/18.
//  Copyright © 2018 Tyler Stickler. All rights reserved.
//

import Foundation

protocol BigTacToeDelegate: class {
    func gameOver(winner: Player?)
    func largeSquareWon(playerMarker: String, squareWon: Int)
    func highlightBars(verticalBars: [Int], horizontalBars: [Int])
    func placeMarker(playerMarker: String, square: Int)
}
