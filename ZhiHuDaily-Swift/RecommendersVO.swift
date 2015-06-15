//
//  ReCommendersVO.swift
//  ZhiHuDaily-Swift
//
//  Created by SUN on 15/6/15.
//  Copyright (c) 2015年 SUN. All rights reserved.
//

import Foundation

class RecommendersVO {
    var itemCount = 0
    
    var items : [RecommenderVO]?
    
    init(itemCount:Int,items:[RecommenderVO]?){
        self.itemCount = itemCount
        self.items = items
    }
}

class RecommenderVO {
    var index : Int
    var author : String
    var recommenders : [RecommenderInfoVO]
    
    init(index:Int,author:String,recommenders : [RecommenderInfoVO] = []) {
        self.index = index
        self.author = author
        self.recommenders = recommenders
    }
}

class RecommenderInfoVO {
    var bio : String
    var token : String
    var id : Int
    var avatar:String
    var name:String
    
    init(id:Int,name:String,token:String,avatar:String,bio:String = ""){
        self.id = id
        self.name = name
        self.token = token
        self.avatar = avatar
        self.bio = bio
    }
}