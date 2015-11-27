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

    @IBOutlet weak var sideMenuTable: UITableView!
    
    let themesListControl = ThemesListControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let nib=UINib(nibName: "SideMenuTableViewCell", bundle: nil)
        sideMenuTable.registerNib(nib, forCellReuseIdentifier: "sideMenuTableViewCell")
        // Do any additional setup after loading the view.
        self.sideMenuTable.backgroundColor = UIColor(red: 0.102, green: 0.122, blue: 0.141, alpha: 1)
        self.sideMenuTable.delegate = self
        self.sideMenuTable.dataSource = self
        self.sideMenuTable.rowHeight = 50.5
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        
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

extension LeftViewController:UITableViewDelegate,UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return themesListControl.themes.count + 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:SideMenuTableViewCell
        if indexPath.row == 0 {
            //首页
            
            let tmp = tableView.dequeueReusableCellWithIdentifier("sideMenuTableViewCell")
            if  tmp == nil {
                cell = SideMenuTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "sideMenuTableViewCell")
            }else {
                cell = tmp as! SideMenuTableViewCell
            }
            
            cell.titleLabel.text = "首页"
//            if originState == false {
//                cell.contentView.backgroundColor = UIColor(red: 19/255.0, green: 26/255.0, blue: 32/255.0, alpha: 1)
//                cell.homeImageView.tintColor = UIColor(red: 136/255.0, green: 141/255.0, blue: 145/255.0, alpha: 1)
//                cell.homeTitleLabel.textColor = UIColor(red: 136/255.0, green: 141/255.0, blue: 145/255.0, alpha: 1)
//            }
            return cell
        }
        
        //其他页
        let tmp = tableView.dequeueReusableCellWithIdentifier("sideMenuTableViewCell")
        
        if  tmp == nil {
            cell = SideMenuTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "sideMenuTableViewCell")
        }else {
            cell = tmp as! SideMenuTableViewCell
        }
        
        cell.titleLabel.text = themesListControl.themes[indexPath.row-1].name
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    }
    
}
