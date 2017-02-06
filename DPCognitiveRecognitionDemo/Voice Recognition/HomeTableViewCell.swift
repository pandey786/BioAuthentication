//
//  HomeTableViewCell.swift
//  SpeakerIdentification
//
//  Created by Pragati Dubey on 19/10/16.
//  Copyright © 2016 cognizant. All rights reserved.
//

import UIKit

class HomeTableViewCell: UITableViewCell {

    // MARK: Properties
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var arrowIcon: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
