//
//  Constant.swift
//  ZhiHuDaily-Swift
//
//  Created by SUN on 15/5/29.
//  Copyright (c) 2015年 SUN. All rights reserved.
//

import UIKit


//主页上得各种高度的变量
let TABLE_CELL_HEIGHT : Float = 100
let SECTION_HEIGHT:Float = 24
let SCROLL_HEIGHT:Float = 80
let IMAGE_HEIGHT:Float = 400
let IN_WINDOW_HEIGHT:Float = 200
let TITLE_HEIGHT:Float = 44

//知乎的各种网址
let LAUNCH_IMAGE_URL="http://news-at.zhihu.com/api/4/start-image/1080*1776"
let LATEST_NEWS_URL="http://news-at.zhihu.com/api/4/news/latest"
let SOMEDAY_NEWS_URL = "http://news.at.zhihu.com/api/4/news/before/"
let NEWS_DETAIL_URL = "http://news-at.zhihu.com/api/4/news/"
let NEWS_EXTRA_URL = "http://news-at.zhihu.com/api/4/story-extra/"
let COMMONS_URL = "http://news-at.zhihu.com/api/4/story/"

//由于NewsDetailViewController和NavigationControllerDelegate 都需要访问这个转场控制器,而且两个的关系差太远,所以只能写到这作为全局变量了
var interactionController : UIPercentDrivenInteractiveTransition?

enum PopActionState {
    case NONE
    case FINISH
    case CANCEL
}