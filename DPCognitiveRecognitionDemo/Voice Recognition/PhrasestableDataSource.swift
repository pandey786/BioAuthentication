//
//  PhrasestableDataSource.swift
//  SpeakerRecognitionApp
//
//  Created by Pragati Dubey on 28/09/16.
//  Copyright © 2016 cognizant. All rights reserved.
//

import UIKit

protocol GeneralDataSource: UITableViewDataSource, UITableViewDelegate {}

class PhrasestableDataSource: NSObject, GeneralDataSource {
    
    var itemListArr:NSArray = ["My voice is my passport verify me", "You can get in without your password", "You can activate security system now", "My voice is stronger than passwords"]
    let textCellIdentifier = "contentCell"
    
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
      //  let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath as IndexPath)
        
        let cell:ListedUserTableViewCell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier) as! ListedUserTableViewCell

        let row = indexPath.row
        let itemStr =  itemListArr[row] as? String
        
        // Items
        cell.lblName?.text = itemStr
        
        cell.selectionStyle = .none

        // Return
        return cell
    }
    
    // ------------------------------------------------------------------------------------------------------------------------------------------
    // heightForRowAtIndexPath
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    // ------------------------------------------------------------------------------------------------------------------------------------------
    // estimatedHeightForRowAt
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }


}
