//
//  RecommendersListViewController.swift
//  ZhiHuDaily-Swift
//
//  Created by SUN on 15/6/14.
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

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class RecommendersListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    fileprivate let recommenderControl = RecommenderControl()
    
    var newsId : Int?
    
    fileprivate var recommenders : RecommendersVO?
    
    @IBOutlet weak var recommenderTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        recommenderTableView.register(UINib(nibName: "RecommenderTableViewCell", bundle: nil), forCellReuseIdentifier: "recommenderTableViewCell")
        
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        
        recommenderControl.getNewsRecommenders(self.newsId!, complate: { (recommenders) -> Void in
            self.recommenders = recommenders
            
            self.recommenderTableView.reloadData()
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRecommenderDetailSegue" {
            let recommenderDetailViewController = segue.destination as? RecommenderDetailViewController
            
            let recommenderInfo = sender as? RecommenderInfoVO
            
            recommenderDetailViewController?.recommenderId = recommenderInfo?.id
            recommenderDetailViewController?.recommenderName = recommenderInfo?.name
            recommenderDetailViewController?.recommenderToken = recommenderInfo?.token
            
        }
    }
    
    @IBAction func doBackAction(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    //====================实现UITableViewDelegate=========================
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let recommender = recommenders?.items?[(indexPath as NSIndexPath).section].recommenders[(indexPath as NSIndexPath).row]
        
        self.performSegue(withIdentifier: "showRecommenderDetailSegue", sender: recommender)
    }
    //====================实现UITableViewDelegate=========================
    
    
    //====================实现UITableViewDataSource=========================
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return recommenders?.items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return recommenders?.items?[section].recommenders.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if  recommenders?.items?.count > 1 {
            let item = recommenders?.items?[section]
            
            let index = item?.index
            let author = item?.author
            
            return "回答\(index!) (作者:\(author!)) 推荐者"
        }else {
            return nil
        }
        
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "recommenderTableViewCell") as? RecommenderTableViewCell
        
        let item = recommenders?.items?[(indexPath as NSIndexPath).section]
        
        let recommender = item?.recommenders[(indexPath as NSIndexPath).row]
        
        cell?.userNameLabel.text = recommender?.name
        cell?.userDesLabel.text = recommender?.bio
        cell?.userAvatorImage.kf_setImage(with: URL(string: recommender!.avatar)!, placeholder: UIImage(named:"Setting_Avatar"))
        
        return cell!
    }

    //====================实现UITableViewDataSource=========================
}
