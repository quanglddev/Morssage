//
//  MainCell.swift
//  
//
//  Created by QUANG on 6/18/17.
//
//

import UIKit
import LTMorphingLabel

class MainCell: UITableViewCell {
    
    @IBOutlet weak var lblName: LTMorphingLabel!
    @IBOutlet weak var lblText: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
