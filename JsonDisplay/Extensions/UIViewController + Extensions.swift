//
//  UIViewController + Extensions.swift
//  ImageSearch
//
//  Created by Mike Haydan on 09/06/2018.
//  Copyright © 2018 Misha Apps. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func alert(message: String) {
        let alertController = UIAlertController(title: "ImageSearch", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default) { (_) in
            alertController.dismiss(animated: true)
        }
        alertController.addAction(action)
        
        present(alertController, animated: true)
    }
}
