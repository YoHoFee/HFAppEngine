//
//  HFStartViewController.swift
//  Ecosphere
//
//  Created by 姚鸿飞 on 2017/6/13.
//  Copyright © 2017年 encifang. All rights reserved.
//

import UIKit

class HFStartViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.imageView.image = UIImage(named: self.splashImage())
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("【AppEngine】：伪启动页加载完毕")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("【AppEngine】：伪启动页已退出")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //获取启动图片名（根据设备方向和尺寸）
    func splashImage() -> String{
        
        var launchImageName = ""
        var viewOrientation: String
        let viewSize = UIScreen.main.bounds.size
        let orientation = UIApplication.shared.statusBarOrientation
        
        if orientation == .landscapeLeft || orientation == .landscapeRight {
            viewOrientation = "Landscape"
        }else {
            viewOrientation = "Portrait"
        }
  
        guard let imagesInfoArray = Bundle.main.infoDictionary?["UILaunchImages"] else { return "" }
        
        for dict: Dictionary<String, String> in imagesInfoArray as! Array {
            
            let imageSize = NSCoder.cgSize(for: dict["UILaunchImageSize"]!)
            if imageSize.equalTo(viewSize) && viewOrientation == dict["UILaunchImageOrientation"] {
                launchImageName = dict["UILaunchImageName"]!
            }
            
        }
        
        return launchImageName
        
        
    }

}
