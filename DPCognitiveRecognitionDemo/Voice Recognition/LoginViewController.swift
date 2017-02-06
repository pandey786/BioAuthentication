//
//  LoginViewController.swift
//  SpeakerIdentification
//
//  Created by MSP on 26/12/16.
//  Copyright © 2016 cognizant. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController , UITextFieldDelegate,NDIntroViewDelegate {
    
    public func launchAppButtonPressed() {
        UIView.animate(withDuration: 0.7, animations: {
            self.introView.alpha = 0;
        }) { (finished) in
            self.introView.removeFromSuperview()
        }
    }
    
    
    @IBOutlet weak var voiceAuthenticationButton: UIButton!
    @IBOutlet weak var faceRecView: UIView!
    @IBOutlet weak var voiceAuthView: UIView!
    @IBOutlet weak var faceRecognitionButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var memberNumberTextField: UITextField!
    var introView = NDIntroView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        memberNumberTextField.delegate = self
        passwordTextField.delegate = self
        setLeftImage()
        
        startInto()
        
        //setCornerRadius()
    }
    
    func startInto(){
        let pageContentArray = [[kNDIntroPageTitle : "Intro View",
                                 kNDIntroPageDescription : "Welcome to Cognitive Recognition Demo App by Barclays.",
                                 kNDIntroPageImageName : "parallax"
            ],
                                [kNDIntroPageTitle : "Work-It-Out",
                                 kNDIntroPageDescription : "A great App to create your own personal workout and get instructed by your phone.",
                                 kNDIntroPageImageName : "workitout"
            ],
                                [kNDIntroPageTitle : "ColorSkill",
                                 kNDIntroPageDescription : "A small game while waiting for the bus. Easy, quick and addictive.",
                                 kNDIntroPageImageName : "colorskill"
            ],
                                [kNDIntroPageTitle : "Appreciate",
                                 kNDIntroPageDescription : "A little helper to make your life happier. Soon available on the AppStore",
                                 kNDIntroPageImageName : "appreciate"
            ],
                                [kNDIntroPageTitle : "Do you like it?",
                                 kNDIntroPageImageName : "firstImage",
                                 kNDIntroPageTitleLabelHeightConstraintValue : 0,
                                 kNDIntroPageImageHorizontalConstraintValue : -40
            ]
        ];
        
        self.introView = NDIntroView.init(frame: self.view.frame, parallaxImage: UIImage.init(named: "parallaxBgImage"), andData: pageContentArray)
        
        self.introView.delegate = self;
        self.view.addSubview(self.introView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Set Image in TextField
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        setCornerRadius()
    }
    func setLeftImage() {
        
        let paddingView = UIView(frame:CGRect(x: 0, y: 0, width: 30, height: 30))
        memberNumberTextField.leftViewMode = UITextFieldViewMode.always
        memberNumberTextField.placeholder="Membership number"
        let imageView = UIImageView(frame: CGRect(x: 10, y: 8, width: 14, height: 14))
        let image = UIImage(named: "user@1x")
        imageView.image = image
        paddingView.addSubview(imageView)
        memberNumberTextField.leftView=paddingView;
        
        let passwordPaddingView = UIView(frame:CGRect(x: 0, y: 0, width: 30, height: 30))
        passwordTextField.leftViewMode = UITextFieldViewMode.always
        passwordTextField.placeholder="Password"
        let passwordImageView = UIImageView(frame: CGRect(x: 10, y: 8, width: 14, height: 14))
        let passwordImage = UIImage(named: "lock@1x")
        passwordImageView.image = passwordImage
        passwordPaddingView.addSubview(passwordImageView)
        passwordTextField.leftView=passwordPaddingView;
    }
    
    //MARK: - Set Corner Radius
    func setCornerRadius() {
        voiceAuthView.layer.cornerRadius = 42.0
        voiceAuthenticationButton.layer.cornerRadius = 42.0
        voiceAuthView.layer.borderWidth = 1
        voiceAuthView.layer.borderColor = UIColor(red:46/255.0, green:176/255.0, blue:229/255.0, alpha: 1.0).cgColor
        
        
        faceRecView.layer.cornerRadius = 42.0
        faceRecognitionButton.layer.cornerRadius = 42.0
        faceRecView.layer.borderWidth = 1
        faceRecView.layer.borderColor = UIColor(red:46/255.0, green:176/255.0, blue:229/255.0, alpha: 1.0).cgColor
        
        loginButton.layer.cornerRadius = 3.0
        
        
        
    }
    
    //MARK: TextField Delegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        let paddingView = UIView(frame:CGRect(x: 0, y: 0, width: 30, height: 30))
        memberNumberTextField.rightViewMode = UITextFieldViewMode.always
        let imageView = UIImageView(frame: CGRect(x: -5, y: 5, width: 22, height: 22))
        if memberNumberTextField.text == "123456" {
            let image = UIImage(named: "correct@1x")
            imageView.image = image
            paddingView.addSubview(imageView)
            memberNumberTextField.rightView=paddingView;
            
        }
        else {
            let image = UIImage(named: "incorrect@1x")
            imageView.image = image
            paddingView.addSubview(imageView)
            memberNumberTextField.rightView=paddingView;
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        memberNumberTextField.resignFirstResponder();
        passwordTextField.resignFirstResponder();
        return true;
    }
    //MARK: Login Button Action
    @IBAction func loginButtonAction(_ sender: AnyObject) {
        if memberNumberTextField.text == "123456" && passwordTextField.text == "123456" {
            
            let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as? HomeViewController
            self.navigationController?.pushViewController(homeVC!, animated: false)
            
        }
        else {
            
            let alert = UIAlertController(title: "Wrong Credential", message: "Wrong Credentials", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            //memberNumberTextField.text = nil
            //passwordTextField.text = nil
            
        }
        
    }
    
    @IBAction func unwindToMenu(segue: UIStoryboardSegue) {
    
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
