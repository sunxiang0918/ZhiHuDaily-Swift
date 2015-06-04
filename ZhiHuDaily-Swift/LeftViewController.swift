//
//  LeftViewController.swift
//  ZhiHuDaily-Swift
//
//  Created by SUN on 15/6/4.
//  Copyright (c) 2015年 SUN. All rights reserved.
//

import UIKit
import Haneke

class LeftViewController: UIViewController {

    @IBOutlet weak var usedSizeLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        
        Shared.imageCache.calculateSizeWithCompletionBlock { (i_count, i_size) -> Void in
            
            Shared.stringCache.calculateSizeWithCompletionBlock { (s_count, s_size) -> Void in
                self.usedSizeLabel.text = "缓存个数:\(i_count+s_count) 大小:\(i_size+s_size)"
            }
            
        }
        
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
