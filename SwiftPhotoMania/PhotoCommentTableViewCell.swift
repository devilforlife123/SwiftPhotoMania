//
//  PhotoTableViewCell.swift
//  SwiftPhotoMania
//
//  Created by suraj poudel on 4/06/2016.
//  Copyright © 2016 suraj poudel. All rights reserved.
//

import Foundation
import UIKit

class PhotoCommentTableViewCell:UITableViewCell{
    
    @IBOutlet weak var userImageView:UIImageView!
    @IBOutlet weak var commentLabel:UILabel!
    @IBOutlet weak var userFullNameLabel:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userImageView.layer.cornerRadius = 5.0
        userImageView.layer.masksToBounds = true
        
        commentLabel.numberOfLines = 0
    }
}