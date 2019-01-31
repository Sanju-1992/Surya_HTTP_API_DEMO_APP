//
//  APIService.swift
//  HttpPostApiDemo_Surya
//
//  Created by Toor, Sanju on 30/01/19.
//  Copyright © 2019 Toor, Sanju. All rights reserved.
//

import Foundation

class APIService {
    
    private init() {}
    static let shared = APIService()
    
    // We'll need a completion block that returns an error if we run into any problems
    func submitPost(post: Post, completion: @escaping(_ itemsDict: [[String: Any]]?, _ error: Error?) -> ()) {
        var urlComponents = URLComponents()
        urlComponents.scheme = "http"
        urlComponents.host = "surya-interview.appspot.com"
        urlComponents.path = "/list"
        guard let url = urlComponents.url else { fatalError("Could not create URL from components") }
        
        // Specify this request as being a POST method
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Make sure that we include headers specifying that our request's HTTP body
        // will be JSON encoded
        var headers = request.allHTTPHeaderFields ?? [:]
        headers["Content-Type"] = "application/json"
        request.allHTTPHeaderFields = headers
        
        // Now let's encode out Post struct into JSON data...
        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(post)
            // ... and set our request's HTTP body
            request.httpBody = jsonData
            print("jsonData: ", String(data: request.httpBody!, encoding: .utf8) ?? "sanjutoor@gmail.com")
        } catch {
            completion(nil,error)
        }
        
        // Create and run a URLSession data task with our JSON encoded POST request
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: request) { (responseData, response, responseError) in
            guard responseError == nil else {
                completion(nil, responseError)
                return
            }
            
            
            // APIs usually respond with the data you just sent in your POST request
            if let data = responseData, let utf8Representation = String(data: data, encoding: .utf8) {
                print("response: ", utf8Representation)
                
                do {
                    let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                    guard let jsonDictionary = jsonObject as? [String: Any], let result = jsonDictionary["items"] as? [[String: Any]] else {
                        //throw NSError(domain: dataErrorDomain, code: DataErrorCode.wrongDataFormat.rawValue, userInfo: nil)
                        throw NSError(domain: "wrong format error", code: 101, userInfo: nil)
                    }
                    print("response Data in dictionary format:\(result)")
                    completion(result, nil)
                } catch {
                    completion(nil, error)
                }
            } else {
                print("no readable data received in response")
                completion(nil,nil)
            }
        }
        task.resume()
    }
    
}
