//
//  AppConfiguration.swift
//  Ecosphere
//
//  Created by 姚鸿飞 on 2017/6/3.
//  Copyright © 2017年 encifang. All rights reserved.
//

import UIKit
import SwiftyJSON

let dataFilePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last! as NSString).appendingPathComponent("DataCent.dc")

let savePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last! as String


class HFAppConfiguration: NSObject {
    
    // 是否允许跳过登录限制
    static let isAllowSkipLogin = false
    
    // 请求超时时间设置
    static let requestOutTime = 10
    
    // 服务器的响应中 消息 字段Key
    static let respond_MsgKey = "msg"
    
    // 服务器的响应中 状态 字段Key
    static let respond_StatusKey = "status"
    
    // 服务器的响应中 数据 字段Key
    static let respond_DataKey = "data"
    
    // 登录接口请求参数 账号 字段Key
    static let login_ApiAccountKey = "phone"
    
    // 登录接口请求参数 密码 字段Key
    static let login_ApiPasswordKey = "password"
    
    /// 设置需要展示的控制器
    /// - 此方法默认会添加一个UITabBarController
    /// - Returns: 将控制器放在数组中返回
    class func setupViewController() -> [UIViewController] {
        
        /*--------------------在下面创建控制器--------------------*/
        
        let VC1 = UIViewController()
        VC1.view.frame = UIScreen.main.bounds
        VC1.view.backgroundColor = UIColor.white
        let VCN1 = UINavigationController(rootViewController: VC1)
        VCN1.navigationBar.isTranslucent = false
        VCN1.tabBarItem.title = "VC1"
        VC1.navigationItem.title = "VC1"
        VC1.view.backgroundColor = UIColor.white
        
        
        let VC2 = UIViewController()
        VC2.view.frame = UIScreen.main.bounds
        VC2.view.backgroundColor = UIColor.white
        let VCN2 = UINavigationController(rootViewController: VC2)
        VCN2.navigationBar.isTranslucent = false
        VCN2.tabBarItem.title = "VC2"
        VC2.navigationItem.title = "VC2"
        VC2.view.backgroundColor = UIColor.red
        
        let VC3 = UIViewController()
        VC3.view.frame = UIScreen.main.bounds
        VC3.view.backgroundColor = UIColor.white
        let VCN3 = UINavigationController(rootViewController: VC3)
        VCN3.navigationBar.isTranslucent = false
        VCN3.tabBarItem.title = "VC3"
        VC3.navigationItem.title = "VC3"
        VC3.view.backgroundColor = UIColor.blue
        
        let VC4 = UIViewController()
        VC4.view.frame = UIScreen.main.bounds
        VC4.view.backgroundColor = UIColor.white
        let VCN4 = UINavigationController(rootViewController: VC4)
        VCN4.navigationBar.isTranslucent = false
        VCN4.tabBarItem.title = "VC4"
        VC4.navigationItem.title = "VC4"
        VC4.view.backgroundColor = UIColor.green
        
        /*--------------------创建好控制器添加到数组中即可--------------------*/
        
        
        return [
            VCN1,
            VCN2,
            VCN3,
            VCN4
        ]
        
    }
    
    /// 设置自定义主控制器
    /// - 此方法在需要使用自定义UITabBarController的时候调用
    /// - Returns: 将控制器放在数组中返回
    class func setupMainController() -> UITabBarController? {
        
        
        
        return nil
    }
    
    
    /// 设置登录成功后的操作
    ///
    /// - Parameters:
    ///   - result: 返回的结果
    ///   - NextExecute: 下一步操作
    class func setupLoginSucceedHandle(result:JSON, NextExecute: (_ isSuccess: Bool,_ msg: String) -> Void) {
        
        
        
        /// 当您完成您的操作时，请调用此闭包并告诉引擎您处理的结果是否允许登录，isSuccess为false时将登录失败，并且弹窗提示您传递的msg
        NextExecute(true,"msg")
        
    }
    
    
}
