//
//  HFAlertController.swift
//  SmallTradePlatform
//
//  Created by 姚鸿飞 on 2016/12/20.
//  Copyright © 2016年 pmec. All rights reserved.
//

import UIKit


/// 弹窗类型枚举
///
/// - Default: 默认弹窗
/// - ActionSheet: 底部弹窗
/// - OnlyConfirm: 只可确认的默认弹窗
/// - AccountAction: 带账户输入框的弹窗（该样式在自定义弹窗中不可用）
@objc enum HFAlertType: Int {
    
    case Default
    
    case ActionSheet
    
    case OnlyConfirm
    
    case AccountAction
    
}

/// 弹出动画枚举
///
/// - System:       仿系统弹出样式（默认）
/// - Elasticity:   弹力样式
/// - Sheet:        仿系统底部弹窗样式
/// - SheetExit:    仿系统底部弹窗退出动画
@objc enum HFAlertAnimationOption: Int {
    
    case System
    
    case Elasticity
    
    case Sheet
    
    case SheetExit
    
}

/// 对系统弹窗控制器进行封装，实现背景点击返回
class HFAlertController: UIAlertController, HFAlertBkViewDelegate {


    // MARK: - 快速弹出方法 -
    
    
    // MARK: 弹出自定义弹窗
    /// 弹出自定义弹窗
    ///
    /// - Parameters:
    ///   - view: 需要弹出的View
    ///   - type: 提示框类型
    @discardableResult
    open class func showCustomView(view customView: UIView,type: HFAlertType? = .Default) -> (() -> Void)? {
        
        guard let windouw = UIApplication.shared.keyWindow else {
            print(print("HFAlertController_ErrerMsg = ”Window为空，无法弹出自定义弹窗“"))
            return nil
        }
        
        let bkView: HFAlertBkView
        var animation: HFAlertAnimationOption = .System
        
        bkView                = HFAlertBkView.fullBackground()
        bkView.alpha          = 0
        customView.center     = windouw.center
        
        switch type! {
        case .Default:
            bkView.setupFullBkButton()
        case .ActionSheet:
            animation = .Sheet
            bkView.setupFullBkButton()
            bkView.willExitCallBack = {
                HFAlertController.alertAnimation(view: customView, animation: .SheetExit)
            }
        case .OnlyConfirm: break
        case .AccountAction: break
            
        }
        
        windouw.addSubview(bkView)
        bkView.addSubview(customView)
        
        HFAlertController.alertAnimation(view: customView, animation: animation)
        
        UIView.animate(withDuration: 0.25, animations: {
            bkView.alpha = 1
        })
        
        return bkView.exitBkView
        
    }
    // MARK: 弹出默认提示框
    /// 弹出默认提示框
    ///
    /// - Parameters:
    ///   - type: 提示框类型
    ///   - title: 提示框标题
    ///   - message: 提示框内容
    ///   - ConfirmCallBack: 完成回调
    @discardableResult
    open class func showAlert(type:HFAlertType? = .Default, title: String, message: String, ConfirmCallBack:((_ account: String?, _ password:String?) -> Void)?) -> HFAlertController {
        
        var alertController: HFAlertController
        
        switch type! {
        case HFAlertType.Default:
            alertController = HFAlertController.alertController(title: title, message: message, ConfirmCallBack: {
                ConfirmCallBack?(nil,nil)
            })

        case HFAlertType.ActionSheet:
            alertController = HFAlertController.alertController(title: title, message: message, preferredStyle: .actionSheet, ConfirmCallBack: {
                 ConfirmCallBack?(nil,nil)
            })
        case HFAlertType.OnlyConfirm:
            alertController = HFAlertController.alertControllerByOnlyConfirm(title: title, message: message, ConfirmCallBack: {
                ConfirmCallBack?(nil,nil)
            })
        case .AccountAction:
            
            let accountTextField = UITextField()
            let passwordtextField = UITextField()
            
            accountTextField.placeholder = "请输入账号"
            accountTextField.textColor = UIColor.black
            accountTextField.clearButtonMode = .whileEditing
            accountTextField.borderStyle = .roundedRect
            accountTextField.returnKeyType = .next
            accountTextField.font = UIFont.systemFont(ofSize: 15)
            
            passwordtextField.placeholder = "请输入密码"
            passwordtextField.textColor = UIColor.black
            passwordtextField.clearButtonMode = .whileEditing
            passwordtextField.borderStyle = .roundedRect
            passwordtextField.isSecureTextEntry = true
            passwordtextField.returnKeyType = .done
            passwordtextField.font = UIFont.systemFont(ofSize: 15)
            
            alertController = HFAlertController.alertControllerWithTextFields(title: title, message: message, textFields: [accountTextField,passwordtextField], ConfirmCallBack: { (textFields) in
                
                let accountTextField: UITextField = textFields[0]
                let passwordTextField: UITextField = textFields[1]
                if ConfirmCallBack != nil {
                    ConfirmCallBack!(accountTextField.text!, passwordTextField.text!)
                }
                
            })
            
        }
        
        if self.currentDisplayViewController != nil {
            self.currentDisplayViewController!.present(alertController, animated: true, completion: nil)
        }else {
            print("HFAlertController_ErrerMsg = ”当前没有可用的视图控制器可供弹出，请检查视图层级“")
        }
        
        return alertController
    }

    
    
    // MARK: - 快速创建方法 -
    
    
    // MARK: 创建一个默认的提示框
    /// 创建一个默认的提示框
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - message: 内容文本
    ///   - preferredStyle: 提示框类型
    ///   - ConfirmCallBack: 确定按钮回调
    /// - Returns: 一个默认的提示框
    open class func alertController(title: String, message: String, preferredStyle: UIAlertControllerStyle = .alert, ConfirmCallBack:(() -> Void)?) -> HFAlertController {
        
        let alertController = HFAlertController(title: title, message: message, preferredStyle: preferredStyle)
        let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel, handler: nil)
        let yesAction = UIAlertAction(title: "确定", style: UIAlertActionStyle.default) { (_) in
            if ConfirmCallBack != nil {
                ConfirmCallBack!()
            }
        }
        alertController.addAction(yesAction)
        alertController.addAction(cancelAction)
        
        return alertController
    }
    // MARK: 创建一个自定义确定按钮文本的弹出窗
    /// 创建一个自定义确定按钮文本的弹出窗
    ///
    /// - Parameters:
    ///   - title: 标题文本
    ///   - message: 弹窗内容
    ///   - yesBtnTitle: 确定按钮文本
    ///   - ConfirmCallBack: 确定按钮回调
    /// - Returns: return value description
    open class func alertController(title: String, message: String, yesBtnTitle: String, ConfirmCallBack:(() -> Void)?) -> HFAlertController {
        
        let alertController = HFAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel, handler: nil)
        let yesAction = UIAlertAction(title: yesBtnTitle, style: UIAlertActionStyle.default) { (_) in
            if ConfirmCallBack != nil {
                ConfirmCallBack!()
            }
        }
        alertController.addAction(yesAction)
        alertController.addAction(cancelAction)
        
        return alertController
    }
    // MARK: 创建一个只可确定的弹框
    /// 创建一个只可确定的弹框（没有取消按钮）
    ///
    /// - Parameters:
    ///   - title: 标题文本
    ///   - message: 弹框内容
    ///   - ConfirmCallBack: 确定按钮回调
    /// - Returns: return value description
    open class func alertControllerByOnlyConfirm(title: String, message: String, ConfirmCallBack:(() -> Void)?) -> HFAlertController {
        
        let alertController = HFAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let yesAction = UIAlertAction(title: "确定", style: UIAlertActionStyle.default) { (_) in
            if ConfirmCallBack != nil {
                ConfirmCallBack!()
            }
        }
        alertController.addAction(yesAction)
        alertController.isAllowedCancel = false
        return alertController
    }
    
    
    // MARK: 创建一个带账户密码输入框的弹窗
    /// 创建一个带账户密码输入框的弹窗
    ///
    /// - Parameters:
    ///   - title: 标题文本
    ///   - message: 弹框内容
    ///   - ConfirmCallBack: 确定按钮回调
    /// - Returns: return value description
    open class func alertControllerWithAccount(title: String, message: String, ConfirmCallBack:((_ account: String, _ password: String) -> Void)?) -> HFAlertController {
        
        let alertController = HFAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)

        alertController.addTextField { (textField) in
            textField.placeholder = "请输入账号"
            textField.textColor = UIColor.black
            textField.clearButtonMode = .whileEditing
            textField.borderStyle = .roundedRect
            textField.returnKeyType = .next
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "请输入密码"
            textField.textColor = UIColor.black
            textField.clearButtonMode = .whileEditing
            textField.borderStyle = .roundedRect
            textField.isSecureTextEntry = true
            textField.returnKeyType = .done
        }

        let yesAction = UIAlertAction(title: "确定", style: UIAlertActionStyle.default) { (action) in

            let accountTextField: UITextField = alertController.textFields![0]
            let passwordTextField: UITextField = alertController.textFields![1]
            if ConfirmCallBack != nil {
                ConfirmCallBack!(accountTextField.text!, passwordTextField.text!)
            }
        }
        alertController.addAction(yesAction)
        return alertController
        
    }
    
    
    /// 创建一个带输入框的弹窗
    ///
    /// - Parameters:
    ///   - title: 标题文本
    ///   - message: 弹框内容
    ///   - textFields: 输入框数组
    ///   - ConfirmCallBack: 回调
    /// - Returns:
    open class func alertControllerWithTextFields(title: String, message: String,textFields: [UITextField], ConfirmCallBack:((_ textFields: [UITextField]) -> Void)?) -> HFAlertController {
        
        let alertController = HFAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        for item: UITextField in textFields {
            alertController.addTextField(configurationHandler: { (textField: UITextField) in
                
                textField.placeholder = item.placeholder
                textField.text = item.text
                textField.textAlignment = item.textAlignment
                textField.borderStyle = item.borderStyle
                textField.textColor = item.textColor
                textField.font = item.font
                textField.delegate = item.delegate
                textField.attributedPlaceholder = item.attributedPlaceholder
                textField.attributedText = item.attributedText
                textField.alpha = item.alpha
                textField.isSecureTextEntry = item.isSecureTextEntry
                textField.isHidden = item.isHidden
                textField.isEnabled = item.isEnabled
                textField.keyboardType = item.keyboardType
                textField.returnKeyType = item.returnKeyType
                textField.leftView = item.leftView
                textField.leftViewMode = item.leftViewMode
                textField.defaultTextAttributes = item.defaultTextAttributes
                textField.clearsOnBeginEditing = item.clearsOnBeginEditing
                textField.minimumFontSize = item.minimumFontSize
                textField.background = item.background
                textField.disabledBackground = item.disabledBackground
                textField.allowsEditingTextAttributes = item.allowsEditingTextAttributes
                textField.clearButtonMode = item.clearButtonMode
                textField.clearsOnInsertion = item.clearsOnInsertion
                textField.rightView = item.rightView
                textField.rightViewMode = item.rightViewMode
                textField.adjustsFontSizeToFitWidth = item.adjustsFontSizeToFitWidth
                if #available(iOS 10.0, *) {
                    textField.textContentType = item.textContentType
                } else {
                    // Fallback on earlier versions
                }
                
            })
            
        }
        let yesAction = UIAlertAction(title: "确定", style: UIAlertActionStyle.default) { (action) in
            ConfirmCallBack?(alertController.textFields!)
        }
        alertController.addAction(yesAction)
        
        return alertController
    }
    
    // MARK: - 私有属性 -
    
    
    /// 当前显示的控制器
    fileprivate class var currentDisplayViewController: UIViewController? {
        get{ return HFAlertController.currentViewController() }
    }
    fileprivate var currentDisplayViewControllerCache: UIViewController?
    /// 底部蒙版
    fileprivate var newBottonView:  HFAlertBkView?
    /// 头部蒙版
    fileprivate var newTopView:     HFAlertBkView?
    /// 左边蒙版
    fileprivate var newLeftView:    HFAlertBkView?
    /// 右边蒙版
    fileprivate var newRightView:   HFAlertBkView?
    /// 是否允许取消
    fileprivate var isAllowedCancel: Bool = true
    
    
    // MARK: - 私有方法 -
    
    
    /// 获取当前显示的控制器
    ///
    /// - Parameter base: 基控制器
    /// - Returns: 当前显示的控制器
    fileprivate class func currentViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
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
    /// 仅在此方法中可获取AlertView的大小
    ///
    /// - Parameter animated: -
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        let windouw: UIWindow   = UIApplication.shared.keyWindow!
        let bkView: UIView      = (windouw.subviews.last)!
        self.layoutNewbackgroundView(bkView: bkView)
        
    }
    /// 布局与设置蒙版
    ///
    /// - Parameter bkView: 背景View
    fileprivate func layoutNewbackgroundView(bkView: UIView) {
        
        newBottonView   = HFAlertBkView(delegate: self)
        newTopView      = HFAlertBkView(delegate: self)
        newRightView    = HFAlertBkView(delegate: self)
        newLeftView     = HFAlertBkView(delegate: self)
        
        bkView.addSubview(newTopView!)
        bkView.addSubview(newBottonView!)
        bkView.addSubview(newLeftView!)
        bkView.addSubview(newRightView!)
        

        newBottonView!.frame     = CGRect.init(x: 0, y: self.view.frame.maxY, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height-self.view.frame.maxY)
        newTopView!.frame        = CGRect(x:0, y:0, width: UIScreen.main.bounds.width, height: self.view.frame.origin.y)
        newLeftView!.frame       = CGRect(x:0, y:self.view.frame.origin.y,width: self.view.frame.origin.x, height:self.view.frame.size.height)
        newRightView!.frame      = CGRect(x:self.view.frame.maxX, y:self.view.frame.origin.y,width:UIScreen.main.bounds.width - self.view.frame.maxX,height: self.view.frame.size.height)
        
        
    }
    /// 添加弹窗动画
    ///
    /// - Parameters:
    ///   - view: 需要添加动画的View
    ///   - animation: 动画类型枚举
    fileprivate class func alertAnimation(view: UIView,animation: HFAlertAnimationOption) {
        
        let popAnimation: CAKeyframeAnimation = CAKeyframeAnimation(keyPath: "transform")
        var values: [NSValue]
        var timingFunctions: [CAMediaTimingFunction]
        
        switch animation {
            
        case .System:
            values = [NSValue(caTransform3D: CATransform3DMakeScale(1.2, 1.2, 1.0)),
                      NSValue(caTransform3D: CATransform3DMakeScale(1.0, 1.0, 1.0))]
            timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear),
                               CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)]
            popAnimation.duration        = 0.4
            popAnimation.values          = values
            popAnimation.keyTimes        = [0.0,0.5,0.75,1.0]
            popAnimation.timingFunctions = timingFunctions
            view.layer.add(popAnimation, forKey: nil)
            
        case .Elasticity:
            values = [NSValue(caTransform3D: CATransform3DMakeScale(0.01, 0.01, 1.0)),
                      NSValue(caTransform3D: CATransform3DMakeScale(1.1, 1.1, 1.0)),
                      NSValue(caTransform3D: CATransform3DMakeScale(0.9, 0.9, 1.0)),
                      NSValue(caTransform3D: CATransform3DIdentity)]
            timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut),
                               CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut),
                               CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)]
            popAnimation.duration        = 0.4
            popAnimation.values          = values
            popAnimation.keyTimes        = [0.0,0.5,0.75,1.0]
            popAnimation.timingFunctions = timingFunctions
            view.layer.add(popAnimation, forKey: nil)
            
        case .Sheet:
            var frame = view.frame
            frame.origin.y = UIScreen.main.bounds.maxY + (view.frame.height)
            view.frame = frame
            let newFrame = CGRect(x: frame.origin.x, y: UIScreen.main.bounds.maxY - (view.frame.height) - 10, width: frame.width, height: frame.height)
            
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 2, options: .curveLinear, animations: {
                view.frame = newFrame
                
            }, completion: nil)
            
        case .SheetExit:
            var newFrame = view.frame
            newFrame.origin.y = UIScreen.main.bounds.maxY + (view.frame.height)
            UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 2, options: .curveLinear, animations: {
                view.frame = newFrame
            }, completion: nil)
        }
        
    }
    /// 蒙版点击回调
    func touchCallBack() {
        if self.isAllowedCancel == true {
            self.dismiss(animated: true, completion: nil)
        }
    }
    /// 获取类的属性列表
    ///
    /// - Returns: 属性名字数组
    class func getPropertyList(className:AnyClass) -> [String] {
        
        var count: UInt32 = 0
//        let list = class_copyPropertyList(className, &count)
        let list = class_copyIvarList(className, &count)
        var tempArr:[String] = []
        
        for i in 0..<Int(count) {
            let pty = list?[i]
            let cName = ivar_getName(pty!)
            if let name = String(utf8String: cName!) {
                tempArr.append(name)
            }
        }
        
        free(list)
        return tempArr
    }
    
    
}

protocol HFAlertBkViewDelegate: class {
    func touchCallBack()
}


/// 背景View
fileprivate class HFAlertBkView: UIView {
    
    fileprivate weak var bkViewDelegate: HFAlertBkViewDelegate?
    
    /// 背景View是否响应点击事件（选择不影响子控件的响应）
    private var isResponseEvent: Bool = true
    
    /// 用于响应事件的按钮
    fileprivate var fullBkButton: UIButton?
    
    /// 退出背景View的闭包，用于外界调用退出
    private(set) var exitBkView: (() -> Void)?
    
    /// 即将推出时会调用该闭包
    fileprivate var willExitCallBack: (() -> Void)?
    
    
    init(delegate: HFAlertBkViewDelegate?) {
        
        super.init(frame: CGRect.null)
        self.bkViewDelegate = delegate
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    
    /// 创建一个使用按钮事件的完整的背景View，用于自定义弹窗
    ///
    /// - Returns: HFAlertBkView
    fileprivate class func fullBackground() -> HFAlertBkView {
        
        let bkView = HFAlertBkView(frame: UIScreen.main.bounds)
        bkView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.35)
        bkView.isResponseEvent = false
        
        bkView.exitBkView = { () in
            bkView.exit()
        }
        
        return bkView
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 设置背景按钮
    fileprivate func setupFullBkButton() {
        
        let bkButton: UIButton
        bkButton = UIButton(frame: UIScreen.main.bounds)
        bkButton.addTarget(self, action: #selector(HFAlertBkView.fullBkButtonClickCallBack), for: UIControlEvents.touchUpInside)
        self.fullBkButton = bkButton
        self.addSubview(self.fullBkButton!)
        
    }
    
    
    /// 重写点击时间处理
    ///
    /// - Parameters:
    ///   - touches: 触摸点
    ///   - event: 事件
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if self.bkViewDelegate != nil && self.isResponseEvent != false {
            self.bkViewDelegate?.touchCallBack()
            self.removeFromSuperview()
        }
        
    }
    
    
    /// 事件响应按钮的点击回调
    @objc fileprivate func fullBkButtonClickCallBack() {
        
        self.exit()

    }
    
    
    /// 退出背景View
    fileprivate func exit() {
        
        if self.willExitCallBack != nil { self.willExitCallBack!() }
        
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 0
        }, completion: { (_) in
            self.removeFromSuperview()
        })
        
    }
    
    

    
    
}





