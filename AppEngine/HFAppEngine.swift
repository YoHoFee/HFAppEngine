//
//  AppEngine.swift
//  Ecosphere
//
//  Created by 姚鸿飞 on 2017/5/24.
//  Copyright © 2017年 encifang. All rights reserved.
//

import UIKit
import SVProgressHUD
import SnapKit
import CryptoSwift



class HFAppEngine: NSObject, UITabBarControllerDelegate {
    
    /// 单例
    @objc static let shared = HFAppEngine.init()
    
    /// 窗口
    private lazy var window: UIWindow? = {
        
        guard let window = UIApplication.shared.delegate?.window else {
            return nil
        }
        return window
    }()
    
    /// 加载Window执行代码块
    private var execute: ((UIViewController) -> Void)?
    
    // 配置对象
    @objc open var configuration: HFEngineConfiguration = HFEngineConfiguration.defaultConfiguration()
    
    /// 主控制器
    private var mainViewController: UITabBarController?
    
    /// 登录控制器
    private var loginViewComtroller: UIViewController?
    
    /// 伪启动控制器
    private var startViewController: HFStartViewController?
    
    /// 主数据中心
    @objc open let mainDataCent: HFMainDataCent = HFMainDataCent()
    
    /// 网络管理类
    @objc open let networkManager: HFNetworkManager = HFNetworkManager()
    
    /// 当前显示的控制器
    open var currentDisplayViewController: UIViewController? {
        get{ return self.currentViewController() }
    }
    
    
    // MARK: 程序运行方法
    
    
    /// 运行引擎 - 默认函数
    @objc open class func run() {
        guard let delegat = UIApplication.shared.delegate as? AppDelegate else { return }
        delegat.setupWindow()
        HFAppEngine.shared.run { (rootVC) in
            guard let window = UIApplication.shared.delegate?.window else { return }
            HFAppEngine.shared.fadeOver(window: window!, toViewVC: rootVC)
            window!.backgroundColor = UIColor.white
            window!.frame = UIScreen.main.bounds
            window!.makeKeyAndVisible()
        }
        
    }
    
    /// 引擎主函数
    ///
    /// - Parameter loadEnd: loadEnd description
    open func run(execute:@escaping ((UIViewController) -> Void)) {
        self.execute = execute
        
        SVProgressHUD.setDefaultStyle(.light)
        SVProgressHUD.setMaximumDismissTimeInterval(2)
        SVProgressHUD.setDefaultMaskType(.black)
        
        // 设置并加载显示假启动页
        self.execute!(self.setupStartViewController())
        
        // 运行启动任务池
        self.startPrepositionTaskPool { (isSuccee) in
            
            if isSuccee == false {
                if self.startViewController != nil {
                    HFAlertController.showAlert(type: .OnlyConfirm, title: "错误", message: "网络连接失败，请稍后再试！", ConfirmCallBack: { (_, _) in
                        self.gotoLoginViewController()
                    })
                }
                return
            }
            
            // 检查App状态
            switch self.checkAppStatus() {
                
            // 第一次开启
            case .FirstRun:
                
                let VC = HFWelcomeViewController(nibName: "HFWelcomeViewController", bundle: nil)
                self.execute!(VC)                           // 显示欢迎界面
                self.resetAppStatus()
                
            // 未登录
            case .NotLogin:
                
                if self.configuration.isMustLogin == true {
                    self.gotoLoginViewController()         // 显示登录界面
                }else {
                    self.execute!(self.setupMainViewController())
                }
                
            // 已登录
            case .DidLogin:
                
               self.gotoMainController()                   // 显示主控制器
                
            }
            

        }
        
     
    }
    
    /// 设置导航栏控制器
    ///
    /// - Returns: return value description
    private func setupMainViewController() -> UITabBarController {
        let obj = UITabBarController()
        obj.tabBar.isTranslucent = false
        obj.tabBar.tintColor = UIColor.orange
        self.mainViewController = obj
        self.mainViewController!.viewControllers = HFAppConfiguration.setupViewController()
        self.mainViewController!.delegate = self
        return mainViewController!
        
    }
    
    /// 设置伪启动视图控制器
    ///
    /// - Returns: return value description
    private func setupStartViewController() -> UIViewController {
        let vc = HFStartViewController()
        self.startViewController = vc
        return self.startViewController!
    }
    
    /// 跳转至主控制器
    internal func gotoMainController() -> Void {
        self.resetAppStatus()
        self.execute!(self.setupMainViewController())
    }
    
    /// 未登录跳转至主控制器
    internal func gotoMainControllerWithNotLogin() -> Void {
        self.execute!(self.setupMainViewController())
    }
    
    /// 跳转至登录控制器
    internal func gotoLoginViewControllerWithPush() -> Void {
        self.loginViewComtroller = HFLoginViewController()
        self.currentDisplayViewController?.navigationController?.pushViewController(self.loginViewComtroller!, animated: true)
        
    }
    
    /// 跳转至登录控制器
    internal func gotoLoginViewController() -> Void {
        self.loginViewComtroller = UINavigationController(rootViewController: HFLoginViewController())
        self.execute!(self.loginViewComtroller!)
    }
    
    /// 检查App启动状态
    ///
    /// - Returns: return value description
    private func checkAppStatus() -> AppStatus {
        
        let appStatusStr    = UserDefaults.standard.string(forKey: HFEngineConfiguration.appStatusKey) == nil ? AppStatus.FirstRun.rawValue : UserDefaults.standard.string(forKey: HFEngineConfiguration.appStatusKey)!
        
        var appStatus       = AppStatus(rawValue: appStatusStr)
        
        if  appStatus == AppStatus.FirstRun && self.configuration.isNeedWelcomeView == false {
            appStatus       = AppStatus.NotLogin
        }
        
        if self.configuration.autoLoginByLocalTokenKey != nil && (UserDefaults.standard.string(forKey: self.configuration.autoLoginByLocalTokenKey!) == nil) {
            appStatus       = AppStatus.NotLogin
        }
        
        return appStatus!
        
    }
    
    /// 重置App启动状态
    func resetAppStatus(status: AppStatus) -> Void {
        UserDefaults.standard.set(status.rawValue, forKey: HFEngineConfiguration.appStatusKey)
    }
    
    /// 设置App启动状态
    private func resetAppStatus() -> Void {
        
        switch self.checkAppStatus() {
        case .FirstRun:
            UserDefaults.standard.set(AppStatus.NotLogin.rawValue, forKey: HFEngineConfiguration.appStatusKey)
        case .NotLogin:
            UserDefaults.standard.set(AppStatus.DidLogin.rawValue, forKey: HFEngineConfiguration.appStatusKey)
        case .DidLogin: break
            
        }
        
        
    }
    
    private func taskPoolDemonstration(flag:Bool,complete:@escaping ((Bool) -> Void)) -> Void {
        
        
        if self.configuration.isEnabledDemonstration == true {
            let label = UILabel()
            label.text = "伪启动页，演示中5秒后自动消失"
            label.sizeToFit()
            label.textColor = UIColor.black
            label.font = UIFont.systemFont(ofSize: 15)
            label.center = self.startViewController!.view.center
            
            self.startViewController?.view.addSubview(label)
            
            DispatchQueue.init(label: "").asyncAfter(deadline: DispatchTime.now() + 5, execute: DispatchWorkItem(block: {
                DispatchQueue.main.sync(execute: {
                    
                    complete(flag)
                })
            }))
            
            
        }else {
            complete(flag)
            
        }
        
    }
    
    
    /// 获取当前显示的控制器
    ///
    /// - Parameter base: 基控制器
    /// - Returns: 当前显示的控制器
    open func currentViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return currentViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            return currentViewController(base: tab.selectedViewController)
        }
        if let presented = base?.presentedViewController {
            return currentViewController(base: presented)
        }
        return base
    }
    
    
    
    
    // MARK: 任务池
    
    
    /// 启动前置任务池
    ///
    /// - Parameter complete: complete description
    private func startPrepositionTaskPool(complete:((Bool) -> Void)?) {
        
        let group = DispatchGroup()
        var flag = true
        
        flag = true
        
        
        group.notify(queue: .main) {
            
            if complete == nil { return }
            
            self.taskPoolDemonstration(flag: flag, complete: complete!)
            
        }
        
        
    }

    
    
    
    
    // MARK: 效果模块
    
    
    /// 注册运动动态效果
    ///
    /// - Parameters:
    ///   - aView: 需要添加效果的View
    ///   - depth: 偏移量
    internal func registerEffectForView(aView: UIView, depth: CGFloat) {
        
        for effect: UIMotionEffect in aView.motionEffects {
            aView.removeMotionEffect(effect)
        }
        let interpolationHorizontal = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        interpolationHorizontal.minimumRelativeValue = depth
        interpolationHorizontal.maximumRelativeValue = -depth
        
        let interpolationVertical = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        interpolationVertical.minimumRelativeValue = depth
        interpolationVertical.maximumRelativeValue = -depth
        
        aView.addMotionEffect(interpolationHorizontal)
        aView.addMotionEffect(interpolationVertical)
    }
    
    
    /// 淡入淡出效果
    ///
    /// - Parameters:
    ///   - window: window description
    ///   - toViewVC: toViewVC description
    internal func fadeOver(window:UIWindow,toViewVC:UIViewController) {
    
        if window.rootViewController != nil {
            
            UIView.transition(from: window.rootViewController!.view, to: toViewVC.view, duration: 0.5, options: UIViewAnimationOptions.transitionCrossDissolve, completion: { (finished) in
                window.rootViewController = toViewVC
            })
            
        }else {
            window.rootViewController = toViewVC;
        }
        
        
    }
    
    //播放启动画面动画
    private func launchAnimation(beforeAnimation:(() -> Void)) {
  
        
            //获取启动图片，
            let launchImage = self.startViewController!.imageView.image
            let launchview = UIImageView(frame: UIScreen.main.bounds)
            launchview.image = launchImage
            //将图片添加到视图上
            //            self.view.addSubview(launchview)
            let delegate = UIApplication.shared.delegate
            let mainWindow = delegate?.window
            mainWindow!!.addSubview(launchview)
            beforeAnimation()
            //播放动画效果，完毕后将其移除
            UIView.animate(withDuration: 1, delay: 1.5, options: .beginFromCurrentState,
                           animations: {
                            launchview.alpha = 0.0
                            launchview.layer.transform = CATransform3DScale(CATransform3DIdentity, 1.5, 1.5, 1.0)
            }) { (finished) in
                launchview.removeFromSuperview()
            }
        
    }
    

    // MARK: 验证码定时器模块
    
    
    /// 验证码定时器
    private var generalTimer: Timer?
    /// 验证码定时器回调
    private var generalTimerCallBack: ((_ time: Int) -> Void)?
    /// 验证码定时器标记
    var generalTimerTime: Int = 0
    /// 运行验证码定时器
    internal func runGeneralTimerTimer(duration: Int, callback:((_ time: Int) -> Void)?) {
        self.generalTimerCallBack = callback
        if self.generalTimer != nil { return }
        self.generalTimerTime = duration
        self.generalTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.timerCallBack), userInfo: nil, repeats: true)
    }
    /// 手动停止并销毁验证码定时器
    internal func stopGeneralTimer() {
        self.generalTimer?.invalidate()
        self.generalTimer = nil
        self.generalTimerTime = 0
    }
    /// 定时器回调
    @objc private func timerCallBack() {
        if self.generalTimerCallBack != nil {
            self.generalTimerCallBack!(self.generalTimerTime)
        }
        if self.generalTimerTime <= 0 {
            self.generalTimer?.invalidate()
            self.generalTimer = nil
        }else {
            self.generalTimerTime -= 1
        }
    }
    
    
    
    
    
    
    
    
}


