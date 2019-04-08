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
import FirebaseDatabase


class MainViewController: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var userEmail: UILabel! {
        didSet {
            userEmail.text = ""
        }
    }
    @IBOutlet weak var userName: UILabel! {
        didSet {
            userName.text = ""
        }
    }
    @IBOutlet weak var userPicture: UIImageView!
    
    var currentUser: UserProfile?
    
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
        view.addVerticalGradientLayer(topColor: primaryColor, bottomColor: secondaryColor)
        checkLoggedIn()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchUserData()
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
        fetchUserData()
       
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
    
    private func fetchUserData() {
        if Auth.auth().currentUser != nil {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            Database.database().reference()
            .child("users")
            .child(uid)
                .observeSingleEvent(of: .value, with: { (snapshot) in
                    guard let userData = snapshot.value as? [String: Any] else { return }
                    self.currentUser = UserProfile(data: userData, true)
                    print(userData)
                    self.setupUserUI()
                }) { (error) in
                    print(error)
            }
        }
    }
    
    private func setupUserUI() {
        
        guard let user = currentUser else { return }
        let url = URL(string: user.picture!)
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: url!)
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.userPicture.image = UIImage(data: data!)
                self.userName.text = user.name!
                self.userEmail.text = user.email!

            }
        }
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }

}

