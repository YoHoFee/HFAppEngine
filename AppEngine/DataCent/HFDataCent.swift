//
//  HFDataCentBase.swift
//  Ecosphere
//
//  Created by 姚鸿飞 on 2017/5/26.
//  Copyright © 2017年 encifang. All rights reserved.
//

import UIKit



class HFDataCent: NSObject {
    
 
    
    internal func uploadImages(images:[UIImage],complete:@escaping ((_ isSucceed: Bool,_ msg: String, _ data: String) -> Void)) {
        
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "getOrderData")
        var flag = true
        var msg = ""
        var tmpStr: String = ""
        
        for image: UIImage in images {
            
            let imageData = UIImageJPEGRepresentation(image, 0.8)
            let encodedImageStr = imageData!.base64EncodedString(options: .lineLength64Characters)
            let param:[String:Any] = ["img":encodedImageStr]
            group.enter()
            queue.async(group: group) {
            HFNetworkManager.request(url: API.imgUp, method: .post, parameters: param, description: "图片批量上传") { (error, resp) in
                
                // 连接失败时
                if error != nil {
                    flag = false
                    tmpStr = ""
                    msg = error!.localizedDescription
                    group.leave()
                    return
                }
                
                let info: String? = resp?["msg"].stringValue
                
                let status: Int? = resp?["status"].intValue
                
                // 请求失败时
                if status != 1 {
                    flag = false
                    tmpStr = ""
                    msg = info!
                    group.leave()
                    return
                }
                
                // 请求成功时
                
                let data = resp!["data"].dictionaryObject
                if tmpStr != "" {
                    tmpStr += ","
                }
                tmpStr += data!["imgUrl"] as! String
                
                msg = info!
                
                group.leave()
                
                }
            }
            
        }
        
        group.notify(queue: .main) {
            
            complete(flag, msg, tmpStr)
        }
        
    }
    
    internal func uploadImages(image:UIImage,complete:@escaping ((_ isSucceed: Bool,_ msg: String, _ data: String?) -> Void)) {
        
        
            let imageData = UIImageJPEGRepresentation(image, 0.8)
            let encodedImageStr = imageData!.base64EncodedString(options: .lineLength64Characters)
            let param:[String:Any] = ["img":encodedImageStr]

                HFNetworkManager.request(url: API.imgUp, method: .post, parameters: param, description: "图片上传") { (error, resp) in
                    
                    // 连接失败时
                    if error != nil {
                        complete(false, error!.localizedDescription, nil)
                        return
                    }
                    
                    let info: String? = resp?["msg"].stringValue
                    
                    let status: Int? = resp?["status"].intValue
                    
                    // 请求失败时
                    if status != 1 {
                        complete(false, info!, nil)
                        return
                    }
                    
                    // 请求成功时
                    
                    let data = resp!["data"].dictionaryObject
                    let imgUrl = data!["imgUrl"] as! String
                    
                    complete(true, info!, imgUrl)

                }

        
    }

    
    /// 写入数据到本地
    ///
    /// - Parameter setSave: 在此回调中设置存储的属性
    /// - Returns: 是否写入成功
    @discardableResult
    internal func writeDataToLocal(setSave:(( _ archiver: inout NSKeyedArchiver) -> String)) -> Bool {
        let data: NSMutableData = NSMutableData()
        var archiver = NSKeyedArchiver(forWritingWith: data)
        
        // 写入数据
//        archiver.encode(self.data_saveList, forKey: "saveList")
//        for (key, obj) in self.data_saveList {
//            archiver.encode(obj, forKey: key)
//        }
        let fileName = setSave(&archiver)
        
        
        
        let path = savePath + "/" + fileName
        
        archiver.finishEncoding()
        let result = data.write(toFile: path, atomically: true)
        return result
    }
    
    
    /// 从本地读取数据
    ///
    /// - Parameter setRead: 设置读取的数据赋值的对象
    internal func readDataFormLocal(fileName: String,setRead:((_ unarchiver: inout NSKeyedUnarchiver) -> Void)) {
        
        let data = NSData(contentsOfFile: savePath + "/" + fileName)
        
        if data == nil {
            return
        }
        var unarchiver = NSKeyedUnarchiver(forReadingWith: data! as Data)
        
        
//        // 读取数据
//        if let list = unarchiver.decodeObject(forKey: "saveList") as? [String: Any] {
//            self.data_saveList = list
//        }
//        for (key, obj) in self.data_saveList {
        //            obj = unarchiver.decodeObject(forKey: "key")
        //        }
        setRead(&unarchiver)
        
        unarchiver.finishDecoding()
        
    }
    
    /// 清理本地数据
    ///
    /// - Returns: return value description
    internal func cleanLocalData() -> Bool {
        
        let fileManager = FileManager.default
        
        let blHave = fileManager.fileExists(atPath: dataFilePath)
        
        if !blHave {
            return false
        }else {
            
            do{
                try fileManager.removeItem(atPath: dataFilePath)
                return true
            }catch{
                return false
            }
            
        }
        
    }
    
    

//    func cleanAllData() -> Void {
//        
//        
//        
//    }

//    /**
//     清空数据
//     */
//    - (void)cleanAllData {
//    
//    u_int count;
//    objc_property_t *properties  =class_copyPropertyList([self class], &count);
//    for (int i = 0; i < count ; i++)
//    {
//    const char* propertyName = property_getName(properties[i]);
//    NSString *propertyStr = [NSString stringWithUTF8String: propertyName];
//    if (propertyStr.length <= 5) {
//    continue;
//    }
//    NSString *subStr = [propertyStr substringWithRange:NSMakeRange(0, 5)];
//    const char *type = property_getAttributes(properties[i]);
//    NSString * typeString = [NSString stringWithUTF8String:type];
//    NSArray * attributes = [typeString componentsSeparatedByString:@","];
//    NSString * typeAttribute = [attributes objectAtIndex:0];
//    NSString * propertyType = [typeAttribute substringFromIndex:1];
//    const char * rawPropertyType = [propertyType UTF8String];
//    if ([subStr  isEqual: @"data_"] || [subStr  isEqual: @"uploa"]) {
//    
//    if (strcmp(rawPropertyType,@encode(NSInteger)) == 0) {
//    [self setValue:@0 forKey:propertyStr];
//    
//    } else if (strcmp(rawPropertyType, @encode(CGFloat)) == 0) {
//    [self setValue:@0 forKey:propertyStr];
//    }else {
//    [self setValue:nil forKey:propertyStr];
//    }
//    }
//    }
//    free(properties);
//    
//    }
//
}
