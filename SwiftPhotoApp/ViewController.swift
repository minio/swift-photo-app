//
//  SwiftPhotoApp, (C) 2017 Minio, Inc.
// 
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
// 
//      http://www.apache.org/licenses/LICENSE-2.0
// 
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.


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

