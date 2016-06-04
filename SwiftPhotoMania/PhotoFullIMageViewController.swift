//
//  PhotoFullIMageViewController.swift
//  SwiftPhotoMania
//
//  Created by suraj poudel on 4/06/2016.
//  Copyright © 2016 suraj poudel. All rights reserved.
//

import Foundation
import UIKit


class PhotoFullImageViewController:UIViewController{
    
    
    var URL:NSURL?
    @IBOutlet weak var imageView:UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            let localFileData = NSFileManager.defaultManager().contentsAtPath(self.URL!.path! )
            let image = UIImage(data: localFileData!,scale: UIScreen.mainScreen().scale)
            dispatch_async(dispatch_get_main_queue(), { 
                self.imageView.image = image
            })
        }
        
        
    }
}