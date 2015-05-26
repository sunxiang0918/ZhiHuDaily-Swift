//
//  HttpControl.swift
//  DouBanFM
//
//  Created by SUN on 15/4/21.
//  Copyright (c) 2015年 SUN. All rights reserved.
//

import UIKit
import Alamofire

class HttpControl {
    
    //定义一个回调代理
    var delegate:HttpProtocol?
    
    /**
    接收一个网址,然后回调代理的方法,传回数据
    
    :param: url 网址
    */
    func onSearch(url:String) {
        Alamofire.Manager.sharedInstance.request(Method.GET, url, parameters: nil, encoding: ParameterEncoding.URL).responseJSON(options: NSJSONReadingOptions.MutableContainers) { (_, _, data, error) -> Void in
            if let result: AnyObject = data {
                self.delegate?.didRecieveReusults(result)
            }
        }
    }
}

//定义一个http协议

protocol HttpProtocol {
    /**
    *  定义了一个协议,接收anyObject. 然后解析处理结果
    */
    func didRecieveReusults(results:AnyObject)
}
