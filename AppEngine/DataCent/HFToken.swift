//
//  HFToken.swift
//  3HMall
//
//  Created by 姚鸿飞 on 2018/4/21.
//  Copyright © 2018年 姚鸿飞. All rights reserved.
//

import UIKit
import ObjectMapper

class HFToken: NSObject,Mappable {
    
    /// 长时效签名
    var longSign: String = "" {
        didSet {
            UserDefaults.standard.set(self.longSign, forKey: HFToken.longSignKey)
            print("[write success] ======= Token已经成功将longSign写入本地")
        }
    }
    
    /// 短时效签名
    var apiSign: String = "" {
        didSet {
            UserDefaults.standard.set(self.apiSign, forKey: HFToken.apiSignKey)
            print("[write success] ======= Token已经成功将apiSign写入本地")
        }
    }
    
    /// 长时效签名本地存储键
    static let longSignKey: String = "longSign"
    
    /// 短时效签名本地存储键
    static let apiSignKey: String = "apiSign"
    
    
    // MARK: - 工厂方法
    override init() {
        super.init()
    }
    
    init(longSign: String, apiSign: String) {
        super.init()
        
        self.longSign = longSign
        self.apiSign = apiSign
        
    }
    
    required init?(map: Map) {
        
    }
    
    
    func mapping(map: Map) {
        
        self.longSign <- map["sign_login"]
        self.apiSign <- map["sign_api"]
        
        
    }
    
    
    // MARK: - 刷新令牌
    /// 刷新令牌
    ///
    /// - Parameter complete: -
    func refreshApiSign(complete:@escaping ((_ isSucceed: Bool, _ message: String) -> Void)) {
        
    }
    
    // MARK: - 从本地加载令牌
    /// 从本地加载令牌
    ///
    /// - Returns: -
    class func loadInLocation() -> HFToken? {
        
        let longSign = UserDefaults.standard.string(forKey: self.longSignKey)
        let apiSign = UserDefaults.standard.string(forKey: self.apiSignKey)
        if longSign != nil && apiSign != nil {
            let token = HFToken(longSign: longSign!, apiSign: apiSign!)
            return token
        }else {
            return nil
        }
        
        
    }
    
    // MARK: - 清理令牌
    /// 清理令牌
    class func cleanToken() {
        UserDefaults.standard.set(nil, forKey: self.longSignKey)
        UserDefaults.standard.set(nil, forKey: self.apiSignKey)
    }
    
    

    
    
}
