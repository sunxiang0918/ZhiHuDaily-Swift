//
//  ThemesListControl.swift
//  ZhiHuDaily-Swift
//
//  Created by SUN on 15/10/30.
//  Copyright © 2015年 SUN. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

/*
主页左边的主题获取控制器
*/
class ThemesListControl {
    
    var themes : [ThemeVO] = []
    
    /**
     加载用户主题列表
     */
    func loadThemeList(){
        
        Alamofire.Manager.sharedInstance.request(Method.GET, THEME_URL, parameters: nil, encoding: ParameterEncoding.URL).responseJSON(options: NSJSONReadingOptions.MutableContainers) { (_, _, data) -> Void in
            if  let result:AnyObject = data.value {
                let json = JSON(result)
                
                //主题列表
                let themes:[JSON]? = json["others"].array
                
                for theme in themes! {
                    self.themes.append(self.convertJSON2Theme(theme))
                }
                
            }
        }
    }
    
    /**
     JSON对象和VO对象的转换
     
     - parameter json:
     
     - returns:
     */
    private func convertJSON2Theme(json:JSON) -> ThemeVO {
        let color = json["color"].intValue
        let thumbnail = json["thumbnail"].stringValue
        let description = json["description"].stringValue
        let id = json["id"].intValue
        let name = json["name"].stringValue
        
        return ThemeVO(color: color, thumbnail: thumbnail, description: description, id: id, name: name)
    }
    
}