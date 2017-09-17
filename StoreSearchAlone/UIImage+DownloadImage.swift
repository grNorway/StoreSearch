//
//  UIImage+DownloadImage.swift
//  StoreSearch
//
//  Created by Panagiotis Siapkaras on 7/8/17.
//  Copyright © 2017 Panagiotis Siapkaras. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView{
    
    func loadImage(url: URL) -> URLSessionDownloadTask{
        
        let session = URLSession.shared
        
        let downloadTask = session.downloadTask(with: url) { [weak self](url, response, error) in
            
            if error == nil , let url = url , let data = try? Data(contentsOf: url),let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    if let strongSelf = self{
                        strongSelf.image = image
                    }
                }
            }
        }
        downloadTask.resume()
        return downloadTask
    }
    
}
