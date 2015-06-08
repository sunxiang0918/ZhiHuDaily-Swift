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
        
        let offsetY = Float(scrollView.contentOffset.y)
        let contentHeight = Float(scrollView.contentSize.height)
        let frameHeight = Float(scrollView.frame.height)
        
        //这部分代码是为了 限制下拉滑动的距离的.当到达scrollHeight后,就不允许再继续往下拉了
        if -offsetY>SCROLL_HEIGHT{
            //表示到顶了,不能再让他滑动了,思路就是让offset一直保持在最大值. 并且 animated 动画要等于false
            scrollView.setContentOffset(CGPointMake(CGFloat(0), CGFloat(-SCROLL_HEIGHT)), animated: false)
            return
        }else if offsetY > contentHeight-frameHeight+SCROLL_HEIGHT {
            //表示到底了,不能再让他滑动了,思路就是让offset一直保持在最大值. 并且 animated 动画要等于false
            scrollView.setContentOffset(CGPointMake(CGFloat(0), CGFloat(contentHeight-frameHeight+SCROLL_HEIGHT)), animated: false)
            return
        }
        
    }
    

}
