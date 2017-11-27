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
                       method: HTTPMethod = .post,
                       parameters: Parameters? = nil,
                       description: String = "未命名请求",
                       complete: @escaping (_ error: Error? ,_ data:JSON?) -> Void) {
        
        let api = API.baseURL + url
        
        if HFAppEngine.shared.networkManager.requestPool[api] != nil {
            complete(NSError(domain: "重复请求", code: 10088, userInfo: nil), nil)
            return
        }
        
        
        HFAppEngine.shared.networkManager.requestPool[api] = "\(HFAppEngine.shared.networkManager.requestNumber)"
        HFAppEngine.shared.networkManager.requestNumber += 1
        
        
        print("———————— 发起请求 ————————\n请求名称: \(description)\n请求编号: \(HFAppEngine.shared.networkManager.requestPool[api]!)\n请求方式: \(method.rawValue)\n地址: \(api)\n参数: \(JSON(parameters ?? [:]))\n—————————————————————\n")
        
        HFAppEngine.shared.networkManager.sessionManager.request(api, method: method, parameters: parameters).responseJSON { (resp) in
            let url = resp.request?.url?.absoluteString
            let data = JSON(resp.result.value as Any)
            let status = data["status"].intValue
            let requestNumber = HFAppEngine.shared.networkManager.requestPool[url!]!
            debugPrint(resp)
            if resp.result.isSuccess == false {
                
                print("———————— 连接失败 ————————\n请求名称: \(description)\n请求编号: \(requestNumber)\n请求方式: \(method.rawValue)\n地址: \(api)\n异常: \(String(describing: resp.result.error.debugDescription))\n—————————————————————\n")
                HFAppEngine.shared.networkManager.requestPool.removeValue(forKey: url!)
                complete(resp.result.error!,nil)
                return
                
            }else {
                
                if status == 1 {
                    print("———————— 收到响应 ————————\n请求名称: \(description)\n请求编号: \(requestNumber)\n请求方式: \(method.rawValue)\n地址: \(api)\n状态: \(resp.result.isSuccess)\n数据: \(data)\n—————————————————————\n")
                    HFAppEngine.shared.networkManager.requestPool.removeValue(forKey: url!)
                    complete(nil,data)
                    
                    return
                }else if status == 10000 {
                    print("———————— 连接失败 ————————\n请求名称: \(description)\n请求编号: \(requestNumber)\n请求方式: \(method.rawValue)\n地址: \(api)\n异常: \(data["msg"].stringValue))\n—————————————————————\n")
                    SVProgressHUD.dismiss()
                    HFAppEngine.shared.networkManager.requestPool.removeValue(forKey: url!)
//                    HFAppEngine.shared.loginDidFailure(msg: data["msg"].stringValue)
                    return
                } else {
                    
                    print("———————— 收到响应 ————————\n请求名称: \(description)\n请求编号: \(requestNumber)\n请求方式: \(method.rawValue)\n地址: \(api)\n状态: \(resp.result.isSuccess)\n异常: \(data["info"].stringValue)\n数据: \(data)\n—————————————————————\n")
                    HFAppEngine.shared.networkManager.requestPool.removeValue(forKey: url!)
                    complete(nil,data)
                    return
                }
                
                
            }
            
        }
        
    }


}
