//
//  CommentSectionTitleView.swift
//  ZhiHuDaily-Swift
//
//  Created by SUN on 15/6/13.
//  Copyright (c) 2015年 SUN. All rights reserved.
//

import UIKit

class CommentSectionTitleView: UITableViewHeaderFooterView {

    static var isExpanded = false
    
    var delegate : CommentSectionTitleViewDelegate?
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var expandButton: UIButton!
    
    override func drawRect(rect: CGRect) {
        if  CommentSectionTitleView.isExpanded {
            self.expandButton.selected = true
        } else {
            self.expandButton.selected = false
        }
    }
    
    @IBAction func doExpandAction(sender: UIButton) {
        
        if self.expandButton.selected {
            CommentSectionTitleView.isExpanded = false
            delegate?.doSectionCollapse(self)
            self.expandButton.selected = false
        }else {
            CommentSectionTitleView.isExpanded = true
            delegate?.doSectionExpand(self)
            self.expandButton.selected = true
        }
        
    }
}

protocol CommentSectionTitleViewDelegate {
    
    func doSectionExpand(sender:CommentSectionTitleView)
    
    func doSectionCollapse(sender:CommentSectionTitleView)
    
}
