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


class LoginViewController: UIViewController {

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


//        if FBSDKAccessToken.currentAccessTokenIsActive() {
//            print("User is logged in")
//        }
        
        
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
                self.fetchFacebookFields()
                self.openMainViewController()
            }
        }
    }
    private func singIntoFirebase() {
        
        let accessToken = FBSDKAccessToken.current()
        
        guard let accessTokenString = accessToken?.tokenString else { return }
        
        let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
        
        Auth.auth().signInAndRetrieveData(with: credentials) { (user, error) in
            
            if let error = error {
                print("Something went wrong with our facebook user: ", error)
                return
            }
            
            print("Successfully logged in with our FB user: ", user!)
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
        FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, email, first_name, last_name, picture.type(large)"])?.start(completionHandler: { (_, result, error) in
//            if let error = error {
//                print(error)
//                return
//            }
//
//            if let userData = results as? [String: Any] {
//                print(userData)
//            }
//
            guard let userInfo = result as? [String: Any] else { return }
            print(userInfo)
            
            if let imageURL = ((userInfo["picture"] as? [String: Any])?["data"] as? [String: Any])?["url"] as? String {
                //Download image from imageURL
                print(imageURL)
            }
            
        })
        
        let request = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, email, picture.type(large)"])
        let _ = request?.start(completionHandler: { (connection, result, error) in
            guard let userInfo = result as? [String: Any] else { return } //handle the error
            
            //The url is nested 3 layers deep into the result so it's pretty messy
            if let imageURL = ((userInfo["picture"] as? [String: Any])?["data"] as? [String: Any])?["url"] as? String {
                //Download image from imageURL
            }
        })
        

    }
    
}
