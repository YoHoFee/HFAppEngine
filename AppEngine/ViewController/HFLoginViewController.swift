//
//  HFLoginViewController.swift
//  AppEngineDemo
//
//  Created by 姚鸿飞 on 2017/6/14.
//  Copyright © 2017年 姚鸿飞. All rights reserved.
//

import UIKit

class HFLoginViewController: UIViewController {

    @IBOutlet weak var phone: UITextField!
    
    @IBOutlet weak var pw: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.frame = UIScreen.main.bounds
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginBtnClickCallBack(_ sender: UIButton) {
        HFAppEngine.shared.gotoMainController()
    }

    @IBAction func getVerificationCodeBtnClickCallBack(_ sender: UIButton) {
        
        sender.isUserInteractionEnabled = false
        sender.setTitleColor(UIColor.gray, for: .normal)
        HFAppEngine.shared.runGeneralTimerTimer(duration: 60) { (flag) in
            sender.setTitle("\(flag)", for: .normal)
            if flag == 0 {
                sender.isUserInteractionEnabled = true
                sender.setTitleColor(UIColor.blue, for: .normal)
                sender.setTitle("获取验证码", for: .normal)
            }
        }
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
