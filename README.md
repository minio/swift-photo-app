# Swift Photo App

![minio_SWIFT1](https://github.com/minio/swift-photo-app/blob/master/docs/screenshots/minio-SWIFT1.jpg?raw=true)

This example will guide you through the code to build a simple Swift Photo app. In this app, you will learn how a Swift client can use the Photo API Service and load a random image. Full code is available here: https://github.com/minio/swift-photo-app, released under Apache 2.0 License.

##  1. Dependencies

We will be building this app using Xcode 7.0 with Swift 2.0. This app will also consume the Photo API Service we built to get presigned urls that are randomly loaded on click of a button.

* Xcode 7.0 Beta
* Swift 2.0

## 2. SetUp  

Launch Xcode and complete the following steps.

 * Step 1 - Create a new Project. Select Single View Application as shown below and click Next. 


![minio_SWIFT2](https://github.com/minio/swift-photo-app/blob/master/docs/screenshots/minio-SWIFT2.jpg?raw=true)


 * Step 2 - Fill in the Project Name and Organization Name and Identifiers. We have used the below in this example, feel free to customize it to your own needs. Click Next. 


![minio_SWIFT3](https://github.com/minio/swift-photo-app/blob/master/docs/screenshots/minio-SWIFT3.jpg?raw=true)


 * Step 3 -  Now you have an empty MainStoryBoard that is ready to be worked on.

![minio_SWIFT4](https://github.com/minio/swift-photo-app/blob/master/docs/screenshots/minio-SWIFT4.jpg?raw=true)


## 3. MainStoryBoard  
 
 * Let's drag and drop a UIButton to the StoryBoard.
 * Let's also drag and drop an imageView to the StoryBoard.
 * Select both and Add Missing Constraints.
 * Feel free to change the background colors of the UIButton and UIView.

![minio_SWIFT5](https://github.com/minio/swift-photo-app/blob/master/docs/screenshots/minio-SWIFT5.jpg?raw=true)

 
## 4. ViewController.swift 

We will use the Photo API Service we built earlier to service the SwiftPhotoApp client. For the sake of simplicity, we will not use a TableView or a CollectionView to display all of the photos. Instead we will randomly load one of the photos from the presigned URLs we receive from the PhotoAPI Service.

```swift

import UIKit

class ViewController: UIViewController {

    @IBAction func refreshButton(sender: UIButton) {
        
        // Set up the URL Object.
        let url = NSURL(string: "http://play.minio.io:8080/PhotoAPIService-0.0.1-SNAPSHOT/minio/photoservice/list")
        
        // Task fetches the url contents asynchronously.
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
            
            let httpResponse = response as! NSHTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            // Process the response.
            if (statusCode == 200) {
                
                do{
                		// Get the json response.
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments)
                    
                    // Extract the Album json into the albums array.
                    if let albums = json["Album"] as? [[String: AnyObject]] {
                    	
                      	// Pick a random index from the albums array.
                        let randomIndex = Int(arc4random_uniform(UInt32(albums.count)))
                        
                        // Extract the url from the albums array using this random index we generated.
                        let loadImageUrl:String = albums[randomIndex]["url"]  as! String
                        
                        // Prepare the imageView.
                        self.imageView.contentMode = .ScaleAspectFit
                        
                        // Download and place the image in the image view with a helper function.
                        if let checkedUrl = NSURL(string: loadImageUrl) {
                            self.imageView.contentMode = .ScaleAspectFit
                            self.downloadImage(checkedUrl)
                        }
                   
                    }
                }
                    catch {
                        print("Error with Json: \(error)")
                    }
                }
    
        }
        
        task!.resume()
        
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

    // Asynchronous helper function that fecthes data from the PhotoAPIService.
    func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }!.resume()
    }
    
    // Helper function that download asynchronously an image from a given url.
    func downloadImage(url: NSURL){    
        getDataFromUrl(url) { (data, response, error)  in
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                guard let data = data where error == nil else { return }
                self.imageView.image = UIImage(data: data)
            }
        }
    }

}

```

## 5. Info.plist

We need to add the permissions into our info.plist file so that the app can fetch the URLs & images from play.

![minio_SWIFT6](https://github.com/minio/swift-photo-app/blob/master/docs/screenshots/minio-SWIFT6.jpg?raw=true)


Here's the full info.plist file  if you prefer to see the xml version of the above changes.

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

## 7. Run the App

* Launch the iOS Simulator. 
* Press the play button to run & deploy the app onto the simulator. 
* Click on the Load Random Image Button to load a different image overtime.

## 8. Explore Further

- [Photo API Service Example](https://docs.minio.io/docs/java-photo-api-service)
- [Using `minio-java`client SDK with Minio Server](https://docs.minio.io/docs/java-client-quickstart-guide) 
- [Minio Java Client SDK API Reference](https://docs.minio.io/docs/java-client-api-reference)
