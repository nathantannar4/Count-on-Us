//
//  ImageCell.swift
//  WESST
//
//  Created by Nathan Tannar on 2016-06-18.
//  Copyright © 2016 NathanTannar. All rights reserved.
//

import UIKit
import Former

final class PostCell: UITableViewCell, LabelFormableRow {
    
    // MARK: Public
    
    @IBOutlet weak var company: UILabel!
    @IBOutlet weak var website: UILabel!
    @IBOutlet weak var deal: UILabel!
    @IBOutlet weak var dealDates: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .Gray
        
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