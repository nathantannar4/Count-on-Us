//
//  ImageCell.swift
//  WESST
//
//  Created by Nathan Tannar on 2016-06-18.
//  Copyright © 2016 NathanTannar. All rights reserved.
//

import UIKit
import Former

final class ImageCell: UITableViewCell, LabelFormableRow {
    
    // MARK: Public
    
    @IBOutlet var displayImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        if iconViewColor == nil {
            iconViewColor = displayImage.backgroundColor
        }
        super.setSelected(selected, animated: animated)
        if let color = iconViewColor {
            displayImage.backgroundColor = color
        }
    }
    
    func formTextLabel() -> UILabel? {
        return UILabel()
    }
    
    func formSubTextLabel() -> UILabel? {
        return nil
    }
    
    func updateWithRowFormer(rowFormer: RowFormer) {}
    
    // MARK: Private
    
    private var iconViewColor: UIColor?
    
}