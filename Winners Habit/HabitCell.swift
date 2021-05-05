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
    
    let checkBGView = UIView().then {
        $0.backgroundColor = UIColor(rgb: 0x363636)
        $0.layer.cornerRadius = 15
    }
    let checkView = UIImageView().then {
        let checkImg = UIImage(systemName: "checkmark")
        $0.image = checkImg
        $0.tintColor = UIColor(rgb: 0x525252)
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.hView.layer.cornerRadius = 15
        self.hView.backgroundColor = UIColor(rgb: 0x464646)
    }
    
    func toggleChecking() {
        if isChecked {
            checkBGView.removeFromSuperview()
            isChecked = !isChecked
        } else {
            self.hView.addSubview(checkBGView)
            checkBGView.addSubview(checkView)
            checkBGView.snp.makeConstraints { make in
                make.size.equalTo(self.hView.snp.size)
                make.center.equalTo(self.hView.snp.center)
            }
            checkView.snp.makeConstraints { make in
                make.size.equalTo(CGSize(width: 50, height: 50))
                make.center.equalTo(checkBGView.snp.center)
            }
            isChecked = !isChecked
        }
    }
    
    func clearChecking() {
        if isChecked {
            checkBGView.removeFromSuperview()
            isChecked = !isChecked
        }
    }
    
    func setChecking(done: Bool) {
        if done {
            self.hView.addSubview(checkBGView)
            checkBGView.addSubview(checkView)
            checkBGView.snp.makeConstraints { make in
                make.size.equalTo(self.hView.snp.size)
                make.center.equalTo(self.hView.snp.center)
            }
            checkView.snp.makeConstraints { make in
                make.size.equalTo(CGSize(width: 50, height: 50))
                make.center.equalTo(checkBGView.snp.center)
            }
            isChecked = !isChecked
        }
    }
}
