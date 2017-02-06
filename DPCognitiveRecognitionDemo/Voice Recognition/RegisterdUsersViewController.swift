//
//  RegisterdUsersViewController.swift
//  SpeakerRecognitionApp
//
//  Created by Pragati Dubey on 28/09/16.
//  Copyright © 2016 cognizant. All rights reserved.
//

import UIKit
import AVFoundation

class RegisterdUsersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Property variable
    @IBOutlet var tblView: UITableView!
    
    // MARK: Instance variable
    var itemListArr:NSArray = NSArray()
    var playedAudioArr:NSMutableArray = NSMutableArray()
    
    let textCellIdentifier = "contentCell"
    var player:AVAudioPlayer?
    var lastSelectedID:String!
    
    // MARK: Custom Methods
    // -------------------------------------------------------------------------------------------------------------------------
    // calculateHeightForString
    
    func calculateHeightForString(_ inString:String) -> CGFloat {
        let messageString = inString
        let attributes = [ NSFontAttributeName: UIFont.systemFont(ofSize: 16)]
        let attrString:NSAttributedString? = NSAttributedString(string: messageString, attributes: attributes)
        let rect:CGRect = (attrString?.boundingRect(with: CGSize.init(width: 160, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil))!
        let requredSize:CGRect = rect
        return requredSize.height
    }
    
    // MARK: ViewController Life cycle methods
    // -------------------------------------------------------------------------------------------------------------------------T
    // ViewDidLoad
    
    override func viewDidLoad() {
        // Call super
        super.viewDidLoad()
        
        self.title = "Enrolled Users"
        
        self.navigationController?.navigationBar.isHidden = false

        // Register table view cell
        self.tblView.layer.borderColor = UIColor.white.cgColor
        self.tblView.layer.borderWidth = 1.0

        self.tblView.dataSource = self
        self.tblView.delegate = self
        self.tblView.estimatedRowHeight = 68.0
        self.tblView.rowHeight = UITableViewAutomaticDimension
        
        // Get users list
        itemListArr = DataModelClass.instance.getEnrolledUsersList()
        self.tblView.reloadData()
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
    
    func actionOnButtonClick(_ sender: AnyObject) {
        
        let row = sender.tag
        let dict:NSDictionary =  itemListArr[row!] as! NSDictionary
        let keyid:String = dict[Constants.ValuesKey.identificationKey] as! String
        let audioPath = DataModelClass.instance.getUserAudio(guuid: keyid)
        
        let selectedIndex:NSNumber = NSNumber.init(value: row!)
        
        AlertHandler.instance.showInfoAlert(title: "Playing Audio", message: "Audio has been started ....")
        if playedAudioArr.contains(selectedIndex) {
            player?.stop()
            playedAudioArr.remove(selectedIndex)
        }
        else{
            playedAudioArr.removeAllObjects()
            playedAudioArr.add(selectedIndex)
            if player != nil {
                player?.stop()
                player = nil

            }
            do {
                player = try AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: audioPath) as URL)
                player?.play()
            }
            catch {
                print("Something bad happened. Try catching specific errors to narrow things down")
            }
        }
        
        self.tblView.reloadData()
    }
    
    
    // MARK: TableView Delegates & Data Source
    
    // ------------------------------------------------------------------------------------------------------
    // numberOfSectionsInTableView
    
    internal func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // ------------------------------------------------------------------------------------------------------
    // numberOfRowsInSection
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.itemListArr.count
    }
    
    // ------------------------------------------------------------------------------------------------------
    // cellForRowAtIndexPath
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath as IndexPath)
        
        let cell:ListedUserTableViewCell = self.tblView.dequeueReusableCell(withIdentifier: textCellIdentifier) as! ListedUserTableViewCell
        
        let row = indexPath.row
        let dict:NSDictionary =  itemListArr[row] as! NSDictionary
        let name:String = dict["name"] as! String
       // let keyid:String = dict[Constants.ValuesKey.identificationKey] as! String
        let nameStr = "Name: \(name)"
        
        cell.btnRecord.addTarget(self, action: #selector(self.actionOnButtonClick(_:)), for: .touchUpInside)
        cell.btnRecord.tag = row
        
        let selectedIndex:NSNumber = NSNumber.init(value: row)

        if playedAudioArr.contains(selectedIndex) {
            let image:UIImage = UIImage(named: "Record")!
            cell.btnRecord.setImage(image, for: .normal)
        }
        else{
            let image:UIImage = UIImage(named: "Stop")!
            cell.btnRecord.setImage(image, for: .normal)
        }
      
        // Items
        cell.lblName?.text = nameStr
        cell.lblName?.sizeToFit()
        cell.lblName?.numberOfLines = 0
        
        cell.selectionStyle = .none

        // Return
        return cell
    }
    
    // ------------------------------------------------------------------------------------------------------------------------------------------
    // heightForRowAtIndexPath
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    // ------------------------------------------------------------------------------------------------------------------------------------------
    // didSelectRowAtIndexPath:
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
