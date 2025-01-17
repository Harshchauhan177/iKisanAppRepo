//
//  User Data Model.swift
//  iKisanApp
//
//  Created by Batch - 2 on 15/01/25.
//

import Foundation

class currentUser {
    static let shared = currentUser()
    
    private init() {}
    
    var user: User?
}

struct User {
    let userID: UUID
    var name: String
    var phone: String
    var location: Location
    var selectedCrops: [UUID]
    var fieldArea: Double
    var groupID: UUID?
}

struct Location {
    
    
}


