//
//  MainViewController.swift
//  OAuth2
//
//  Created by Maxim Spiridonov on 07/04/2019.
//  Copyright © 2019 Maxim Spiridonov. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FirebaseAuth


class MainViewController: UIViewController {
    
    lazy var fbLoginButton: UIButton = {
        let loginButton = FBSDKLoginButton()
        loginButton.frame = CGRect(x: 32,
                                   y: view.frame.height - 128,
                                   width: view.frame.width - 64,
                                   height: 50)
        loginButton.delegate = self
        return loginButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        checkLoggedIn()
        setupViews()
    }
    
    private func setupViews() {
        view.addSubview(fbLoginButton)
    }
}

// MARK: Facebook SDK
extension MainViewController {
    
    private func checkLoggedIn() {
        
        if Auth.auth().currentUser == nil {
            
            DispatchQueue.main.async {
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let loginViewController = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                self.present(loginViewController, animated: true)
                return
            }
        }
    }
}

extension MainViewController: FBSDKLoginButtonDelegate {
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        if error != nil {
            print(error)
            return
        }
       
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
        print("Did log out of facebook")
        openLoginViewController()
    }
    private func openLoginViewController() {
        
        // проверяем пользователя в Firebase
    
        do {
            try Auth.auth().signOut()
            
            DispatchQueue.main.async {
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let loginViewController = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                self.present(loginViewController, animated: true)
                return
            }
        } catch let error {
            print("Failed to sign out with error:" + error.localizedDescription)
        }
    }
    
}

