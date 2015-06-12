//
//  EmptyCommentTableViewCell.swift
//  ZhiHuDaily-Swift
//
//  Created by SUN on 15/6/12.
//  Copyright (c) 2015年 SUN. All rights reserved.
//

import UIKit

class EmptyCommentTableViewCell: UITableViewCell {

    @IBOutlet weak var emptyImageView: UIImageView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
