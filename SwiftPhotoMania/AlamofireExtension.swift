//
//  AlamofireExtension.swift
//  SwiftPhotoMania
//
//  Created by suraj poudel on 29/05/2016.
//  Copyright © 2016 suraj poudel. All rights reserved.
//

import Foundation
import Alamofire



public protocol ResponseCollectionSerializable{
    
    static func collection(response response:NSHTTPURLResponse,representation:AnyObject)->[Self]
}


public protocol ResponseObjectSerializable{
    
    init?(response:NSHTTPURLResponse,representation:AnyObject)
}

extension Request{
    
    public func responseCollection<T:ResponseCollectionSerializable>(completionHandler:Response<[T],NSError>->())->Self{
        
        let responseSerializer = ResponseSerializer<[T],NSError> { (request, response, data, error) -> Result<[T], NSError> in
            guard error == nil else { return .Failure(error!)}
            
            let jsonSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
            let result = jsonSerializer.serializeResponse(request, response, data, error)
            
            switch result{
            case .Success(let value):
                if let response = response{
                    return .Success(T.collection(response: response, representation: value))
                }else{
                    let failureReason = "Response collection could not be serialized"
                    let error = Error.errorWithCode(.JSONSerializationFailed, failureReason: failureReason)
                    return .Failure(error)
                }
            case .Failure(let error):
                return .Failure(error)
            }
        }
        
        return response(responseSerializer:responseSerializer,completionHandler:completionHandler)
        
    }
    
    
    public func responseObject<T:ResponseObjectSerializable>(completionHandler:Response<T,NSError>->())->Self{
        
        let responseSerializer = ResponseSerializer<T,NSError> { (request, response, data, error) -> Result<T, NSError> in
            guard error == nil else { return .Failure(error!)}
            
            let jsonResponseSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
            let result = jsonResponseSerializer.serializeResponse(request, response, data, error)
            switch result{
            case .Success(let value):
                if let response = response , JSON = T(response: response, representation: value){
                    return .Success(JSON)
                }else{
                    
                    let failureReason =  "JSON could not be serialized into response object \(value)"
                    let error =  Error.errorWithCode(.JSONSerializationFailed, failureReason: failureReason)
                    return .Failure(error)
                }
            case .Failure(let error):
                return .Failure(error)
            }
        }
        return response(responseSerializer:responseSerializer,completionHandler:completionHandler)
    }
    
    
    public func responseImage(completionHandler:Response<UIImage,NSError>->())->Self{
        return response(responseSerializer:Request.imageResponseSerializer(),completionHandler:completionHandler)
    }
    
    public static func imageResponseSerializer()->ResponseSerializer<UIImage,NSError>{
        return ResponseSerializer(serializeResponse: { (request, response, data, error) -> Result<UIImage, NSError> in
            guard let validData = data else{
                let failureReason = "Data could not be serialized.Input data was nil"
                let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
                return .Failure(error)
            }
            guard let image = UIImage(data:validData,scale: UIScreen.mainScreen().scale)else{
                
                let failureReason = "Data could not be converted to UIImage"
                let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
                return .Failure(error)
            }
            
            return .Success(image)
        })
    }
}
