//
//  NewsDetailVO.swift
//  ZhiHuDaily-Swift
//
//  Created by SUN on 15/6/4.
//  Copyright (c) 2015年 SUN. All rights reserved.
//

import Foundation

/**
*  新闻详细的对象
*/
class NewsDetailVO {

    /// 主要的内容
    let body: String?

    /// 图片版权
    let imageSource: String?

    /// 标题
    let title: String

    /// 图片的URL
    let image: String?

    /// 分享地址
    let shareUrl: String?

    /// 网页js的url地址
    let js: [String]?

    /// 推荐者的头像
    let recommenders: [String]?

    /// 无用
    let gaPrefix: Int = 0

    /// 新闻类型  内部新闻是0  外联是1
    let type: Int

    /// 新闻的ID
    let id: Int

    /// 网页的css的url地址
    let css: [String]?

    ///栏目对象
    let section: Section?

    init(id: Int, title: String, body: String?, image: String?, imageSource: String?, type: Int = 0, css: [String]?, section: Section?, recommenders: [String]?, js: [String]?, shareUrl: String?) {
        self.id = id
        self.title = title
        self.body = body
        self.image = image
        self.imageSource = imageSource
        self.type = type
        self.css = css
        self.section = section
        self.recommenders = recommenders
        self.js = js
        self.shareUrl = shareUrl
    }
}

/// 表示栏目的对象
struct Section {
    let thumbnail: String
    let id: Int
    let name: String

    init(thumbnail: String, id: Int, name: String) {
        self.id = id
        self.thumbnail = thumbnail
        self.name = name
    }
}

/**
*  新闻的扩展信息
*/
struct NewsExtraVO {
    let longComments : Int
    let popularity : Int
    let shortComments : Int
    let comments : Int
    
    init(longComments:Int,popularity:Int,shortComments:Int,comments:Int) {
        self.comments = comments
        self.longComments = longComments
        self.shortComments = shortComments
        self.popularity = popularity
    }
}