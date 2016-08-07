//
//  MessagesViewController.swift
//  
//
//  Created by Jesse Hu on 3/3/15.
//
//

import UIKit
import Parse

class MessagesViewController: UITableViewController, UIActionSheetDelegate, SelectSingleViewControllerDelegate, SelectMultipleViewControllerDelegate  {
    
    var messages = [PFObject]()
    
    @IBOutlet var composeButton: UIBarButtonItem!
    @IBOutlet var emptyView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addLeftBarButtonWithImage(UIImage(named: "ic_menu_black_24dp")!)
        self.tableView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MessagesViewController.cleanup), name: NOTIFICATION_USER_LOGGED_OUT, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MessagesViewController.loadMessages), name: "reloadMessages", object: nil)
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: #selector(MessagesViewController.loadMessages), forControlEvents: UIControlEvents.ValueChanged)
        self.tableView?.addSubview(self.refreshControl!)
        
        self.emptyView?.hidden = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if PFUser.currentUser() != nil {
            self.loadMessages()
        } else {
            Utilities.loginUser(self)
        }
    }
    
    
    // MARK: - Backend methods
    
    func loadMessages() {
        let query = PFQuery(className: PF_MESSAGES_CLASS_NAME)
        query.whereKey(PF_MESSAGES_USER, equalTo: PFUser.currentUser()!)
        query.includeKey(PF_MESSAGES_LASTUSER)
        query.orderByDescending(PF_MESSAGES_UPDATEDACTION)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                self.messages.removeAll(keepCapacity: false)
                self.messages += objects as [PFObject]!
                self.tableView.reloadData()
                self.updateEmptyView()
                self.updateTabCounter()
            } else {
                print("Network error")
            }
            self.refreshControl!.endRefreshing()
        }
    }
    
    // MARK: - Helper methods
    
    func updateEmptyView() {
        self.emptyView?.hidden = (self.messages.count != 0)
    }
    
    
    func updateTabCounter() {
        var total = 0
        for message in self.messages {
            total += message[PF_MESSAGES_COUNTER]!.integerValue
        }
        UIApplication.sharedApplication().applicationIconBadgeNumber = total
    }
 
    
    // MARK: - User actions
    
    func openChat(groupId: String) {
        self.performSegueWithIdentifier("messagesChatSegue", sender: groupId)
    }
    
    func cleanup() {
        self.messages.removeAll(keepCapacity: false)
        self.tableView.reloadData()
        self.updateTabCounter()
        self.updateEmptyView()
    }
    
    @IBAction func compose(sender: AnyObject?) {
        //Create the AlertController
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            //Just dismiss the action sheet
        }
        actionSheetController.addAction(cancelAction)
        let single: UIAlertAction = UIAlertAction(title: "Single Recipient", style: .Default)
        { action -> Void in
            self.performSegueWithIdentifier("selectSingleSegue", sender: self)
        }
        actionSheetController.addAction(single)
        let multiple: UIAlertAction = UIAlertAction(title: "Multiple Recipients", style: .Default)
        { action -> Void in
            self.performSegueWithIdentifier("selectMultipleSegue", sender: self)
        }
        actionSheetController.addAction(multiple)
        
        //Present the AlertController
        self.presentViewController(actionSheetController, animated: true, completion: nil)
    }

    // MARK: - Prepare for segue to chatVC

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "messagesChatSegue" {
            let chatVC = segue.destinationViewController as! ChatViewController
            chatVC.hidesBottomBarWhenPushed = true
            let groupId = sender as! String
            chatVC.groupId = groupId
        } else if segue.identifier == "selectSingleSegue" {
            let selectSingleVC = (segue.destinationViewController as! UINavigationController).viewControllers[0] as! SelectSingleViewController
            selectSingleVC.delegate = self
        } else if segue.identifier == "selectMultipleSegue" {
            let selectMultipleVC = (segue.destinationViewController as! UINavigationController).viewControllers[0] as! SelectMultipleViewController
            selectMultipleVC.delegate = self
        }
    }
    
    // MARK: - SelectSingleDelegate
    
    func didSelectSingleUser(user2: PFUser) {
        let user1 = PFUser.currentUser()!
        let groupId = Messages.startPrivateChat(user1, user2: user2)
        self.openChat(groupId)
    }
    
    // MARK: - SelectMultipleDelegate
    
    func didSelectMultipleUsers(selectedUsers: [PFUser]!) {
        let groupId = Messages.startMultipleChat(selectedUsers)
        self.openChat(groupId)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("messagesCell") as! MessagesCell
        cell.bindData(self.messages[indexPath.row])
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        Messages.deleteMessageItem(self.messages[indexPath.row])
        self.messages.removeAtIndex(indexPath.row)
        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        self.updateEmptyView()
        //self.updateTabCounter()
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let message = self.messages[indexPath.row] as PFObject
        self.openChat(message[PF_MESSAGES_GROUPID] as! String)
    }

}
