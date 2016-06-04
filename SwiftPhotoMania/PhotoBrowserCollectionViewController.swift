//
//  PhotoBrowserCollectionViewController.swift
//  SwiftPhotoMania
//
//  Created by suraj poudel on 29/05/2016.
//  Copyright © 2016 suraj poudel. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class PhotoBrowserCollectionViewController:UICollectionViewController,UICollectionViewDelegateFlowLayout{
    
    
    var photos = NSMutableOrderedSet()
    
    let imageCache = NSCache()
    
    var populatingPhotos = false
    
    let refreshControl = UIRefreshControl()
    
    var currentPage = 1
    
    let PhotoBrowserCellIdentifier = "PhotoBrowserCell"
    
    let PhotoBrowserFooterViewIdentifier = "PhotoBrowserFooterView"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        populatePhotos()
    }
    
    func setupView(){
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        let layout = UICollectionViewFlowLayout()
        
        let itemWidth = (view.bounds.size.width - 2)/3
        
        layout.itemSize = CGSize(width: itemWidth,height: itemWidth)
        
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        layout.footerReferenceSize = CGSize(width: collectionView!.bounds.size.width,height: 100.0)
        collectionView!.collectionViewLayout = layout
        navigationItem.title = "Featured"
        
        collectionView!.collectionViewLayout = layout
        
        collectionView!.registerClass(PhotoBrowserCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: PhotoBrowserCellIdentifier)
        collectionView!.registerClass(PhotoBrowserCollectionViewLoadingCell.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: PhotoBrowserFooterViewIdentifier)
        
        refreshControl.tintColor = UIColor.whiteColor()
        refreshControl.addTarget(self, action: #selector(PhotoBrowserCollectionViewController.handleRefresh), forControlEvents: .ValueChanged)
        collectionView!.addSubview(refreshControl)
    }
    
    
    func populatePhotos(){
        if populatingPhotos{
            return
        }
        
        populatingPhotos = true
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            
            if self.populatingPhotos{
                return
            }
            
            self.populatingPhotos = true
            
            request(Five100px.Router.PopularPhotos(self.currentPage)).responseJSON { (response) in
                if let JSON = response.result.value{
                    //print(JSON)
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                        let photoInfos =  ((JSON as! NSDictionary).valueForKey("photos") as! [NSDictionary]).filter({
                            ($0["nsfw"] as! Bool) == false }).map {
                                PhotoInfo(id: ($0["id"] as! Int), url: $0["image_url"] as! String)
                        }
                        
                        //print("PhotoInfos are \(photoInfos)")
                        //Store the current number of photos before adding any new batch
                        
                        let lastItem = self.photos.count
                        
                        //If someone uploaded new photos to 500px.com before you scrolled, the next batch of photos you get might contain a few photos that you’d already downloaded. That’s why you defined var photos = NSMutableOrderedSet() as a set; since all items in a set must be unique, this guarantees you won’t show a photo more than once
                        //print("The number of photInfos are \(photoInfos.count)")
                        self.photos.addObjectsFromArray(photoInfos)
                        
                        //Create an array of indexPath objects to insert into collectionView
                        
                        
                        //Changes every element in the array to the NSIndexPath object and returns an array of NSIndexPaths
                        let indexPaths = (lastItem ..< self.photos.count).map({NSIndexPath(forItem: $0, inSection: 0)})
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            self.collectionView!.insertItemsAtIndexPaths(indexPaths)
                        })
                        
                        
                        self.currentPage += 1
                        
                    })
                }
                self.populatingPhotos = false
            }
        }
        
        populatingPhotos = false
        
        
    }
    
    
    func handleRefresh(){
        
        //The code below simply empties your current - All it does is empty your model(self.photos), reset the currentPage and refresh the UI
        refreshControl.beginRefreshing()
        self.photos.removeAllObjects()
        self.currentPage = 1
        self.collectionView!.reloadData()
        refreshControl.endRefreshing()
        populatePhotos()
        
    }
}

extension PhotoBrowserCollectionViewController{
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        //print("The number of photos are \(photos.count)")
        return photos.count
    }

    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PhotoBrowserCellIdentifier, forIndexPath: indexPath) as!
        PhotoBrowserCollectionViewCell
        
        let imageURL = (photos.objectAtIndex(indexPath.item) as! PhotoInfo).url
        cell.request?.cancel()//The dequeued Cell may already have an alamofire request attached to it. You can simply cancel it because it's no longer valid for this new cell
        
        //If it is in the cache
        if let image = self.imageCache.objectForKey(imageURL) as? UIImage{
            cell.imageView.image = image
        }else{
            //If you don’t have a cached version of the photo, download it. However, the the dequeued cell may be already showing another image; in this case, set it to nil so that the cell is blank while the requested photo is downloaded
            cell.imageView.image = nil
            //Download the image from the server, but this time validate the content-type of the returned response. If it’s not an image, error will contain a value and therefore you won’t do anything with the potentially invalid image response. The key here is that you you store the Alamofire request object in the cell, for use when your asynchronous network call returns
            
            cell.request = request(.GET, imageURL).validate(contentType: ["image/*"]).responseImage({ (response) in
                if let img = response.result.value where response.result.error == nil{
                    self.imageCache.setObject(img, forKey: response.request!.URLString)
                    
                    cell.imageView.image = img
                }else{
                    
                }
            })
        }
        
        return cell
    }
    
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("ShowPhoto", sender: (self.photos.objectAtIndex(indexPath.item) as! PhotoInfo).id)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowPhoto"{
            
            (segue.destinationViewController as! PhotoViewerViewController).photoID = sender!.integerValue
            (segue.destinationViewController as! PhotoViewerViewController).hidesBottomBarWhenPushed = true 
            
        }
    }
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: PhotoBrowserFooterViewIdentifier, forIndexPath: indexPath)
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y + view.frame.size.height > scrollView.contentSize.height * 0.8{
            //Loads more photos once the user has scrolled 80% of the view
            populatePhotos()
        }
    }

    
}

























