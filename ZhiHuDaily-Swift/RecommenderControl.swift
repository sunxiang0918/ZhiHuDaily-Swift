//
//  RecommenderControl.swift
//  ZhiHuDaily-Swift
//
//  Created by SUN on 15/6/15.
//  Copyright (c) 2015年 SUN. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON3

class RecommenderControl {
    
    /**
    获取一个新闻的推荐者
    
    - parameter newsId:   新闻Id
    - parameter complate: 读取后的操作
    */
    func getNewsRecommenders(_ newsId:Int,complate:@escaping (_ recommenders:RecommendersVO)->Void,block:((_ error:NSError)->Void)? = nil){
        
        Alamofire.request(RECOMMENDERS_URL+"\(newsId)/recommenders").responseJSON(options: JSONSerialization.ReadingOptions.mutableContainers) { response in
                if let result: Any = response.result.value {
                    //转换成JSON
                    let json = JSON(result)
                    
                    complate(self.convertJSON2VO(json))
                }
        }
    }
    
    /**
    把JSON对象转换成VO
    
    - parameter json:
    
    - returns:
    */
    fileprivate func convertJSON2VO(_ json:JSON) -> RecommendersVO{
    
        let item_count = json["item_count"].int!
        
        var recommenderVOs:[RecommenderVO] = []
        if let items = json["items"].array {
            for item in items {
                let index = item["index"].int!
                let name = item["author"]["name"].string!
                var infos : [RecommenderInfoVO] = []
                if  let recommenders = item["recommenders"].array {
                    for recommender in recommenders {
                        let bio = recommender["bio"].string!
                        let token = recommender["zhihu_url_token"].string!
                        let id = recommender["id"].int!
                        let avatar = recommender["avatar"].string!
                        let name = recommender["name"].string!
                        infos.append(RecommenderInfoVO(id: id, name: name, token: token, avatar: avatar, bio: bio))
                    }
                }
                recommenderVOs.append(RecommenderVO(index: index, author: name, recommenders: infos))
            }
        }
        
        let recommendersVO = RecommendersVO(itemCount: item_count, items: recommenderVOs)
        
        return recommendersVO
    }
    
}
