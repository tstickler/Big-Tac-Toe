//
//  FirebaseDelegate.swift
//  BigTacToe
//
//  Created by Tyler Stickler on 12/7/18.
//  Copyright © 2018 Tyler Stickler. All rights reserved.
//

import Foundation

protocol FirebaseDelegate: class {
    func signUpSuccessful(username: String)
    func signUpUnsuccessful(reason: String)
}
