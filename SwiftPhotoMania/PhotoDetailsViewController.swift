//
//  PhotoDetailsViewController.swift
//  SwiftPhotoMania
//
//  Created by suraj poudel on 4/06/2016.
//  Copyright © 2016 suraj poudel. All rights reserved.
//

import Foundation
import UIKit

class PhotoDetailsViewController:UIViewController{
    
    @IBOutlet weak var highestLabel:UILabel!
    @IBOutlet weak var pulseLabel:UILabel!
    @IBOutlet weak var viewsLabel:UILabel!
    @IBOutlet weak var descriptionLabel:UILabel!
    
    var photoInfo:PhotoInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(PhotoDetailsViewController.dismiss))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        view.addGestureRecognizer(tapGesture)
        
        highestLabel.text = String(format: "%.1f", photoInfo?.highest ?? 0)
        pulseLabel.text = String(format: "%.1f", photoInfo?.pulse ?? 0)
        viewsLabel.text = "\(photoInfo?.views ?? 0)"
        descriptionLabel.text = photoInfo?.desc
    }
    
    func dismiss(){
     self.dismissViewControllerAnimated(true, completion: nil)
    }
}
