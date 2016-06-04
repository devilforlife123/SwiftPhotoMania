//
//  DownloadedPhotoBrowserCollectionViewController.swift
//  SwiftPhotoMania
//
//  Created by suraj poudel on 29/05/2016.
//  Copyright © 2016 suraj poudel. All rights reserved.
//

import Foundation
import UIKit

class DownloadedPhotoBrowserCollectionViewController:UICollectionViewController{
    
    var downloadedPhotoURLs:[NSURL]?
    let DownloadedPhotoBrowserCellIdentifier = "DownloadedPhotoBrowserCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.bounds.size.width, height: 200.0)
        
        collectionView!.collectionViewLayout = layout
        
        collectionView!.registerClass(DownloadedPhotoBrowserCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: DownloadedPhotoBrowserCellIdentifier)
        
        navigationItem.title = "Downloads"

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if let directoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as? NSURL{
            var error:NSError?
            let urls:[AnyObject]?
            do{
                urls = try NSFileManager.defaultManager().contentsOfDirectoryAtURL(directoryURL, includingPropertiesForKeys: nil, options: [])
            }catch let error1 as NSError{
                error = error1
                urls = nil
            }
            
            if error == nil{
                downloadedPhotoURLs = urls as? [NSURL]
                collectionView?.reloadData()
            }
            
        }
    }
    
    
}

extension DownloadedPhotoBrowserCollectionViewController{
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return downloadedPhotoURLs?.count ?? 0
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(DownloadedPhotoBrowserCellIdentifier
            , forIndexPath: indexPath) as! DownloadedPhotoBrowserCollectionViewCell
        let localFileData = NSFileManager.defaultManager().contentsAtPath(downloadedPhotoURLs![indexPath.item].path!)
        print("URL is  \(downloadedPhotoURLs![indexPath.item])")
        let image = UIImage(data: localFileData!,scale: UIScreen.mainScreen().scale)
        cell.imageView.image = image
        return cell 
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        performSegueWithIdentifier("ShowFullImage", sender: self.downloadedPhotoURLs![indexPath.item])
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowFullImage"{
            
            (segue.destinationViewController as! PhotoFullImageViewController).URL = sender as? NSURL
            
        }
    }

}
