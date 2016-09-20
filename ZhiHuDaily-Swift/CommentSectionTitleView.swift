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
    
    override func draw(_ rect: CGRect) {
        if  CommentSectionTitleView.isExpanded {
            self.expandButton.isSelected = true
        } else {
            self.expandButton.isSelected = false
        }
    }
    
    @IBAction func doExpandAction(_ sender: UIButton) {
        
        if self.expandButton.isSelected {
            CommentSectionTitleView.isExpanded = false
            delegate?.doSectionCollapse(self)
            self.expandButton.isSelected = false
        }else {
            CommentSectionTitleView.isExpanded = true
            delegate?.doSectionExpand(self)
            self.expandButton.isSelected = true
        }
        
    }
}

protocol CommentSectionTitleViewDelegate {
    
    func doSectionExpand(_ sender:CommentSectionTitleView)
    
    func doSectionCollapse(_ sender:CommentSectionTitleView)
    
}
