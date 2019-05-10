//
//  LoginViewController.swift
//  BigTacToe
//
//  Created by Tyler Stickler on 12/7/18.
//  Copyright © 2018 Tyler Stickler. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    var firebase: Firebase!
    var game: BigTacToe!
    
    @IBOutlet weak var usernameField: UITextField!
    
    @IBAction func signUpTapped(_ sender: UIButton) {
        let usernameEntered = usernameField.text
        
        if usernameEntered == nil {
            return
        }
        
        firebase.addNewUser(username: usernameEntered!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firebase = Firebase.init()
        firebase.delegate = self
        usernameField.delegate = self

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if UserDefaults.standard.string(forKey: "username") != nil {
            performSegue(withIdentifier: "gameSelectionNoAnimation", sender: self)
        }
    }
}

extension LoginViewController: FirebaseDelegate {
    func signUpSuccessful(username: String) {
        UserDefaults.standard.set(username, forKey: "username")
        performSegue(withIdentifier: "gameSelectionSegue", sender: self)
    }
    
    func signUpUnsuccessful(reason: String) {
        print(reason)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet.alphanumerics
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }
}
