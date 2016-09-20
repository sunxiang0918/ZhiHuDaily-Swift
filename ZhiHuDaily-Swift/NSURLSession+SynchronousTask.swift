//  由于IOS9 废弃了NSURLConnection.sendSynchronousRequest:returningResponse: 这几个方法,推荐实用NSURLSession来实现.
//  又由于我这里必须实用同步的调用,因此,给NSURLSession写了一个扩展, 增加了两个synchronous同步的方法.
//  NSURLSession+SynchronousTask.swift
//  ZhiHuDaily-Swift
//
//  Created by SUN on 15/7/13.
//  Copyright © 2015年 SUN. All rights reserved.
//

import Foundation

extension URLSession {
    
    func sendSynchronousDataTaskWithRequest(_ request:URLRequest) throws -> (URLResponse?,Data?){
        
        let semaphore:DispatchSemaphore = DispatchSemaphore(value: 0)
        
        var data:Data? = nil
        
        var response:URLResponse? = nil
        
        var error:NSError? = nil
        
        URLSession.shared.dataTask(with: request, completionHandler: { (taskData, taskResponse, taskError) -> Void in
            data = taskData
            
            if let _response = taskResponse {
                response = _response
            }
            
            error = taskError as NSError?
            
            semaphore.signal();
        }) .resume()
        
        semaphore.wait(timeout: DispatchTime.distantFuture);
        
        if let _error = error {
            //异常
            throw AppException.other(_error.description)
        }
        
        return (response,data)
    }
    
    func sendSynchronousDataTaskWithURL(_ url:URL) throws -> (URLResponse?,Data?){
        let semaphore:DispatchSemaphore = DispatchSemaphore(value: 0)
        
        var data:Data? = nil
        var response:URLResponse? = nil
        
        var error:NSError? = nil
        
        URLSession.shared.dataTask(with: url, completionHandler: { (taskData, taskResponse, taskError) -> Void in
            data = taskData
            if let _response = taskResponse {
                response = _response
            }
            
            error = taskError as NSError?
            
            semaphore.signal();
        }) .resume()
        
        semaphore.wait(timeout: DispatchTime.distantFuture);
        
        if let _error = error {
            //异常
            throw AppException.other(_error.description)
        }
        
        return (response,data)
    }
    
}
