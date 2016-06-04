//
//  DownloadedPhotoBrowserCollectionViewCell.swift
//  SwiftPhotoMania
//
//  Created by suraj poudel on 4/06/2016.
//  Copyright © 2016 suraj poudel. All rights reserved.
//

import Foundation
import UIKit

class DownloadedPhotoBrowserCollectionViewCell:UICollectionViewCell{
    let imageView = UIImageView()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(imageView)
        imageView.frame = bounds
        imageView.contentMode = .ScaleAspectFit
    }
}