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
    
    private var onEdit: UIBarButtonItem!

    
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
        self.initUI()
        self.bindUI()
    }
    
    // MARK: - BindUI
    
    private func bindUI() {
        
        // --------------------------------
        //             INPUT
        // --------------------------------
        
        // edit 버튼 누르면 edit 모드 바꾸기
        self.onEdit.rx.tap
            .debug("onEdit.rx.tap")
            .bind(to: self.viewModel.inputs.changeEditMode)
            .disposed(by: self.disposeBag)
        
        // --------------------------------
        //             OUTPUT
        // --------------------------------
        
        // data source
        self.viewModel.outputs.getHabitDetailVO
            .subscribe(onNext: { habitDetailVO in
                
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
                self.attribute.textColor = habitDetailVO.color
                
                if habitDetailVO.alarmFlag {
                    self.alarmTimeSwitch.isOn = true
                    self.alarmTime.text = convertAlarmTime(time: habitDetailVO.alarmTime!)
                    self.alarmTime2.text = convertAlarmTime(time: habitDetailVO.alarmTime!)
                    self.alarmTime.textColor = habitDetailVO.color
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
                
                self.initAlarmButton(btn: self.alarmMon, repeat: habitDetailVO.repeatMon!, color: habitDetailVO.color)
                self.initAlarmButton(btn: self.alarmTue, repeat: habitDetailVO.repeatTue!, color: habitDetailVO.color)
                self.initAlarmButton(btn: self.alarmWed, repeat: habitDetailVO.repeatWed!, color: habitDetailVO.color)
                self.initAlarmButton(btn: self.alarmThu, repeat: habitDetailVO.repeatThu!, color: habitDetailVO.color)
                self.initAlarmButton(btn: self.alarmFri, repeat: habitDetailVO.repeatFri!, color: habitDetailVO.color)
                self.initAlarmButton(btn: self.alarmSat, repeat: habitDetailVO.repeatSat!, color: habitDetailVO.color)
                self.initAlarmButton(btn: self.alarmSun, repeat: habitDetailVO.repeatSun!, color: habitDetailVO.color)
                
                self.memo.text = habitDetailVO.memo
                self.memo.isEditable = false
            })
            .disposed(by: self.disposeBag)

        // edit mode
        self.viewModel.outputs.editMode // default mode is not editing mode
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { editMode in
                if editMode {
                    // ### open editing Mode ###")
                    self.alarmTimeSwitch.isEnabled = true
                    self.alarmMusicSwitch.isEnabled = true
                    self.alarmHapticSwitch.isEnabled = true
                    self.onEdit.image = nil
                    self.onEdit.title = "Done"
                    self.onEdit.setTitleTextAttributes([.font: UIFont.boldSystemFont(ofSize: 17)], for: .normal)
                } else { 
                    // ### not editing Mode ###")
                    self.alarmTimeSwitch.isEnabled = false
                    self.alarmMusicSwitch.isEnabled = false
                    self.alarmHapticSwitch.isEnabled = false
                    self.onEdit.image = UIImage(systemName: "pencil")
                    self.onEdit.title = nil
                }
            })
            .disposed(by: self.disposeBag)
        
    }
    
    // MARK: - UI
    
    func initUI() {
        // edit mode 버튼
        self.onEdit = UIBarButtonItem().then { [unowned self] in
            $0.image = UIImage(systemName: "pencil")
            $0.tintColor = .label
            self.navigationItem.rightBarButtonItem = $0
        }
    }
    
    func initAlarmButton(btn: UIButton, repeat: Bool, color: UIColor) {
        btn.layer.cornerRadius = btn.frame.width / 2
        if `repeat` {
            btn.backgroundColor = color
        } else {
            btn.backgroundColor = .systemBackground
        }
    }
    
    func enableAllAlarmButton() {
        self.alarmMon.rx.tap
            .subscribe(onNext: { })
    }
    
    func initFSCalendar() {
        self.fsCalendar.delegate = self
        self.fsCalendar.dataSource = self
        self.fsCalendar.allowsSelection = false
        self.fsCalendar.scrollEnabled = true
        self.fsCalendar.scrollDirection = .horizontal
        self.fsCalendar.register(FSCalendarCell.self, forCellReuseIdentifier: "cell")
    }
    
    //    func getHistories(month: Int) -> [HabitHistory] {
    //        var habitHistoriesByMonth = [HabitHistory]()
    //        if let habitHistories = self.habitDetailVO.habitHistories {
    //            for history in habitHistories {
    //                if getMonth(date: history.date!) == "\(month)" {
    //                    habitHistoriesByMonth.append(history)
    //                }
    //            }
    //        }
    //        return habitHistoriesByMonth
    //    }
    
    // MARK: - FS Calendar Delegate
    
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        var _habitDetailVO: HabitDetailVO? = nil
        
        self.viewModel.outputs.getHabitDetailVO.subscribe(onNext: {
            _habitDetailVO = $0
        })
        .disposed(by: self.disposeBag)
        
        let cell = calendar.dequeueReusableCell(withIdentifier: "cell", for: date, at: position).then {
            $0.layer.cornerRadius = $0.frame.width / 2
        }
        
        guard let habitDetailVO = _habitDetailVO,
            let habitHistories = habitDetailVO.habitHistories else {
            fatalError("calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell")
        }
        
        for history in habitHistories {
            if stringDate(date: history.date!) == date && history.doneFlag {
                cell.backgroundColor = habitDetailVO.color
                return cell
            } else {
                cell.backgroundColor = .systemBackground
            }
        }
        
        return cell
    }
}
