//
//  Five100px.swift
//  SwiftPhotoMania
//
//  Created by suraj poudel on 29/05/2016.
//  Copyright © 2016 suraj poudel. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

struct Five100px{
    
    enum Router:URLRequestConvertible{
        
        static let baseURLString = "https://api.500px.com/v1"
        static let consumerKey = "eSEbYZiDOYlzdy0tJcQDxTvtaSJ5c2X1CUQP9jtX"
        case PopularPhotos(Int)
        case PhotoInfo(Int,ImageSize)
        case Comments(Int,Int)
        
        var URLRequest: NSMutableURLRequest{
            let(path,params):(String,[String:AnyObject]) = {
                switch self{
                case .PopularPhotos(let page):
                    let params = ["consumer_key": Router.consumerKey, "page": "\(page)", "feature": "popular", "rpp": "50", "include_store": "store_download", "include_states":"votes"]
                    return ("/photos",params)
                case .PhotoInfo(let photoID,let imageSize):
                    let params = ["consumer_key": Router.consumerKey, "image_size": "\(imageSize.rawValue)"]
                    return ("/photos/\(photoID)", params)
                case .Comments(let photoID,let commentsPage):
                    let params = ["consumer_key": Router.consumerKey, "comments": "1", "comments_page": "\(commentsPage)"]
                    return ("/photos/\(photoID)/comments", params)
                }
            }()
            
            
            let URL = NSURL(string: Router.baseURLString)
            let URLRequest = NSMutableURLRequest(URL: URL!.URLByAppendingPathComponent(path))
            let encoding = ParameterEncoding.URL
            return encoding.encode(URLRequest, parameters: params).0
        }
        
    }
    
    
    enum ImageSize:Int{
        case Tiny = 1
        case Small = 2
        case Medium = 3
        case Large = 4
        case XLarge = 5
    }
}