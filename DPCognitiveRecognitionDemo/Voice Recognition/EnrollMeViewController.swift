//
//  EnrollMeViewController.swift
//  SpeakerRecognitionApp
//
//  Created by Pragati Dubey on 28/09/16.
//  Copyright © 2016 cognizant. All rights reserved.
//

import UIKit

class EnrollMeViewController: ParentEnrollIdentifyViewController {
    
    // MARK: Properties
    var personNameStr : String!
    @IBOutlet weak var txtFldName: UITextField!
    @IBOutlet weak var btnRecord: UIButton!
    @IBOutlet var containerView: UIView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var tblView: UITableView!
    
    // MARK: Instance variable
    var count:Int = 0
    var myDataSource: GeneralDataSource?
    var indetificationGUUID:String!
    
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
        self.title = "Enroll Voice"
        
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
        NotificationCenter.default.addObserver(self, selector: #selector(self.enrollVoiceSucceed(_:)), name: NSNotification.Name(rawValue: Constants.NotificationsName.enrollIdentificationVoiceSuccess), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.createIdetificationProfileSucceed(_:)), name: NSNotification.Name(rawValue: Constants.NotificationsName.createIdentificationProfileSuccess), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.apiLimitAlert(_:)), name: NSNotification.Name(rawValue: Constants.NotificationsName.apiLimitExceeded), object: nil)
        
        self.containerView.isHidden = true
        self.activityIndicator.isHidden = true
    }
    
    // ----------------------------------------------------------------------------------------------------------------------------------
    // viewDidAppear
    
    override func viewWillAppear(_ animated:Bool) {
        // Call Super
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
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
                
                // Validate then proceed
                var firstName:String = self.personNameStr! as String
                firstName = firstName.trimmingCharacters(in: .whitespaces)
                
                var errString:String?
                if firstName.characters.count == 0 {
                    errString = "Please enter your first name"
                    AlertHandler.instance.showInfoAlert(title: "Alert", message: errString!)
                }
                else{
                    // Call APi for create profile
                    self.showIndicator()
                    
                    // Create Identification ID
                    NetworkHelperClassIdentification.instance.createProfile()
                }
            }
            break;
            
        case 2: // Enroll Voice for indetification
            break;
            
        default: ()
        break;
            
        }
    }
    
    // MARK: - TextFieldDelegate Method
    // -------------------------------------------------------------------------------------------------------------------------
    // textFieldShouldReturn
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.txtFldName{
            textField.resignFirstResponder()
        }
        
        // return
        return true
    }
    
    // MARK: Touch Delegate Methods
    // -------------------------------------------------------------------------------------------------------------------------
    // touchesBegan
    
    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?){
        // End editing
        self.view.endEditing(true)
    }
    
    // MARK: Notification Methods
    // -------------------------------------------------------------------------------------------------------------------------
    // enrollVoiceSucceed
    
    func enrollVoiceSucceed(_ inNotification:NSNotification) {
        DataModelClass.instance.saveDetailsOfPerson(guuid: indetificationGUUID, nameStr: self.personNameStr!)
        DataModelClass.instance.saveUserAudio(guuid: indetificationGUUID)
        
        self.hideIndicator()
        self.performSegue(withIdentifier: "unwindToMenu", sender: nil)
    }
    
    // -------------------------------------------------------------------------------------------------------------------------
    // createIdetificationProfileSucceed
    
    func createIdetificationProfileSucceed(_ inNotification:NSNotification) {
        let userDict:NSDictionary = inNotification.object as! NSDictionary
        
        // Save the file
        indetificationGUUID = userDict[Constants.ValuesKey.identificationKey] as! String
        NetworkHelperClassIdentification.instance.enrollVoice(indetificationGUUID)
    }
    
    // -------------------------------------------------------------------------------------------------------------------------
    // apiLimitAlert
    
    func apiLimitAlert(_ inNotification:NSNotification) {
        self.hideIndicator()
    }
}
