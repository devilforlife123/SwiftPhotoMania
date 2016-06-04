//
//  PhotoInfo.swift
//  SwiftPhotoMania
//
//  Created by suraj poudel on 29/05/2016.
//  Copyright © 2016 suraj poudel. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class PhotoInfo: NSObject,ResponseObjectSerializable{
    
    let id: Int
    let url: String
    
    var name: String?
    
    var favoritesCount: Int?
    var votesCount: Int?
    var commentsCount: Int?
    
    var highest: Float?
    var pulse: Float?
    var views: Int?
    var camera: String?
    var desc: String?
    
    init(id:Int,url:String){
        self.id = id
        self.url = url
    }
    
    required init?(response: NSHTTPURLResponse, representation: AnyObject) {
        self.id = representation.valueForKeyPath("photo.id") as! Int
        self.url = representation.valueForKeyPath("photo.image_url") as! String
        
        self.favoritesCount = representation.valueForKeyPath("photo.favorites_count") as? Int
        self.votesCount = representation.valueForKeyPath("photo.votes_count") as? Int
        self.commentsCount = representation.valueForKeyPath("photo.comments_count") as? Int
        self.highest = representation.valueForKeyPath("photo.highest_rating") as? Float
        self.pulse = representation.valueForKeyPath("photo.rating") as? Float
        self.views = representation.valueForKeyPath("photo.times_viewed") as? Int
        self.camera = representation.valueForKeyPath("photo.camera") as? String
        self.desc = representation.valueForKeyPath("photo.description") as? String
        self.name = representation.valueForKeyPath("photo.name") as? String
    }
    
    override func isEqual(object: AnyObject!) -> Bool {
        return (object as! PhotoInfo).id == self.id
    }
    
    override var hash: Int {
        return (self as PhotoInfo).id
    }
    
}

final class Comment:ResponseCollectionSerializable{
    
    
    let userFullName:String
    let userPictureURL:String
    let commentBody:String
   
    init(JSON:AnyObject){
        userFullName = JSON.valueForKeyPath("user.fullname") as! String
        userPictureURL = JSON.valueForKeyPath("user.userpic_url") as! String    
        commentBody = JSON.valueForKeyPath("body") as! String
    }
    
    static func collection(response response:NSHTTPURLResponse,representation:AnyObject)->[Comment]{
        
        var comments = [Comment]()
        
        for comment in representation.valueForKey("comments") as! [NSDictionary]{
            comments.append(Comment(JSON: comment))
        }
        return comments
    }
    
}





























