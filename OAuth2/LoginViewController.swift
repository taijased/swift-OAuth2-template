//
//  LoginViewController.swift
//  OAuth2
//
//  Created by Maxim Spiridonov on 07/04/2019.
//  Copyright © 2019 Maxim Spiridonov. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FirebaseAuth
import FirebaseDatabase


class LoginViewController: UIViewController {
    
    var userProfile: UserProfile?

    lazy var customFBLoginButton: UIButton = {
        let loginButton = UIButton()
        loginButton.backgroundColor = UIColor(hexValue: "#3B5999", alpha: 1)
        loginButton.setTitle("Login with Facebook", for: .normal)
        loginButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.frame = CGRect(x: 32, y: 320, width: view.frame.width - 64, height: 50)
        loginButton.layer.cornerRadius = 4
        loginButton.addTarget(self, action: #selector(handleCustomFBLogin), for: .touchUpInside)
        return loginButton
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addVerticalGradientLayer(topColor: primaryColor, bottomColor: secondaryColor)

        setupViews()    
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }

    private func setupViews() {
        view.addSubview(customFBLoginButton)
    }

}

extension LoginViewController: FBSDKLoginButtonDelegate {
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        if error != nil {
            print(error)
            return
        }
        
        guard FBSDKAccessToken.currentAccessTokenIsActive() else { return }
        
        openMainViewController()
        print("Successfully logged in with facebook...")
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
        print("Did log out of facebook")
    }
    private func openMainViewController() {
        dismiss(animated: true)
    }
    
    @objc private func handleCustomFBLogin() {
        
        FBSDKLoginManager().logIn(withReadPermissions: ["email", "public_profile"], from: self) { (result, error) in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let result = result else { return }
            
            if result.isCancelled { return }
            else {
                self.singIntoFirebase()
            }
        }
    }
    private func singIntoFirebase() {
        
        let accessToken = FBSDKAccessToken.current()
        
        guard let accessTokenString = accessToken?.tokenString else { return }
        
        let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
        
        Auth.auth().signInAndRetrieveData(with: credentials) { (user, error) in
            
            if let error = error {
                print("Что то пошло не так !Упс при аунтентификации в Facebook: ", error)
                return
            }
            
            print("Успешная аунтентификация в Facebook")
            self.fetchFacebookFields()
        }
    }
    
    private func fetchFacebookFields() {
        
        /*
            Вот наиболее распространенные поля public_user:
         
            id
            cover
            name
            first_name
            last_name
            age_range
            link
            gender
            locale
            picture
            timezone
            updated_time
            verified
        */
        
        FBSDKGraphRequest(graphPath: "me",
                          parameters: ["fields": "id, name, email, first_name, last_name, picture.type(large)"])?.start(completionHandler: { (_, result, error) in
            if let error = error {
                print(error)
                return
            }
            guard let userData = result as? [String: Any] else { return }
            self.userProfile = UserProfile(data: userData)
            print("Публичные данные получены с  Facebook")
            self.saveIntoFirebase()
        })
    }
    
    private func saveIntoFirebase() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Database.database().reference().child("users").updateChildValues([uid: userProfile?.fetchUserData() as Any]) { (error, _) in
            if let error = error {
                print(error)
                return
            }
            print("Данныe сохранены в Firebase")
            self.openMainViewController()
        }
        
        
    }
    
}
