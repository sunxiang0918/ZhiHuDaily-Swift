//
//  RefreshViewDelegate.swift
//  ZhiHuDaily-Swift
//
//  Created by SUN on 15/5/29.
//  Copyright (c) 2015年 SUN. All rights reserved.
//

import Foundation

protocol RefreshViewDelegate {
    
    /**
    重新设置Layout
    */
    func resetLayoutSubViews()
    
    /**
    松开可刷新
    */
    func canEngageRefresh()
    
    /**
    松开返回
    */
    func didDisengageRefresh()
    
    /**
    开始刷新
    */
    func startRefreshing()
    
    /**
    结束刷新
    */
    func finishRefreshing()
    
}