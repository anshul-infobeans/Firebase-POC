//
//  ChannelsViewController.swift
//  Firebase_RTC
//
//  Created by Anshul Saraf on 12/09/17.
//  Copyright © 2017 InfoBeans Technologies Limited. All rights reserved.
//

import UIKit
import Firebase

class ChannelsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    //  MARK:-  IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var warningMessageLabel: UILabel!
    
    //  MARK:-  Private Properties
    private var channels: [Channel] = []
    private let existingChannelCellReuseIdentifier = "ExistingChannel"
    private lazy var channelRef: FIRDatabaseReference = FIRDatabase.database().reference().child("channels")
    private var channelRefHandle: FIRDatabaseHandle?
    
    //  MARK:-  Instance Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //  title
        self.title = "Channels"
        
        //  do not show the blank lines below table data
        self.tableView.tableFooterView = UIView()
        
        //  do not adjust scroll view insets automatically
        self.automaticallyAdjustsScrollViewInsets = false
        
        //  start observing channels
        self.observeChannels()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //  MARK:-  IBActions
    @IBAction func addNewChannelDidTap(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "New Channel", message: "Please enter channel name", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addTextField { (textField) in
            textField.keyboardAppearance = .dark
        }
        
        let createAction = UIAlertAction(title: "Create", style: UIAlertActionStyle.default) { (action) in
            if let textField = alertController.textFields?.first {
                if let text = textField.text, !text.isEmpty {
                    let channelName = text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    if !channelName.isEmpty {
                        let newChannelRef = self.channelRef.childByAutoId()
                        let channelItem = ["name": channelName]
                        newChannelRef.setValue(channelItem)
                        Utility.showAlertWith(title: AlertMessages.channelAddedMessage, message: nil)
                    }
                    else {
                        Utility.showAlertWith(title: AlertMessages.invalidChannelNameMessage, message: nil)
                    }
                }
                else {
                    Utility.showAlertWith(title: AlertMessages.invalidChannelNameMessage, message: nil)
                }
            }
        }
        alertController.addAction(createAction)
        
        let cancelAction = UIAlertAction(title: "cancel", style: UIAlertActionStyle.cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func signoutDidTap(_ sender: UIBarButtonItem) {
        do {
            AppDataManager.sharedInstance.userEmailID = nil
            try FIRAuth.auth()?.signOut()
            self.dismiss(animated: true, completion: nil)
        }
        catch {
            //  TODO:-  show error
            debugPrint(error.localizedDescription)
        }
    }
    
    //  MARK:-  Private Methods
    fileprivate func observeChannels() {
        // Use the observe method to listen for new
        // channels being written to the Firebase DB
        self.setWarning(message: AlertMessages.fetchingChannelsMessage)
        channelRefHandle = channelRef.observe(.childAdded, with: { (snapshot) -> Void in
            if let channelData = snapshot.value as? [String: AnyObject] {
                let id = snapshot.key
                if let name = channelData["name"] as? String, !name.isEmpty {
                    self.channels.append(Channel(id: id, name: name))
                    self.tableView.reloadData()
                } else {
                    print("Error! Could not decode channel data")
                }
            }
        })
        
        //  check after 10 seconds if no data is available
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 10) { 
            if self.channels.count > 0 {
                self.setWarning(message: nil)
            }
            else {
                self.setWarning(message: AlertMessages.noChannelsMessage)
            }
        }
    }
    
    fileprivate func setWarning(message: String?) {
        if let text = message, !text.isEmpty {
            self.warningMessageLabel.text = text
            self.warningMessageLabel.isHidden = false
        }
        else {
            self.warningMessageLabel.text = nil
            self.warningMessageLabel.isHidden = true
        }
    }
    
    //  MARK:-  UITableViewDataSource and UITableViewDelegate Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = channels.count
        
        if count > 0 {
            self.setWarning(message: nil)
        }
        
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: existingChannelCellReuseIdentifier, for: indexPath)
        
        cell.textLabel?.text = channels[indexPath.row].name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let chatView = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController {
            let channel = channels[indexPath.row]
            chatView.channel = channel
            chatView.channelRef = channelRef.child(channel.id!)
            self.navigationController?.pushViewController(chatView, animated: true)
        }
    }
}
