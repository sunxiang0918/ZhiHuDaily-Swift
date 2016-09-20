//
//  RefreshBottomView.swift
//  ZhiHuDaily-Swift
//
//  Created by SUN on 15/6/1.
//  Copyright (c) 2015年 SUN. All rights reserved.
//

import Foundation

class RefreshBottomView:UIView,RefreshViewDelegate {
    
    fileprivate var _refreshControl:RefreshControl?     //关联的刷新Control
    
    let activityIndicatorView:UIActivityIndicatorView
    
    let loadingLabel:UILabel
    
    let promptLabel:UILabel
    
    override init(frame: CGRect) {
        activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
        loadingLabel = UILabel(frame: CGRect.zero)
        promptLabel = UILabel(frame: CGRect.zero)
        
        super.init(frame: frame)
        
        self.initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
        loadingLabel = UILabel(frame: CGRect.zero)
        promptLabel = UILabel(frame: CGRect.zero)
        
        super.init(coder: aDecoder)
        
        self.initView()
    }
    
    func initView() {
        self.backgroundColor = UIColor(red: 237.0/255.0, green: 237.0/255.0, blue: 237.0/255.0, alpha: 237.0/255.0)
        
        
        activityIndicatorView.hidesWhenStopped=true;
//        activityIndicatorView.color=
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(activityIndicatorView)
        
        loadingLabel.backgroundColor=UIColor.clear
        loadingLabel.font=UIFont.systemFont(ofSize: 13)
        loadingLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(loadingLabel)
        
        promptLabel.backgroundColor=UIColor.clear
        promptLabel.font=UIFont.systemFont(ofSize: 13)
        promptLabel.translatesAutoresizingMaskIntoConstraints = false
        promptLabel.textAlignment = NSTextAlignment.center
        self.addSubview(promptLabel)
        
        self.resetViews()
        self.resetLayoutSubViews()
    }
    
    
    func resetViews(){
        
        promptLabel.isHidden=false;
        promptLabel.text="上拉加载更多"
    
        loadingLabel.isHidden=true;
        loadingLabel.text="正在加载...";
    
        if  self.activityIndicatorView.isAnimating {
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
        
        let tempContraint = self.constraints

        if  tempContraint.count > 0 {
            self.removeConstraints(tempContraint)
        }
        
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            let aTop = NSLayoutConstraint(item: self.activityIndicatorView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 13)
            let aRight = NSLayoutConstraint(item: self.activityIndicatorView, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: -5)
            let aWidth = NSLayoutConstraint(item: self.activityIndicatorView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.width, multiplier: 0, constant: 35)
            let aHeight = NSLayoutConstraint(item: self.activityIndicatorView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.height, multiplier: 0, constant: 35)
        
            self.addConstraints([aTop,aRight,aWidth,aHeight])
            
            let tLeft = NSLayoutConstraint(item: self.loadingLabel, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
            let tTop = NSLayoutConstraint(item: self.loadingLabel, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0)
            let tRight = NSLayoutConstraint(item: self.loadingLabel, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.right, multiplier: 1, constant: 0)
            let tHeight = NSLayoutConstraint(item: self.loadingLabel, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.height, multiplier: 0, constant: 32)

            self.addConstraints([tLeft,tTop,tRight,tHeight])
            
            let viewsDictionary = ["promptLabel":self.promptLabel]
            
            let pHList = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[promptLabel]-0-|", options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary as [String : AnyObject])
            let pVList = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[promptLabel(==45)]", options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary  as [String : AnyObject])
            
            self.addConstraints(pHList)
            self.addConstraints(pVList)
        })
        
    }
    
    func needContentInset(_ direction:RefreshDirection) -> Bool{
        return false
    }
    
    /**
    松开可刷新的动画
    */
    func canEngageRefresh(_ scrollView:UIScrollView,direction:RefreshDirection){
        if  direction == RefreshDirection.refreshDirectionBottom{
            promptLabel.text="松开即可加载"
        }
    }
    
    /**
    松开返回的动画
    */
    func didDisengageRefresh(_ scrollView:UIScrollView,direction:RefreshDirection){
        if  direction == RefreshDirection.refreshDirectionBottom{
            self.resetViews()
        }
    }
    
    /**
    开始刷新的动画
    */
    func startRefreshing(_ direction:RefreshDirection){
        
        if  direction == RefreshDirection.refreshDirectionBottom{
            promptLabel.isHidden=true;
            loadingLabel.isHidden=false;
            self.activityIndicatorView.stopAnimating()
        }
        
    }
    
    /**
    结束刷新的动画
    */
    func finishRefreshing(_ direction:RefreshDirection){
        if  direction == RefreshDirection.refreshDirectionBottom{
            self.resetViews()
        }
    }
    
}
