//
//  CommentControl.swift
//  ZhiHuDaily-Swift
//
//  Created by SUN on 15/6/11.
//  Copyright (c) 2015年 SUN. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON3

class CommentControl {
    
    /// 加载 长评论
    func loadLongComments(_ id:Int,complate:@escaping (_ longComments:[CommentVO]?)->Void,block:((_ error:NSError)->Void)? = nil){
        
        Alamofire.request(COMMENTS_URL+"\(id)/long-comments").responseJSON(options: JSONSerialization.ReadingOptions.mutableContainers){ response -> Void in
            if let result: Any = response.result.value {
                //转换成JSON
                let json = JSON(result)
                
                complate(self.convertJSON2VO(json))
            }
        }
    }
    
    /**
    加载更多的长评论
    
    - parameter newsId:
    - parameter beforeId:
    - parameter complate:
    */
    func loadMoreLongComments(_ newsId:Int,beforeId:Int,complate:@escaping (_ longComments:[CommentVO]?)->Void,block:((_ error:NSError)->Void)? = nil) {
        
        Alamofire.request(COMMENTS_URL+"\(newsId)/long-comments/before/\(beforeId)").responseJSON(options: JSONSerialization.ReadingOptions.mutableContainers) { response -> Void in
            if let result: Any = response.result.value {
                //转换成JSON
                let json = JSON(result)
                
                complate(self.convertJSON2VO(json))
            }
        }
        
    }

    
    /// 加载 短评论
    func loadShortComments(_ id:Int,complate:@escaping (_ shortComments:[CommentVO]?)->Void,block:((_ error:NSError)->Void)? = nil){
        
        Alamofire.request(COMMENTS_URL+"\(id)/short-comments").responseJSON(options: JSONSerialization.ReadingOptions.mutableContainers) { response -> Void in
            if let result: Any = response.result.value {
                //转换成JSON
                let json = JSON(result)
                
                complate(self.convertJSON2VO(json))
            }
        }
        
    }
    
    func loadMoreShortComments(_ newsId:Int,beforeId:Int,complate:@escaping (_ shortComments:[CommentVO]?)->Void,block:((_ error:NSError)->Void)? = nil) {
        
        Alamofire.request(COMMENTS_URL+"\(newsId)/short-comments/before/\(beforeId)").responseJSON(options: JSONSerialization.ReadingOptions.mutableContainers) { response -> Void in
            if let result: Any = response.result.value {
                //转换成JSON
                let json = JSON(result)
                
                complate(self.convertJSON2VO(json))
            }
        }
        
    }
    
    fileprivate func convertJSON2VO(_ json:JSON) -> [CommentVO]? {
        
        if  let comments = json["comments"].array {
            var vos:[CommentVO] = []
            for comment in comments {
                let author = comment["author"].string!
                let content = comment["content"].string!
                let avatar = comment["avatar"].string
                let time = comment["time"].int!
                let id = comment["id"].int!
                let likes = comment["likes"].int!
                
                let replay = comment["reply_to"]
                
                let vo = CommentVO(author: author, content: content, avatar: avatar, time: time, id: id, likes: likes)
                
                vos.append(vo)
                
                if replay.null == nil{
                    //表示有引用
                    let _status = replay["status"].int!
                    
                    if  _status == 0 {
                        let _content = replay["content"].string!
                        let _id = replay["id"].int!
                        let _author = replay["author"].string!
                        vo.replayTo = RefCommentVO(id: _id, author: _author, content: _content, status: _status)
                    } else {
                        //  状态为1的 是被删除了的
                        let _error_msg = replay["error_msg"].string!
                        vo.replayTo = RefCommentVO(errorMsg: _error_msg, status: _status)
                    }
                    
                }
            }
            return vos
        }
        return nil
    }
    
}
