//
//  HabitDetailVC.swift
//  Winners Habit
//
//  Created by 최동호 on 2021/05/07.
//

import Foundation
import UIKit
import OpenAPIClient
import FSCalendar

class HabitDetailVC: UIViewController, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    
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
    
    var habitVO: HabitVO! = nil
    let habitDetail = HabitDetail(userHabitId: 1, createDate: "2021-01-03", alarmFlag: true, alarmTime: "06:30:00", alarmMusic: "Oh my god", alarmHaptic: "Basic call", repeatMon: true, repeatTue: true, repeatWed: true, repeatThu: true, repeatFri: true, repeatSat: false, repeatSun: false, memo: "아침에 일어나서 하는 명상은 정말 중요합니다.", habitHistories: [
        HabitHistory(habitId: 1, date: "2021-05-01", doneFlag: true),
        HabitHistory(habitId: 1, date: "2021-05-02", doneFlag: true),
        HabitHistory(habitId: 1, date: "2021-05-03", doneFlag: false),
        HabitHistory(habitId: 1, date: "2021-05-04", doneFlag: true),
        HabitHistory(habitId: 1, date: "2021-05-05", doneFlag: true),
        HabitHistory(habitId: 1, date: "2021-05-06", doneFlag: false),
        HabitHistory(habitId: 1, date: "2021-05-07", doneFlag: false),
    ])
    var challenge: Challenge! = nil
    
    lazy var habitColor = habitVO.color
    
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        self.initHabitDetails()
        self.initFSCalendar()
    }
    
    // MARK: - Actions
    func initHabitDetails() {
        self.challengeName.text = self.challenge.challengeName
        self.habitImg.image = self.habitVO.iconImage
        self.habitTitle.text = self.habitVO.habitName
        
        self.createDate.text = convertDate1(date: self.habitDetail.createDate)
        
        switch habitVO.attribute {
        case "s/f":
            self.attribute.text = "성공/실패"
        case "min":
            self.attribute.text = "0/\(habitVO.defaultAttributeValue!) min"
        case "pages":
            self.attribute.text = "0/\(habitVO.defaultAttributeValue!) 장"
        default:
            ()
        }
        self.attribute.textColor = self.habitColor
        
        self.alarmTimeSwitch.isEnabled = false
        self.alarmMusicSwitch.isEnabled = false
        self.alarmHapticSwitch.isEnabled = false
        
        if self.habitVO.alarmFlag {
            self.alarmTimeSwitch.isOn = true
            self.alarmTime.text = convertAlarmTime(time: self.habitVO.alarmTime!)
            self.alarmTime2.text = convertAlarmTime(time: self.habitVO.alarmTime!)
            self.alarmTime.textColor = self.habitColor
            self.alarmHaptic.text = self.habitDetail.alarmHaptic
        } else {
            self.alarmImg.removeFromSuperview()
            self.alarmTime.removeFromSuperview()
            self.alarmTimeSwitch.isOn = false
            self.alarmTime2.text = "없음"
            self.alarmTime2.textColor = .systemGray6
            self.alarmMusic.textColor = .systemGray6
            self.alarmHaptic.textColor = .systemGray6
        }
        
        if self.habitDetail.alarmMusic != nil {
            self.alarmMusicSwitch.isOn = true
            self.alarmMusic.text = self.habitDetail.alarmMusic
        } else{
            self.alarmMusicSwitch.isOn = false
            self.alarmMusic.text = "없음"
        }
        
        if self.habitDetail.alarmHaptic != nil {
            self.alarmHapticSwitch.isOn = true
            self.alarmHaptic.text = self.habitDetail.alarmHaptic
        } else{
            self.alarmHapticSwitch.isOn = false
            self.alarmHaptic.text = "없음"
        }
        
        self.alarmDay(btn: self.alarmMon, repeat: self.habitDetail.repeatMon!, color: habitColor)
        self.alarmDay(btn: self.alarmTue, repeat: self.habitDetail.repeatTue!, color: habitColor)
        self.alarmDay(btn: self.alarmWed, repeat: self.habitDetail.repeatWed!, color: habitColor)
        self.alarmDay(btn: self.alarmThu, repeat: self.habitDetail.repeatThu!, color: habitColor)
        self.alarmDay(btn: self.alarmFri, repeat: self.habitDetail.repeatFri!, color: habitColor)
        self.alarmDay(btn: self.alarmSat, repeat: self.habitDetail.repeatSat!, color: habitColor)
        self.alarmDay(btn: self.alarmSun, repeat: self.habitDetail.repeatSun!, color: habitColor)
        
        self.memo.text = self.habitDetail.memo
        self.memo.isEditable = false
    }
    
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

        guard let habitHistories = self.habitDetail.habitHistories else {
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
        if let habitHistories = self.habitDetail.habitHistories {
            for history in habitHistories {
                if getMonth(date: history.date!) == "\(month)" {
                    habitHistoriesByMonth.append(history)
                }
            }
        }
        return habitHistoriesByMonth
    }
    
}
