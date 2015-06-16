//
//  SharePopupView.swift
//  ZhiHuDaily-Swift
//
//  Created by SUN on 15/6/16.
//  Copyright (c) 2015年 SUN. All rights reserved.
//

import UIKit

class SharePopupView: UIView,UIScrollViewDelegate {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override func drawRect(rect: CGRect) {
        
        self.scrollView.delegate = self
        
        println(self)
        println(rect)
        
    }
    
    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var pageControl: UIPageControl!
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        let pageWidth = self.scrollView.frame.size.width
        
        let page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1
        
        self.pageControl.currentPage = Int(page);
        self.pageControl.updateCurrentPageDisplay()
    }
    
    @IBAction func changeCurrentPage(sender: UIPageControl) {
        
        let page = pageControl.currentPage

        var width:CGFloat,height:CGFloat
        
        width = scrollView.frame.size.width;
        height = scrollView.frame.size.height;
        
        let frame = CGRectMake(width * CGFloat(page), 0, width, height)
        
        scrollView.scrollRectToVisible(frame, animated: true)
    }
}
