//
//  CommonListTableViewCell.swift
//  ZhiHuDaily-Swift
//
//  Created by SUN on 15/6/10.
//  Copyright (c) 2015年 SUN. All rights reserved.
//

import UIKit

class CommonListTableViewCell: UITableViewCell {

    var delegate : CommonListTableViewCellDelegate?
    
    @IBOutlet weak var avatorImage: FilletImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var voteNumberLabel: UILabel!
    @IBOutlet weak var expandButton: UIButton!
    @IBOutlet weak var replayCommentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func doExpandAction(sender: UIButton) {
        
        if self.expandButton.selected {
            delegate?.doCollapse(self)
            self.expandButton.selected = false
        }else {
            delegate?.doExpand(self)
            self.expandButton.selected = true
        }
        
    }
}

protocol CommonListTableViewCellDelegate{
    
    func doExpand(sender:CommonListTableViewCell)
    
    func doCollapse(sender:CommonListTableViewCell)
    
}
