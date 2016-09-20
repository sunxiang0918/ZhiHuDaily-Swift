//
//  CommonViewController.swift
//  ZhiHuDaily-Swift
//
//  Created by SUN on 15/6/9.
//  Copyright (c) 2015年 SUN. All rights reserved.
//

import UIKit
import Kingfisher

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


class CommonViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,CommonListTableViewCellDelegate,CommentSectionTitleViewDelegate {

    /// 用于获取评论的Control
    let commentControl : CommentControl = CommentControl()
    
    var newsId:Int!
    
    var newsExtral:NewsExtraVO!
    
    var longComments:[CommentVO]?
    var shortComments:[CommentVO]?
    
    fileprivate let formatter:DateFormatter = DateFormatter()
    
    @IBOutlet weak var commonTableView: UITableView!
    @IBOutlet weak var commentNumberLabel: UILabel!
    
    /// 用于记录POP动画状态的变量
    fileprivate var popstate = PopActionState.none
    
    fileprivate var sectionExpanded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        formatter.dateFormat = "MM-dd HH:mm"
        
        let nib=UINib(nibName: "CommonListTableViewCell", bundle: nil)
        commonTableView.register(nib, forCellReuseIdentifier: "commonListTableViewCell")
        commonTableView.register(UINib(nibName: "EmptyCommentTableViewCell", bundle: nil), forCellReuseIdentifier: "emptyCommentTableViewCell")
        commonTableView.register(UINib(nibName: "CommentSectionTitleView", bundle: nil), forHeaderFooterViewReuseIdentifier: "commentSectionTitleView")
        
        
        //IOS8 新增的逻辑,输入一个预估的高度,然后默认设置self.tableView.rowHeight = UITableViewAutomaticDimension;  这样就能自动的适配高度了,而不用去重载 tableview:heightForRowAtIndexPath:这个方法了
        commonTableView.estimatedRowHeight = 90;
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
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
    
    override func viewDidDisappear(_ animated: Bool) {
        //当评论页面消失的时候 还原这个状态. 为下一个评论页面做准备
        CommentSectionTitleView.isExpanded = false
    }
    
    @IBAction func doBackAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func panGestureAction(_ sender: UIPanGestureRecognizer) {
        
        let view = self.view
        
        if  sender.state == UIGestureRecognizerState.began {
            //当拖动事件开始的时候
            
            popstate = PopActionState.none
            
//            //获取拖动事件的开始点坐标
//            let location = sender.locationInView(view)
            
            //获取拖动事件的偏移坐标
            let translation = sender.translation(in: view!)
            
            //当偏移坐标的x轴大于0,也就是向右滑动的时候.开始做真正的动作
            if  translation.x >= 0 && self.navigationController?.viewControllers.count >= 2 {
                //开启新的转场动画控制器
                interactionController = UIPercentDrivenInteractiveTransition()
                
                //开始调用navigation的POP转场
                self.navigationController?.popViewController(animated: true)
            }
        }else if  sender.state == UIGestureRecognizerState.changed {
            //当拖动事件进行时
            
            //获取到事件的偏移坐标
            let translation = sender.translation(in: view!)
            
            if translation.x<0 {
                //如果是向左移动,就不采取动作
                return
            }
            
            //获取view的CGRect
            let b = (view?.bounds)!
            
            //计算百分比
            let d = fabs(translation.x / b.width)
            
            //设置转场动画的百分比
            interactionController?.update(d)
        }else if sender.state == UIGestureRecognizerState.ended {
            //当拖动事件结束时
            
            let translation = sender.translation(in: view!)
            
            //判断速率向量是否大于0, 并且拉动的距离已经过半了
            if  sender.velocity(in: view).x > 0 && translation.x > (view?.bounds.midX)!-20  {
                popstate = PopActionState.finish
                //完成整个动画
                interactionController?.finish()
            }else {
                popstate = PopActionState.cancel
                //停止转场
                interactionController?.cancel()
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
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
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
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let tmp = tableView.dequeueReusableHeaderFooterView(withIdentifier: "commentSectionTitleView") as! CommentSectionTitleView
        
        if tmp.delegate == nil {
            tmp.delegate = self
        }
        
        if  section == 0 {
            tmp.titleLabel.text = "\(newsExtral.longComments)条长评"
            tmp.expandButton.isHidden = true
        }else {
            tmp.titleLabel.text = "\(newsExtral.shortComments  )条短评"
            tmp.expandButton.isHidden = false
        }
        
        return tmp
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell
        
        var comment:CommentVO? = nil
        
        if  (indexPath as NSIndexPath).section == 0 {
            //长评论
            
            let count = longComments?.count
            
            if count == nil || count! == 0{
                //表示没有长评论.
                let tmp = tableView.dequeueReusableCell(withIdentifier: "emptyCommentTableViewCell") as! EmptyCommentTableViewCell
                
                //直接设置图片View的 约束的高度为  屏幕高度 - 上下title高度 - 两个section的高度
                tmp.heightConstraint.constant = self.view.frame.height - 50 - 30 - 32 - 32
                
                return tmp
                
            }else {
                //表示有长评论
                if  let _longComments = longComments {
                    comment = _longComments[(indexPath as NSIndexPath).row]
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
                    comment = _shortComments[(indexPath as NSIndexPath).row]
                }
            }
        }
        
        //到这里来的 都是一定有cell的
        let tmp = tableView.dequeueReusableCell(withIdentifier: "commonListTableViewCell") as? CommonListTableViewCell
        
        if  tmp?.delegate == nil {
            tmp?.delegate = self
        }
        
        tmp?.replayCommentLabel.textColor = UIColor(white: 0.396, alpha: 1)
        
        cell = tmp!
        
        if  let _comment = comment {
            tmp?.nameLabel.text=_comment.author
            
            tmp?.contentLabel.text = _comment.content
            
            let date = Date(timeIntervalSince1970: TimeInterval(_comment.time))
            
            tmp?.dateLabel.text=formatter.string(from: date)
            tmp?.voteNumberLabel.text="\(_comment.likes)"
            if let url = _comment.avatar {
                tmp?.avatorImage.kf_setImage(with: URL(string: url)!, placeholder: UIImage(named:"Setting_Avatar"))
            }
            
            tmp?.replayCommentLabel.numberOfLines = 2
            tmp?.expandButton.isSelected = false
            
            if let replay = _comment.replayTo {
                tmp?.expandButton.isHidden = false
                tmp?.replayCommentLabel.isHidden = false
                
                if  replay.status == 0 {
                    let content = "//\(replay.author):\(replay.content)"

                    //通过使用attributedText 来设置 同一个Label里面的字体和颜色不一样.从而实现引用的作者名加粗
                    let attributedText = NSMutableAttributedString(string: content)
                    attributedText.addAttribute(NSForegroundColorAttributeName, value: UIColor.black, range: NSMakeRange(0,replay.author.characters.count+3))
                    attributedText.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFont(ofSize: 12), range: NSMakeRange(0,replay.author.characters.count+3))
                    tmp?.replayCommentLabel.attributedText = attributedText
                    
                    tmp?.replayCommentLabel.backgroundColor = UIColor.clear
                    
                    //根据字数 来计算是否需要显示展开按钮.
                    //TODO 这个地方其实还是有问题的.有些情况下计算不准确...
                    let width = tmp?.replayCommentLabel.frame.width
                    let size = content.boundingRect(with: CGSize(width: width!, height: 999), options: [NSStringDrawingOptions.usesLineFragmentOrigin, NSStringDrawingOptions.usesFontLeading] , attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 12)], context:nil)
                    if  size.height > 30 {
                        tmp?.expandButton.isHidden = false
                    }else {
                        tmp?.expandButton.isHidden = true
                    }
                    
                }else {
                    tmp?.replayCommentLabel.text = "  \(replay.content)"
                    tmp?.replayCommentLabel.backgroundColor = UIColor(white: 0.957, alpha: 1)
                    tmp?.expandButton.isHidden = true
                }
                
            }else{
                //没有引用的评论.
                tmp?.expandButton.isHidden = true
                tmp?.replayCommentLabel.isHidden = true
                tmp?.replayCommentLabel.text = ""
            }
        }
        
        // 这里要处理 分页的加载了. 这里的逻辑是这样的. 判断到 如果界面已经刷新到 短新闻的倒数第3条了.那么就尝试进行新的数据
        if  (indexPath as NSIndexPath).section == 0 && (indexPath as NSIndexPath).row+2 == (self.longComments?.count ?? 0) && (self.longComments?.count ?? 0 ) >= 20 && self.newsExtral.longComments > (self.longComments?.count ?? 0) {
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
        }else if  (indexPath as NSIndexPath).section == 1 && (indexPath as NSIndexPath).row+2 == (self.shortComments?.count ?? 0) && (self.shortComments?.count ?? 0) >= 20 && self.newsExtral.shortComments > (self.shortComments?.count ?? 0) {
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
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
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    //====================CommonListTableViewCellDelegate实现=============================
    //执行展开操作
    func doExpand(_ sender:CommonListTableViewCell) {
        //设置行数
        sender.replayCommentLabel.numberOfLines = 100
        //放弃原来的大小,重新计算大小
        sender.replayCommentLabel.invalidateIntrinsicContentSize()
        
        //调用table的 beginUpdates endUpdates 来动态刷新Table的 Cell
        self.commonTableView.beginUpdates()
        self.commonTableView.endUpdates()
        
    }
    
    //执行关闭操作
    func doCollapse(_ sender:CommonListTableViewCell) {
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
    func doSectionExpand(_ sender:CommentSectionTitleView){
        sectionExpanded = true
        commonTableView.reloadData()
    }
    
    func doSectionCollapse(_ sender:CommentSectionTitleView){
        sectionExpanded = false
        commonTableView.reloadData()
    }
    //====================CommentSectionTitleViewDelegate实现=============================
}
