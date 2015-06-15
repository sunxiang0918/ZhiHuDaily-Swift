//
//  RecommenderTableViewCell.swift
//  ZhiHuDaily-Swift
//
//  Created by SUN on 15/6/15.
//  Copyright (c) 2015年 SUN. All rights reserved.
//

import UIKit

class RecommenderTableViewCell: UITableViewCell {

    @IBOutlet weak var userAvatorImage: FilletImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userDesLabel: UILabel!
    @IBOutlet weak var detailButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
