//
//  ListedUserTableViewCell.swift
//  SpeakerRecognitionApp
//
//  Created by Pragati Dubey on 04/10/16.
//  Copyright © 2016 cognizant. All rights reserved.
//

import UIKit

class ListedUserTableViewCell: UITableViewCell {

    // MARK: Properties
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var btnRecord: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
