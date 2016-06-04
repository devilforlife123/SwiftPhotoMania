//
//  PhotoViewerViewController.swift
//  SwiftPhotoMania
//
//  Created by suraj poudel on 29/05/2016.
//  Copyright © 2016 suraj poudel. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class PhotoViewerViewController:UIViewController,UIScrollViewDelegate,UIPopoverPresentationControllerDelegate,UIActionSheetDelegate{
    
    var photoID:Int = 0
    let scrollView = UIScrollView()
    let imageView = UIImageView()
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    
    var photoInfo:PhotoInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        loadPhoto()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if photoInfo != nil {
            navigationController?.setToolbarHidden(false, animated: true)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setToolbarHidden(true, animated: true)
    }
    
    func loadPhoto(){
        request(Five100px.Router.PhotoInfo(self.photoID, .Large)).validate().responseObject { (response:Response<PhotoInfo,NSError>) in
            switch response.result{
            case .Success(let photoInfo):
                self.photoInfo = photoInfo
                self.addButtomBar()
                self.title = photoInfo.name
                request(.GET,photoInfo.url).validate().responseImage({ (response) in
                    if let image = response.result.value{
                        self.imageView.image = image
                        self.imageView.frame = self.centerFrameFromImage(image)
                        self.spinner.stopAnimating()
                        self.centerScrollViewContents()
                    }
                })
            case .Failure(let error):
                print(error.localizedDescription)
            }
        }
        
    }
    
    func setupView(){
        
        spinner.center = CGPoint(x: view.center.x,y:view.center.y - view.bounds.origin.y/2.0)
        spinner.hidesWhenStopped = true
        spinner.startAnimating()
        view.addSubview(spinner)
        
        scrollView.frame = view.bounds
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 3.0
        scrollView.zoomScale = 1.0
        view.addSubview(scrollView)
        
        imageView.contentMode = .ScaleAspectFill
        scrollView.addSubview(imageView)
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(PhotoViewerViewController.handleDoubleTap(_:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(doubleTapRecognizer)
    }
    
    func zoomInZoomOut(point:CGPoint!){
        let newZoomScale = self.scrollView.zoomScale > (self.scrollView.maximumZoomScale/2) ? self.scrollView.minimumZoomScale : self.scrollView.maximumZoomScale
        
        let scrollViewSize = self.scrollView.bounds.size
        
        let width = scrollViewSize.width / newZoomScale
        let height = scrollViewSize.height / newZoomScale
        let x = point.x - (width / 2.0)
        let y = point.y - (height / 2.0)
        
        let rectToZoom = CGRect(x: x, y: y, width: width, height: height)
        
        self.scrollView.zoomToRect(rectToZoom, animated: true)
    }

    
    func handleDoubleTap(recognizer:UITapGestureRecognizer){
        let pointInView = recognizer.locationInView(self.imageView)
        self.zoomInZoomOut(pointInView)
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }

    
    func centerFrameFromImage(image:UIImage?)->CGRect{
        
        if image == nil{
            return CGRectZero
        }
        
        let scaleFactor = scrollView.frame.size.width / image!.size.width
        
        let newHeight = image!.size.height * scaleFactor
        
        var newImageSize = CGSize(width: scrollView.frame.size.width, height: newHeight)
        
        newImageSize.height = min(scrollView.frame.size.height, newImageSize.height)
        
        let centerFrame = CGRect(x: 0.0, y: scrollView.frame.size.height/2 - newImageSize.height/2, width: newImageSize.width, height: newImageSize.height)
        
        return centerFrame

    }
    
    func centerScrollViewContents() {
        let boundsSize = scrollView.frame
        var contentsFrame = self.imageView.frame
        
        if contentsFrame.size.width < boundsSize.width {
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
        } else {
            contentsFrame.origin.x = 0.0
        }
        
        if contentsFrame.size.height < boundsSize.height {
            contentsFrame.origin.y = (boundsSize.height - scrollView.scrollIndicatorInsets.top - scrollView.scrollIndicatorInsets.bottom - contentsFrame.size.height) / 2.0
        } else {
            contentsFrame.origin.y = 0.0
        }
        
        self.imageView.frame = contentsFrame
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.OverCurrentContext
    }
    
    func presentationController(controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        let navController = UINavigationController(rootViewController: controller.presentedViewController)
        
        return navController
    }

    

    func addButtomBar() {
        var items = [UIBarButtonItem]()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        
        items.append(barButtonItemWithImageNamed("hamburger", title: nil, action: #selector(PhotoViewerViewController.showDetails)))
        
        if photoInfo?.commentsCount > 0 {
            items.append(barButtonItemWithImageNamed("bubble", title: "\(photoInfo?.commentsCount ?? 0)", action: #selector(PhotoViewerViewController.showComments)))
        }
        
        items.append(flexibleSpace)
        items.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: Selector("showActions")))
        items.append(flexibleSpace)
        
        items.append(barButtonItemWithImageNamed("like", title: "\(photoInfo?.votesCount ?? 0)"))
        items.append(barButtonItemWithImageNamed("heart", title: "\(photoInfo?.favoritesCount ?? 0)"))
        
        self.setToolbarItems(items, animated: true)
        navigationController?.setToolbarHidden(false, animated: true)
    }
    
    func barButtonItemWithImageNamed(imageName: String?, title: String?, action: Selector? = nil) -> UIBarButtonItem {
        
        let button = UIButton(type: .Custom)
        
        if imageName != nil {
            button.setImage(UIImage(named: imageName!)!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        }
        
        if title != nil {
            button.setTitle(title, forState: .Normal)
            button.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: 0.0)
            
            let font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
            button.titleLabel?.font = font
        }
        
        let size = button.sizeThatFits(CGSize(width: 90.0, height: 30.0))
        button.frame.size = CGSize(width: min(size.width + 10.0, 60), height: size.height)
        
        if action != nil {
            button.addTarget(self, action: action!, forControlEvents: .TouchUpInside)
        }
        
        let barButton = UIBarButtonItem(customView: button)
        
        return barButton
    }


    
    func showDetails() {
        let photoDetailsViewController = storyboard?.instantiateViewControllerWithIdentifier("PhotoDetails") as? PhotoDetailsViewController
        photoDetailsViewController?.modalPresentationStyle = .OverCurrentContext
        photoDetailsViewController?.modalTransitionStyle = .CoverVertical
        photoDetailsViewController?.photoInfo = photoInfo
    
        presentViewController(photoDetailsViewController!, animated: true, completion: nil)
    }

    
    func showComments(){
        let photoCommentsViewController = storyboard?.instantiateViewControllerWithIdentifier("PhotoComments") as? PhotoCommentsViewController
        photoCommentsViewController?.modalPresentationStyle = .Popover
        photoCommentsViewController?.modalTransitionStyle = .CoverVertical
        photoCommentsViewController?.photoID = photoID
        photoCommentsViewController?.popoverPresentationController?.delegate = self
        presentViewController(photoCommentsViewController!, animated: true, completion: nil)
    }
    
    func showActions(){
        let actionSheet = UIActionSheet(title: nil,delegate: self,cancelButtonTitle: "Cancel",destructiveButtonTitle: nil,otherButtonTitles: "Download Photo")
        actionSheet.showFromToolbar((navigationController?.toolbar)!)
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            downloadPhoto()
        }
    }

    func downloadPhoto(){
        
        request(Five100px.Router.PhotoInfo(photoInfo!.id, .XLarge)).validate().responseObject { (response:Response<PhotoInfo,NSError>) in
            if let error = response.result.error{
                print(error.localizedDescription)
            }else{
                switch response.result{
                case .Failure(let error):
                    print(error.localizedDescription)
                case .Success(let photoInfo):
                    let imageURL = photoInfo.url
                    print("imageURL is \(imageURL)")
                    let destination = Request.suggestedDownloadDestination(directory: .DocumentDirectory, domain: .UserDomainMask)
                    
                    let progressIndicatorView = UIProgressView(frame: CGRect(x: 0.0, y: 80.0, width: self.view.bounds.width, height: 10.0))
                    progressIndicatorView.tintColor = UIColor.blueColor()
                    self.view.addSubview(progressIndicatorView)
                    
                    download(.GET, imageURL,destination: destination).progress({ (bytesRead, totalBytesRead, totalBytesExpectedToRead) in
                        dispatch_async(dispatch_get_main_queue(), { 
                            progressIndicatorView.setProgress(Float(totalBytesRead) / Float(totalBytesExpectedToRead), animated: true)
                            
                            if totalBytesRead == totalBytesExpectedToRead {
                                //Once the download is finished, simply remove the progress bar from the view hierarchy.
                                progressIndicatorView.removeFromSuperview()
                            }

                        })
                    })
                }
            }
        }
        
    }
    
    
    

}

