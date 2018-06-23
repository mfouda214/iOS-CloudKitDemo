//
//  MessagesTableViewController.swift
//  CloudKitDemo
//
//  Created by Mohamed Sobhi  Fouda on 6/23/18.
//  Copyright © 2018 Mohamed Sobhi Fouda. All rights reserved.
//

import UIKit
import CloudKit

class MessagesTableViewController: UITableViewController {
    
    // messages array will hold fetched messages from cloud
    var messages = [CKRecord]()
    
    var refresh: UIRefreshControl!
    
    @IBAction func addMessage(_ sender: Any) {
        
        let alert = UIAlertController(title: "New Message", message: "Enter a Message", preferredStyle: .alert)
        
        alert.addTextField { (textField: UITextField) in
            textField.placeholder = "Your message..."
        }
        
        alert.addAction(UIAlertAction(title: "Send", style: .default, handler: { (action: UIAlertAction) in
            let textField = alert.textFields?.first
            
            if textField?.text != "" {
                let newMessage = CKRecord(recordType: "Messages")
                newMessage["content"] = textField?.text as CKRecordValue?
                
                let publicDatabase = CKContainer.default().publicCloudDatabase
                publicDatabase.save(newMessage, completionHandler: { (record: CKRecord?, error: Error?) in
                    if error == nil {
                        print("message saved")
                        DispatchQueue.main.async(execute: {
                            self.tableView.beginUpdates()
                            self.messages.insert(newMessage, at: 0)
                            let indexPath = IndexPath(row: 0, section: 0)
                            self.tableView.insertRows(at: [indexPath], with: .top)
                            self.tableView.endUpdates()
                        })
                    } else {
                        print("Error: \(error.debugDescription)")
                    }
                })
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
        
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        refresh = UIRefreshControl()
        refresh.attributedTitle = NSAttributedString(string: "Pull to load messages")
        refresh.addTarget(self, action: #selector(MessagesTableViewController.loadMessages), for: .valueChanged)
        tableView.addSubview(refresh)
        
        loadMessages()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return messages.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let message = messages[indexPath.row]
        
        if let content = message["content"] as? String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            let date = dateFormatter.string(from: message.creationDate!)
            
            cell.textLabel?.text = content
            cell.detailTextLabel?.text = date
        }
        
        return cell
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Laod Data from Cloud
    
    @objc func loadMessages() {
        let publicDatabase = CKContainer.default().publicCloudDatabase
        let query = CKQuery(recordType: "Messages", predicate: NSPredicate(format: "TRUEPREDICATE", argumentArray: nil))
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        publicDatabase.perform(query, inZoneWith: nil) { (results: [CKRecord]?, error: Error?) in
            if let messages = results {
                self.messages = messages
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                    self.refresh.endRefreshing()
                })
            }
        }
    }

}
