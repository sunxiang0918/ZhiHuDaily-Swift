//
//  CommonViewController.swift
//  ZhiHuDaily-Swift
//
//  Created by SUN on 15/6/9.
//  Copyright (c) 2015年 SUN. All rights reserved.
//

import UIKit

class CommonViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var commonTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let nib=UINib(nibName: "CommonListTableViewCell", bundle: nil)
        commonTableView.registerNib(nib, forCellReuseIdentifier: "commonListTableViewCell")
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //================UITableViewDataSource的实现================================
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 10
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell
        if  indexPath.section==0 && indexPath.row == 0 {
            //如果是第一行,就需要构建热门条目
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: nil)
            cell.backgroundColor = UIColor.clearColor()
            cell.contentView.backgroundColor = UIColor.clearColor()
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.clipsToBounds = true
            
            return cell
        }else{
            let tmp = tableView.dequeueReusableCellWithIdentifier("commonListTableViewCell") as? CommonListTableViewCell
            cell = tmp!
            
            tmp?.nameLabel.text="123123"
            tmp?.contentLabel.text="aasdfsandfansdfasdlkjflskadfnsad"
            tmp?.dateLabel.text="06-10 22:37"
            tmp?.voteNumberLabel.text="10"
            
            return cell
        }
    }

    //================UITableViewDataSource的实现================================
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if  section == 0 {
            return 32
        }
        return 22
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if  section == 0 {
            return "23条长评"
        }else {
            return "116条短评"
        }
    }
}
