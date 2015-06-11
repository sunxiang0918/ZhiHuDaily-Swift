//
//  CommonControl.swift
//  ZhiHuDaily-Swift
//
//  Created by SUN on 15/6/11.
//  Copyright (c) 2015年 SUN. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class CommonControl {
    
    /// 加载 长评论
    func loadLongCommons(id:Int,complate:(longCommons:[CommonVO]?)->Void,block:((error:NSError)->Void)? = nil){
        
        Alamofire.Manager.sharedInstance.request(Method.GET,COMMONS_URL+"\(id)/long-comments", parameters: nil, encoding: ParameterEncoding.URL).responseJSON(options: NSJSONReadingOptions.MutableContainers){ (_, _, data, error) -> Void in
            if let result: AnyObject = data {
                //转换成JSON
                let json = JSON(result)
                
                complate(longCommons: self.convertJSON2VO(json))
            }
        }
    }
    
    /// 加载 短评论
    func loadShortCommons(id:Int,complate:(shortCommons:[CommonVO]?)->Void,block:((error:NSError)->Void)? = nil){
        
        Alamofire.Manager.sharedInstance.request(Method.GET,COMMONS_URL+"\(id)short-comments", parameters: nil, encoding: ParameterEncoding.URL).responseJSON(options: NSJSONReadingOptions.MutableContainers) { (_, _, data, error) -> Void in
            if let result: AnyObject = data {
                //转换成JSON
                let json = JSON(result)
                
                complate(shortCommons: self.convertJSON2VO(json))
            }
        }
        
    }
    
    private func convertJSON2VO(json:JSON) -> [CommonVO]? {
        
        if  let comments = json["comments"].array {
            var vos:[CommonVO] = []
            for comment in comments {
                let author = comment["author"].string!
                let content = comment["content"].string!
                let avatar = comment["avatar"].string
                let time = comment["time"].int!
                let id = comment["id"].int!
                let likes = comment["likes"].int!
                
                let replay = comment["reply_to"]
                
                let vo = CommonVO(author: author, content: content, avatar: avatar, time: time, id: id, likes: likes)
                
                vos.append(vo)
                
                if replay.null == nil{
                    //表示有引用
                    let _content = replay["content"].string!
                    let _status = replay["status"].int!
                    let _id = replay["id"].int!
                    let _author = replay["author"].string!
                    
                    vo.replayTo = RefCommonVO(id: _id, author: _author, content: _content, status: _status)
                }
            }
            return vos
        }
        return nil
    }
    
}