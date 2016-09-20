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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func doExpandAction(_ sender: UIButton) {
        
        if self.expandButton.isSelected {
            delegate?.doCollapse(self)
            self.expandButton.isSelected = false
        }else {
            delegate?.doExpand(self)
            self.expandButton.isSelected = true
        }
        
    }
}

protocol CommonListTableViewCellDelegate{
    
    func doExpand(_ sender:CommonListTableViewCell)
    
    func doCollapse(_ sender:CommonListTableViewCell)
    
}
