//
//  ThemeVO.swift
//  ZhiHuDaily-Swift
//
//  Created by SUN on 15/10/30.
//  Copyright © 2015年 SUN. All rights reserved.
//

import Foundation

/// 主题的domain模型
class ThemeVO {
    
    let color:Int
    
    let thumbnail:String
    
    let description:String
    
    let id:Int
    
    let name:String
    
    init(color:Int,thumbnail:String,description:String,id:Int,name:String){
        self.color = color
        self.thumbnail = thumbnail
        self.description = description
        self.id = id
        self.name = name
    }
    
}