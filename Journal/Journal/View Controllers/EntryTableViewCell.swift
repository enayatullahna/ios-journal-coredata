//
//  EntryTableViewCell.swift
//  Journal
//
//  Created by Enayatullah Naseri on 12/4/19.
//  Copyright © 2019 Enayatullah Naseri. All rights reserved.
//

import UIKit

class EntryTableViewCell: UITableViewCell {

    //Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLable: UILabel!
    @IBOutlet weak var detailLable: UILabel!
    
    
    
    var entry: Entry? {
        didSet {
            updateViews()
        }
        
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func updateViews() {
        guard let entry = entry else {return}
        // time format
        let format = DateFormatter()
        format.dateStyle = .short
        format.timeStyle = .short
        
        titleLabel.text = entry.title
        dateLable.text = format.string(from: entry.timestamp!)
        detailLable.text = entry.bodyText
        
        
        
    }

}
