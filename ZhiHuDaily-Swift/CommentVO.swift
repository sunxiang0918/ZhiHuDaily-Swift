//  评论的VO
//  CommentVO.swift
//  ZhiHuDaily-Swift
//
//  Created by SUN on 15/6/11.
//  Copyright (c) 2015年 SUN. All rights reserved.
//

import Foundation


class CommentVO {
    
    /// 作者名
    let author : String
    
    /// 内容
    let content : String
    
    /// 头像
    let avatar : String?
    
    /// 时间
    let time : Int
    
    /// 评论id
    let id : Int
    
    /// 喜欢数
    let likes : Int
    
    var replayTo : RefCommentVO?
    
    init(author:String,content:String,avatar:String?,time:Int,id:Int,likes:Int = 0){
        self.author = author
        self.content = content
        self.avatar = avatar
        self.time = time
        self.id = id
        self.likes = likes
    }
    
}

//关联的评论
class RefCommentVO {
    
    let content : String
    
    let status : Int
    
    let id : Int
    
    let author : String
    
    init(id:Int,author:String,content:String = "抱歉,原点评已经被删除",status:Int = 0) {
        self.id = id
        
        self.author = author
        
        self.content = content
        
        self.status = status
    }
}