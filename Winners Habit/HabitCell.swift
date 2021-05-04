//
//  HabitCell.swift
//  Winners Habit
//
//  Created by 최동호 on 2021/05/03.
//

import Foundation
import UIKit

class HabitCell: UITableViewCell {
    @IBOutlet weak var habitImg: UIImageView!
    @IBOutlet weak var habitTitle: UILabel!
    @IBOutlet weak var habitAlarmTime: UILabel!
    @IBOutlet weak var habitAttr: UILabel!
    @IBOutlet weak var hView: UIView!
    
    var isChecked = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.hView.layer.cornerRadius = 15
        self.hView.backgroundColor = UIColor(rgb: 0x464646)
    }
    
}
