//
//  HFEngineConfiguration.swift
//  AppEngineDemo
//
//  Created by 姚鸿飞 on 2017/9/4.
//  Copyright © 2017年 姚鸿飞. All rights reserved.
//

import UIKit

class HFEngineConfiguration: NSObject {
    
    
    /// 默认配置
    ///
    /// - Returns: 默认配置对象
    open class func defaultConfiguration() -> HFEngineConfiguration { return HFEngineConfiguration() }
    /// 是否需要欢迎界面，默认为true
    open var isNeedWelcomeView: Bool
    /// 是否开启自动登录，默认为true
    open var isNeedAutomaticLogin: Bool
    /// 是否开启引擎演示模式
    open var isEnabledDemonstration: Bool
    /// 如果关闭强制登录，需要自行判断用户登录状态，并手动调用“resetAppStatus”方法设置登录状态
    open var isMustLogin: Bool
    /// 存储在本地用于自动登录的Token的Key，用于启动判断是否进行自动登录,如果该属性不为Nil，则通过该Key进行本地检索并通过结果判断是否需要自动登录，如该属性为Nil，则通过常规方式进行自动登录判断
    open var autoLoginByLocalTokenKey: String?
    /// 本地存储App状态的Key
    static var appStatusKey: String { get { return "AppStatus" } }
    
    
    
    override init() {
        
        self.isNeedWelcomeView          = true
        self.isNeedAutomaticLogin       = true
        self.isEnabledDemonstration     = true
        self.isMustLogin                = true
        super.init()
        
    }
    

}
