//
//  AppDelegate.swift
//  ZhiHuDaily-Swift
//
//  Created by SUN on 15/5/26.
//  Copyright (c) 2015年 SUN. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import SwiftyJSON
import Haneke

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    //获取开始图片的URL
    private let url = "http://news-at.zhihu.com/api/4/start-image/1080*1776"
    
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        //获取到原来的根视图的Controller作为主的Controller
//        let navigationController = self.window?.rootViewController as! UINavigationController
        
        //使用UINavigationController.topViewController 可以获取最上面的视图Controller
//        let rightController = navigationController.topViewController as! ViewController
        
        let rightController = self.window?.rootViewController as! ViewController
        
        
        //从主的StoryBoard中获取名为leftViewController的视图 也就是左视图
        let leftController: UIViewController?=UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("leftViewController") as? UIViewController
        
        rightController.leftViewController = leftController
        
        //实例化一个PKRevealController 也就是能左右滑动的视图
        let revealController = PKRevealController(frontViewController: rightController, leftViewController: leftController)
        
        //同步加载开始图片
        loadStartImage(url, onSuccess: {(name,image) in
            //回调闭包
            //修改窗体的根视图的Controller为启动Image的Controller.
            //这里自定义了一个启动的ViewController, 他指定了消失后切换的视图的Controller.还有动画效果,以及显示的图片.
            self.window?.rootViewController = KCLaunchImageViewController.addTransitionToViewController(revealController!, modalTransitionStyle: UIModalTransitionStyle.CrossDissolve, withImageDate: image, withSourceName: name)
            //UIModalTransitionStyle转场动画效果   CrossDissolve渐变  PartialCurl翻页  FlipHorizontal上下翻转  CoverVertical上下平移(默认值)
        })
        
        return true
    }
    
    //从网络上加载开始图片
    func loadStartImage(url:String,onSuccess:(String,UIImage)->Void){
        //同步调用URL,获取开始图片的JSON结果
        var data = NSURLConnection.sendSynchronousRequest(NSURLRequest(URL: NSURL(string: url)!), returningResponse: nil, error: nil)
        
        if let temp = data {
            //把结果NSData 转换成JSON
            let json = JSON(data:temp)
            //获取结果中得img,也就是真正的图片的URL
            let imageUrl = json["img"].string
            //获取版权人
            let name = json["text"].string
            
            if  var iu = imageUrl {
                
                //这个使用的是异步加载的,所以界面可能就会有闪烁
                let imageCache=Shared.imageCache
                
                if  let image = imageCache.get(key: iu) {
                    //在缓存中找到了图片,直接返回
                    onSuccess(name!,image)
                }else{
                    //在缓存中没有找到图片,那么就需要请求一次获取图片
                    //这个是同步加载的,所以界面不会有闪烁
                    //获取图片的NSData
                    data = NSURLConnection.sendSynchronousRequest(NSURLRequest(URL: NSURL(string: iu)!), returningResponse: nil, error: nil)
                    
                    //把NSData转换成必要的UIImage对象
                    if let d  = data, let image = UIImage(data: d) {
                        //把图片放入缓存
                        imageCache.set(value: image, key: iu)
                        //调用成功的回调
                        onSuccess(name!,image)
                    }

                }
                
            }
        }
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "edu.cuit.sun.ZhiHuDaily_Swift" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as! NSURL
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("ZhiHuDaily_Swift", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("ZhiHuDaily_Swift.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }

}

