//
//  ProfileHeaderCell.swift
//  Former-Demo
//
//  Created by Ryo Aoyama on 10/31/15.
//  Copyright © 2015 Ryo Aoyama. All rights reserved.
//

import UIKit
import Former

final class ProfileHeaderCell: UITableViewCell, LabelFormableRow {
    
    // MARK: Public
    
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var schoolLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backgroundLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .None
        iconView.layer.borderWidth = 4
        iconView.layer.borderColor = UIColor.whiteColor().CGColor
        iconView.layer.cornerRadius = iconView.frame.height/2
    }
    
    func formTextLabel() -> UILabel? {
        return nameLabel
    }
    
    func formSubTextLabel() -> UILabel? {
        return schoolLabel
    }
    
    func updateWithRowFormer(rowFormer: RowFormer) {}
    
    // MARK: Private
    
    private var iconViewColor: UIColor?
}