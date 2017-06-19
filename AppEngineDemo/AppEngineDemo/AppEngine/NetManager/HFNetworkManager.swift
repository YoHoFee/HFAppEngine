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
    
    
    class func request(url: String, method: HTTPMethod = .get, parameters: Parameters? = nil, description: String = "未命名请求", complete: @escaping (_ error: Error? ,_ data:JSON?) -> Void) {
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10
        
        let api = API.baseURL + url
        print("———————— 发起请求 ————————\n请求名称: \(description)\n请求方式: \(method.rawValue)\n地址: \(api)\n参数: \(JSON(parameters ?? [:]))\n—————————————————————\n")
        
//        Alamofire.responseSerializer

        Alamofire.request(api, method: method, parameters: parameters).responseJSON { (resp) in
            let data = JSON(resp.result.value as Any)
            print(resp)
            let status = data["status"].intValue
            
            if resp.result.isSuccess == false {
                
                print("———————— 连接失败 ————————\n请求名称: \(description)\n请求方式: \(method.rawValue)\n地址: \(api)\n异常: \(String(describing: resp.result.error.debugDescription))\n—————————————————————\n")

                complete(resp.result.error!,nil)
                return
                
            }else {
                
                if status == 1 {
                    print("———————— 收到响应 ————————\n请求名称: \(description)\n请求方式: \(method.rawValue)\n地址: \(api)\n状态: \(resp.result.isSuccess)\n数据: \(data)\n—————————————————————\n")
                    
                    complete(nil,data)
                    return
                }else if status == 10000 {
                    print("———————— 连接失败 ————————\n请求名称: \(description)\n请求方式: \(method.rawValue)\n地址: \(api)\n异常: \(data["msg"].stringValue))\n—————————————————————\n")
                    SVProgressHUD.dismiss()
                    HFAppEngine.shared.loginDidFailure(msg: data["msg"].stringValue)
                    return
                } else {
                    
                    print("———————— 收到响应 ————————\n请求名称: \(description)\n请求方式: \(method.rawValue)\n地址: \(api)\n状态: \(resp.result.isSuccess)\n异常: \(data["info"].stringValue)\n数据: \(data)\n—————————————————————\n")
                    complete(nil,data)
                    return
                }
                
                
            }
            
            //            complete(data)
            
        }
        
    }
    
//    class func download(url: String, description: String = "未命名请求", complete: @escaping (_ error: Error? ,_ data:JSON?) -> Void) {
//        Alamofire.download(url).response { (resp) in
//            print(resp)
//        }
//    }
//    

}
