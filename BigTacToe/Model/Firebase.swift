//
//  Firebase.swift
//  BigTacToe
//
//  Created by Tyler Stickler on 12/7/18.
//  Copyright © 2018 Tyler Stickler. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Firebase {
    var ref: DatabaseReference!
    weak var delegate: FirebaseDelegate?
    
    init() {
        ref = Database.database().reference()
    }
    
    func findPlayer(withName name: String?, completion: @escaping (Player) -> Void) {
        ref.child("users").observeSingleEvent(of: .value, with: {
            snapshot in
            
            let users = snapshot.value as! [String: Any]
            var player = users.randomElement()
            while (player?.key == UserDefaults.standard.string(forKey: "username")) {
                player = users.randomElement()
            }
            let username = player?.key
            var playerValues: [String: Any]
            if name == nil {
                playerValues = player?.value as! [String: Any]
            } else {
                playerValues = users[name!] as! [String: Any]
            }
            let gamesPlayerWon = playerValues["GamesWon"] as! Int
            let playerMarker = playerValues["FavoriteMarker"] as! String
            let ownedMarkers = playerValues["OwnedMarkers"] as! [String]
            var playerGames = playerValues["PlayerGames"] as? [String]
            
            if playerGames == nil {
                playerGames = [String]()
            }
            
            let playerToReturn = Player(playerName: name ?? username!, playerNumber: 0, playerWins: gamesPlayerWon, playerMarker: playerMarker, ownedMarkers: ownedMarkers, playerGames: playerGames!)
            
            completion(playerToReturn)
        })
    }
    
    func findGame(withID gameID: String?, completion: @escaping (BigTacToe?) -> Void) {
        ref.child("games").observeSingleEvent(of: .value, with: {
            snapshot in
            var gameToReturn: BigTacToe?
            
            if gameID != nil {
                let games = snapshot.value as? [String: Any]
                if let games = games {
                    for game in games {
                        if game.key == gameID {
                            
                            let game = games[game.key] as! [String: Any]
                            // Fix this and actually find players from the database
                            let playerOne = Player(playerName: game["playerOne"] as! String, playerNumber: 1, playerWins: 0, playerMarker: "❌", ownedMarkers: [""], playerGames: [""])
                            let playerTwo = Player(playerName: game["playerTwo"] as! String, playerNumber: 2, playerWins: 0, playerMarker: "⭕️", ownedMarkers: [""], playerGames: [""])
                            
                            let moveHistory = game["moveHistory"] as? [Int]
                            
                            
                            gameToReturn = BigTacToe(playerOne: playerOne, playerTwo: playerTwo, gameType: "online", gameID: gameID!, history: moveHistory)
                        }
                    }
                }
            }
            
            completion(gameToReturn)
        })
    }
    
    func addNewUser(username: String) {
        ref.child("users").observeSingleEvent(of: .value, with: {
            snapshot in
            var builtUsername = "\(username)-\(Int.random(in: 1000...9999))"
            while snapshot.hasChild(builtUsername) {
                builtUsername = "\(username)#\(Int.random(in: 1000...9999))"
            }
            self.ref.child("users/\(builtUsername)").setValue(["GamesWon": 0, "FavoriteMarker": "❌", "OwnedMarkers": ["❌", "⭕️"]]) {
                (err, ref) in
                
                if err == nil {
                    self.delegate?.signUpSuccessful(username: builtUsername)
                } else {
                    self.delegate?.signUpUnsuccessful(reason: "Error")
                }
            }
        })
    }
    
    func updateGame(gameID: String, playerOne: String, playerTwo: String, currentPlayer: String, lastMove: Int, moveHistory: [Int], gameOver: Bool) {
        ref.child("games/\(gameID)/lastMove").setValue(lastMove)
        ref.child("games/\(gameID)/playerOne").setValue(playerOne)
        ref.child("games/\(gameID)/playerTwo").setValue(playerTwo)
        ref.child("games/\(gameID)/currentPlayer").setValue(currentPlayer)
        ref.child("games/\(gameID)/moveHistory").setValue(moveHistory)
        ref.child("games/\(gameID)/gameOver").setValue(gameOver)
    }
    
    func updatePlayerGames(player: String, gameID: String) {
        ref.child("users/\(player)").observeSingleEvent(of: .value, with: {
            snapshot in
            let userInfo = snapshot.value as! [String: Any]
            
            var userGames = userInfo["PlayerGames"] as? [String]
                    
            if userGames == nil {
                userGames = [String]()
            }
                    
            userGames!.append(gameID)
            self.ref.child("users/\(player)/PlayerGames").setValue(userGames)
        })
    }
    
    func observeGame(withID gameID: String, completion: @escaping (Int) -> Void) {
        ref.child("games/\(gameID)").observe(.value, with: {
            snapshot in
            
            let snap = snapshot.value as? [String: Any]
            
            if let game = snap {
                let move = game["lastMove"] as! Int
                completion(move)
            }
        })
        
    }
}
