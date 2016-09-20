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
    case refreshingDirectionNone
    case refreshingDirectionTop
    case refreshingDirectionBottom
}

/**
用于记录回调的方向

- RefreshDirectionTop:    向上回调
- RefreshDirectionBottom: 向下回调
*/
enum RefreshDirection {
    case refreshDirectionTop
    case refreshDirectionBottom
}

class RefreshControl:NSObject {
    
    /// 计算属性, 获取当前的状态
    var refreshingDirection : RefreshingDirections {
        get{
            return _refreshingDirection
        }
    }
    
    fileprivate var _refreshingDirection : RefreshingDirections = .refreshingDirectionNone
    
    var scrollView:UIScrollView     //被监听的滑动视图
    
    var delegate:RefreshControlDelegate     //刷新事件响应
    
    var topEnabled:Bool = false     //是否开启上部的下滑刷新
    
    var bottomEnabled:Bool = false  //是否开启下部的上拉刷新
    
    var enableInsetTop:Float = 65   //下滑刷新的距离
    
    var enableInsetBottom:Float = 65    //上拉刷新的距离
    
    var autoRefreshTop:Bool = false         //是否开启自动刷新,下拉到enableInsetTop位置自动刷新
    
    var autoRefreshBottom:Bool = false      //是否开启自动上拉刷新，上拉到enableInsetBottom位置自动上拉刷新
    
    fileprivate var topView:RefreshViewDelegate?     //顶部视图
    
    fileprivate var bottomView:RefreshViewDelegate?      //底部视图
    
    /**
    构造函数
    
    - parameter scrollView: 被监控的滑动视图
    - parameter delegate:   事件响应方
    
    - returns: 自身
    */
    init(scrollView:UIScrollView,delegate:RefreshControlDelegate){
        
        self.scrollView = scrollView
        self.delegate = delegate
        
        super.init()
        
        //增加scrollView的 contentSize 和 contentOffset 属性的 变化的 监听
        self.scrollView.addObserver(self, forKeyPath: "contentSize", options: [NSKeyValueObservingOptions.new, NSKeyValueObservingOptions.old], context: nil)
        self.scrollView.addObserver(self, forKeyPath: "contentOffset", options: [NSKeyValueObservingOptions.new, NSKeyValueObservingOptions.old, NSKeyValueObservingOptions.prior], context: nil)

    }
    
    deinit{
        self.scrollView.removeObserver(self, forKeyPath: "contentSize")
        self.scrollView.removeObserver(self, forKeyPath: "contentOffset")
        
    }
    
    /**
    实现KVO 事件监听的响应
    
    - parameter keyPath: 事件名字
    - parameter object:  发起对象
    - parameter change:  变化对象
    - parameter context: 上下文
    */

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
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
            
            if  self.refreshingDirection == .refreshingDirectionNone {
                //如果是Offset正在滑动 并且当前没有其他的刷新事件
                self.drogForChange(change!)
            }
        }
    }
    
    /**
    注册头部的显示视图,这个视图必须是继承自UIView,并且实现RefreshViewDelegate协议
    
    - parameter topView: 头部视图
    */
    func registeTopView<T>(_ topView:T) where T:RefreshViewDelegate{
        self.topView = topView
        
        self.topView?.refreshControl = self
    }
    
    /**
    注册底部的显示视图,这个视图必须是继承自UIView,并且实现RefreshViewDelegate协议
    
    - parameter topView: 底部视图
    */
    func registeBottomView<T>(_ bottomView:T) where T:RefreshViewDelegate{
        self.bottomView = bottomView
        
        self.bottomView?.refreshControl = self
    }
    
    /**
    通过程序调用 开始刷新
    
    - parameter direction: 刷新的方向事件
    */
    func startRefreshingDirection(_ direction:RefreshDirection){
        self.startRefreshingDirection(direction, animation: true)
    }
    
    /**
    通过程序调用 完成刷新
    
    - parameter direction: 刷新的方向事件
    */
    func finishRefreshingDirection(_ direction:RefreshDirection){
        self.finishRefreshingDirection(direction, animation: true)
    }
    
    //================以下是 private 方法=======================
    
    /**
    这个方法就是当触发滑动的时候,处理滑动的事件的
    
    - parameter change:
    */
    fileprivate func drogForChange(_ change:[AnyHashable: Any]){
        
        if self.scrollView.contentOffset.y<0 {
            
            if -Float(self.scrollView.contentOffset.y) >= self.enableInsetTop {
                //这个地方是 已经满足刷新的条件了.要开始刷新了
                if  self.autoRefreshTop || (self.scrollView.isDecelerating && !self.scrollView.isDragging) {
                    self.engageRefreshDirection(.refreshDirectionTop)
                }else {
                    self.canEngageRefreshDirection(.refreshDirectionTop)
                }
            }else{
                //这个是 还没有满足刷新条件的时候, 触发 topView的 动画
                self.didDisengageRefreshDirection(.refreshDirectionTop)
            }
        }
        
        if  self.scrollView.contentOffset.y>0 {
            
            let result = Float(self.scrollView.contentSize.height) + self.enableInsetBottom - Float(self.scrollView.bounds.height)
//            println("result:\(result)")
            if Float(self.scrollView.contentOffset.y) >= result {
                if  self.autoRefreshBottom || (self.scrollView.isDecelerating && !self.scrollView.isDragging){
                     self.engageRefreshDirection(.refreshDirectionBottom)
                }else {
                    self.canEngageRefreshDirection(.refreshDirectionBottom)
                }
            }else{
                self.didDisengageRefreshDirection(.refreshDirectionBottom)
            }
            
        }
    }

    /**
    允许开始刷新
    
    - parameter direction: 事件类型
    */
    fileprivate func canEngageRefreshDirection(_ direction:RefreshDirection) {
        
        if  let top = self.topView {
            top.canEngageRefresh(self.scrollView,direction: direction)
        }
        
        if  let bottom = self.bottomView {
            bottom.canEngageRefresh(self.scrollView,direction: direction)
        }
    }

    /**
    执行还没有进行刷新的时候,view的动画效果
    
    - parameter direction: 事件类型
    */
    fileprivate func didDisengageRefreshDirection(_ direction:RefreshDirection) {
        
        if  let top = self.topView {
            top.didDisengageRefresh(self.scrollView,direction:direction)
        }
        
        if  let bottom = self.bottomView {
            bottom.didDisengageRefresh(self.scrollView,direction:direction)
        }
        
    }
    
    /**
    开始真正的执行刷新命令
    
    - parameter direction: 事件类型
    */
    fileprivate func engageRefreshDirection(_ direction:RefreshDirection) {
        var edge:UIEdgeInsets = UIEdgeInsets.zero
        
        if  direction == .refreshDirectionTop {
            //修改事件类型为 正在执行下滑刷新
            self._refreshingDirection = .refreshingDirectionTop
            //获取下滑的距离
            let topH = self.enableInsetTop < 45 ? 45:self.enableInsetTop
            
            //配置scroll的偏移等待的位置
            edge = UIEdgeInsetsMake(CGFloat(topH), 0, 0, 0)
            
            //设置scrollView的contentInset
            if let t = self.topView {
                if  t.needContentInset(direction) {
                    self.scrollView.contentInset = edge
                }
            }
            
        }else if direction == .refreshDirectionBottom {
            let bottomH = self.enableInsetBottom < 45 ? 45:self.enableInsetBottom
            edge = UIEdgeInsetsMake(0, 0, CGFloat(bottomH), 0)
            self._refreshingDirection = .refreshingDirectionBottom
            
            //设置scrollView的contentInset
            if let t = self.bottomView {
                if  t.needContentInset(direction) {
                    self.scrollView.contentInset = edge
                }
            }
        }
        
        //执行刷新操作
        self.didEngageRefreshDirection(direction)
    }
    
    /**
    开始执行View的刷新事件
    
    - parameter direction: 刷新事件
    */
    fileprivate func didEngageRefreshDirection(_ direction:RefreshDirection){
        if  let top = self.topView {
            top.startRefreshing(direction)
        }
        
        if  let bottom = self.bottomView {
            bottom.startRefreshing(direction)
        }
        
        self.delegate.refreshControl(self, didEngageRefreshDirection: direction)
    }
    
    fileprivate func startRefreshingDirection(_ direction:RefreshDirection,animation:Bool) {
        
        var point = CGPoint.zero
        
        if  direction == .refreshDirectionTop {
            let topH = self.enableInsetTop < 45 ? 45:self.enableInsetTop
            point = CGPoint(x: 0, y: CGFloat(-topH))
        }else if direction == .refreshDirectionBottom {
            let height = max(self.scrollView.contentSize.height,self.scrollView.frame.height)
            let bottomH = self.enableInsetBottom < 45 ? 45:self.enableInsetBottom
            let result = height - self.scrollView.bounds.height + CGFloat(bottomH)
            point = CGPoint(x: 0, y: result)
        }
        
        self.scrollView.setContentOffset(point, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.25 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {

            self.engageRefreshDirection(direction)
        })
    }
    
    fileprivate func finishRefreshingDirection(_ direction:RefreshDirection,animation:Bool) {
        
//        UIView.animateWithDuration(0.25, animations: { () -> Void in
//            self.scrollView.contentInset = UIEdgeInsetsZero
//        })
        
        self._refreshingDirection = .refreshingDirectionNone
        
        if  let top = self.topView {
            top.finishRefreshing(direction)
        }
        
        if  let bottom = self.bottomView {
            bottom.finishRefreshing(direction)
        }
        
    }
    
}


