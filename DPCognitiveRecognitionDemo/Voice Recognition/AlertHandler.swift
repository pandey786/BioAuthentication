//
//  AlertHandler.swift
//  SpeakerRecognitionApp
//
//  Created by Pragati Dubey on 20/09/16.
//  Copyright © 2016 cognizant. All rights reserved.
//

import UIKit

class AlertHandler: NSObject{
    
    static let  instance = AlertHandler()
    
    func showInfoAlert(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
            
        }
        alertController.addAction(OKAction)
        
        // Present it
        let rootViewController = UIApplication.shared.keyWindow!.rootViewController
        rootViewController!.present(alertController, animated: true, completion:nil)
    }
}
