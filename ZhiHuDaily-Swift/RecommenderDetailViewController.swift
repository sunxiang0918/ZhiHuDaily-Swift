//
//  RecommenderDetailViewController.swift
//  ZhiHuDaily-Swift
//
//  Created by SUN on 15/6/15.
//  Copyright (c) 2015年 SUN. All rights reserved.
//

import UIKit

class RecommenderDetailViewController: UIViewController {

    @IBOutlet weak var recommenderNameLabel: UILabel!
    @IBOutlet weak var recommenderWebView: UIWebView!
    
    var recommenderName:String?
    var recommenderId:Int?
    var recommenderToken:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        recommenderNameLabel.text = "\(recommenderName!) - 知乎"
        
        recommenderWebView.loadRequest(URLRequest(url: URL(string: PEOPLE_URL+recommenderToken!)!))
        
    }
    
    @IBAction func doBackAction(_ sender: AnyObject) {
        
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

}
