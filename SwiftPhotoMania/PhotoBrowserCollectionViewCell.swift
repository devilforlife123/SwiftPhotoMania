//
//  PhotoBrowserCollectionViewCell.swift
//  SwiftPhotoMania
//
//  Created by suraj poudel on 29/05/2016.
//  Copyright © 2016 suraj poudel. All rights reserved.
//

import Foundation
import UIKit
import Alamofire


class PhotoBrowserCollectionViewCell:UICollectionViewCell{
    
    let imageView = UIImageView()
    var request:Request?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        imageView.frame = bounds
        addSubview(imageView)
    }
}