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
        
        /// 设置scrollView 委托为自己
        self.scrollView.delegate = self
        
        var pageNumber = 0
        /// 设置弹出内容的宽度
        if  rect.width < 600 {
            pageNumber = 2
        }else {
            pageNumber = 1
        }
        
        contentViewWidth.constant = rect.width * CGFloat(pageNumber) - 30
        
        self.pageControl.numberOfPages = pageNumber
        
        self.pageControl.hidesForSinglePage = true
    }
    
    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var contentViewWidth: NSLayoutConstraint!
    @IBOutlet weak var contentView: UIView!
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        //滑动的时候 进行pageControl的控制
        
        let pageWidth = self.scrollView.frame.size.width
        
        // 计算页数
        let page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1
        
        self.pageControl.currentPage = Int(page)
        self.pageControl.updateCurrentPageDisplay()
    }
    
    @IBAction func changeCurrentPage(sender: UIPageControl) {
        //pageControl的页数变化的时候,反过来控制scrollView的滑动
        
        let page = pageControl.currentPage

        var width:CGFloat,height:CGFloat
        
        width = scrollView.frame.size.width
        height = scrollView.frame.size.height
        
        let frame = CGRectMake(width * CGFloat(page), 0, width, height)
        
        scrollView.scrollRectToVisible(frame, animated: true)
    }
    
    /// 执行取消操作
    @IBAction func doCancelAction(sender: UIButton) {
        if let handel = self.cancelHandel {
            handel()
        }
    }
    
    /// 取消处理的 闭包.由外部来定义操作
    var cancelHandel:(()->Void)?
}


