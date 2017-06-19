# HFAppEngine
**v1.0.0**

> HFAppEngine是大多数App的通用引擎，封装了常用的跳转逻辑与方法，例如伪启动图、启动前置任务池、登录前置任务池、登录跳转、注销跳转、验证码定时等。    

## 目录
* [1. 环境要求](#1)
* [2.安装](#2)
* [3.配置](#3)
* [4.使用](#4)
* [5.许可](#5)


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

<h2 id = "3">三、配置</h2>
> 配置引擎是引擎正常运行的关键一步，引擎内置请求逻辑，但需要您根据情况设置项目API中所使用的字段，以及您对请求结果的处理，现在这些需要您处理的代码都集成到**AppConfiguration**文件中。  

### API配置
> API配置是引擎为您进行网络请求的基础，正确配置API地址才可以进行正确的接口请求，现在API配置单独在**API**文件中进行配置，并且我们鼓励您将项目中所有的API接口均记录在此。  

```swift
 // MARK: 服务器地址
    static let baseURL          = "http://www.baidu.com/"
    // MARK: - 通用API -
    // MARK: 图片上传
    static let imgUp            = "/Api/common/Login"
    // MARK: - 登录注册模块API -
    // MARK: 登陆
    static let login            = ""
    // MARK: 注册
    static let register         = ""
    // MARK: 刷新Token
    static let TimeToken        = ""
    // MARK: 自动登录
    static let autoLogin        = ""
    // MARK: 忘记密码
    static let ForgetPwd        = ""
```

### 基础设置
> 只有正确的配置基础设置，才能使引擎的登录功能发挥作用，引擎将使用您设置的字段组合请求参数，发送给您指定的API。  

```swift
    // 是否允许跳过登录限制
    static let isAllowSkipLogin = true
    
    // 服务器的响应中 消息 字段Key
    static let respond_MsgKey = "msg"
    
    // 服务器的响应中 状态 字段Key
    static let respond_StatusKey = "status"
    
    // 服务器的响应中 数据 字段Key
    static let respond_DataKey = "data"
    
    // 登录接口请求参数 账号 字段Key
    static let login_ApiAccountKey = "phone"
    
    // 登录接口请求参数 密码 字段Key
    static let login_ApiPasswordKey = "password"
```

### 视图控制器配置
> 引擎提供了一个默认的UITabBarController，但是所需显示的标签控制器仍需您进行指定，现在您可以在**AppConfiguration**进行视图控制器的配置了，首先找到**setupViewController** 函数，将您控制器的创建代码写在此方法中，并添加到数组返回即可。  

```swift
    /// 设置需要展示的控制器
    /// - 此方法默认会添加一个UITabBarController
    /// - Returns: 将控制器放在数组中返回
    class func setupViewController() -> [UIViewController] {
        
        /*--------------------在下面创建控制器--------------------*/
        
        let VC1 = UIViewController()
        VC1.view.frame = UIScreen.main.bounds
        VC1.view.backgroundColor = UIColor.white
        let VCN1 = UINavigationController(rootViewController: VC1)
        VCN1.navigationBar.isTranslucent = false
        VCN1.tabBarItem.title = "VC1"
        VC1.navigationItem.title = "VC1"
        VC1.view.backgroundColor = UIColor.white
        
        
        let VC2 = UIViewController()
        VC2.view.frame = UIScreen.main.bounds
        VC2.view.backgroundColor = UIColor.white
        let VCN2 = UINavigationController(rootViewController: VC2)
        VCN2.navigationBar.isTranslucent = false
        VCN2.tabBarItem.title = "VC2"
        VC2.navigationItem.title = "VC2"
        VC2.view.backgroundColor = UIColor.red
        
        /*--------------------创建好控制器添加到数组中即可--------------------*/
        
        
        return [
            VCN1,
            VCN2
        ]
        
    }
```

> 如果您需要拥有属于自己的自定义UITabBarController，那么我们还提供了一个全新的函数支持您的想法，首先我们找到**setupMainController**函数，把我们希望使用的UITabBarController在此创建，并将它返回。  

```swift
    /// 设置自定义主控制器
    /// - 此方法在需要使用自定义UITabBarController的时候调用
    /// - Returns: UITabBarController
    class func setupMainController() -> UITabBarController? {
        
        let tabBarController = UITabBarController()
        
        let VC1 = UIViewController()
        VC1.view.frame = UIScreen.main.bounds
        VC1.view.backgroundColor = UIColor.white
        let VCN1 = UINavigationController(rootViewController: VC1)
        VCN1.navigationBar.isTranslucent = false
        VCN1.tabBarItem.title = "VC1"
        VC1.navigationItem.title = "VC1"
        VC1.view.backgroundColor = UIColor.white
        
        
        let VC2 = UIViewController()
        VC2.view.frame = UIScreen.main.bounds
        VC2.view.backgroundColor = UIColor.white
        let VCN2 = UINavigationController(rootViewController: VC2)
        VCN2.navigationBar.isTranslucent = false
        VCN2.tabBarItem.title = "VC2"
        VC2.navigationItem.title = "VC2"
        VC2.view.backgroundColor = UIColor.red
        
        tabBarController.viewControllers = [VC1,
                                            VC2]
        
        
        return tabBarController
    }
```

### 登录结果处理
> 有时登录完成后需要您对登录成功所产生的数据进行处理，我们无法断定您的处理方式，所以这需要您在**AppConfiguration**进行相应处理，首先找到**setupLoginSucceedHandle**函数，并在此进行登录结果的处理，并且在您处理完成后，记得调用函数参数中的**NextExecute**闭包，以告知我们进行下一步处理，这**非常重要！**  

```swift 
    /// 设置登录成功后的操作
    ///
    /// - Parameters:
    ///   - result: 返回的结果
    ///   - NextExecute: 下一步操作
    class func setupLoginSucceedHandle(result:JSON, NextExecute: (Void) -> Void) {

		  // 在此处理您的数据
        NextExecute()
        
    }
```


<h2 id = “4”>四、使用</h2>
### 运行方法

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

### 效果
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

<h2 id = “5”>五、许可</h2>

**此项目为开源项目，允许任何人免费使用并提出宝贵的意见，本项目仅限学习交流，不得用于商业用途，如因本项目引发任何损失，作者不承担任何法律责任。**
