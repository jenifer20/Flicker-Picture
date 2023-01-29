//
//  FlickrAPI.swift
//  Flickr Pictures
//
//  Created by jenifer_s on 27/01/23.
//

import UIKit

// NSCache to cache all downloaded images
var imageCache: NSCache<AnyObject, AnyObject> = NSCache()

class FlickrAPI {
    
    //Generate request URL based on searchBar input text
    class func buildRequestURL(text:String) -> URL {
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.flickr.com"
        components.path = "/services/rest"
        components.queryItems = [URLQueryItem]()
        
        let queryKey = URLQueryItem(name: "api_key", value: "1508443e49213ff84d566777dc211f2a")
        let queryMethod = URLQueryItem(name: "method", value: "flickr.photos.search")
        let queryFormat = URLQueryItem(name: "format", value: "json")
        let queryText = URLQueryItem(name: "text", value: text)
        let queryExtra = URLQueryItem(name: "extras", value: "url_l")
        let queryNojsoncallback = URLQueryItem(name: "nojsoncallback", value: "1")
        let queryPage = URLQueryItem(name: "page", value: "1")
        
        components.queryItems!.append(queryKey)
        components.queryItems!.append(queryMethod)
        components.queryItems!.append(queryFormat)
        components.queryItems!.append(queryText)
        components.queryItems!.append(queryExtra)
        components.queryItems!.append(queryNojsoncallback)
        components.queryItems!.append(queryPage)
        
        return components.url!
    }
    
    static func downloadData(with url:URL,completion:@escaping (_ data:Data?,_ error:Error?)->Void) {
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let validData = data, error == nil else {
                completion(nil,error!)
                return
            }
            completion(validData,nil)
        }
        task.resume()
    }
    
    
    //SwiftyJSON to parse response json :  photoArray[0]["url_l"]
    class func parseJSON_Search(with text:String, json:JSON) -> PhotosResponse {
        
        var imageURLs = [URL]()
        let photoArray = json["photos"]["photo"].arrayValue
        var response = PhotosResponse()
        
        for i in 0 ..< photoArray.count where imageURLs.count < 25 {
            
            let title = photoArray[i]["title"].stringValue
            let urlString = photoArray[i]["url_l"].stringValue
            
            let farm = photoArray[i]["farm"]
            let server = photoArray[i]["server"]
            let id = photoArray[i]["id"]
            let secret = photoArray[i]["secret"]
            let size = "m"
            
            let thumbnailUrl = "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_\(size).jpg"
            if let url = URL(string: thumbnailUrl) {
                response.thumbnail.append(url)
            } else {
                if let thumbnail = URL(string: "https://www.flickr.com/images/buddyicon.gif") {
                    response.thumbnail.append(thumbnail)
                }
            }
            
            response.title.append(title)
            
            if let url = URL(string: urlString) {
                response.url.append(url)
                imageURLs.append(url)
            }
        }
        return response
    }
}
