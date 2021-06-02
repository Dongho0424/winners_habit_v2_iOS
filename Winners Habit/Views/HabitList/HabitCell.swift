//
//  HabitCell.swift
//  Winners Habit
//
//  Created by 최동호 on 2021/05/03.
//

import Foundation
import UIKit
import RxSwift

class HabitCell: UITableViewCell {
    static let identifier = "habitCell"
    
    var cellDisposeBag = DisposeBag()
    
    // MARK: - Stream

    private let check$: PublishSubject<Bool>
    private let fetchImage$: PublishSubject<Void>
    private let showHabitDetailView$: PublishSubject<Void>
    
    // MARK: - Input
    
    let check: AnyObserver<Bool>
    let showHabitDetailView: AnyObserver<Void>
    
    // MARK: - Output
    
    let checked: Observable<Bool>
    let fetchImage: Observable<Void>
    let getHabitDetailView: Observable<Void>
    
    // MARK: - Init
    
    required init?(coder: NSCoder) {
        self.check$ = PublishSubject<Bool>()
        self.checked = self.check$.debug("Cell: self.checked").asObservable()
        self.check = self.check$.asObserver()
        
        self.fetchImage$ = PublishSubject<Void>()
        self.fetchImage = self.fetchImage$.asObservable()
        
        self.showHabitDetailView$ = PublishSubject<Void>()
        self.showHabitDetailView = showHabitDetailView$.asObserver()
        self.getHabitDetailView = showHabitDetailView$.asObservable()
        
        super.init(coder: coder)
    }
    
    // MARK: - UI Components
    
    @IBOutlet weak var habitImg: UIImageView!
    @IBOutlet weak var habitTitle: UILabel!
    @IBOutlet weak var habitAlarmTime: UILabel!
    @IBOutlet weak var habitAttr: UILabel!
    @IBOutlet weak var alarmImg: UIImageView!
    @IBOutlet weak var hView: UIView!
    
    // MARK: - UI
    
    var isChecked = false
    
    lazy var checkBGView = UIView().then {
        $0.backgroundColor = UIColor(rgb: 0x363636)
        $0.layer.cornerRadius = 15
    }
    lazy var checkView = UIImageView().then {
        let checkImg = UIImage(systemName: "checkmark")
        $0.image = checkImg
        $0.tintColor = UIColor(rgb: 0x525252)
    }
    
    func setChecking(done: Bool, date: Date) {
        // 오늘만 check 바꿀 수 있음.
        guard compareDate(date, Date()) else {
            return
        }
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
            self.isChecked = done
        } else {
            checkBGView.removeFromSuperview()
            self.isChecked = done
        }
    }
    
    func initCell(habitVO: HabitVO) {
        let cellColor = habitVO.color
        
        self.habitTitle.text = habitVO.habitName

        if habitVO.iconImage == nil {
            self.fetchImage$.onNext(())
        } else {
            self.habitImg.image = habitVO.iconImage
        }
        
        if habitVO.alarmFlag {
            self.habitAlarmTime.text = convertAlarmTime(time: habitVO.alarmTime!)
            self.habitAlarmTime.textColor = cellColor
        } else {
            self.alarmImg.isHidden = true
            self.habitAlarmTime.isHidden = true
        }
        
        switch habitVO.attribute {
        case "s/f":
            self.habitAttr.text = "성공/실패"
        case "min":
            self.habitAttr.text = "0/\(habitVO.defaultAttributeValue!) min"
        case "pages":
            self.habitAttr.text = "0/\(habitVO.defaultAttributeValue!) 장"
        default:
            ()
        }
        self.habitAttr.textColor = cellColor
        
        self.selectedBackgroundView = UIView()
        
        self.hView.layer.cornerRadius = 15
        self.hView.backgroundColor = UIColor(rgb: 0x464646)
        
        self.setChecking(done: habitVO.doneFlag, date: Date())
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.cellDisposeBag = DisposeBag()
    }
}
