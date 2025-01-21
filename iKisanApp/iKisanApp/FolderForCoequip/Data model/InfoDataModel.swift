//
//  InfoDataModel.swift
//  iKisanApp
//
//  Created by chandan kumar on 22/01/25.
//

import UIKit

class InfoRow {
    var icon: UIImage?
    var title: String
    var inputText: String?
    var workingIcon: UIImage?
    
    init(icon: UIImage?, title: String, inputText: String?, workingIcon: UIImage?) {
        self.icon = icon
        self.title = title
        self.inputText = inputText
        self.workingIcon = workingIcon
    }
}
