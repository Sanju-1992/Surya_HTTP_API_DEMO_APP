//
//  UserItem.swift
//  HttpPostApiDemo_Surya
//
//  Created by Toor, Sanju on 30/01/19.
//  Copyright © 2019 Toor, Sanju. All rights reserved.
//

import CoreData

class Users: NSManagedObject {

    @NSManaged var firstName: String
    @NSManaged var lastName: String
    @NSManaged var  emailID: String
    @NSManaged var imageUrl: String

    func update(with jsonDictionary: [String: Any]) throws {
        guard let firstName = jsonDictionary["firstName"] as? String,
            let lastName = jsonDictionary["lastName"] as? String,
            let imageUrl = jsonDictionary["imageUrl"] as? String,
            let emailID = jsonDictionary["emailId"] as? String
            else {
                throw NSError(domain: "", code: 100, userInfo: nil)
        }

        self.firstName = firstName
        self.lastName = lastName
        self.emailID = emailID
        self.imageUrl = imageUrl
    }

}
