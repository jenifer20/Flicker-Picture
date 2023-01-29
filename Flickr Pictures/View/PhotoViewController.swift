//
//  PhotoViewController.swift
//  Flickr Pictures
//
//  Created by jenifer_s on 27/01/23.
//

import UIKit

class PhotoViewController: UIViewController {
    
    @IBOutlet weak var photoSpinner: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    var url : URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photoSpinner.style = .large
        photoSpinner.hidesWhenStopped = true
        photoSpinner.startAnimating()
        
        imageView.contentMode = .scaleToFill
        imageView.load(url: self.url) { (result) -> () in
            if result {
                self.photoSpinner.stopAnimating()
            }
        }
        imageView.backgroundColor = .white
    }
}
