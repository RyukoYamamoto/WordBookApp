//
//  ResultCell.swift
//  WordBook
//
//  Created by 山本龍昂 on 2020/08/30.
//  Copyright © 2020 Ryuko Yamamoto. All rights reserved.
//

import UIKit

class ResultCell: UITableViewCell {

    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var meaningLabel: UILabel!
    @IBOutlet weak var resultLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
