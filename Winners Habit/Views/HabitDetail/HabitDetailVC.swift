//
//  HabitDetailVC.swift
//  Winners Habit
//
//  Created by 최동호 on 2021/05/07.
//

import Foundation
import UIKit
import WinnersHabitOAS
import FSCalendar
import RxSwift
import RxCocoa

class HabitDetailVC: UIViewController, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    static let identifier = "HabitDetailVC"
    
    // MARK: - UI Components
    
    @IBOutlet weak var challengeName: UILabel!
    @IBOutlet weak var habitImg: UIImageView!
    @IBOutlet weak var habitTitle: UILabel!
    @IBOutlet weak var alarmImg: UIImageView!
    @IBOutlet weak var alarmTime: UILabel!
    @IBOutlet weak var attribute: UILabel!
    @IBOutlet weak var createDate: UILabel!
    @IBOutlet weak var alarmTime2: UILabel!
    @IBOutlet weak var alarmMusic: UILabel!
    @IBOutlet weak var alarmHaptic: UILabel!
    @IBOutlet weak var alarmTimeSwitch: UISwitch!
    @IBOutlet weak var alarmMusicSwitch: UISwitch!
    @IBOutlet weak var alarmHapticSwitch: UISwitch!
    @IBOutlet weak var alarmMon: UIButton!
    @IBOutlet weak var alarmTue: UIButton!
    @IBOutlet weak var alarmWed: UIButton!
    @IBOutlet weak var alarmThu: UIButton!
    @IBOutlet weak var alarmFri: UIButton!
    @IBOutlet weak var alarmSat: UIButton!
    @IBOutlet weak var alarmSun: UIButton!
    @IBOutlet weak var memo: UITextView!
    
    @IBOutlet weak var fsCalendar: FSCalendar!
    
    private var habitDetailVO: HabitDetailVO!
    private var habitColor: UIColor!
    
    // MARK: - MVVM-Rx Components
    
    var viewModel : HabitDetailVMType
    private let disposeBag = DisposeBag()
    
    // MARK: - Init
    
    init(viewModel: HabitDetailVMType = HabitDetailVM()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = HabitDetailVM()
        super.init(coder: coder)
    }
    
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        self.initFSCalendar()
        
        self.bindUI()
    }
    
    // MARK: - BindUI
    
    private func bindUI() {
        print("hi HabitDetailVC")
        // data source
        self.viewModel.outputs.getHabitDetailVO
            .subscribe(onNext: { habitDetailVO in
                // 좋은 방법은 아닌 것 같은데,,,,,,,
                self.habitDetailVO = habitDetailVO
                
                self.challengeName.text = habitDetailVO.challengeName
                self.habitImg.image = habitDetailVO.habitImg
                self.habitTitle.text = habitDetailVO.habitTitle
                
                self.createDate.text = convertDate1(date: habitDetailVO.createDate)
                
                switch habitDetailVO.attribute {
                case "s/f":
                    self.attribute.text = "성공/실패"
                case "min":
                    self.attribute.text = "0/\(habitDetailVO.defaultAttributeValue!) min"
                case "pages":
                    self.attribute.text = "0/\(habitDetailVO.defaultAttributeValue!) 장"
                default:
                    ()
                }
                self.habitColor = habitDetailVO.color
                
                self.alarmTimeSwitch.isEnabled = false
                self.alarmMusicSwitch.isEnabled = false
                self.alarmHapticSwitch.isEnabled = false
                
                if habitDetailVO.alarmFlag {
                    self.alarmTimeSwitch.isOn = true
                    self.alarmTime.text = convertAlarmTime(time: habitDetailVO.alarmTime!)
                    self.alarmTime2.text = convertAlarmTime(time: habitDetailVO.alarmTime!)
                    self.alarmTime.textColor = habitDetailVO.color
                    print("habitDetailVO.color: \(habitDetailVO.color)")
                    self.alarmHaptic.text = habitDetailVO.alarmHaptic
                } else {
                    self.alarmImg.removeFromSuperview()
                    self.alarmTime.removeFromSuperview()
                    self.alarmTimeSwitch.isOn = false
                    self.alarmTime2.text = "없음"
                    self.alarmTime2.textColor = .systemGray6
                    self.alarmMusic.textColor = .systemGray6
                    self.alarmHaptic.textColor = .systemGray6
                }
                
                if habitDetailVO.alarmMusic != nil {
                    self.alarmMusicSwitch.isOn = true
                    self.alarmMusic.text = habitDetailVO.alarmMusic
                } else{
                    self.alarmMusicSwitch.isOn = false
                    self.alarmMusic.text = "없음"
                }
                
                if habitDetailVO.alarmHaptic != nil {
                    self.alarmHapticSwitch.isOn = true
                    self.alarmHaptic.text = habitDetailVO.alarmHaptic
                } else{
                    self.alarmHapticSwitch.isOn = false
                    self.alarmHaptic.text = "없음"
                }
                
                self.alarmDay(btn: self.alarmMon, repeat: habitDetailVO.repeatMon!, color: habitDetailVO.color)
                self.alarmDay(btn: self.alarmTue, repeat: habitDetailVO.repeatTue!, color: habitDetailVO.color)
                self.alarmDay(btn: self.alarmWed, repeat: habitDetailVO.repeatWed!, color: habitDetailVO.color)
                self.alarmDay(btn: self.alarmThu, repeat: habitDetailVO.repeatThu!, color: habitDetailVO.color)
                self.alarmDay(btn: self.alarmFri, repeat: habitDetailVO.repeatFri!, color: habitDetailVO.color)
                self.alarmDay(btn: self.alarmSat, repeat: habitDetailVO.repeatSat!, color: habitDetailVO.color)
                self.alarmDay(btn: self.alarmSun, repeat: habitDetailVO.repeatSun!, color: habitDetailVO.color)
                
                self.memo.text = habitDetailVO.memo
                self.memo.isEditable = false
            })
            .disposed(by: self.disposeBag)
        
        
    }
    
    // MARK: - UI
    func alarmDay(btn: UIButton, repeat: Bool, color: UIColor) {
        btn.layer.cornerRadius = btn.frame.width / 2
        if `repeat` {
            btn.backgroundColor = color
        }
    }
    
    func initFSCalendar() {
        self.fsCalendar.delegate = self
        self.fsCalendar.dataSource = self
        self.fsCalendar.allowsSelection = false
        self.fsCalendar.scrollEnabled = true
        self.fsCalendar.scrollDirection = .horizontal
        self.fsCalendar.register(FSCalendarCell.self, forCellReuseIdentifier: "cell")
    }
    
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {

        let cell = calendar.dequeueReusableCell(withIdentifier: "cell", for: date, at: position)
        
        cell.layer.cornerRadius = cell.frame.width / 2

        guard let habitHistories = self.habitDetailVO.habitHistories else {
            fatalError("calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell")
        }

        for history in habitHistories {
            if stringDate(date: history.date!) == date && history.doneFlag{
                cell.backgroundColor = self.habitColor
                return cell
            } else {
                cell.backgroundColor = .systemBackground
            }
        }
        return cell
    }
    
    func getHistories(month: Int) -> [HabitHistory] {
        var habitHistoriesByMonth = [HabitHistory]()
        if let habitHistories = self.habitDetailVO.habitHistories {
            for history in habitHistories {
                if getMonth(date: history.date!) == "\(month)" {
                    habitHistoriesByMonth.append(history)
                }
            }
        }
        return habitHistoriesByMonth
    }
}
