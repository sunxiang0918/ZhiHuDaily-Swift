//
//  Cache+Extensions.swift
//  Haneke
//
//  Created by SUN on 15/5/27.
//  Copyright (c) 2015年 Haneke. All rights reserved.
//

import UIKit

public extension Cache {
    
    //计算缓存大小  block (count,size)
    public func calculateSizeWithCompletionBlock(block:(Int,Int)->Void) {
        
//        dispatch_async(cacheQueue, {
            var count = 0
            var size = 0
        
            for (_, (_, memoryCache, diskCache)) in self.formats {
                
                //重新计算下大小
                diskCache.calculateSize()
                
                count += Int(diskCache.fileCount)
                size += Int(diskCache.size)
            }
        
            block(count,size)
//        })
        
    }
   
}
