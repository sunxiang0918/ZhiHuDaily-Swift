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
    
    /// 用于记录POP动画状态的变量
    private var popstate = PopActionState.NONE
    
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
    
    @IBAction func doBackAction(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }

    @IBAction func panGestureAction(sender: UIPanGestureRecognizer) {
        
        let view = self.view
        
        if  sender.state == UIGestureRecognizerState.Began {
            //当拖动事件开始的时候
            
            popstate = PopActionState.NONE
            
            //获取拖动事件的开始点坐标
            let location = sender.locationInView(view)
            
            //获取拖动事件的偏移坐标
            let translation = sender.translationInView(view!)
            
            //当偏移坐标的x轴大于0,也就是向右滑动的时候.开始做真正的动作
            if  translation.x > 0 && self.navigationController?.viewControllers.count >= 2 {
                //开启新的转场动画控制器
                interactionController = UIPercentDrivenInteractiveTransition.new()
                
                //开始调用navigation的POP转场
                self.navigationController?.popViewControllerAnimated(true)
            }
        }else if  sender.state == UIGestureRecognizerState.Changed {
            //当拖动事件进行时
            
            //获取到事件的偏移坐标
            let translation = sender.translationInView(view!)
            
            if translation.x<0 {
                //如果是向左移动,就不采取动作
                return
            }
            
            //获取view的CGRect
            let b = (view?.bounds)!
            
            //计算百分比
            let d = fabs(translation.x / CGRectGetWidth(b))
            
            //设置转场动画的百分比
            interactionController?.updateInteractiveTransition(d)
        }else if sender.state == UIGestureRecognizerState.Ended {
            //当拖动事件结束时
            
            let translation = sender.translationInView(view!)
            
            //判断速率向量是否大于0, 并且拉动的距离已经过半了
            if  sender.velocityInView(view).x > 0 && translation.x > CGRectGetMidX(view.bounds)-20  {
                popstate = PopActionState.FINISH
                //完成整个动画
                interactionController?.finishInteractiveTransition()
            }else {
                popstate = PopActionState.CANCEL
                //停止转场
                interactionController?.cancelInteractiveTransition()
            }
            
            //这个地方必须设置成nil. 避免两次之间的转场冲突了
            interactionController = nil;
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
