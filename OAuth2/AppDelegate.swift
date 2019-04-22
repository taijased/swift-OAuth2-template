//
//  AppDelegate.swift
//  OAuth2
//
//  Created by Maxim Spiridonov on 07/04/2019.
//  Copyright © 2019 Maxim Spiridonov. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import Firebase
import GoogleSignIn

let primaryColor = UIColor(hexValue: "#6FCF97", alpha: 1)!
let secondaryColor = UIColor(red: 107/255, green: 148/255, blue: 230/255, alpha: 1)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FBSDKApplicationDelegate.sharedInstance()?.application(application, didFinishLaunchingWithOptions: launchOptions)
        FirebaseApp.configure()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
       /* let appId = FBSDKSettings.appID()
        
        if url.scheme != nil && url.scheme!.hasPrefix("fb\(appId)") && url.host ==  "authorize" {
            return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
        }
        
        return false */
        
        
        
        return GIDSignIn.sharedInstance()
            .handle(url,
                    sourceApplication:options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                    annotation: [:])
    }
    

}


