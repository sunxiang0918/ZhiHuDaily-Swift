//
//  RecommendersView.swift
//  ZhiHuDaily-Swift
//
//  Created by SUN on 15/6/9.
//  Copyright (c) 2015年 SUN. All rights reserved.
//

import UIKit

class RecommendersView: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var image2: UIImageView!
    @IBOutlet weak var image3: UIImageView!
    @IBOutlet weak var image4: UIImageView!
    @IBOutlet weak var image5: UIImageView!
    
    func getImageView(index:Int) -> UIImageView? {
        
        switch index {
        case 0: return image1
        case 1: return image2
        case 2: return image3
        case 3: return image4
        case 4: return image5
        default:
            return nil
        }
        
    }
    
}
