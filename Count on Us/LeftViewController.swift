//
//  LeftViewController.swift
//  SlideMenuControllerSwift
//
//  Created by Yuji Hato on 12/3/14.
//

import UIKit

enum LeftMenu: Int {
    case Main = 0
    case Profile
    case Food
    case Services
    case Goods
    case Messages
    case Colleagues
    case Schedule
}

protocol LeftMenuProtocol : class {
    func changeViewController(menu: LeftMenu)
}

class LeftViewController : UIViewController, LeftMenuProtocol {
    
    @IBOutlet weak var tableView: UITableView!
    var menus = ["Home", "Profile", "Food", "Services", "Goods", "Messages", "Colleagues", "Schedule"]
    var mainViewController: UIViewController!
    var profileViewController: UIViewController!
    var foodViewController: UIViewController!
    var servicesViewController: UIViewController!
    var goodsViewController: UIViewController!
    var messagesViewController: UIViewController!
    var colleaguesViewController: UIViewController!
    var scheduleViewController: UIViewController!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorColor = SAP_COLOR
        self.tableView.separatorStyle = .None
        self.tableView.scrollEnabled = false
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let profileViewController = storyboard.instantiateViewControllerWithIdentifier("ProfileViewController") as! ProfileViewController
        self.profileViewController = UINavigationController(rootViewController: profileViewController)
        
        let foodViewController = storyboard.instantiateViewControllerWithIdentifier("FoodViewController") as! FoodViewController
        self.foodViewController = UINavigationController(rootViewController: foodViewController)
        
        let servicesViewController = storyboard.instantiateViewControllerWithIdentifier("ServicesViewController") as! ServicesViewController
        self.servicesViewController = UINavigationController(rootViewController: servicesViewController)
        
        let goodsViewController = storyboard.instantiateViewControllerWithIdentifier("GoodsViewController") as! GoodsViewController
        self.goodsViewController = UINavigationController(rootViewController: goodsViewController)
        
        let messagesViewController = storyboard.instantiateViewControllerWithIdentifier("MessagesViewController") as! MessagesViewController
        self.messagesViewController = UINavigationController(rootViewController: messagesViewController)
        
        let colleaguesViewController = storyboard.instantiateViewControllerWithIdentifier("ColleaguesViewController") as! ColleaguesViewController
        self.colleaguesViewController = UINavigationController(rootViewController: colleaguesViewController)
        
        let scheduleViewController = storyboard.instantiateViewControllerWithIdentifier("ScheduleViewController") as! ScheduleViewController
        self.scheduleViewController = UINavigationController(rootViewController: scheduleViewController)
        
        self.tableView.registerCellClass(BaseTableViewCell.self)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func changeViewController(menu: LeftMenu) {
        switch menu {
        case .Main:
            self.slideMenuController()?.changeMainViewController(self.mainViewController, close: true)
        case .Profile:
            self.slideMenuController()?.changeMainViewController(self.profileViewController, close: true)
        case .Food:
            self.slideMenuController()?.changeMainViewController(self.foodViewController, close: true)
        case .Services:
            self.slideMenuController()?.changeMainViewController(self.servicesViewController, close: true)
        case .Goods:
            self.slideMenuController()?.changeMainViewController(self.goodsViewController, close: true)
        case .Messages:
            self.slideMenuController()?.changeMainViewController(self.messagesViewController, close: true)
        case .Colleagues:
            self.slideMenuController()?.changeMainViewController(self.colleaguesViewController, close: true)
        case .Schedule:
            self.slideMenuController()?.changeMainViewController(self.scheduleViewController, close: true)
        }
    }
}

extension LeftViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let menu = LeftMenu(rawValue: indexPath.item) {
            switch menu {
            case .Main, .Profile, .Food, .Services, .Goods, .Messages, .Colleagues, .Schedule:
                return BaseTableViewCell.height()
            }
        }
        return 0
    }
}

extension LeftViewController : UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menus.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if let menu = LeftMenu(rawValue: indexPath.item) {
            switch menu {
            case .Main, .Profile, .Food, .Services, .Goods, .Messages, .Colleagues, .Schedule:
                let cell = BaseTableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: BaseTableViewCell.identifier)
                cell.setData(menus[indexPath.row])
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let menu = LeftMenu(rawValue: indexPath.item) {
            self.changeViewController(menu)
        }
    }
}

extension LeftViewController: UIScrollViewDelegate {
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if self.tableView == scrollView {
            
        }
    }
}
