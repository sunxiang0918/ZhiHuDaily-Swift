//
//  RefreshControl.swift
//  ZhiHuDaily-Swift
//
//  Created by SUN on 15/5/29.
//  Copyright (c) 2015年 SUN. All rights reserved.
//

import UIKit

/**
用于显示刷新方向的枚举

- RefreshingDirectionNone:   无刷新
- RefreshingDirectionTop:    下滑
- RefreshingDirectionBottom: 上拉
*/
enum RefreshingDirections {
    case RefreshingDirectionNone
    case RefreshingDirectionTop
    case RefreshingDirectionBottom
}

/**
用于记录回调的方向

- RefreshDirectionTop:    向上回调
- RefreshDirectionBottom: 向下回调
*/
enum RefreshDirection {
    case RefreshDirectionTop
    case RefreshDirectionBottom
}

class RefreshControl:NSObject {
    
    /// 计算属性, 获取当前的状态
    var refreshingDirection : RefreshingDirections {
        get{
            return _refreshingDirection
        }
    }
    
    private var _refreshingDirection : RefreshingDirections = .RefreshingDirectionNone
    
    var scrollView:UIScrollView     //被监听的滑动视图
    
    var delegate:RefreshControlDelegate     //刷新事件响应
    
    var topEnabled:Bool = false     //是否开启上部的下滑刷新
    
    var bottomEnabled:Bool = false  //是否开启下部的上拉刷新
    
    var enableInsetTop:Float = 65   //下滑刷新的距离
    
    var enableInsetBottom:Float = 65    //上拉刷新的距离
    
    var autoRefreshTop:Bool = false         //是否开启自动刷新,下拉到enableInsetTop位置自动刷新
    
    var autoRefreshBottom:Bool = false      //是否开启自动上拉刷新，上拉到enableInsetBottom位置自动上拉刷新
    
    private var topView:RefreshViewDelegate?     //顶部视图
    
    private var bottomView:RefreshViewDelegate?      //底部视图
    
    /**
    构造函数
    
    :param: scrollView 被监控的滑动视图
    :param: delegate   事件响应方
    
    :returns: 自身
    */
    init(scrollView:UIScrollView,delegate:RefreshControlDelegate){
        
        self.scrollView = scrollView
        self.delegate = delegate
        
        super.init()
        
        //增加scrollView的 contentSize 和 contentOffset 属性的 变化的 监听
        self.scrollView.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.New | NSKeyValueObservingOptions.Old, context: nil)
        self.scrollView.addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.New | NSKeyValueObservingOptions.Old | NSKeyValueObservingOptions.Prior, context: nil)

    }
    
    deinit{
        self.scrollView.removeObserver(self, forKeyPath: "contentSize")
        self.scrollView.removeObserver(self, forKeyPath: "contentOffset")
        
    }
    
    /**
    实现KVO 事件监听的响应
    
    :param: keyPath 事件名字
    :param: object  发起对象
    :param: change  变化对象
    :param: context 上下文
    */
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        
        if  "contentSize" == keyPath{
            //如果是scrollView的 contentSize 改变了大小
            
            if  self.topEnabled {
                //初始化上部视图
            }
            
            if  self.bottomEnabled {
                //初始化下部视图
            }
            
        }else if "contentOffset" == keyPath {
            //如果是scrollView进行了滑动
            
            if  self.refreshingDirection == .RefreshingDirectionNone {
                //如果是用户的滑动松开命令, 那就开始激活刷新事件
                
            }
        }
    }
    
    /**
    注册头部的显示视图,这个视图必须是继承自UIView,并且实现RefreshViewDelegate协议
    
    :param: topView 头部视图
    */
    func registeTopView<T:UIView,RefreshViewDelegate>(topView:T){
        
    }
    
    /**
    注册底部的显示视图,这个视图必须是继承自UIView,并且实现RefreshViewDelegate协议
    
    :param: topView 底部视图
    */
    func registeBottomView<T:UIView,RefreshViewDelegate>(bottomView:T){
        
    }
    
    /**
    开始刷新
    
    :param: direction 刷新的方向事件
    */
    func startRefreshingDirection(direction:RefreshDirection){
        self.startRefreshingDirection(direction, animation: true)
    }
    
    /**
    完成刷新
    
    :param: direction 刷新的方向事件
    */
    func finishRefreshingDirection(direction:RefreshDirection){
        self.finishRefreshingDirection(direction, animation: true)
    }
    
    //================以下是 private 方法=======================
    
    /**
    这个方法就是当触发滑动的时候,处理滑动的事件的
    
    :param: change
    */
    private func drogForChange(change:[NSObject : AnyObject]){
        
        if self.topEnabled && self.scrollView.contentOffset.y<0 {
            
            if Float(self.scrollView.contentOffset.y) < -self.enableInsetTop {
                if  self.autoRefreshTop || (self.scrollView.decelerating && !self.scrollView.dragging) {
                    //[self _engageRefreshDirection:RefreshDirectionTop];
                }else {
                    self.canEngageRefreshDirection(.RefreshDirectionTop)
                }
            }else{
                self.didDisengageRefreshDirection(.RefreshDirectionTop)
            }
        }
        
        if  self.bottomEnabled && self.scrollView.contentOffset.y>0 {
            
            let result = Float(self.scrollView.contentSize.height) + self.enableInsetBottom - Float(self.scrollView.bounds.height)
            
            if Float(self.scrollView.contentOffset.y) > result {
                if  self.autoRefreshBottom || (self.scrollView.decelerating && !self.scrollView.dragging){
                    //[self _engageRefreshDirection:RefreshDirectionBottom];
                }else {
                    self.canEngageRefreshDirection(.RefreshDirectionBottom)
                }
            }else{
                self.didDisengageRefreshDirection(.RefreshDirectionBottom)
            }
            
        }
    }

    private func canEngageRefreshDirection(direction:RefreshDirection) {
        
        if  direction == .RefreshDirectionTop {
            if  let top = self.topView {
                top.canEngageRefresh()
            }
        }else if direction == .RefreshDirectionBottom {
            if  let bottom = self.bottomView {
                bottom.canEngageRefresh()
            }
        }
        
    }

    private func didDisengageRefreshDirection(direction:RefreshDirection) {
        if  direction == .RefreshDirectionTop {
            if  let top = self.topView {
                top.didDisengageRefresh()
            }
        }else if direction == .RefreshDirectionBottom {
            if  let bottom = self.bottomView {
                bottom.didDisengageRefresh()
            }
        }
    }
    
    private func engageRefreshDirection(direction:RefreshDirection) {
        var edge:UIEdgeInsets = UIEdgeInsetsZero
        
        if  direction == .RefreshDirectionTop {
            self._refreshingDirection = .RefreshingDirectionTop
            let topH = self.enableInsetTop < 45 ? 45:self.enableInsetTop
            edge = UIEdgeInsetsMake(CGFloat(topH), 0, 0, 0)
        }else if direction == .RefreshDirectionBottom {
            let bottomH = self.enableInsetBottom < 45 ? 45:self.enableInsetBottom
            edge = UIEdgeInsetsMake(0, 0, CGFloat(bottomH), 0)
            self._refreshingDirection = .RefreshingDirectionBottom
        }
        self.scrollView.contentInset = edge
        
        self.didEngageRefreshDirection(direction)
    }
    
    private func didEngageRefreshDirection(direction:RefreshDirection){
        if  direction == .RefreshDirectionTop {
            if  let top = self.topView {
                top.startRefreshing()
            }
        }else if direction == .RefreshDirectionBottom {
            if  let bottom = self.bottomView {
                bottom.startRefreshing()
            }
        }
        
        self.delegate.refreshControl(self, didEngageRefreshDirection: direction)
    }
    
    private func startRefreshingDirection(direction:RefreshDirection,animation:Bool) {
        
        var point = CGPointZero
        
        if  direction == .RefreshDirectionTop {
            let topH = self.enableInsetTop < 45 ? 45:self.enableInsetTop
            point = CGPointMake(0, CGFloat(-topH))
        }else if direction == .RefreshDirectionBottom {
            let height = max(self.scrollView.contentSize.height,self.scrollView.frame.height)
            let bottomH = self.enableInsetBottom < 45 ? 45:self.enableInsetBottom
            let result = height - self.scrollView.bounds.height + CGFloat(bottomH)
            point = CGPointMake(0, result)
        }
        
        self.scrollView.setContentOffset(point, animated: true)
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(0.25 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
            //[strongSelf _engageRefreshDirection:direction];
        })
    }
    
    private func finishRefreshingDirection(direction:RefreshDirection,animation:Bool) {
        
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.scrollView.contentInset = UIEdgeInsetsZero
        })
        
        self._refreshingDirection = .RefreshingDirectionNone
        
        if  direction == .RefreshDirectionTop {
            if  let top = self.topView {
                top.finishRefreshing()
            }
        }else if direction == .RefreshDirectionBottom {
            if  let bottom = self.bottomView {
                bottom.finishRefreshing()
            }
        }
        
    }
    
}


