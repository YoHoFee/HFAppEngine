//
//  HFNetworkManager.swift
//  Ecosphere
//
//  Created by 姚鸿飞 on 2017/6/2.
//  Copyright © 2017年 encifang. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SVProgressHUD
import ObjectMapper


class HFNetworkManager: NSObject {
    
    /// 请求池
    private var requestPool: Dictionary<String,String> = [:]
    /// 请求编号主键
    private var requestNumber: Int = 1
    /// 会话管理
    private lazy var sessionManager:SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = TimeInterval(HFAppConfiguration.requestOutTime)
        return Alamofire.SessionManager(configuration: configuration)
    }()
    
    
    /// 请求连接
    ///
    /// - Parameters:
    ///   - url: 请求地址
    ///   - method: 请求方法
    ///   - parameters: 请求参数
    ///   - description: 请求描述
    ///   - complete: complete description
    class func request(url: String,
                       needBaseURL: Bool = true,
                       method: HTTPMethod = .post,
                       parameters: Parameters? = nil,
                       description: String = "未命名请求",
                       complete: @escaping (_ error: Error? ,_ data:HFNetworkResponseModel?) -> Void) {
        
        
        var api = url
        if needBaseURL == true {
            api = API.baseURL + url
        }
        
        if HFAppEngine.shared.networkManager.requestPool[api] != nil {
            //            complete(NSError(domain: "重复请求", code: 10088, userInfo: nil), nil)
            return
        }
        
        
        HFAppEngine.shared.networkManager.requestPool[api] = "\(HFAppEngine.shared.networkManager.requestNumber)"
        HFAppEngine.shared.networkManager.requestNumber += 1
        
        var requestHeader: HTTPHeaders = ["language": UserDefaults.standard.array(forKey: "AppleLanguages")![0] as! String]
        
        if HFAppEngine.shared.token != nil {
            if url == API.TimeToken {
                requestHeader["loginsign"] = HFAppEngine.shared.token!.longSign
            }else {
                requestHeader["apisign"] = HFAppEngine.shared.token!.apiSign
            }
        }
        
        print(requestHeader)
        
        print("———————— 发起请求 ————————\n请求名称: \(description)\n请求编号: \(HFAppEngine.shared.networkManager.requestPool[api]!)\n请求方式: \(method.rawValue)\n地址: \(api)\n参数: \(JSON(parameters ?? [:]))\n—————————————————————\n")
        
        HFAppEngine.shared.networkManager.sessionManager.request(api, method: method, parameters: parameters,headers: requestHeader).responseJSON { (resp) in
            let fullUrl = resp.request?.url?.absoluteString
            let data = JSON(resp.result.value as Any)
            let status = data["status"].intValue
            let code = data["code"].intValue
            let requestNumber = HFAppEngine.shared.networkManager.requestPool[fullUrl!]!
            debugPrint(resp)
            let statusCode = resp.response == nil ? 0 : resp.response?.statusCode
            let dataSize = resp.data == nil ? 0 : resp.data?.count
            if resp.result.isSuccess == false {
                
                print("———————— 连接失败 ————————\n请求名称: \(description)\n请求编号: \(requestNumber)\n状态码:\(statusCode!)\n请求方式: \(method.rawValue)\n地址: \(api)\n异常: \(String(describing: resp.result.error.debugDescription))\n—————————————————————\n")
                HFAppEngine.shared.networkManager.requestPool.removeValue(forKey: fullUrl!)
                complete(resp.result.error!,nil)
                return
                
            }else {
                
                let instance = HFNetworkResponseModel(status: status, msg: data["msg"].string, data: data["data"], code: code, rawData: data)
                if status == 1 {
                    print("———————— 收到响应 ————————\n请求名称: \(description)\n请求编号: \(requestNumber)\n请求方式: \(method.rawValue)\n地址: \(api)\n状态: \(resp.result.isSuccess)\n状态码:\(statusCode!)\n包大小:\(dataSize!) bytes\n数据: \(data)\n—————————————————————\n")
                    HFAppEngine.shared.networkManager.requestPool.removeValue(forKey: fullUrl!)
                    complete(nil,instance)
                    
                    return
                }else if code == 10000 {
                    print("———————— 连接失败 ————————\n请求名称: \(description)\n请求编号: \(requestNumber)\n状态码:\(statusCode!)\n请求方式: \(method.rawValue)\n地址: \(api)\n异常: \(data["msg"].stringValue))\n—————————————————————\n")
                    SVProgressHUD.dismiss()
                    HFAppEngine.shared.networkManager.requestPool.removeValue(forKey: fullUrl!)
                    //                    HFAppEngine.shared.loginDidFailure(msg: data["msg"].stringValue)
                    return
                }else if code == 30003 || code == 30004 {
                    print("———————— Token过期 ————————\n请求名称: \(description)\n请求编号: \(requestNumber)\n请求方式: \(method.rawValue)\n地址: \(api)\n状态: \(resp.result.isSuccess)\n状态码:\(statusCode!)\n异常: \(data["info"].stringValue)\n数据: \(data)\n—————————————————————\n")
                    HFAppEngine.shared.networkManager.requestPool.removeValue(forKey: fullUrl!)
                    self.requestRefreshToken(complete: { (isSucceed, msg) in
                        switch isSucceed {
                        case true:
                            
                            HFNetworkManager.request(url: url, needBaseURL: needBaseURL, method: method, parameters: parameters, description: description, complete: complete)
                            
                            break
                        case false:
                            SVProgressHUD.showError(withStatus: msg)
                            break
                        }
                    })
                    
                }else if code == 30001 {
                    
                    print("===========长Token失效")
                    //                    HFAlertController.showAlert(type: HFAlertType.OnlyConfirm, title: localized(key: "登录失效"), message: localized(key: "用户登录已过期，请重新登录"), ConfirmCallBack: { (_, _) in
                    //                        AppEngine?.loginOut()
                    //                    })
                    
                    
                }else {
                    
                    print("———————— 收到响应 ————————\n请求名称: \(description)\n请求编号: \(requestNumber)\n请求方式: \(method.rawValue)\n地址: \(api)\n状态: \(resp.result.isSuccess)\n状态码:\(statusCode!)\n异常: \(data["info"].stringValue)\n数据: \(data)\n—————————————————————\n")
                    HFAppEngine.shared.networkManager.requestPool.removeValue(forKey: fullUrl!)
                    complete(nil,instance)
                    return
                }
                
                
            }
            
        }
        
    }
    
    
    class func requestRefreshToken(complete:@escaping ((_ isSucceed: Bool, _ message: String) -> Void)) {
        
        if HFAppEngine.shared.token?.longSign == nil {
            HFAppEngine.shared.loginOut()
            return
        }
        
        let param: [String:Any] = [:]
        
        HFNetworkManager.request(url: API.TimeToken, method: .post, parameters:param, description: "刷新Token") { (error, resp) in
            
            // 连接失败时
            if error != nil {
                complete(false, error!.localizedDescription)
                return
            }
            let status: Int = resp!.status!
            let msg: String = resp!.msg!
            
            // 请求失败时
            if status == 0 {
                complete(false, msg)
                HFAppEngine.shared.loginOut()
                return
            }
            
            // 请求成功时
            HFAppEngine.shared.token?.apiSign = resp!.data!["sign_api"].string!
            
            complete(true ,msg)
        }
        
    }
    
}

