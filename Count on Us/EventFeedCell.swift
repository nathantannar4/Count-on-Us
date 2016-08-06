//
//  EventFeedCell.swift
//  WESST
//
//  Created by Tannar, Nathan on 2016-07-09.
//  Copyright © 2016 NathanTannar. All rights reserved.
//

import UIKit
import Former

final class EventFeedCell: UITableViewCell, LabelFormableRow {
    
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var timeDay: UILabel!
    
    @IBOutlet weak var organizer: UILabel!
    
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var attendence: UILabel!
    // MARK: Public
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
    }
    
    func formTextLabel() -> UILabel? {
        return nil
    }
    
    func formSubTextLabel() -> UILabel? {
        return nil
    }
    
    func updateWithRowFormer(rowFormer: RowFormer) {}
    
    // MARK: Private
    
    private var iconViewColor: UIColor?
    
}
