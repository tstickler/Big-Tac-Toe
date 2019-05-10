//
//  Player.swift
//  BigTacToe
//
//  Created by Tyler Stickler on 12/3/18.
//  Copyright © 2018 Tyler Stickler. All rights reserved.
//

import Foundation

class Player {
    var playerNumber: Int!
    var playerName: String!
    var playerWins: Int!
    var playerMarker: String!
    var ownedMarkers: [String]!
    var playerGames: [String]!
    
    init(playerName: String, playerNumber: Int, playerWins: Int, playerMarker: String, ownedMarkers: [String], playerGames: [String]) {
        self.playerName = playerName
        self.playerNumber = playerNumber
        self.playerWins = playerWins
        self.playerMarker = playerMarker
        self.ownedMarkers = ownedMarkers
        self.playerGames = playerGames
    }
}
