//
//  PhotoTableViewCell.swift
//  Flickr Pictures
//
//  Created by jenifer_s on 27/01/23.
//

import UIKit

class PhotoTableViewCell : UITableViewCell {
    
    @IBOutlet weak var aImageView: UIImageView!
    @IBOutlet weak var aSpinner: UIActivityIndicatorView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var url = URL(string: "") {
        didSet {
            setupUI()
        }
    }
    
    func setupUI() {
        aImageView.contentMode = .scaleAspectFill
        guard let url = url else {return}
        
        aSpinner.style = .medium
        aSpinner.hidesWhenStopped = true
        aSpinner.startAnimating()
        
        if let cachedImage = imageCache.object(forKey: url as AnyObject) as? UIImage {
            aImageView.image = cachedImage
            aSpinner.stopAnimating()
        } else  {
            FlickrAPI.downloadData(with: url) { data, error in
                guard let validData = data , error == nil else {
                    return
                }
                
                DispatchQueue.main.async {
                    let downloadedImage = UIImage(data: validData)
                    self.aImageView.image = downloadedImage
                    self.aSpinner.stopAnimating()
                    imageCache.setObject(downloadedImage!, forKey: url as AnyObject)
                }
            }
        }
    }
}
