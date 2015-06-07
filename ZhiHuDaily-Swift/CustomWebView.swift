//
//  CustomWebView.swift
//  ZhiHuDaily-Swift
//
//  Created by SUN on 15/6/7.
//  Copyright (c) 2015年 SUN. All rights reserved.
//

import UIKit

class CustomWebView: UIWebView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        println(scrollView)
        println("=======")
    }

}
