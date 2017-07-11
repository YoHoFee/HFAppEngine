//
//  AppEngine.swift
//  Ecosphere
//
//  Created by 姚鸿飞 on 2017/5/24.
//  Copyright © 2017年 encifang. All rights reserved.
//

import UIKit
import SVProgressHUD
import CryptoSwift



class HFAppEngine: NSObject, UITabBarControllerDelegate {
    
    /// 单例
    static let shared = HFAppEngine.init()
    
    /// 窗口
    private lazy var window: UIWindow? = {
        
        guard let obj = UIApplication.shared.delegate?.window else {
            return nil
        }
        return obj
    }()
    
    /// 加载Window执行代码块
    private var execute: ((UIViewController) -> Void)?
    
    /// 主控制器
    private var mainViewController: UITabBarController?
    
    /// 登录控制器
    private var loginViewComtroller: HFLoginViewController?
    
    /// 伪启动控制器
    private var startViewController: HFStartViewController?
    
    /// 主数据中心
    internal let mainDataCent: HFMainDataCent = HFMainDataCent()
    
    /// 网络管理类
    internal let networkManager: HFNetworkManager = HFNetworkManager()
    
    
    
    
    // MARK: - 程序运行方法
    
    
    /// 运行引擎 - 默认函数
    internal class func run() {
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
    ///     此方法需要手动创建Windouw并且展示
    /// - Parameter loadEnd: loadEnd description
    internal func run(execute:@escaping ((UIViewController) -> Void)) {
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
                    HFAlertController.showOneBtnAlertController(controller: self.startViewController!, title: "错误", message: "网络连接失败，请稍后再试！", yesCallBack: { (_) in
                        self.gotoLoginViewController()
                    })
                }
                return
            }
            
            // 判断是否需要进入登录界面的标记
            var flg = false
            //判断是否第一次打开App的标记
            var welcomeFlag = false
            welcomeFlag = UserDefaults.standard.bool(forKey: "welcomeFlag")
            flg = UserDefaults.standard.bool(forKey: "flg")
            if welcomeFlag == false {
                let VC = HFWelcomeViewController(nibName: "HFWelcomeViewController", bundle: nil)
                self.execute!(VC)
                UserDefaults.standard.set(true, forKey: "welcomeFlag")
            }else {
                if flg == false {
                    let VC = HFLoginViewController()
                    self.execute!(VC)
                    UserDefaults.standard.set(true, forKey: "flg")
                }else {
                    if self.mainDataCent.readDataFormLocal() == false {
                        let VC = HFLoginViewController()
                        self.execute!(VC)
                    }else {
                        //                            self.loadEnd!(self.setupMainViewController())
                        
                        self.loginOfAuto { (isSucceed, msg) in
                            if isSucceed == true {
                                self.execute!(self.setupMainViewController())
                            } else {
                                
                                self.loginDidFailure(msg: msg)
                                
                            }
                        }
                        
                        
                        
                    }
                    
                }
                
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
        return mainViewController!;
        
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
    internal func gotoMainController() {
        self.execute!(self.setupMainViewController())
    }
    
    /// 跳转至登录控制器
    internal func gotoLoginViewController() {
        self.loginViewComtroller = HFLoginViewController()
        self.execute!(self.loginViewComtroller!)
    }
    
    
    
    
    
    
    // MARK: - 用户登录模块
    /// 登录
    ///
    /// - Parameters:
    ///   - account: 用户名
    ///   - password: 密码
    ///   - complete: complete description
    internal func login(account: String, password: String, complete: @escaping ((_ isSuccee: Bool, _ msg: String) -> Void)) {
        
        if HFAppConfiguration.isAllowSkipLogin == true { self.gotoMainController(); return }
        
        let param:[String:Any] = [HFAppConfiguration.login_ApiAccountKey:account,HFAppConfiguration.login_ApiPasswordKey:password.md5()]
        
        HFNetworkManager.request(url: API.login, method: .post, parameters: param, description: "登录") { (error, resp) in
            
            
            // 连接失败时
            if error != nil {
                complete(false, error!.localizedDescription)
                return
            }
            
            let info: String? = resp?[HFAppConfiguration.respond_MsgKey].stringValue
            
            let status: Int? = resp?[HFAppConfiguration.respond_StatusKey].intValue
            
            // 请求失败时
            if status != 1 {
                complete(false, info == nil ? "" : info!)
                return
            }
            
            HFAppConfiguration.setupLoginSucceedHandle(result: (resp?[HFAppConfiguration.respond_DataKey])!, NextExecute: { (isSuccess, msg) in
                
                if isSuccess == false {
                    complete(false,msg)
                    return
                }
                 // 执行登录前置任务池
                self.loginPrepositionTaskPool(complete: { (flag) in
                    SVProgressHUD.dismiss(completion: {
                        
                        if flag == true {
                            self.mainDataCent.writeDataToLocal()
                            complete(true,info == nil ? "" : info!)
                            self.execute!(self.setupMainViewController())
                            
                        }else {
                            complete(flag,"数据获取失败")
                        }
                        
                    })
                })
                
            })
           
            
            
            
        }
        
    }
    /// 自动登录
    ///
    /// - Parameter complete: complete description
    internal func loginOfAuto(complete: @escaping ((_ isSuccee: Bool, _ msg: String) -> Void)) {
        
        
//        SVProgressHUD.show(withStatus: "连接中...")
        let param:[String:Any] = ["timetoken":self.mainDataCent.data_UserData!.data_Token]
        
        HFNetworkManager.request(url: API.autoLogin, method: .post, parameters: param, description: "自动登录") { (error, resp) in
            SVProgressHUD.dismiss()
            // 连接失败时
            if error != nil {
                guard let rootVC = self.window?.rootViewController else {
                    self.loginOut()
                    return
                }
                HFAlertController.showOneBtnAlertController(controller:rootVC , title: "错误", message: error!.localizedDescription,yesCallBack: { (_) in
                    self.loginOut()
                })
         
                return
            }
            
            let info: String? = resp?["msg"].stringValue
            
            let status: Int? = resp?["status"].intValue
            
            // 请求失败时
            if status != 1 {
                guard let VC = UIApplication.shared.keyWindow?.rootViewController else {
                    return
                }
                HFAlertController.showOneBtnAlertController(controller: VC, title: "错误", message: info!,yesCallBack: { (_) in
                    self.loginOut()
                })
            
                return
            }
            
            self.loginPrepositionTaskPool(complete: { (flag) in
                SVProgressHUD.dismiss()
                if flag == true {
                    // 请求成功时
                    _ = self.mainDataCent.writeDataToLocal()
                    complete(true,info == nil ? "" : info!)
                    
                }else {
                    guard let VC = UIApplication.shared.keyWindow?.rootViewController else {
                        return
                    }
                    HFAlertController.showOneBtnAlertController(controller: VC, title: "错误", message: info!,yesCallBack: { (_) in
                        self.loginOut()
                    })
                }
            })
            
            
            
        }
        
        
    }
    /// 注销登录
    internal func loginOut() {
        
        self.mainDataCent.data_UserData = HFUserData(UserID: "", MID: "", Token: "", RefreshToken: "", PhoneNumber: "")
        let VC = HFLoginViewController(nibName: "HFLoginViewController", bundle: Bundle.main)
        self.execute!(VC)
        self.mainViewController = nil
        _ = self.mainDataCent.cleanLocalData()
        UserDefaults.standard.set(false, forKey: "flg")
        
    }
    /// 忘记密码
    ///
    /// - Parameters:
    ///   - account: 手机号
    ///   - password: 密码
    ///   - vcode: 验证码
    ///   - complete: complete description
    internal func forgetPassword(account: String, password: String, vcode: String, complete: @escaping ((_ isSuccee: Bool, _ msg: String) -> Void)) {
        
        let param:[String:Any] = ["phone":account,
                                  "password":password.md5(),
                                  "code":vcode]
        
        HFNetworkManager.request(url: API.ForgetPwd, method: .post, parameters: param, description: "忘记密码") { (error, resp) in
            
            // 连接失败时
            if error != nil {
                complete(false, error.debugDescription)
                return
            }
            
            let info: String? = resp?["msg"].stringValue
            
            let status: Int? = resp?["status"].intValue
            
            // 请求失败时
            if status != 1 {
                complete(false, info == nil ? "" : info!)
                return
            }
            
            // 请求成功时
            complete(true, info!)
            
            
            
        }
        
    }
    /// 登录失效
    ///
    /// - Parameter msg: 失效msg
    internal func loginDidFailure(msg:String) {
        guard let VC = UIApplication.shared.keyWindow?.rootViewController else {
            return
        }
        HFAlertController.showOneBtnAlertController(controller: VC, title: "错误", message: msg) { (_) in
            self.loginOut()
        }

        
    }
    
    
    
    
    
    // MARK: - 任务池
    
    
    /// 启动前置任务池
    ///
    /// - Parameter complete: complete description
    internal func startPrepositionTaskPool(complete:((Bool) -> Void)?) {
        
        let group = DispatchGroup()
        var flag = true
        
        flag = true
        
        
        group.notify(queue: .main) {
            
            if complete == nil { return }
            
            complete!(flag)
            // 删除以下代码
            sleep(5)
            
            
        }
        
        
    }
    /// 登录前置任务池
    ///
    /// - Parameter loadEnd: 当所有数据加载任务完成时调用
    internal func loginPrepositionTaskPool(complete:((Bool) -> Void)?) {
        
        let group = DispatchGroup()
        let flag = true
        
       
        
        group.notify(queue: .main) {
            
            if complete == nil { return }
            
            complete!(flag)
            
            
        }
        
        
    }
    
    
    
    
    
    // MARK: - 效果模块
    
    
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
    private func launchAnimation(beforeAnimation:((Void) -> Void)) {
  
        
            //获取启动图片
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
    

    
    
    
    // MARK: - 验证码定时器模块
    
    
    /// 验证码定时器
    var verificationCodeTimer: Timer?
    /// 验证码定时器回调
    private var verificationCodeTimerCallBack: ((_ time: Int) -> Void)?
    /// 验证码定时器标记
    var verificationCodeTimerFlag: Int = 0
    /// 运行验证码定时器
    internal func runVerificationCodeTimer(callback:((_ time: Int) -> Void)?) {
        self.verificationCodeTimerCallBack = callback
        if self.verificationCodeTimer != nil { return }
        
        self.verificationCodeTimerFlag = 60;
        
        self.verificationCodeTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.timerCallBack), userInfo: nil, repeats: true)
        
    }
    /// 手动停止并销毁验证码定时器
    internal func stopVerificationCodeTimer() {
        self.verificationCodeTimer?.invalidate()
        self.verificationCodeTimer = nil
        self.verificationCodeTimerFlag = 0
    }
    /// 定时器回调
    @objc private func timerCallBack() {
        if self.verificationCodeTimerCallBack != nil {
            self.verificationCodeTimerCallBack!(self.verificationCodeTimerFlag)
        }
        if self.verificationCodeTimerFlag <= 0 {
            self.verificationCodeTimer?.invalidate()
            self.verificationCodeTimer = nil
        }else {
            self.verificationCodeTimerFlag -= 1
        }
    }
    
    
    
    
    
    
    
    
}


