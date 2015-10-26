//
//  CircleImage.swift
//  ZhiHuDaily-Swift
//
//  Created by SUN on 15/10/26.
//  Copyright © 2015年 SUN. All rights reserved.
//

import Foundation

class CircleImage: UIImageView {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        //设置圆角
        
        self.clipsToBounds = true
        
        self.layer.cornerRadius = self.frame.size.width / 2
    }
}