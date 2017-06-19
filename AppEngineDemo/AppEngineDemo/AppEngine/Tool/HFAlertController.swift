//
//  HFAlertController.swift
//  SmallTradePlatform
//
//  Created by 姚鸿飞 on 2016/12/20.
//  Copyright © 2016年 pmec. All rights reserved.
//

import UIKit

/// 对系统弹窗控制器进行封装，实现背景点击返回
class HFAlertController: UIAlertController, HFAlertBkViewDelegate {
    
    /// 底部蒙版
    var newBottonView:  HFAlertBkView?
    /// 头部蒙版
    var newTopView:     HFAlertBkView?
    /// 左边蒙版
    var newLeftView:    HFAlertBkView?
    /// 右边蒙版
    var newRightView:   HFAlertBkView?
    /// 是否允许取消
    var isAllowedCancel: Bool = true
    
    
    /// 弹出默认弹窗
    ///
    /// - Parameters:
    ///   - controller: 主控制器（一般是self）
    ///   - title: 标题文本
    ///   - message: 弹窗内容
    ///   - yesCallBack: 确定按钮回调
    class func showAlertController(controller: UIViewController, title: String, message: String, yesCallBack:((Void) -> Void)?) {
        let obj = HFAlertController.alertController(title: title, message: message, yesCallBack: yesCallBack)
        controller.present(obj, animated: true, completion: nil)
    }
    
    /// 弹出默认弹窗
    ///
    /// - Parameters:
    ///   - controller: 主控制器（一般是self）
    ///   - title: 标题文本
    ///   - message: 弹窗内容
    ///   - yesCallBack: 确定按钮回调
    class func showSheetAlertController(controller: UIViewController, title: String, message: String, yesCallBack:((Void) -> Void)?) {
        let obj = HFAlertController.alertController(title: title, message: message, preferredStyle: .actionSheet ,yesCallBack: yesCallBack)
        controller.present(obj, animated: true, completion: nil)
    }
    
    /// 弹出默认弹窗
    ///
    /// - Parameters:
    ///   - controller: 主控制器（一般是self）
    ///   - title: 标题文本
    ///   - message: 弹窗内容
    ///   - yesCallBack: 确定按钮回调
    class func showOneBtnAlertController(controller: UIViewController, title: String, message: String, yesCallBack:((Void) -> Void)?) {
        let obj = HFAlertController.oneBtnAlertController(title: title, message: message, yesCallBack: yesCallBack)
        controller.present(obj, animated: true, completion: nil)
    }
    
    /**
     默认的弹出窗
     
     - parameter yesCallBack: yesCallBack description
     
     - returns: return value description
     */
    class func alertController(title: String, message: String, preferredStyle: UIAlertControllerStyle = .alert, yesCallBack:((Void) -> Void)?) -> HFAlertController {
        
        let obj = HFAlertController(title: title, message: message, preferredStyle: preferredStyle)
        let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel, handler: nil)
        let yesAction = UIAlertAction(title: "确定", style: UIAlertActionStyle.default) { (_) in
            if yesCallBack != nil {
                yesCallBack!()
            }
        }
        obj.addAction(yesAction)
        obj.addAction(cancelAction)
        
        return obj
    }
    
    
    /// 自定义确定按钮文本的弹出窗
    ///
    /// - Parameters:
    ///   - title: 标题文本
    ///   - message: 弹窗内容
    ///   - yesBtnTitle: 确定按钮文本
    ///   - yesCallBack: 确定按钮回调
    /// - Returns: return value description
    class func alertController(title: String, message: String, yesBtnTitle: String, yesCallBack:((Void) -> Void)?) -> HFAlertController {
        
        let obj = HFAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel, handler: nil)
        let yesAction = UIAlertAction(title: yesBtnTitle, style: UIAlertActionStyle.default) { (_) in
            if yesCallBack != nil {
                yesCallBack!()
            }
        }
        obj.addAction(yesAction)
        obj.addAction(cancelAction)
        
        return obj
    }
    
    
    /// 只有一个确定按钮的弹框（没有取消按钮）
    ///
    /// - Parameters:
    ///   - title: 标题文本
    ///   - message: 弹框内容
    ///   - yesCallBack: 确定按钮回调
    /// - Returns: return value description
    class func oneBtnAlertController(title: String, message: String, yesCallBack:((Void) -> Void)?) -> HFAlertController {
        
        let obj = HFAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let yesAction = UIAlertAction(title: "确定", style: UIAlertActionStyle.default) { (_) in
            if yesCallBack != nil {
                yesCallBack!()
            }
        }
        obj.addAction(yesAction)
        obj.isAllowedCancel = false
        return obj
    }
    
    
    
    /**
     仅在此方法中可获取AlertView的大小
     */
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        let windouw: UIWindow   = UIApplication.shared.keyWindow!
        let bkView: UIView      = (windouw.subviews.last)!
        self.layoutNewbackgroundView(bkView: bkView)
        
    }
    
    
    /**
     布局与设置蒙版
     */
    func layoutNewbackgroundView(bkView: UIView) {
        
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
    
    /**
     蒙版点击回调
     */
    func touchCallBack() {
        if self.isAllowedCancel == true {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}

protocol HFAlertBkViewDelegate: class {
    func touchCallBack()
}

class HFAlertBkView: UIView {
    
    weak var bkViewDelegate: HFAlertBkViewDelegate?
    
    init(delegate: HFAlertBkViewDelegate) {
        
        super.init(frame: CGRect.null)
        self.bkViewDelegate = delegate
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.bkViewDelegate != nil {
            self.bkViewDelegate?.touchCallBack()
            self.removeFromSuperview()
        }
    }
    
    
}

