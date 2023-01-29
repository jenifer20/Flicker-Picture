//
//  Flickr PicturesAPITests.swift
//  Flickr PicturesTests
//
//  Created by jenifer_s on 27/01/23.
//

import XCTest
@testable import Flickr_Pictures

class Flickr_PicturesAPITests: XCTestCase {
    
    var flikrAPI : FlickrAPI!
    override func setUp() {
        super.setUp()
        flikrAPI = FlickrAPI()
    }
    
    override func tearDown() {
        flikrAPI = nil
        super.tearDown()
    }
    
    // test if requestURL is correctly generated for searching "warnerbros" related flickr photos
    func testBuildRequestURL() {
        let text = "warnerbros"
        let requestURL = FlickrAPI.buildRequestURL(text: text)
        let requestURLString = requestURL.absoluteString
        let correctURLString = "https://api.flickr.com/services/rest?api_key=1508443e49213ff84d566777dc211f2a&method=flickr.photos.search&format=json&text=warnerbros&extras=url_l&nojsoncallback=1&page=1"
        XCTAssertEqual(requestURLString, correctURLString)
    }
    
    
    // a Asynchornous download test. to check if a "cat" related Flickr image can be downloaded
    // "cat" --> requestURL --> downloaded Image
    // test fail when image property is nil
    func testDownloadCatPhoto() {
        
        var image : UIImage?
        let requestURL = FlickrAPI.buildRequestURL(text: "cat")
        
        let flicrAnswerExpectation = expectation(description: "WaitForFlicrToResponse")
        
        FlickrAPI.downloadData(with: requestURL) { data, error in
            guard let data = data, let json = try? JSON(data:data) else {
                return
            }
            
            let urls = FlickrAPI.parseJSON_Search(with: "cat", json: json)
            let url = urls.url[0]
            FlickrAPI.downloadData(with: url) { data, error in
                guard let validData = data , error == nil else {
                    print(" fail to download image at url:\(url)")
                    return
                }
                
                DispatchQueue.main.async {
                    let downloadedImage = UIImage(data: validData)
                    imageCache.setObject(downloadedImage!, forKey: url as AnyObject)
                    
                    // successfully download image to image
                    image = downloadedImage
                    flicrAnswerExpectation.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 10, handler:nil)
        XCTAssertNotNil(image)
    }
    
    func testDownloadMatchingURLs_Performance() {
        
        measure {
            let requestURL = FlickrAPI.buildRequestURL(text: "cat")
            FlickrAPI.downloadData(with: requestURL) { data, error in
                guard let data = data, let json = try? JSON(data:data) else {
                    return
                }
                
                let urls = FlickrAPI.parseJSON_Search(with: "cat", json: json)
                var pictureItems = PhotosResponse()
                pictureItems.url = urls.url
            }
        }
    }
    
    func testRequestMatchingPhotos_Performance() {
        
        measure {
            let requestURL = FlickrAPI.buildRequestURL(text: "cat")
            FlickrAPI.downloadData(with: requestURL) { data, error in
                guard let data = data, let json = try? JSON(data:data) else {
                    return
                }
                
                let urls = FlickrAPI.parseJSON_Search(with: "cat", json: json)
                for url in urls.url {
                    FlickrAPI.downloadData(with: url) { data, error in
                        guard let validData = data , error == nil else {
                            print(" fail to download image at url:\(url)")
                            return
                        }
                        
                        DispatchQueue.main.async {
                            let downloadedImage = UIImage(data: validData)
                            imageCache.setObject(downloadedImage!, forKey: url as AnyObject)
                        }
                    }
                }
            }
        }
    }
}
