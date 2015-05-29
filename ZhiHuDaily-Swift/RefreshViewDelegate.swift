//
//  RefreshViewDelegate.swift
//  ZhiHuDaily-Swift
//
//  Created by SUN on 15/5/29.
//  Copyright (c) 2015年 SUN. All rights reserved.
//

import Foundation

protocol RefreshViewDelegate {
    
    var refreshControl:RefreshControl? {get set}
    
    /**
    重新设置Layout
    */
    func resetLayoutSubViews()
    
    /**
    松开可刷新的动画
    */
    func canEngageRefresh(scrollView:UIScrollView)
    
    /**
    松开返回的动画
    */
    func didDisengageRefresh(scrollView:UIScrollView)
    
    /**
    开始刷新的动画
    */
    func startRefreshing()
    
    /**
    结束刷新的动画
    */
    func finishRefreshing()
    
}
