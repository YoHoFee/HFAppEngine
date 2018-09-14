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

    var status: Int?
    var msg: String?
    var data: JSON?
    var code: Int?
    var rawData: JSON?
    
    init(status: Int?, msg: String?, data:JSON?, code: Int?,rawData: JSON?) {
        self.status = status
        self.msg = msg
        self.data = data
        self.code = code
        self.rawData = rawData
    }
    
}
