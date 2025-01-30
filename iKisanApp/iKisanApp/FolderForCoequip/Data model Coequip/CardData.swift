

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

class Pupil{
    static var allPeopleData: [PersonList] = [
            PersonList(name: "Harsh Singh", image: "person1", isSelected: false),
            PersonList(name: "Vikash Kumar", image: "person2", isSelected: false),
            PersonList(name: "Ram pal", image: "person3", isSelected: false),
            PersonList(name: "Vicky ", image: "person4", isSelected: false),
            PersonList(name: "Rahul kumar", image:"person5", isSelected: false)
        ]
}
class MyRequestInfo {
   var name: String
    var image: String
    init(name: String, image: String) {
        self.name = name
        self.image = image
    }
}
