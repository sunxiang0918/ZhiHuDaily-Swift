//
//  NewsListVO.swift
//  ZhiHuDaily-Swift
//
//  Created by SUN on 15/5/30.
//  Copyright (c) 2015年 SUN. All rights reserved.
//

import Foundation

/**
*  用于保存新闻列表中的一条信息的Model
*/
struct NewsVO {
    
    /// 列表缩略图, 可能没有
    let images : [String]?
    
    /// 标题
    let title : String
    
    /// 类型,作用未知
    let type : Int = 0
    
    /// 新闻ID
    let id :Int
    
    /// 无用
    let gaPrefix : Int?
    
    let multipic : Bool

    
    init(id:Int,title:String,images:[String]? = nil,multipic:Bool? = false,gaPrefix:Int? = nil) {
        self.id = id
        self.title = title
        self.images = images
        self.multipic = multipic ?? false
        self.gaPrefix = gaPrefix
    }
    
}

class NewsListVO {
    
    var date : Int!
    
    var topNews : [NewsVO]?
    
    var news : [NewsVO]?
    
    init(){
    }
    
    init(date:Int,news:[NewsVO]?,topNews:[NewsVO]?){
        self.date = date
        
        self.topNews = topNews
        
        self.news = news
    }
}