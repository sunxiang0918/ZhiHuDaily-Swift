//
//  RefreshBottomView.swift
//  ZhiHuDaily-Swift
//
//  Created by SUN on 15/6/1.
//  Copyright (c) 2015年 SUN. All rights reserved.
//

import Foundation

class RefreshBottomView:UIView,RefreshViewDelegate {
    
    private var _refreshControl:RefreshControl?     //关联的刷新Control
    
    let activityIndicatorView:UIActivityIndicatorView
    
    let loadingLabel:UILabel
    
    let promptLabel:UILabel
    
    override init(frame: CGRect) {
        activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        loadingLabel = UILabel(frame: CGRectZero)
        promptLabel = UILabel(frame: CGRectZero)
        
        super.init(frame: frame)
        
        self.initView()
    }
    
    required init(coder aDecoder: NSCoder) {
        activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        loadingLabel = UILabel(frame: CGRectZero)
        promptLabel = UILabel(frame: CGRectZero)
        
        super.init(coder: aDecoder)
        
        self.initView()
    }
    
    func initView() {
        self.backgroundColor = UIColor(red: 237.0/255.0, green: 237.0/255.0, blue: 237.0/255.0, alpha: 237.0/255.0)
        
        
        activityIndicatorView.hidesWhenStopped=true;
//        activityIndicatorView.color=
        activityIndicatorView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.addSubview(activityIndicatorView)
        
        loadingLabel.backgroundColor=UIColor.clearColor()
        loadingLabel.font=UIFont.systemFontOfSize(13)
        loadingLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.addSubview(loadingLabel)
        
        promptLabel.backgroundColor=UIColor.clearColor()
        promptLabel.font=UIFont.systemFontOfSize(13)
        promptLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        promptLabel.textAlignment = NSTextAlignment.Center
        self.addSubview(promptLabel)
        
        self.resetViews()
        self.resetLayoutSubViews()
    }
    
    
    func resetViews(){
        
        promptLabel.hidden=false;
        promptLabel.text="上拉加载更多"
    
        loadingLabel.hidden=true;
        loadingLabel.text="正在加载...";
    
        if  self.activityIndicatorView.isAnimating() {
            self.activityIndicatorView.stopAnimating()
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    //==================RefreshViewDelegate实现===============================
    
    var refreshControl:RefreshControl? {
        get{
            return _refreshControl
        }
        
        set{
            _refreshControl = newValue
        }
    }
    
    /**
    重新设置Layout
    */
    func resetLayoutSubViews(){
        
        let tempContraint = self.constraints()

        if  tempContraint.count > 0 {
            self.removeConstraints(tempContraint)
        }
        
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            let aTop = NSLayoutConstraint(item: self.activityIndicatorView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 13)
            let aRight = NSLayoutConstraint(item: self.activityIndicatorView, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: -5)
            let aWidth = NSLayoutConstraint(item: self.activityIndicatorView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Width, multiplier: 0, constant: 35)
            let aHeight = NSLayoutConstraint(item: self.activityIndicatorView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Height, multiplier: 0, constant: 35)
        
            self.addConstraints([aTop,aRight,aWidth,aHeight])
            
            let tLeft = NSLayoutConstraint(item: self.loadingLabel, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
            let tTop = NSLayoutConstraint(item: self.loadingLabel, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
            let tRight = NSLayoutConstraint(item: self.loadingLabel, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0)
            let tHeight = NSLayoutConstraint(item: self.loadingLabel, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Height, multiplier: 0, constant: 32)

            self.addConstraints([tLeft,tTop,tRight,tHeight])
            
            let viewsDictionary = [NSString(string:"promptLabel"):self.promptLabel]
            
            let pHList = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[promptLabel]-0-|", options: NSLayoutFormatOptions.allZeros, metrics: nil, views: viewsDictionary)
            let pVList = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[promptLabel(==45)]", options: NSLayoutFormatOptions.allZeros, metrics: nil, views: viewsDictionary)
            
            self.addConstraints(pHList)
            self.addConstraints(pVList)
        })
        
    }
    
    func needContentInset(direction:RefreshDirection) -> Bool{
        return false
    }
    
    /**
    松开可刷新的动画
    */
    func canEngageRefresh(scrollView:UIScrollView,direction:RefreshDirection){
        if  direction == RefreshDirection.RefreshDirectionBottom{
            promptLabel.text="松开即可加载"
        }
    }
    
    /**
    松开返回的动画
    */
    func didDisengageRefresh(scrollView:UIScrollView,direction:RefreshDirection){
        if  direction == RefreshDirection.RefreshDirectionBottom{
            self.resetViews()
        }
    }
    
    /**
    开始刷新的动画
    */
    func startRefreshing(direction:RefreshDirection){
        
        if  direction == RefreshDirection.RefreshDirectionBottom{
            promptLabel.hidden=true;
            loadingLabel.hidden=false;
            self.activityIndicatorView.stopAnimating()
        }
        
    }
    
    /**
    结束刷新的动画
    */
    func finishRefreshing(direction:RefreshDirection){
        if  direction == RefreshDirection.RefreshDirectionBottom{
            self.resetViews()
        }
    }
    
}