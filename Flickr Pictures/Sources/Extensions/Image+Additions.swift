//
//  Image + Additions.swift
//  Flickr Pictures
//
//  Created by jenifer_s on 28/01/23.
//

import UIKit

extension UIImageView {
    func load(url: URL, completion: @escaping (Bool)->()) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                        completion(true)
                    }
                } else {
                    completion(false)
                }
            } else {
                completion(false)
            }
        }
    }
}
