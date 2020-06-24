//
//  Picture.swift
//  Challenge3
//
//  Created by Danny Vo on 2020-06-18.
//  Copyright © 2020 Danny Vo. All rights reserved.
//

import UIKit

class Picture: NSObject, Codable {
    var caption: String
    var image: String
    
    init(caption: String, image: String){
        self.caption = caption
        self.image = image
    }
}
