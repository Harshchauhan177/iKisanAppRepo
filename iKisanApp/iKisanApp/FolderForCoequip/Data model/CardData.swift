//
//  CardData.swift
//  iKisanApp
//
//  Created by chandan kumar on 21/01/25.
//

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
