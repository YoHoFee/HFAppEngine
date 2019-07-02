//
//  HFWelcomeViewController.swift
//  Ecosphere
//
//  Created by 姚鸿飞 on 2017/6/13.
//  Copyright © 2017年 encifang. All rights reserved.
//

import UIKit
import SnapKit


private let reuseIdentifier = "WelcomeCell"

class HFWelcomeViewController: UICollectionViewController {
    

    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.flowLayout.itemSize = UIScreen.main.bounds.size
        self.flowLayout.minimumLineSpacing = 0;
        self.flowLayout.minimumInteritemSpacing = 0;
        self.collectionView?.backgroundColor = UIColor.white

        self.automaticallyAdjustsScrollViewInsets = false

        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 4
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        let color = UIColor(red: CGFloat(arc4random() % 255) / 255.0, green: CGFloat(arc4random() % 255) / 255.0, blue: CGFloat(arc4random() % 255) / 255.0, alpha: 1.0)
        cell.backgroundColor = color
        
        let tintLabel = UILabel()
        let button = UIButton()
        button.addTarget(self, action: #selector(self.buttonClickOnCallBack), for: UIControl.Event.touchUpInside)
        button.setTitle("点击进入", for: .normal)
        button.titleLabel?.textColor = UIColor.white
        tintLabel.text = "这是引导页，请向左滑动"
        tintLabel.textColor = UIColor.white
        tintLabel.font = UIFont.systemFont(ofSize: 15)
        for item in cell.contentView.subviews {
            item.removeFromSuperview()
        }
//        cell.contentView.addSubview(imageView)
        cell.contentView.addSubview(button)
        
//        imageView.snp.makeConstraints { (make) in
//            make.edges.equalTo(cell.contentView)
//        }
        button.snp.makeConstraints { (make) in
            make.edges.equalTo(cell.contentView)
        }
        

        button.isHidden = true;
        if indexPath.row == 3 {
            button.isHidden = false;
        }else {
            cell.contentView.addSubview(tintLabel)
            tintLabel.snp.makeConstraints { (make) in
                make.center.equalTo(cell.contentView)
            }
        }
        
    
        
        return cell
    }
    
    @objc func buttonClickOnCallBack() {
        if HFAppEngine.shared.configuration.isMustLogin == true {
            HFAppEngine.shared.gotoLoginViewController()
        }else {
            HFAppEngine.shared.gotoMainControllerWithNotLogin()
        }
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    
}
