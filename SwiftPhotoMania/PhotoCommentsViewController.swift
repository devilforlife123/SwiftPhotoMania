//
//  PhotoCommentsViewController.swift
//  SwiftPhotoMania
//
//  Created by suraj poudel on 4/06/2016.
//  Copyright © 2016 suraj poudel. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class PhotoCommentsViewController:UITableViewController{
    
    var photoID:Int = 0
    var comments:[Comment]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50.0
        
        title = "Comments"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .Done, target: self, action: #selector(PhotoCommentsViewController.dismiss))
        
        request(Five100px.Router.Comments(photoID, 1)).validate().responseCollection { (response:Response<[Comment],NSError>) in
            
            if let error = response.result.error{
                print(error.localizedDescription)
            }else{
                switch response.result{
                case .Success(let comments):
                    self.comments = comments
                    self.tableView.reloadData()
                case .Failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func dismiss() {
        dismissViewControllerAnimated(true, completion: nil)
    }

}

extension PhotoCommentsViewController{
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier("CommentCell", forIndexPath: indexPath) as! PhotoCommentTableViewCell
        
        cell.userFullNameLabel.text = comments?[indexPath.row].userFullName
        cell.commentLabel.text = comments?[indexPath.row].commentBody
        cell.userImageView.image = nil
        
        if let imageURL = comments?[indexPath.row].userPictureURL{
            request(.GET, imageURL).validate().responseImage({ (response) in
                if let image = response.result.value{
                    cell.userImageView.image = image
                }
            })
        }
        
        return cell 
        
    }
    
    

}