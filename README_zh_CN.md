# Swift Photo App [![Slack](https://slack.minio.io/slack?type=svg)](https://slack.minio.io)

![minio_SWIFT1](https://github.com/minio/swift-photo-app/blob/master/docs/screenshots/minio-SWIFT1.jpg?raw=true)

本示例将会指导你使用Swift构建一个简单的Photo app。在这个app中，你将会学习一个Swift client是如何访问Photo API Service并随机加载一张图片。你可以通过[这里](https://github.com/minio/swift-photo-app)获取完整的代码，代码是以Apache 2.0 License发布的。

##  1. 依赖

我们将使用Xcode7.0和Swift2.0来构建这个app。这个app也会访问我们发布的Photo API Service来随机获获取一张图片的presigned url。

* Xcode 8.3 Beta
* Swift 3.1

## 2. 设置  

启动Xcode并完成下列步骤。

 * 步骤1 - 创建一个新的工程，选择Single View Application,点击Next。 


![minio_SWIFT2](https://github.com/minio/swift-photo-app/blob/master/docs/screenshots/projectTemplate1.01.png?raw=true)


 * 步骤2 - 输入Project Name，Organization Name和Identifiers。我们在本示例中用的是下图所示的值，你想改的话请便。点击Next。 

![minio_SWIFT3](https://github.com/minio/swift-photo-app/blob/master/docs/screenshots/minio-SWIFT3.jpg?raw=true)


 * 步骤3 - 现在一个空的MainStoryBoard已经准备就绪。

![minio_SWIFT4](https://github.com/minio/swift-photo-app/blob/master/docs/screenshots/storyBoard1.01.png?raw=true)


## 3. MainStoryBoard  
 
 * 拖拽一个UIButton到这个StoryBoard。
 * 拖拽一个imageView到这个StoryBoard。
 * 如果你不太喜欢它们的背景色的话，你可以改成你喜欢的颜色。

![minio_SWIFT5](https://github.com/minio/swift-photo-app/blob/master/docs/screenshots/minio-SWIFT5.jpg?raw=true)

 
## 4. ViewController.swift 

我们将会用到之前构建的Phtoto API Service来给我们的SwiftPhotoApp提供服务。为了简单起见，我们没有用到TableView或者是CollectionView来显示图片列表，我们只是从PhotoAPI Service返回的多个presigned URL中随机选一个进行加载。

```swift
import UIKit

class ViewController: UIViewController {
    
    @IBAction func refButton(sender: UIButton) {
        
        // Set up the URL Object.
        let url = URL(string: "http://play.minio.io:8080/PhotoAPIService-0.0.1-SNAPSHOT/minio/photoservice/list")
        
        // Task fetches the url contents asynchronously.
        let task = URLSession.shared.dataTask(with: url! as URL) {(data, response, error) in
            
            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            // Process the response.
            if (statusCode == 200) {
                
                do{
                    // Get the json response.
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String:AnyObject]
                    
                    // Extract the Album json into the albums array.
                    if let albums = json["Album"] as? [[String: AnyObject]]{
                        
                        // Pick a random index from the albums array.
                        let randomIndex = Int(arc4random_uniform(UInt32(albums.count)))
                        
                        // Extract the url from the albums array using this random index we generated.
                        let loadImageUrl:String = albums[randomIndex]["url"]  as! String
                        
                        // Prepare the imageView.
                        self.imageView.contentMode = .scaleAspectFit
                        
                        // Download and place the image in the image view with a helper function.
                        if let checkedUrl = URL(string: loadImageUrl) {
                            self.imageView.contentMode = .scaleAspectFit
                            self.downloadImage(url: checkedUrl)
                        }
                        
                    }
                }
                catch {
                    print("Error with Json: \(error)")
                }
            }
            
        }
        
        task.resume()
        
    }
    
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Asynchronous helper function that fetches data from the PhotoAPIService.
    func getDataFromUrl(url:URL, completion: @escaping ((_ data: Data?, _ response: URLResponse?, _ error: Error? ) -> Void)) {
        URLSession.shared.dataTask(with: url as URL) { (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
    
    // Helper function that download asynchronously an image from a given url.
    func downloadImage(url: URL){
        getDataFromUrl(url: url) { (data, response, error)  in
            DispatchQueue.main.async() { () -> Void in
                guard let data = data, error == nil else { return }
                self.imageView.image = UIImage(data: data as Data)
            }
        }
    }
    
}

```

## 5. Info.plist

我们需要在info.plist文件中添加权限，这样的话app才能从play服务上获取URL和图片。

![minio_SWIFT6](https://github.com/minio/swift-photo-app/blob/master/docs/screenshots/infoplst1.01.png?raw=true)

以下是完整的info.plist文件。

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>en</string>
	<key>CFBundleExecutable</key>
	<string>$(EXECUTABLE_NAME)</string>
	<key>CFBundleIdentifier</key>
	<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>$(PRODUCT_NAME)</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0</string>
	<key>CFBundleSignature</key>
	<string>????</string>
	<key>CFBundleVersion</key>
	<string>1</string>
	<key>LSRequiresIPhoneOS</key>
	<true/>
	<key>UILaunchStoryboardName</key>
	<string>LaunchScreen</string>
	<key>UIMainStoryboardFile</key>
	<string>Main</string>
	<key>UIRequiredDeviceCapabilities</key>
	<array>
		<string>armv7</string>
	</array>
	<key>UISupportedInterfaceOrientations</key>
	<array>
		<string>UIInterfaceOrientationPortrait</string>
		<string>UIInterfaceOrientationLandscapeLeft</string>
		<string>UIInterfaceOrientationLandscapeRight</string>
	</array>
    
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSExceptionDomains</key>
        <dict>
            <key>play.minio.io</key>
            <dict>
                <key>NSIncludesSubdomains</key>
                <true/>
                <key>NSTemporaryExceptionAllowsInsecureHTTPLoads</key>
                <true/>
                <key>NSTemporaryExceptionMinimumTLSVersion</key>
                <string>1.0</string>
                <key>NSTemporaryExceptionRequiresForwardSecrecy</key>
                <false/>
            </dict>
        </dict>
    </dict>
</dict>

</plist>
```

## 7. 运行App

* 启动iOS模拟器。 
* 点击play按钮deploy这个app到模拟器上并运行。 
* 点击`Load Random Image Button`随机加载一张图片。

## 8. 了解更多

- [Photo API Service Example](https://docs.minio.io/docs/java-photo-api-service)
- [Using `minio-java`client SDK with Minio Server](https://docs.minio.io/docs/java-client-quickstart-guide) 
- [Minio Java Client SDK API Reference](https://docs.minio.io/docs/java-client-api-reference)
