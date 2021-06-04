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

class HabitDetailVC: UIViewController, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance, UITextViewDelegate {
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
    
    required init?(coder: NSCoder) {
        self.viewModel = HabitDetailVM()
        super.init(coder: coder)
    }
    
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //        print("viewDidLoad")
        self.initFSCalendar()
        self.initUI()
        self.bindUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //        print("viewWillAppear")
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
        
        /*
         현재 edit 모드가 아니면 그냥 change
         현재 edit 모드이면 onComplete 보내고 종료
         */
        
        // --------------------------------
        //             OUTPUT
        // --------------------------------
        
        /*
         UI 요소 그리는 것을 한번에 합쳐버리기
         조건들
         1. current HabitDetailVO가 바뀌는 스트림은
         이것이 구독하여 UI를 그린다.
         HabitDetailVO + editMode 고려하기.
         2. 각각의 ui 요소들의 action (tap, gesture) 등등은 따로 뺀다. (INPUT)으로
         */
        
        // data source
        // MVVM+Rx의 핵심
        //   얘는 받아온 정보를 "그리기"만 한다.
        //   즉, 여기서 UI를 직접 어떤 값에 의해서 변경하는 로직은 좋은. 구조가. 아니다.
        self.viewModel.outputs.currentHabitDetailVO
            //            .debug("HabitDetailVC: self.viewModel.outputs.getHabitDetailVO")
            .subscribe(onNext: { [weak self] habitDetailVO in
                guard let self = self else { return }
                
                // 절대 안바뀌는 애들
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
                
                
                // alarm time
                self.setAlarmTimeUI(alarmFlag: habitDetailVO.alarmFlag,
                                    alarmTime: habitDetailVO.alarmTime,
                                    color: habitDetailVO.color)
                
                // alarm music
                self.setAlarmMusicUI(alarmMusic: habitDetailVO.alarmMusic)
                
                // alarm haptic
                self.setAlarmHapticUI(alarmHaptic: habitDetailVO.alarmHaptic)
                
                // alarm button
                self.setAlarmButton(habitDetailVO)
                
                // alarm memo
                self.memo.text = habitDetailVO.memo

            })
            .disposed(by: self.disposeBag)
        
        // edit mode 시 각 UI 요소들의 기능 같은 것
        // UI 요소만!
        self.viewModel.outputs.editMode // default mode is not editing mode
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] editMode in
                guard let self = self else { return }
                
                /*
                 ### open editing Mode ###
                 
                 1. 각 알람 스위치 enable
                 2. edit 버튼 바뀌기
                 3. 알람 시간, 알람음, 알람 진동 고를 수 있게 하는 창 나오기
                 3-1. 알람 on: 위에 해결, 알람 시간 바꾸면 위에 부분도 해결하기
                 3-2. 알람 off: 위에 알람시계랑 라벨도 떼고
                 알람 시간: 없음
                 알람 음, 진동: 없음
                 4. 각 알람 버튼 선택할 수 있게 하기
                 5. 메모 편집할 수 있도록 + 현재 자/최대 50자 + 지우개 버튼 나오기
                 
                 ### not editing Mode ###

                 1. 각 알람 스위치 not enable
                 2. edit 버튼 바뀌기
                 3. 알람 시간, 알람음, 알람 진동 고를 수 있게 하는 삭제
                 4. 각 알람 버튼 선택할 수 없게 하기
                 5. 메모 편집할 수 없도록 + 현재 자/최대 50자(삭제) + 지우개 버튼 나오기(삭제)
                 */
                
                self.alarmTimeSwitch.isEnabled = editMode
                self.alarmMusicSwitch.isEnabled = editMode
                self.alarmHapticSwitch.isEnabled = editMode
                if editMode {
                    self.onEdit.image = nil
                    self.onEdit.title = "저장!"
                    self.onEdit.setTitleTextAttributes([.font: UIFont.boldSystemFont(ofSize: 17)], for: .normal)
                } else {
                    self.onEdit.image = UIImage(systemName: "pencil")
                    self.onEdit.title = nil
                }
                
                self.setAllAlarmButtonsEnablement(editMode: editMode)
                
                self.memo.isEditable = editMode

            })
            .disposed(by: self.disposeBag)
        
    }
    
    // MARK: - UI
    
    // Things which is not proper in bindUI() method
    // Because, in bindUI() method, things are repeatedly changed whenever
    // new habitDetailVO comes.
    func initUI() {
        // edit mode button initialize
        self.onEdit = UIBarButtonItem().then {
            $0.image = UIImage(systemName: "pencil")
            $0.tintColor = .label
            self.navigationItem.rightBarButtonItem = $0
        }
    }
    
    
    // MARK: - Alarm Time
    
    func setAlarmTimeActions() {
        /*
         actions
         */
        
    }
    
    func setAlarmTimeUI(alarmFlag: Bool, alarmTime: String?, color: UIColor) {
        /*
         가정
         1. alarmFlag가 true면 alarmMusic이랑 alarmHaptic은 알아서
         2. alarmFlag가 false면 alarmMusic이랑 alarmHaptic은 무조건 nil
         */
        if alarmFlag {
            self.alarmImg.isHidden = false
            self.alarmTime.isHidden = false
            self.alarmTimeSwitch.isOn = true
            self.alarmTime.text = convertAlarmTime(time: alarmTime!)
            self.alarmTime2.text = convertAlarmTime(time: alarmTime!)
            self.alarmTime.textColor = color
        } else {
            self.alarmImg.isHidden = true
            self.alarmTime.isHidden = true
            self.alarmTimeSwitch.isOn = false
            self.alarmTime2.text = "없음"
            self.alarmTime2.textColor = .systemGray6
        }
    }
    
    // MARK: - Alarm Music
    
    func setAlarmMusicActions() {
        
    }
    
    func setAlarmMusicUI(alarmMusic: String?) {
        /*
         가정
         1. alarmMusic은 nil이면 없는거
         2. nil이 아니면 무조건 뭐든 있어야 함.
         */
        if alarmMusic != nil {
            self.alarmMusicSwitch.isOn = true
            self.alarmMusic.text = alarmMusic
        } else {
            self.alarmMusic.textColor = .systemGray6
            self.alarmMusicSwitch.isOn = false
            self.alarmMusic.text = "없음"
        }
    }
    // MARK: - Alarm Haptic
    
    func setAlarmHapticActions() {
        
    }
    
    func setAlarmHapticUI(alarmHaptic: String?) {
        /*
         가정
         1. alarmMusic은 nil이면 없는거
         2. nil이 아니면 무조건 뭐든 있어야 함.
         */
        if alarmHaptic != nil {
            self.alarmHapticSwitch.isOn = true
            self.alarmHaptic.text = alarmHaptic
        } else{
            self.alarmHaptic.textColor = .systemGray6
            self.alarmHapticSwitch.isOn = false
            self.alarmHaptic.text = "없음"
        }
    }
    
    // MARK: - Alarm Button
    
    func setAlarmButton(_ habitDetailVO: HabitDetailVO) {
        let buttons: [(UIButton, Bool)]
            = [(self.alarmMon, habitDetailVO.repeatMon!),
               (self.alarmTue, habitDetailVO.repeatTue!),
               (self.alarmWed, habitDetailVO.repeatWed!),
               (self.alarmThu, habitDetailVO.repeatThu!),
               (self.alarmFri, habitDetailVO.repeatFri!),
               (self.alarmSat, habitDetailVO.repeatSat!),
               (self.alarmSun, habitDetailVO.repeatSun!)]
        
        for i in 0 ..< buttons.count {
            let currentButton = buttons[i].0
            let currentRepeat = buttons[i].1
            
            // - UI -
            // 모양
            currentButton.layer.cornerRadius = currentButton.frame.width / 2
            // 색
            if currentRepeat {
                currentButton.backgroundColor = habitDetailVO.color
            } else {
                currentButton.backgroundColor = .systemBackground
            }
            
            // - Rx -
            currentButton.rx.tap.subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                
                var temp = habitDetailVO
                
                switch i {
                case 0: temp.repeatMon = !temp.repeatMon!
                case 1: temp.repeatTue = !temp.repeatTue!
                case 2: temp.repeatWed = !temp.repeatWed!
                case 3: temp.repeatThu = !temp.repeatThu!
                case 4: temp.repeatFri = !temp.repeatFri!
                case 5: temp.repeatSat = !temp.repeatSat!
                case 6: temp.repeatSun = !temp.repeatSun!
                default: ()
                }
                
                self.viewModel.inputs.updateHabitDetailVOOnEditMode
                    .onNext(temp)
            })
            .disposed(by: self.disposeBag)
        }
    }
    
    func setAllAlarmButtonsEnablement(editMode: Bool) {
        let buttons = [self.alarmMon,
                       self.alarmTue,
                       self.alarmWed,
                       self.alarmThu,
                       self.alarmFri,
                       self.alarmSat,
                       self.alarmSun]
        
        for i in 0 ..< buttons.count {
            let button = buttons[i]
            button?.isEnabled = editMode
        }
    }
   
    // MARK: - Fs Calendar
    
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
        
        self.viewModel.outputs.currentHabitDetailVO.subscribe(onNext: {
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


