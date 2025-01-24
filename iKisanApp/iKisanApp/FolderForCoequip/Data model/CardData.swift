

import Foundation
import UIKit

struct CardData{
    let title: String
    let price: String
    let oldPrice: String?
    let rating: String
    let host: String
    let imageName: UIImage
}

class Person {
    var name: String
    var image: UIImage?
    
    init(name: String, image: UIImage?) {
        self.name = name
        self.image = image
    }
}
struct PersonList {
    var name: String
    var image: String
    var isSelected: Bool 
}

class pupil{
    static var allPeopleData: [PersonList] = [
            PersonList(name: "John Doe", image: "person1", isSelected: false),
            PersonList(name: "Jane Smith", image: "person2", isSelected: false),
            PersonList(name: "Paul Walker", image: "person3", isSelected: false),
            PersonList(name: "Robert Johnson", image: "person4", isSelected: false),
            PersonList(name: "Emily Davis", image:"person5", isSelected: false)
        ]
}
