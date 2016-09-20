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
    
    - parameter url: 网址
    */
    func onSearch(_ url:String) {
        Alamofire.request(url, method: HTTPMethod.get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON { response in
            if let result: Any = response.result.value {
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
    func didRecieveReusults(_ results:Any)
}
