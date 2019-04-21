//
//  APIController.swift
//  d04
//
//  Created by Liudmyla POHRIBNIAK on 3/28/19.
//  Copyright © 2019 Liudmyla POHRIBNIAK. All rights reserved.
//

import UIKit

protocol APITwitterDelegate: class {
    func receiveTweets(tweets: [Tweet])
    func callError(error: NSError)
}

class APIController {

    weak var delegate: APITwitterDelegate?
    let token: String
    var tweets : [Tweet] = []
    
    init(delegate: APITwitterDelegate, token: String)
    {
        self.delegate = delegate
        self.token = token
    }
    
    func getTweets(tweet: String) {
        DispatchQueue.global().async {
            let url = "https://api.twitter.com/1.1/search/tweets.json?q=\(tweet)&count=100&lang=en&result_type=recent"
            let searchUrl = NSURL(string : url.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)
            let searchRequest = NSMutableURLRequest(url : searchUrl! as URL)
            
            
            searchRequest.setValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")
            searchRequest.httpMethod = "GET"
            searchRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let taskSearch = URLSession.shared.dataTask(with: searchRequest as URLRequest) {
                (data, response, error) in
                if error != nil {
                    let err = NSError(domain: error as! String, code: 1, userInfo: nil)
                    self.delegate?.callError(error: err
                    )
                    return
                } else if data != nil {
                    do {
                        let dic : NSDictionary = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                        let allTweets = dic["statuses"] as? [NSDictionary]
                        if allTweets != nil{
                            for tweet in allTweets! {
                                let textTweet = tweet["text"] as? String
                                let userDic = tweet["user"] as? NSDictionary
                                var name = ""
                                for (key, value) in userDic! {
                                    if ("\(key)" == "name"){
                                        name = value as! String
                                    }
                                }
                                let date = (tweet["created_at"] as? String)!
                                self.tweets.append(Tweet(description: "", date: date, name: name, text: textTweet!))
                            }
                        }else{
                            let err = NSError(domain: "Tweets not found", code: 1)
                            self.delegate?.callError(error: err)
                            return
                        }
                        self.delegate?.receiveTweets(tweets: self.tweets)
                        return
                    }catch {
                        let err = NSError(domain: "Tweets not found ((", code: 1)
                        self.delegate?.callError(error: err)
                        return
                    }
                }
            }
            taskSearch.resume()
        }
    }
}

