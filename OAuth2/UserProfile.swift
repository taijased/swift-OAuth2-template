//
//  UserProfile.swift
//  OAuth2
//
//  Created by Maxim Spiridonov on 07/04/2019.
//  Copyright © 2019 Maxim Spiridonov. All rights reserved.
//

import Foundation

struct UserProfile {
    let id: String?
    let name: String?
    let lastName: String?
    let firstName: String?
    let email: String?
    let picture: String?

    
    init (id: String?, name: String?, lastName: String?, firstName: String?, email: String?, picture: String?) {
    
        self.id = id
        self.name = name
        self.lastName = lastName
        self.firstName = firstName
        self.email = email
        self.picture = picture

    }
    init (data: [String: Any?]) {
        self.id = data["id"] as? String
        self.name = data["name"] as? String
        self.lastName = data["last_name"] as? String
        self.firstName = data["first_name"] as? String
        self.email = data["email"] as? String
        self.picture  = ((data["picture"] as? [String: Any])?["data"] as? [String: Any])?["url"] as? String
    }
    
    init (data: [String: Any?], _ firebase: Bool) {
        self.id = data["id"] as? String
        self.name = data["name"] as? String
        self.lastName = data["last_name"] as? String
        self.firstName = data["first_name"] as? String
        self.email = data["email"] as? String
        self.picture  = data["picture"] as? String
    }
    
    
    func fetchUserData() -> [String: Any] {
    
        let userData = ["id": self.id ,
                        "name": self.name,
                        "last_name": self.lastName,
                        "first_name": self.firstName,
                        "email": self.email,
                        "picture": self.picture]
    
        return userData as [String : Any]
    }
}
