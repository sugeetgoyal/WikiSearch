//
//  WikiCellTableViewCell.swift
//  WikiSearch
//
//  Created by Sugeet-Home on 09/09/18.
//  Copyright © 2018 Sugeet-Home. All rights reserved.
//

import UIKit

class WikiCellTableViewCell: UITableViewCell {
    @IBOutlet weak var lblPersonName: UILabel!
    @IBOutlet weak var lblPersonDescription: UILabel!
    @IBOutlet weak var personImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
