//
//  ViewController.swift
//  swift-mastdon-client
//
//  Created by Nobuhiro Takahashi on 2017/04/24.
//  Copyright © 2017年 Nobuhiro Takahashi. All rights reserved.
//

import UIKit

class MainViewController: UITableViewController {
    
    var responseJson = Dictionary<String, AnyObject>()
    var responseJson2 = NSDictionary()
    let session = URLSession.shared
    var emailText = ""
    var passwordText = ""
    var domain = ""
    var instanceDomains: Array<String> = []
    var accessTokens: Array<String> = []
    @IBOutlet weak var addButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func addButtonWasTapped(_ sender: UIBarButtonItem) {
        createInstance()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.instanceDomains.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        self.domain = self.instanceDomains[indexPath.row]
        self.loginAlert()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InstanceReadyViewCell")
        cell?.textLabel?.text = self.instanceDomains[indexPath.row]
        return cell!
    }
    
    func createInstance() {
        
        let alert = UIAlertController(title: "SIGN IN", message: "", preferredStyle: .alert)
        alert.addTextField { (textField: UITextField) in
            textField.placeholder = "instance domain"
        }
        let action1 = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {
            (action: UIAlertAction!) in
            self.instanceDomains.append((alert.textFields?[0].text!)!)
            self.tableView.reloadData()
            
            self.dismiss(animated: true, completion: {
                
            })
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: {
            (action: UIAlertAction!) in
            self.dismiss(animated: true, completion: nil)
        })
        
        alert.addAction(action1)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    // =================
    
    func loginAlert() {
        let alert = UIAlertController(title: "SIGN IN", message: "", preferredStyle: .alert)
        alert.addTextField { (textField: UITextField) in
            textField.placeholder = "email"
        }
        alert.addTextField { (textField: UITextField) in
            textField.placeholder = "password"
            textField.isSecureTextEntry = true
        }
        let action1 = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {
            (action: UIAlertAction!) in
            self.emailText = (alert.textFields?[0].text!)!
            self.passwordText = (alert.textFields?[1].text)!
            self.register()
            
            self.dismiss(animated: true, completion: { 
                
            })
        })

        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: {
            (action: UIAlertAction!) in
            self.dismiss(animated: true, completion: nil)
        })
        
        alert.addAction(action1)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func register() {
    
        let registUrl = URL(string: "https://\(self.domain)/api/v1/apps")!
        let body: [String: String] = [
            "client_name": "Swift Client",
            "redirect_uris": "urn:ietf:wg:oauth:2.0:oob",
            "scopes": "read write follow"
        ]
        
        do {
            try post(url: registUrl, body: body) { data, response, error in
                do {
                    self.responseJson = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! Dictionary<String, AnyObject>
                    self.login()
                } catch {
                }
            }
        } catch {
        }
    }
    
    func login() {
        print("login")
        let loginUrl = URL(string: "https://\(self.domain)/oauth/token")!
        
        let body: [String: String] = [
            "scope": "read write follow",
            "client_id": responseJson["client_id"] as! String,
            "client_secret": responseJson["client_secret"] as! String,
            "grant_type": "password",
            "username": self.emailText,
            "password": self.passwordText
        ]
        
        do {
            try post(url: loginUrl, body: body) { data, response, error in
                do {
                    self.responseJson2 = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSDictionary
                    self.toot()
                    
                    
                } catch {
                    print("json error: \(error)")
                    print("json error: \(error.localizedDescription)")
                }
            }
        } catch {
        }
    }
    
    func toot() {
        print("toot")
        let tootUrl = URL(string: "https://\(self.domain)/api/v1/statuses")!
        let body: [String: String] = [
            "access_token": responseJson2["access_token"] as! String,
            "status": "test from ios",
            "visibility": "public"
        ]
        
        do {
            try post(url: tootUrl, body: body) { data, response, error in
            }
        } catch {
        }
    }
    
    
    
    private func post(url: URL, body: Dictionary<String, String>, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) throws {
        var request: URLRequest = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
        
        session.dataTask(with: request, completionHandler: completionHandler).resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

