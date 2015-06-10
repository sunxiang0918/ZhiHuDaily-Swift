//
//  CommonListTableViewCell.swift
//  ZhiHuDaily-Swift
//
//  Created by SUN on 15/6/10.
//  Copyright (c) 2015年 SUN. All rights reserved.
//

import UIKit

class CommonListTableViewCell: UITableViewCell {

    @IBOutlet weak var avatorImage: FilletImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var voteNumberLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
