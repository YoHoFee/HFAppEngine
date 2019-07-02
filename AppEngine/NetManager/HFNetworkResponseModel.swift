//
//  HFNetworkResponseModel.swift
//  3HMall
//
//  Created by 姚鸿飞 on 2018/4/20.
//  Copyright © 2018年 姚鸿飞. All rights reserved.
//

import UIKit
import ObjectMapper
import SwiftyJSON

class HFNetworkResponseModel: NSObject {

    
    /// 请求状态
    var status: Int?
    
    /// 服务器消息
    var msg: String?
    
    /// 数据包
    var data: JSON?
    
    /// 请求码
    var code: Int?
    
    /// 原始数据包
    var rawData: JSON?
    
    init(status: Int?, msg: String?, data:JSON?, code: Int?,rawData: JSON?) {
        self.status = status
        self.msg = msg
        self.data = data
        self.code = code
        self.rawData = rawData
    }
    
}
