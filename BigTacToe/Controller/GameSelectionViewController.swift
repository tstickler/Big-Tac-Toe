//
//  GameSelectionViewController.swift
//  BigTacToe
//
//  Created by Tyler Stickler on 12/11/18.
//  Copyright © 2018 Tyler Stickler. All rights reserved.
//

import UIKit

class GameSelectionViewController: UIViewController {
    var firebase: Firebase!
    var playerOne: Player!
    var playerTwo: Player!
    var game: BigTacToe!
    var user: Player!
    @IBOutlet weak var gamesTableView: UITableView!
    
    @IBAction func gameStartOnline(_ sender: Any) {
        findGameInFirebase(withID: nil)
    }
    
    @IBAction func gameStartLocal(_ sender: Any) {
        playerOne = Player(playerName: UserDefaults.standard.string(forKey: "username")!, playerNumber: 1, playerWins: 0, playerMarker: "❌", ownedMarkers: [], playerGames: [])
        playerTwo = Player(playerName: UserDefaults.standard.string(forKey: "username")!, playerNumber: 2, playerWins: 0, playerMarker: "⭕️", ownedMarkers: [], playerGames: [])

        game = BigTacToe(playerOne: playerOne, playerTwo: playerTwo, gameType: "local")
        performSegue(withIdentifier: "toGameSegue", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firebase = Firebase()
        firebase.findPlayer(withName: UserDefaults.standard.string(forKey: "username")) {
            user in
            self.user = user

            self.gamesTableView.delegate = self
            self.gamesTableView.dataSource = self
            self.gamesTableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let gameVC = segue.destination as? GameViewController {
            gameVC.game = self.game
        }
    }
    
    func findGameInFirebase(withID gameID: String?) {
        firebase.findGame(withID: gameID) {
            game in
            
            if game == nil {
                self.firebase.findPlayer(withName: UserDefaults.standard.string(forKey: "username"), completion: {
                    foundPlayerFirst in
                    foundPlayerFirst.playerNumber = 1
                    self.playerOne = foundPlayerFirst
                    self.playerOne.playerMarker = "❌"
                    
                    self.firebase.findPlayer(withName: nil) {
                        foundPlayerSecond in
                        foundPlayerSecond.playerNumber = 2
                        self.playerTwo = foundPlayerSecond
                        self.playerTwo.playerMarker = "⭕️"
                        
                        self.game = BigTacToe(playerOne: self.playerOne, playerTwo: self.playerTwo, gameType: "online")
                        // TODO: Check for online before setting up firebase observe
                        self.performSegue(withIdentifier: "toGameSegue", sender: self)
                    }
                })
            } else {
                self.game = game
                self.performSegue(withIdentifier: "toGameSegue", sender: self)
            }
        }
    }
}

extension GameSelectionViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return user.playerGames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        
        firebase.ref.child("games/\(user.playerGames[indexPath.row])").observeSingleEvent(of: .value) {
            snap in
            
            let data = snap.value as! [String: Any]
            let currentPlayer = data["currentPlayer"] as! String
            
            if currentPlayer == UserDefaults.standard.string(forKey: "username") {
                cell.textLabel?.text = "It's your turn!"
            } else {
                let currentPlayerSubstring = currentPlayer.split(separator: "-", maxSplits: 1, omittingEmptySubsequences: true)
                cell.textLabel?.text = "Waiting for \(currentPlayerSubstring[0]) to make their move..."
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let gameID = user.playerGames[indexPath.row]
        findGameInFirebase(withID: gameID)
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
