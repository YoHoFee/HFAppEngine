# HFAppEngine
**v1.0.0**

> HFAppEngine是大多数App的通用引擎，封装了常用的跳转逻辑与方法，例如伪启动图、启动前置任务池、登录前置任务池、登录跳转、注销跳转、验证码定时等。  

## 目录
* [1. 环境要求](#jump)
* [2.安装](#2)
* [3.使用](#)
* [4.许可](#)

<h2 id = "1">一、环境要求</h2>
* Xcode 8.1 或 更高
* iOS 8     或 更高
* Swift3.0  或 更高
* Objective-C

<h2 id = "2">二、安装</h2>

1 将AppEngine文件夹拖入项目目录。
2 安装并初始化项目CocoaPod（如果已安装可跳过）

> 安装CocoaPod  

```bash
$ gem install cocoapods
```

> 更新Pod规格库  

```bash
$ pod setup
```

> 跳转到项目根目录  

```bash
$ cd yourPath(项目所在目录) 
```

> 初始化Pod  

```bash
$ pod init
```

3 打开项目根目录*Podfile*文件添加依赖库列表

```ruby
  pod 'SVProgressHUD'
  pod 'Alamofire'
  pod 'SwiftyJSON'
  pod 'SnapKit'
  pod 'CryptoSwift'
  pod 'IQKeyboardManager'
```

4 安装依赖库

```bash
$ pod install
``` 

5 安装完成后重新打开项目文件夹，点击后缀为**.xcworkspace**的项目文件重新打开项目
6 在AppDelegate中运行引擎
```swift
 func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // 启动App引擎
        HFAppEngine.run()
  
        return true
    }

```

**如果需要在Objective-C中使用，请点击[此处](http://www.cnblogs.com/Yun-Longcom/p/5809740.html)查看设置方式，按步骤设置Xcode即可正常调用，在Objective-C中方法名不变。**

<h2 id = “3”>三、使用</h2>
1. 运行方法
**默认运行方式**
> 必须在AppDelegate中运行引擎，引擎会自动为你处理所有事情，包括Window的创建和展示，使用这种方式运行引擎应避免在此方法中添加多余的代码。  
```swift
 func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // 启动App引擎
        HFAppEngine.run()
  
        return true
    }

```

**自定义运行方式**
> 选择此方式启动引擎时所有效果的加载已经Window的创建显示都需要您手动完成，当您需要在AppDelegate中添加其他代码时使用此方式。  
```swift
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        // 启动App引擎
        HFAppEngine.shared.run { (rootVC) in
            
            self.window?.rootViewController = rootVC
            self.window?.makeKeyAndVisible()
            
        }
        
        return true
    }
```

2. 效果
**淡入淡出效果**
> 此效果在使用默认运行模式时将被自动挂载  
```swift
// 当前显示的控制器过渡切换到新的控制器
HFAppEngine.shared.fadeOver(window: window!, toViewVC: rootVC)
```

**视图陀螺仪晃动效果**
> 如果添加此效果的View有背景图片，那么该View的大小需要向四周方法放大，放大的量与您注册时所填入的depth一致，否则将会导致View偏移时的白边  
```swift
/// 注册运动动态效果
///   - aView: 需要添加效果的View
///   - depth: 偏移量
HFAppEngine.shared.registerEffectForView(aView: view, depth: 15)
```

<h2 id = "4">四、许可</h2>

**此项目为开源项目，允许任何人免费使用并提出宝贵的意见，本项目仅限学习交流，不得用于商业用途，如因本项目引发任何损失，作者不承担任何法律责任。**
