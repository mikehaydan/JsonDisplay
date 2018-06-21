//
//  UIView + Extensions.swift
//  JsonDisplay
//
//  Created by Mike Haydan on 21/06/2018.
//  Copyright © 2018 Misha Apps. All rights reserved.
//

import UIKit

extension UIView {
    
    class var nibName: String {
        return String(describing: self)
    }
    
    class var nib: UINib {
        return UINib(nibName: nibName, bundle: nil)
    }
}
