//
//  ViewController.swift
//  ZhiHuDaily-Swift
//
//  Created by SUN on 15/5/26.
//  Copyright (c) 2015年 SUN. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    var leftViewController : UIViewController?
    
    let kImageHeight:Float = 400
    let kInWindowHeight:Float = 200
    
    //主页面上关联的表格
    @IBOutlet weak var mainTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //================UITableViewDataSource的实现================================
    
    //设置tableView的数据行数
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        return 10
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        if  indexPath.row == 0 {
            return CGFloat(self.kInWindowHeight)
        }else {
            return 106
        }
    }
    
    //显示左边界面
    @IBAction func showLeftAction(sender: UIButton) {
        self.revealController.showViewController(leftViewController!)
    }
    
    //配置tableView 的单元格
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell:UITableViewCell
        if  indexPath.row == 0 {
            //如果是第一行,就需要构建热门条目
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: nil)
            cell.backgroundColor = UIColor.clearColor()
            cell.contentView.backgroundColor = UIColor.clearColor()
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.clipsToBounds = true
            
            var slideRect = CGRect(origin:CGPoint(x:0,y:0),size:CGSize(width:tableView.frame.width,height:CGFloat(self.kImageHeight)))
            var slideView = SlideScrollView(frame: slideRect)
            slideView.initWithFrameRect(slideRect,imgArr:["http://pic1.zhimg.com/42207cef5d8621be6a1106a2d46d58f0.jpg","http://pic2.zhimg.com/272834eb23f278f907cf6ca200be5d7d.jpg"],titArr:["苏轼果然不是神，苏轼着凉也会感冒","年年都有「隔夜西瓜」的谣言跳出来，吓唬谁呢？"])
            cell.addSubview(slideView)
            
            return cell
        }else{
            cell = tableView.dequeueReusableCellWithIdentifier("channelViewCell") as! UITableViewCell
            return cell
        }
        
//        let rowData = self.channelData[indexPath.row]
        
        //设置cell的标题
//        cell.textLabel?.text = rowData["name"].string
        
    }
    //================UITableViewDataSource的实现================================
    
    


}

