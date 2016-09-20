//
//  ThemesListControl.swift
//  ZhiHuDaily-Swift
//
//  Created by SUN on 15/10/30.
//  Copyright © 2015年 SUN. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON3

/*
主页左边的主题获取控制器
*/
class ThemesListControl {
    
    var themes : [ThemeVO] = []
    
    /**
     加载用户主题列表
     */
    func loadThemeList(){
        
        Alamofire.request(THEME_URL).responseJSON(options: JSONSerialization.ReadingOptions.mutableContainers) { response in
            
            debugPrint(response)
            
            if  let result:Any = response.result.value {
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
    fileprivate func convertJSON2Theme(_ json:JSON) -> ThemeVO {
        let color = json["color"].intValue
        let thumbnail = json["thumbnail"].stringValue
        let description = json["description"].stringValue
        let id = json["id"].intValue
        let name = json["name"].stringValue
        
        return ThemeVO(color: color, thumbnail: thumbnail, description: description, id: id, name: name)
    }
    
}
