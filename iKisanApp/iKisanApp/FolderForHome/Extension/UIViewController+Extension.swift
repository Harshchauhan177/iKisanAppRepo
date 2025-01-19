//
//  UIViewController+Extension.swift
//  iKisanApp
//
//  Created by ANSHU NAGAR on 19/01/25.
//

import UIKit

extension UIViewController {
    
    static var identifier: String {
        return String(describing: self)
    }
    
    static func instantiate() -> Self {
      
        let storyboard = UIStoryboard(name: "Tab1Home", bundle: nil)
        
        return storyboard.instantiateViewController(withIdentifier: identifier) as! Self
        
        
        //  return UIStoryboard(name: identifier, bundle: nil).instantiateInitialViewController()!
    }
}
