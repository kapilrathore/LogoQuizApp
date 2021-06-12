//
//  ImageLoader.swift
//  QuizApp
//
//  Created by Kapil Rathore on 12/06/21.
//

import UIKit

class ImageLoader {
    private let cache = NSCache<NSString, NSData>()
    private let defaultImage = UIImage(systemName: "trash")
    
    func loadLogo(from urlString: String, completion: @escaping (UIImage?)->()) {
        guard let url = URL(string: urlString) else {
            completion(self.defaultImage)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                completion(self.defaultImage)
                return
            }
            
            completion(UIImage(data: data))
        }.resume()
    }
}
