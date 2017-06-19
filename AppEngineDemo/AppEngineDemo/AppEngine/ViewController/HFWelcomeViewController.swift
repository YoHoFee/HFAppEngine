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
        return 3
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        let imageName = "ImageName + row"
        let imageView = UIImageView(image: UIImage(named: imageName))
        let button = UIButton()
        button.addTarget(self, action: #selector(self.buttonClickOnCallBack), for: UIControlEvents.touchUpInside)
        button.setTitle("点击进入", for: .normal)
        button.titleLabel?.textColor = UIColor.white
        cell.contentView.addSubview(imageView)
        cell.contentView.addSubview(button)
        imageView.snp.makeConstraints { (make) in
            make.edges.equalTo(cell.contentView)
        }
        button.snp.makeConstraints { (make) in
            make.leading.equalTo(cell.contentView).offset(100)
            make.trailing.equalTo(cell.contentView).offset(-100)
            make.bottom.equalTo(cell.contentView).offset(-70)
            make.height.equalTo(60)
        }
        if indexPath.row == 2 {
            button.isHidden = false;
        }else {
            button.isHidden = true;
        }
        
        
        // 删除以下代码
        let red = CGFloat(arc4random_uniform(255))/CGFloat(255.0)
        let green = CGFloat( arc4random_uniform(255))/CGFloat(255.0)
        let blue = CGFloat(arc4random_uniform(255))/CGFloat(255.0)
        let alpha = CGFloat(arc4random_uniform(255))/CGFloat(255.0)
        let label = UILabel()
        label.text = "新特性（欢迎）界面"
        label.textColor = UIColor.black
        label.sizeToFit()
        label.center = cell.contentView.center
        cell.contentView.addSubview(label)
        let color = UIColor.init(red:red, green:green, blue:blue , alpha: alpha)
        cell.contentView.backgroundColor = color
        // -----------
        
        return cell
    }
    
    func buttonClickOnCallBack() {
        HFAppEngine.shared.gotoLoginViewController()
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
