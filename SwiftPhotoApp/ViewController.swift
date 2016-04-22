//
//  ViewController.swift
//  SwiftPhotoApp
//
//  Created by Deepa Mahalingam on 4/21/16.
//  Copyright © 2016 Deepa Mahalingam. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBAction func refreshButton(sender: UIButton) {
        
        
        let url = NSURL(string: "http://play.minio.io:8080/MinioJavaRESTExample-0.0.1-SNAPSHOT/minio/photoservice/list")
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
            
            let httpResponse = response as! NSHTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if (statusCode == 200) {
                
                do{
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments)
                    
                    if let albums = json["Album"] as? [[String: AnyObject]] {
                        let randomIndex = Int(arc4random_uniform(UInt32(albums.count)))
                        
                        
                        let loadImageUrl:String = albums[randomIndex]["url"]  as! String
                        
                        self.imageView.contentMode = .ScaleAspectFit
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

    
    func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }!.resume()
    }
    
    func downloadImage(url: NSURL){
        print("Download Started")
        print("lastPathComponent: " + (url.lastPathComponent ?? ""))
        getDataFromUrl(url) { (data, response, error)  in
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                guard let data = data where error == nil else { return }
                
                self.imageView.image = UIImage(data: data)
            }
        }
    }

}

