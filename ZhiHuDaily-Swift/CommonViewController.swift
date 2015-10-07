//
//  CommonViewController.swift
//  ZhiHuDaily-Swift
//
//  Created by SUN on 15/6/9.
//  Copyright (c) 2015年 SUN. All rights reserved.
//

import UIKit

class CommonViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,CommonListTableViewCellDelegate,CommentSectionTitleViewDelegate {

    /// 用于获取评论的Control
    let commentControl : CommentControl = CommentControl()
    
    var newsId:Int!
    
    var newsExtral:NewsExtraVO!
    
    var longComments:[CommentVO]?
    var shortComments:[CommentVO]?
    
    private let formatter:NSDateFormatter = NSDateFormatter()
    
    @IBOutlet weak var commonTableView: UITableView!
    @IBOutlet weak var commentNumberLabel: UILabel!
    
    /// 用于记录POP动画状态的变量
    private var popstate = PopActionState.NONE
    
    private var sectionExpanded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        formatter.dateFormat = "MM-dd HH:mm"
        
        let nib=UINib(nibName: "CommonListTableViewCell", bundle: nil)
        commonTableView.registerNib(nib, forCellReuseIdentifier: "commonListTableViewCell")
        commonTableView.registerNib(UINib(nibName: "EmptyCommentTableViewCell", bundle: nil), forCellReuseIdentifier: "emptyCommentTableViewCell")
        commonTableView.registerNib(UINib(nibName: "CommentSectionTitleView", bundle: nil), forHeaderFooterViewReuseIdentifier: "commentSectionTitleView")
        
        
        //IOS8 新增的逻辑,输入一个预估的高度,然后默认设置self.tableView.rowHeight = UITableViewAutomaticDimension;  这样就能自动的适配高度了,而不用去重载 tableview:heightForRowAtIndexPath:这个方法了
        commonTableView.estimatedRowHeight = 90;
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
        commentNumberLabel.text = "\(newsExtral.comments)条点评"
        
        //读取长评论和短评论
        commentControl.loadLongComments(newsId, complate: { (longComments) -> Void in
            self.longComments = longComments
            
            self.commentControl.loadShortComments(self.newsId, complate: { (shortComments) -> Void in
                self.shortComments = shortComments
                
                //重新加载数据
                self.commonTableView.reloadData()
            }, block: nil)
            
        }, block: nil)
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        //当评论页面消失的时候 还原这个状态. 为下一个评论页面做准备
        CommentSectionTitleView.isExpanded = false
    }
    
    @IBAction func doBackAction(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }

    @IBAction func panGestureAction(sender: UIPanGestureRecognizer) {
        
        let view = self.view
        
        if  sender.state == UIGestureRecognizerState.Began {
            //当拖动事件开始的时候
            
            popstate = PopActionState.NONE
            
//            //获取拖动事件的开始点坐标
//            let location = sender.locationInView(view)
            
            //获取拖动事件的偏移坐标
            let translation = sender.translationInView(view!)
            
            //当偏移坐标的x轴大于0,也就是向右滑动的时候.开始做真正的动作
            if  translation.x >= 0 && self.navigationController?.viewControllers.count >= 2 {
                //开启新的转场动画控制器
                interactionController = UIPercentDrivenInteractiveTransition()
                
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
        
        if section == 0{
            //这个是长评论
            
            if let count = longComments?.count {
                return count == 0 ? 1 : count
            }else {
                return 1
            }
        }else {
            //这个是短评论
            
            if  sectionExpanded {
                return shortComments?.count ?? 0
            }else {
                return 0
            }
            
        }
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    /**
    重载这个方法 来自定义 sectino的 标题栏
    
    - parameter tableView:
    - parameter section:
    
    - returns:
    */
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let tmp = tableView.dequeueReusableHeaderFooterViewWithIdentifier("commentSectionTitleView") as! CommentSectionTitleView
        
        if tmp.delegate == nil {
            tmp.delegate = self
        }
        
        if  section == 0 {
            tmp.titleLabel.text = "\(newsExtral.longComments)条长评"
            tmp.expandButton.hidden = true
        }else {
            tmp.titleLabel.text = "\(newsExtral.shortComments  )条短评"
            tmp.expandButton.hidden = false
        }
        
        return tmp
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell
        
        var comment:CommentVO? = nil
        
        if  indexPath.section == 0 {
            //长评论
            
            let count = longComments?.count
            
            if count == nil || count! == 0{
                //表示没有长评论.
                let tmp = tableView.dequeueReusableCellWithIdentifier("emptyCommentTableViewCell") as! EmptyCommentTableViewCell
                
                //直接设置图片View的 约束的高度为  屏幕高度 - 上下title高度 - 两个section的高度
                tmp.heightConstraint.constant = self.view.frame.height - 50 - 30 - 32 - 32
                
                return tmp
                
            }else {
                //表示有长评论
                if  let _longComments = longComments {
                    comment = _longComments[indexPath.row]
                }
            }
            
        }else{
            //短评论
            let count = shortComments?.count
            
            if count == nil || count! == 0{
                //表示没有短评论.
            }else {
                //表示有短评论
                if  let _shortComments = shortComments {
                    comment = _shortComments[indexPath.row]
                }
            }
        }
        
        //到这里来的 都是一定有cell的
        let tmp = tableView.dequeueReusableCellWithIdentifier("commonListTableViewCell") as? CommonListTableViewCell
        
        if  tmp?.delegate == nil {
            tmp?.delegate = self
        }
        
        tmp?.replayCommentLabel.textColor = UIColor(white: 0.396, alpha: 1)
        
        cell = tmp!
        
        if  let _comment = comment {
            tmp?.nameLabel.text=_comment.author
            
            tmp?.contentLabel.text = _comment.content
            
            let date = NSDate(timeIntervalSince1970: NSTimeInterval(_comment.time))
            
            tmp?.dateLabel.text=formatter.stringFromDate(date)
            tmp?.voteNumberLabel.text="\(_comment.likes)"
            if let url = _comment.avatar {
                tmp?.avatorImage.hnk_setImageFromURL(NSURL(string: url)!, placeholder: UIImage(named:"Setting_Avatar"))
            }
            
            tmp?.replayCommentLabel.numberOfLines = 2
            tmp?.expandButton.selected = false
            
            if let replay = _comment.replayTo {
                tmp?.expandButton.hidden = false
                tmp?.replayCommentLabel.hidden = false
                
                if  replay.status == 0 {
                    let content = "//\(replay.author):\(replay.content)"

                    //通过使用attributedText 来设置 同一个Label里面的字体和颜色不一样.从而实现引用的作者名加粗
                    let attributedText = NSMutableAttributedString(string: content)
                    attributedText.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor(), range: NSMakeRange(0,replay.author.characters.count+3))
                    attributedText.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFontOfSize(12), range: NSMakeRange(0,replay.author.characters.count+3))
                    tmp?.replayCommentLabel.attributedText = attributedText
                    
                    tmp?.replayCommentLabel.backgroundColor = UIColor.clearColor()
                    
                    //根据字数 来计算是否需要显示展开按钮.
                    //TODO 这个地方其实还是有问题的.有些情况下计算不准确...
                    let width = tmp?.replayCommentLabel.frame.width
                    let size = content.boundingRectWithSize(CGSizeMake(width!, 999), options: [NSStringDrawingOptions.UsesLineFragmentOrigin, NSStringDrawingOptions.UsesFontLeading] , attributes: [NSFontAttributeName:UIFont.systemFontOfSize(12)], context:nil)
                    if  size.height > 30 {
                        tmp?.expandButton.hidden = false
                    }else {
                        tmp?.expandButton.hidden = true
                    }
                    
                }else {
                    tmp?.replayCommentLabel.text = "  \(replay.content)"
                    tmp?.replayCommentLabel.backgroundColor = UIColor(white: 0.957, alpha: 1)
                    tmp?.expandButton.hidden = true
                }
                
            }else{
                //没有引用的评论.
                tmp?.expandButton.hidden = true
                tmp?.replayCommentLabel.hidden = true
                tmp?.replayCommentLabel.text = ""
            }
        }
        
        // 这里要处理 分页的加载了. 这里的逻辑是这样的. 判断到 如果界面已经刷新到 短新闻的倒数第3条了.那么就尝试进行新的数据
        if  indexPath.section == 0 && indexPath.row+2 == (self.longComments?.count ?? 0) && (self.longComments?.count ?? 0 ) >= 20 && self.newsExtral.longComments > (self.longComments?.count ?? 0) {
            let lastId = self.longComments?.last?.id
            self.commentControl.loadMoreLongComments(self.newsId, beforeId: lastId!, complate: { (longComments) -> Void in
                if let _longComments = longComments {
                    if  _longComments.count > 0 {
                        for longComment in _longComments {
                            self.longComments?.append(longComment)
                        }
                        self.commonTableView.reloadData()
                    }
                }
            }, block: nil)
        }else if  indexPath.section == 1 && indexPath.row+2 == (self.shortComments?.count ?? 0) && (self.shortComments?.count ?? 0) >= 20 && self.newsExtral.shortComments > (self.shortComments?.count ?? 0) {
            //必须是短新闻, 然后当前刷新的是 短新闻的倒数第3条新闻, 并且短新闻数量大于20  然后还有 短新闻没有加载
            let lastId = self.shortComments?.last?.id
            self.commentControl.loadMoreShortComments(self.newsId, beforeId: lastId!, complate: { (shortComments) -> Void in
                //当从URL中获取到下一页评论的时候,开始把获取到得新闻 全部加载到 self.commonTableView中.然后重新加载表格数据
                if let _shortComments = shortComments {
                    if _shortComments.count > 0 {
                        for shortComment in _shortComments {
                            self.shortComments?.append(shortComment)
                        }
                        self.commonTableView.reloadData()
                    }
                }
            }, block: nil)
        }
        
        return cell
    }

    //================UITableViewDataSource的实现================================
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if  section == 0 {
            return 32
        }
        return 32
    }
    
    /**
    因为我们的表格使用的是 grouped模式. 所以他默认的 有一个 footer.
    如果有这个footer,那么 视觉上看起来 第二个的header 高度就和第一个是不一样的了.
    所以这个地方要给他设置没
    
    - parameter tableView:
    - parameter section:
    
    - returns:
    */
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.min
    }
    
    //====================CommonListTableViewCellDelegate实现=============================
    //执行展开操作
    func doExpand(sender:CommonListTableViewCell) {
        //设置行数
        sender.replayCommentLabel.numberOfLines = 100
        //放弃原来的大小,重新计算大小
        sender.replayCommentLabel.invalidateIntrinsicContentSize()
        
        //调用table的 beginUpdates endUpdates 来动态刷新Table的 Cell
        self.commonTableView.beginUpdates()
        self.commonTableView.endUpdates()
        
    }
    
    //执行关闭操作
    func doCollapse(sender:CommonListTableViewCell) {
        //设置行数
        sender.replayCommentLabel.numberOfLines = 2
        //放弃原来的大小,重新计算大小
        sender.replayCommentLabel.invalidateIntrinsicContentSize()

        //调用table的 beginUpdates endUpdates 来动态刷新Table的 Cell
        self.commonTableView.beginUpdates()
        self.commonTableView.endUpdates()
        
    }
    //====================CommonListTableViewCellDelegate实现=============================
    
    
    //====================CommentSectionTitleViewDelegate实现=============================
    func doSectionExpand(sender:CommentSectionTitleView){
        sectionExpanded = true
        commonTableView.reloadData()
    }
    
    func doSectionCollapse(sender:CommentSectionTitleView){
        sectionExpanded = false
        commonTableView.reloadData()
    }
    //====================CommentSectionTitleViewDelegate实现=============================
}
