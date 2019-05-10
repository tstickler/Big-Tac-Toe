//
//  ViewController.swift
//  BigTacToe
//
//  Created by Tyler Stickler on 12/3/18.
//  Copyright © 2018 Tyler Stickler. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    var game: BigTacToe!
    var firebase: Firebase!
    
    @IBOutlet weak var gameBoard: UIView!
    @IBOutlet weak var scroller: UIScrollView!
    @IBOutlet weak var zoomOutButton: UIButton!
    @IBOutlet weak var playAgainButton: UIButton!
    @IBOutlet var overlayButtons: [UIButton]!
    @IBOutlet var smallBoardButtons: [UIButton]!
    @IBOutlet var verticalHighlightBars: [UIView]!
    @IBOutlet var horizontalHighlightBars: [UIView]!
    @IBOutlet weak var winnerLabel: UILabel!
    
    @IBAction func smallSpaceTapped(_ sender: UIButton) {
        if game.getCurrentPlayerName() == UserDefaults.standard.string(forKey: "username") {
            game.attemptMarkerPlacement(at: sender.tag)
        }
    }
    
    @IBAction func zoomTo(_ sender: UIButton) {
        let location = sender.convert(sender.frame.origin, to: gameBoard)
        let zoomSpot = CGRect(x: location.x, y: location.y, width: sender.frame.width, height: sender.frame.height)
        scroller.zoom(to: zoomSpot, animated: true)
    }
    
    @IBAction func zoomOut(_ sender: Any) {
        scroller.setZoomScale(1.0, animated: true)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return gameBoard
    }
    
    @IBAction func playAgainTapped(_ sender: Any) {
        // TODO: Figure out logic here for creating new game
        // Don't want both users to tap new game and start 2 games
        // setUpGame()
    }
    
    @IBAction func backButtonTappedTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firebase = Firebase.init()
        setUpGame()
    }
    
    func setUpGame() {
        for button in overlayButtons {
            button.setTitle(nil, for: .normal)
            button.isHidden = true
        }
        for button in smallBoardButtons {
            button.setTitle(nil, for: .normal)
        }
        for bar in horizontalHighlightBars {
            bar.isHidden = false
        }
        for bar in verticalHighlightBars {
            bar.isHidden = false
        }
        winnerLabel.text = nil
        playAgainButton.isHidden = true
        
        game.delegate = self
        game.makeMoves()
        
        if game.gameIsOnline() {
            firebase.observeGame(withID: game.gameID!) {
                move in
                
                if self.game != nil && move != 0 {
                    self.winnerLabel.text = self.game.getCurrentPlayerName()
                    self.game.attemptMarkerPlacement(at: move)
                }
            }
        }
    }
}

extension GameViewController: UIScrollViewDelegate {
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if scroller.zoomScale > 1.0 {
            zoomOutButton.isHidden = false
            zoomOutButton.isEnabled = true
        } else {
            zoomOutButton.isHidden = true
            zoomOutButton.isEnabled = false
        }
    }
}

extension GameViewController: BigTacToeDelegate {
    func placeMarker(playerMarker: String, square: Int) {
        for button in smallBoardButtons {
            if button.tag == square {
                button.layer.borderColor = UIColor.red.cgColor
                button.layer.borderWidth = 3
                button.setTitle(playerMarker, for: .normal)
            } else {
                button.layer.borderColor = UIColor.red.cgColor
                button.layer.borderWidth = 0
            }
        }
    }
    
    func highlightBars(verticalBars: [Int], horizontalBars: [Int]) {
        for i in 0..<verticalHighlightBars.count {
            if verticalBars.contains(i) &&
                (game.getCurrentPlayerName() != UserDefaults.standard.string(forKey: "username") ||
                    !game.gameIsOnline()) {
                verticalHighlightBars[i].isHidden = false
            } else {
                verticalHighlightBars[i].isHidden = true
            }
        }
        
        for i in 0..<horizontalHighlightBars.count {
            if horizontalBars.contains(i) &&
                (game.getCurrentPlayerName() != UserDefaults.standard.string(forKey: "username") ||
                    !game.gameIsOnline()) {
                horizontalHighlightBars[i].isHidden = false
            } else {
                horizontalHighlightBars[i].isHidden = true
            }
        }
    }
    
    func gameOver(winner: Player?) {
        if let winner = winner {
            winnerLabel.text = "\(winner.playerMarker!) \(winner.playerName!) wins! \(winner.playerMarker!)"
        } else {
            winnerLabel.text = "Cats game"
        }
        
        playAgainButton.isHidden = false
    }
    
    func largeSquareWon(playerMarker: String, squareWon: Int) {
        overlayButtons[squareWon].isHidden = false
        overlayButtons[squareWon].setTitle(playerMarker, for: .normal)
    }
}
