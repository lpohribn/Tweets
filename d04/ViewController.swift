//
//  ViewController.swift
//  d04
//
//  Created by Liudmyla POHRIBNIAK on 3/17/19.
//  Copyright © 2019 Liudmyla POHRIBNIAK. All rights reserved.
//

import UIKit

class customCell: UITableViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var tweetText: UILabel!
}

class ViewController: UIViewController , APITwitterDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var fieldOfsearch: UITextField!
    @IBOutlet weak var tweetterTable: UITableView!
    
    let apiKey = "LVWblG1QfGWZrc7eVYkwURUBe"
    let apiSecret = "7ahu3RxFLEsfZxJvpmX2NtOGg3CnB9OufRrqOFtiShfKvYoEg2"
    var accessToken =  ""
    var arrayOftweets : [Tweet] = []
    
    func receiveTweets(tweets: [Tweet]) {
        self.arrayOftweets = tweets
        DispatchQueue.main.async {
            self.tweetterTable.reloadData()
            if self.arrayOftweets.count == 0 {
                self.showAlert("not found tweets")
            }
        }
    }
    
    func callError(error: NSError) {
        showAlert(error.domain)
        print("callError")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fieldOfsearch.delegate = self
        tweetterTable.delegate = self
        tweetterTable.dataSource = self
//        tweetterTable.rowHeight = UITableViewAutomaticDimension
        
        let bearer = ((apiKey + ":" + apiSecret).data(using: String.Encoding.utf8))!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        let url = NSURL(string: "https://api.twitter.com/oauth2/token?grant_type=client_credentials")
        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "POST"
        request.setValue("Basic \(bearer)", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = "grant_type=client_credentials".data(using: String.Encoding.utf8)
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            if error != nil {
                print("error")
                return
            }
            do {
                if let dic : NSDictionary = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary {
                    self.accessToken = (dic["access_token"] as? String)!
//                    print(self.accessToken)
                }
            } catch(let error) {
                self.showAlert(error as! String)
                return
            }

        }
        task.resume()
    }
    
    func showAlert(_ error: String) {
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
        arrayOftweets = []
        tweetterTable.reloadData()
        let apiCon = APIController(delegate: self, token: self.accessToken)
        apiCon.getTweets(tweet: textField.text!)
        return true
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayOftweets.count
    }
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//        tableView.deselectRow(at: indexPath, animated: true)
//    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dateFormatter = DateFormatter()
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "MM/dd/yyyy HH:mm:ss"
        dateFormatter.dateFormat = "E MMM d HH:mm:ss Z yyyy"
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellTweet") as! customCell
        cell.name.text = arrayOftweets[indexPath.row].name
        cell.tweetText.text = arrayOftweets[indexPath.row].text
        let newDate = dateFormatter.date(from: arrayOftweets[indexPath.row].date)
        cell.date.text = dateFormatter1.string(from: newDate!)
//        arrayOftweets[indexPath.row].date
        return cell
    }
}
