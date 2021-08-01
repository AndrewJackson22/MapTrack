//
//  AlertController.swift
//  TraningMap
//
//  Created by Андрей Михайлов on 01.08.2021.
//

import UIKit

extension UIViewController {
    
    func alertAddAdress(title: String, placeholer: String, comlishionHandler: @escaping (String) -> Void) {
        
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let alertOk = UIAlertAction(title: "OK", style: .default) {(action) in
            let tfText = alertController.textFields?.first
            guard let text = tfText?.text else {return}
            comlishionHandler(text)
        }
        let alertCancel = UIAlertAction(title: "Cancel", style: .default)
        
        alertController.addTextField(configurationHandler: {(tf) in
            tf.placeholder = placeholer
        })
        alertController.addAction(alertOk)
        alertController.addAction(alertCancel)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func alertError(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertOk = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(alertOk)
        present(alertController, animated: true, completion: nil)
    }
}
