//
//  CasstomTableViewCell.swift
//  My pleces
//
//  Created by Vadim Labun on 8/30/19.
//  Copyright © 2019 Vadim Labun. All rights reserved.
//

import UIKit
import Cosmos

class CasstomTableViewCell: UITableViewCell {

    @IBOutlet var imageOfPlaces: UIImageView!
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var locationLable: UILabel!
    @IBOutlet var typeLabel: UILabel!
    @IBOutlet var cosmosView: CosmosView! {
        didSet {
            cosmosView.settings.updateOnTouch = false
        }
    }
    
}
