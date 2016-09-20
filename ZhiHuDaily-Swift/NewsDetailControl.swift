//
//  NewsDetailControl.swift
//  ZhiHuDaily-Swift
//
//  Created by SUN on 15/6/4.
//  Copyright (c) 2015年 SUN. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON3
//import Haneke

class NewsDetailControl {
    
    /**
    加载新闻详细的方法
    
    - parameter id:       新闻的id
    - parameter complate: 当加载完成后,调用的回调
    - parameter block: 当加载失败后,调用的回调
    */
    func loadNewsDetail(_ id:Int,complate:@escaping (_ newsDetail:NewsDetailVO?)->Void,block:((_ error:NSError)->Void)? = nil){

        //let cache = Shared.dataCache
        
        //if  let data = cache.get(key: "\(id)") {
            //在缓存中找到了新闻的详细信息,直接返回
          //  let json = JSON(data: data)
                
           // let newsDetailVO=self.convertJSON2VO(json)
            //执行完成的方法回调
           // complate(newsDetail: newsDetailVO)
            
        //}else{
            //没有找到新闻的详细,从网络上读取
            //调用HTTP请求 获取新闻详细
            Alamofire.request(NEWS_DETAIL_URL+"\(id)").responseString(encoding: String.Encoding.utf8){ response -> Void in
                
                if  let result = response.result.value {
                    if let dataFromString = result.data(using: String.Encoding.utf8, allowLossyConversion: false) {
                        let json = JSON(data: dataFromString)
                        
                        let newsDetailVO=self.convertJSON2VO(json)
                        //执行完成的方法回调
                        complate(newsDetailVO)
                        
                        //放入缓存中
            //            cache.set(value: dataFromString, key: "\(id)")
                    }
                }else {
//                    if let b = block {
//                       b(error: error!)
//                    }
                }
            
          //  }
            
        }
    }
    
    /**
    加载新闻扩展信息的
    
    - parameter id:       新闻ID
    - parameter complate: 扩展信息
    */
    func loadNewsExtraInfo(_ id:Int,complate:@escaping (_ newsExtra:NewsExtraVO?)->Void,block:((_ error:NSError)->Void)? = nil){
        
        //由于新闻额外信息 是随时可能变的,所以不能做缓存
        Alamofire.request(NEWS_EXTRA_URL+"\(id)").responseJSON(options: JSONSerialization.ReadingOptions.mutableContainers) { response -> Void in
            if let result: Any = response.result.value {
                //转换成JSON
                let json = JSON(result)
                
                let long_comments = json["long_comments"].int!
                let popularity = json["popularity"].int!
                let short_comments = json["short_comments"].int!
                let comments = json["comments"].int!
                
                let newsExtra = NewsExtraVO(longComments: long_comments, popularity: popularity, shortComments: short_comments, comments: comments)
                
                complate(newsExtra)
            }
            
        }
    }
    
    /**
    把JSON转换成为VO 对象
    
    - parameter json: json
    
    - returns: VO对象
    */
    fileprivate func convertJSON2VO(_ json:SwiftyJSON3.JSON) -> NewsDetailVO {
        let id = json["id"].int!
        
        let body = json["body"].string
        
        let image_source = json["image_source"].string
        
        let title = json["title"].string!
        
        let image = json["image"].string
        
        let share_url = json["share_url"].string
        
        let js = json["js"].array
        
        let recommenders = json["recommenders"].array
        
        let section = json["section"]
        
        let type = json["type"].int!
        
        let css = json["css"].array
        
        var jss:[String]=[]
        if let _js = js {
            for s in _js {
                jss.append(s.string!)
            }
        }
        
        var csss:[String]=[]
        if let _css = css {
            for s in _css {
                csss.append(s.string!)
            }
        }
        
        var recomms:[String]=[]
        if let _recommenders = recommenders {
            for r in _recommenders {
                recomms.append(r["avatar"].string!)
            }
        }
        
        var _section:Section? = nil
        if  section.error == nil {
//            var sect:Section?
            let thumbnail = section["thumbnail"].string!
            let i = section["id"].int!
            let sectionName = section["name"].string!
            _section = Section(thumbnail: thumbnail, id: i, name: sectionName)
        }
        
        
        let newsDetailVO = NewsDetailVO(id: id, title: title, body: body, image: image, imageSource: image_source, type: type, css: csss, section: _section, recommenders: recomms, js: jss, shareUrl: share_url)
        
        return newsDetailVO
    }
    
}
