//
//  HomeViewController.swift
//  SpeakerRecognitionApp
//
//  Created by Pragati Dubey on 28/09/16.
//  Copyright © 2016 cognizant. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: Property variable
    @IBOutlet var tblView: UITableView!
    
    // MARK: Instance variable
    var itemListArr:[String] = ["Enroll Me", "View Status", "Identify"]
    let textCellIdentifier = "contentCell"
    
    // MARK: Custom Methods
    
    // MARK: ViewController Life cycle methods
    // -------------------------------------------------------------------------------------------------------------------------
    // ViewDidLoad
    
    override func viewDidLoad() {
        // Call super
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.topItem?.title = "Voice Authentication"
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.black]
        // Register table view cell
//        self.tblView.layer.borderColor = UIColor.white.cgColor
//        self.tblView.layer.borderWidth = 1.0
        self.tblView.dataSource = self
        self.tblView.delegate = self
        
        self.tblView.tableFooterView = UIView()
        //self.tblView.register(UITableViewCell.self, forCellReuseIdentifier: textCellIdentifier)
    }
    
    // ----------------------------------------------------------------------------------------------------------------------------------
    // viewDidAppear
    
    override func viewWillAppear(_ animated:Bool) {
        // Call Super
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
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
        //let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath as IndexPath) as UITableViewCell
        let cell:HomeTableViewCell = self.tblView.dequeueReusableCell(withIdentifier: textCellIdentifier) as! HomeTableViewCell
        
        let row = indexPath.row
        let itemStr =  itemListArr[row]
        
        // Items
        cell.lblName?.text = itemStr
        cell.imgIcon?.tintColor = UIColor.white
        
        if row == 0 {
            let image:UIImage = UIImage(named: "add_people")!
            cell.imgIcon?.image = image
        }
        else if row == 1{
            let image:UIImage = UIImage(named: "viewlist")!
            cell.imgIcon?.image = image
        }
        else{
            let image:UIImage = UIImage(named: "identify")!
            cell.imgIcon?.image = image
        }
        
        cell.selectionStyle = .none
        
        // Return
        return cell
    }
    
    // ------------------------------------------------------------------------------------------------------------------------------------------
    // heightForRowAtIndexPath
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // return
        return 50.0
    }
    
    // ------------------------------------------------------------------------------------------------------------------------------------------
    // didSelectRowAtIndexPath:
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Start segue with index of cell clicked
        if indexPath.row == 0 {
            let enrollMeVc = self.storyboard?.instantiateViewController(withIdentifier: "EnrollMeVC") as? EnrollMeViewController
            self.navigationController?.pushViewController(enrollMeVc!, animated: true)
        }
        else if indexPath.row == 1 {
            let registerUsersVC = self.storyboard?.instantiateViewController(withIdentifier: "RegisteredUsersListVC") as? RegisterdUsersViewController
            self.navigationController?.pushViewController(registerUsersVC!, animated: true)
        }
        else{
            let identifyVC = self.storyboard?.instantiateViewController(withIdentifier: "IdentifyVC") as? IdentifyViewController
            self.navigationController?.pushViewController(identifyVC!, animated: true)
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true) {
        }
    }
    
    // MARK: Storyboard delegate
    // ------------------------------------------------------------------------------------------------------------------------------------------
    //    prepare:
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}
