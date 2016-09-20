//
//  MainNewsListControl.swift
//  ZhiHuDaily-Swift
//
//  Created by SUN on 15/5/31.
//  Copyright (c) 2015年 SUN. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON3


/**
*  主页上的新闻的内容控制器
*/
class MainNewsListControl {
    
    var todayNews : NewsListVO? //今天的新闻
    
    var news : [NewsListVO]=[]  //用于存储新闻的
    
    /**
    用于刷新当前页面的新闻
    */
    func refreshNews(){
        
        if  todayNews == nil {
            //表示第一次启动,没有加载任何新闻.那就需要第一次加载新闻
            refreshTodayNews()
            return
        }
        
        //表示不是第一次加载了.
        
        //先重载一次最新的新闻
        refreshTodayNews()

        //遍历内存中已经存在了的其他日期的新闻
        for new in news {
            refreshNews(new)
        }
        
    }
    
    /**
    刷新新闻
    
    - parameter date: 日期
    */
    fileprivate func refreshNews(_ news:NewsListVO){
        //获取日期
        let date = news.date
        //获取下一天的日期,因为知乎的API决定的,你要查询今天的,就必须传入明天的日期
        let tomorrow=getNextDateInt(date!)
        
        Alamofire.request(SOMEDAY_NEWS_URL+"\(tomorrow)").responseJSON(options: JSONSerialization.ReadingOptions.mutableContainers) { response -> Void in
            if  let result:Any = response.result.value {
                let json = JSON(result)
                
                _ = json["date"].int!
                
                //最新新闻
                let stories = json["stories"].array
                
                //遍历最新的新闻
                let lastestNews : [NewsVO]? = self.convertStoriesJson2Vo(stories, type: .news)
                
                news.news = lastestNews
            }
        }
    }
    
    /**
    获取到某个日期之后一天的日期的数字
    
    - parameter date: 某个日期
    
    - returns: 第二天的日期
    */
    fileprivate func getNextDateInt(_ date:Int) ->Int? {
        let formatter:DateFormatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let today=formatter.date(from: "\(date)")
        
        if let t = today {
            let tomorrow = Date(timeInterval: (24 * 60 * 60), since: t)
            return Int(formatter.string(from: tomorrow))
        }
        
        return nil
    }
    
    /**
    刷新当天新闻
    */
    fileprivate func refreshTodayNews(){
        
        //使用Alamofire框架 获取最新的新闻列表
        
//        let data = NSURLConnection.sendSynchronousRequest(NSURLRequest(URL: NSURL(string: LATEST_NEWS_URL)!), returningResponse: nil, error: nil)
        
        Alamofire.request(LATEST_NEWS_URL).responseJSON(options: JSONSerialization.ReadingOptions.mutableContainers) { response -> Void in
            
            if let result: Any = response.result.value {
                //转换成JSON
                let json = JSON(result)
                
                let date = Int(json["date"].string!)
                
                //最热新闻
                let top_stories = json["top_stories"].array
                //最新新闻
                let stories = json["stories"].array

                //遍历最热新闻
                let topNews : [NewsVO]? = self.convertStoriesJson2Vo(top_stories, type: .top_NEWS)
                //遍历最新的新闻
                let lastestNews : [NewsVO]? = self.convertStoriesJson2Vo(stories, type: .news)
                
                if let day =  self.todayNews?.date {
                    if  day == date{
                        self.todayNews?.news = lastestNews
                        self.todayNews?.topNews = topNews
                    }else{
                        //日期不一样了,就说明可能都过了一天了.那么就需要把原来的todayNews放入一般的 news中
                        let d = self.todayNews?.date
                        self.news.insert(NewsListVO(date:d!, news: self.todayNews?.news, topNews: self.todayNews?.topNews), at: 0)
                        
                        self.todayNews?.date = date
                        self.todayNews?.news = lastestNews
                        self.todayNews?.topNews = nil
                    }
                }else {
                    //如果日期都没得,就说明todayNews都是空的. 直接重新来过
                    self.todayNews = NewsListVO()
                    
                    self.todayNews?.date = date
                    self.todayNews?.news = lastestNews
                    self.todayNews?.topNews = topNews
                }
            }
        }
    }
    
    /**
    转换新闻List JSON对象到VO对象
    
    - parameter stories: [JSON]
    - parameter type:    新闻类型,因为TOP 和一般的 结构上有点区别
    
    - returns:
    */
    fileprivate func convertStoriesJson2Vo(_ stories:[JSON]?,type:NewsTypeEnum = .news) ->[NewsVO]? {
        var news:[NewsVO]? = nil
        //遍历最热新闻
        if  let _stories = stories {
            news = []
            for story in _stories {
                //把JSON转换成VO
                let new = self.convertJSON2VO(story, type: type)
                news?.append(new)
            }
        }
        
        return news
    }
    
    /**
    把JSON转换成 NewsVO
    
    - parameter json: JSON
    - parameter type: News类型,因为 最热新闻的结构稍微有点不一样
    
    - returns:
    */
    fileprivate func convertJSON2VO(_ json:JSON,type:NewsTypeEnum = .news) -> NewsVO {
        
        let id = json["id"].int!
        
        let title = json["title"].string!
        
        let gaPrefix = json["ga_prefix"].int
        
        var image:[String]? = nil
        if  type == .top_NEWS {
            let  _image = json["image"].string
            
            if  let i = _image {
                image = [i]
            }
        }else {
            let _images = json["images"].array
            
            if let _is = _images {
                image = []
                
                for i in _is {
                    image?.append(i.string!)
                }
            }
        }
        
        let multipic = json["multipic"].bool
        
        return NewsVO(id: id, title: title, images: image, multipic:multipic, gaPrefix: gaPrefix)
    }
    
    
    
    /**
    用于新加载下一天的新闻,并加入到缓存中去
    
    */
    func loadNewDayNews(_ block:@escaping ()->Void){
        
        var day = 0
        if news.isEmpty {
            //表示新的,需要加载的是 昨天的新闻
            let today = Date()
            let formatter:DateFormatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd"
            day = Int(formatter.string(from: today))!
        }else {
            let lastestNews = news.last
            day = (lastestNews?.date)!
        }
        
        Alamofire.request(SOMEDAY_NEWS_URL+"\(day)").responseJSON(options: JSONSerialization.ReadingOptions.mutableContainers) { response -> Void in
            if  let result:Any = response.result.value {
                let json = JSON(result)
                
                let news = NewsListVO()
                
                let date = Int(json["date"].string!)
                
                news.date = date
                
                //最新新闻
                let stories = json["stories"].array
                
                //遍历最新的新闻
                let lastestNews : [NewsVO]? = self.convertStoriesJson2Vo(stories, type: .news)
                
                news.news = lastestNews
                
                self.news.append(news)
                
                block()
            }
        }
        
    }
    
    fileprivate enum NewsTypeEnum {
        case top_NEWS
        case news
    }
    
}
