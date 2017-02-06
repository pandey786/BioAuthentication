//
//  IdentifyViewController.swift
//  SpeakerRecognitionApp
//
//  Created by Pragati Dubey on 28/09/16.
//  Copyright © 2016 cognizant. All rights reserved.
//

import UIKit

class IdentifyViewController: ParentEnrollIdentifyViewController {
    
    // MARK: Properties
    @IBOutlet weak var btnRecord: UIButton!
    @IBOutlet var containerView: UIView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var tblView: UITableView!
    @IBOutlet var lblName: UILabel!
    
    // MARK: Instance variable
    var myDataSource: GeneralDataSource?
    
    // -------------------------------------------------------------------------------------------------------------------------
    // showIndicator
    
    func showIndicator (){
        self.containerView.isHidden = false
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
    }
    
    // -------------------------------------------------------------------------------------------------------------------------
    // hideIndicator
    
    func hideIndicator (){
        self.containerView.isHidden = true
        self.activityIndicator.isHidden = true
        self.activityIndicator.startAnimating()
    }
    
    // MARK: ViewController Life cycle methods
    // -------------------------------------------------------------------------------------------------------------------------
    // ViewDidLoad
    
    override func viewDidLoad() {
        // Call super
        super.viewDidLoad()
        
        // Set Title
        self.title = "Identify Voice"
        
        // Delegates setting
        self.myDataSource = PhrasestableDataSource()
        self.tblView.delegate = self.myDataSource
        self.tblView.dataSource = self.myDataSource
        
        // Register table view cell
        self.tblView.layer.borderColor = UIColor.white.cgColor
        self.tblView.layer.borderWidth = 1.0
        self.tblView.estimatedRowHeight = 68.0
        self.tblView.rowHeight = UITableViewAutomaticDimension
        
        // Register notifications
        NotificationCenter.default.addObserver(self, selector: #selector(self.verifyVoiceSucceed(_:)), name: NSNotification.Name(rawValue: Constants.NotificationsName.verifyVoiceForIdentificationSuccess), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.apiLimitAlert(_:)), name: NSNotification.Name(rawValue: Constants.NotificationsName.apiLimitExceeded), object: nil)
        
        self.containerView.isHidden = true
        self.activityIndicator.isHidden = true
    }
    
    // ----------------------------------------------------------------------------------------------------------------------------------
    // viewDidAppear
    
    override func viewWillAppear(_ animated:Bool) {
        // Call Super
        super.viewWillAppear(animated)
    }
    
    // MARK: - IBAction Method
    // -------------------------------------------------------------------------------------------------------------------------
    // actionOnButtonClick:
    
    @IBAction func actionOnButtonClick(_ sender: AnyObject) {
        
        switch sender.tag {
        case 1: // Record button
            if audioRecorder == nil {
                super.startRecording()
                let image:UIImage = UIImage(named: "Record")!
                self.btnRecord.setImage(image, for: .normal)
            } else {
                super.finishRecording(true)
                let image:UIImage = UIImage(named: "Stop")!
                self.btnRecord.setImage(image, for: .normal)
                
                self.showIndicator()
                
                // Verify
                let listArr:NSMutableArray = DataModelClass.instance.getEnrolledUsersList() as! NSMutableArray
                let idArr:NSMutableArray = NSMutableArray()
                
                // Add id to array
                for index in 0..<listArr.count {
                    let dict:NSDictionary = listArr[index] as! NSDictionary
                    let strGuuid:String = dict[Constants.ValuesKey.identificationKey] as! String
                    idArr.add(strGuuid)
                }
                let stringRepresentation = idArr.componentsJoined(by: ",")
                NetworkHelperClassIdentification.instance.verifyVoice(stringRepresentation)
            }
            break;
            
        default: ()
        break;
            
        }
    }
    
    // MARK: Notification Methods
    // -------------------------------------------------------------------------------------------------------------------------------
    // verifyVoiceSucceed:
    
    func verifyVoiceSucceed(_ inNotification:NSNotification) {
        let guuid:String = inNotification.object as! String
        self.hideIndicator()
        print(guuid)
        
        let myArr:NSMutableArray = DataModelClass.instance.getEnrolledUsersList() as! NSMutableArray
        for index in 0..<myArr.count {
            let dict:NSDictionary = myArr[index] as! NSDictionary
            let strGuuid = dict[Constants.ValuesKey.identificationKey] as! String
            if strGuuid == guuid {
                let firstName:String = dict["name"] as! String
                
                // let mssg:String = "This is \(firstName)"
                
                print("this is name \(strGuuid)")
                
                let appUtil :AppUtility =  AppUtility.sharedInstance() as! AppUtility
                appUtil.presentWelcomeAlert(forName: firstName, on: self)
                
                
                //                AlertHandler.instance.showInfoAlert(title: "Voice Verification", message: "Succeed")
                //                self.lblName.text = mssg
            }
        }
    }

    
    // -------------------------------------------------------------------------------------------------------------------------
    @IBAction func backButtonPressed(_ sender: Any) {
        
       self.dismiss(animated: true) { 
        }
    }
    // apiLimitAlert
    
    func apiLimitAlert(_ inNotification:NSNotification) {
        self.hideIndicator()
    }
    
}
