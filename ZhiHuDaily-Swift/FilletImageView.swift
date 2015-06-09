//
//  FilletImageView.swift
//  ZhiHuDaily-Swift
//
//  Created by SUN on 15/6/9.
//  Copyright (c) 2015年 SUN. All rights reserved.
//

import UIKit

class FilletImageView: UIImageView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        //设置圆角
        self.clipsToBounds = true
        
        //self.layer表示的就是整个UI组件的边界或边缘.
        //self.frame表示的就是 UI组件的框架.  self.frame.size.width表示的就是 UI组件框架的大小的宽
        self.layer.cornerRadius = self.frame.size.width / 2
        
//        //设置边框.边框颜色是白色,透明度70%. 然后边框厚度是4DDI
//        self.layer.borderWidth = 4
//        self.layer.borderColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.7).CGColor
    }

}
