//
//  HabitDetailVC.swift
//  Winners Habit
//
//  Created by 최동호 on 2021/05/07.
//
//                                                           ----------------------------------
//                                                           ----------------------------------
//
//                                                                 SNU HOGWARTS SLYTHERIN
//
//                                                           ----------------------------------
//                                                           ----------------------------------

import Foundation
import UIKit
import WinnersHabitOAS
import FSCalendar
import RxSwift
import RxCocoa

class HabitDetailVC: UIViewController, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    static let identifier = "HabitDetailVC"
    
    // 임시 데이터들
    // 실제 코딩에서는 음 plist 에 추가하든가 해야할듯?
    let musics = ["Oh My God", "IU", "Butter", "Lonely"]
    let haptics = ["Basic Call", "Swing", "HapHap", "NaCl"]
    
    // MARK: - UI Components
    
    @IBOutlet weak var challengeName: UILabel!
    @IBOutlet weak var habitImg: UIImageView!
    @IBOutlet weak var habitTitle: UILabel!
    @IBOutlet weak var alarmImg: UIImageView!
    @IBOutlet weak var alarmTimeLabel: UILabel!
    @IBOutlet weak var attribute: UILabel!
    
    @IBOutlet weak var createDate: UILabel!
    @IBOutlet weak var alarmTimeField: UITextField!
    @IBOutlet weak var alarmMusicTextField: UITextField!
    @IBOutlet weak var alarmHapticTextField: UITextField!
    
    @IBOutlet weak var alarmTimeSwitch: UISwitch!
    @IBOutlet weak var alarmMusicSwitch: UISwitch!
    @IBOutlet weak var alarmHapticSwitch: UISwitch!
    
    @IBOutlet var alarmRepeatButtons: [UIButton]!
    @IBOutlet weak var alarmRepeatMon: UIButton!
    @IBOutlet weak var alarmRepeatTue: UIButton!
    @IBOutlet weak var alarmRepeatWed: UIButton!
    @IBOutlet weak var alarmRepeatThu: UIButton!
    @IBOutlet weak var alarmRepeatFri: UIButton!
    @IBOutlet weak var alarmRepeatSat: UIButton!
    @IBOutlet weak var alarmRepeatSun: UIButton!
    
    @IBOutlet weak var memo: UITextView!
    @IBOutlet weak var fsCalendar: FSCalendar!
    
    private var onEdit: UIBarButtonItem!
    
    // MARK: - MVVM-Rx Components
    
    var viewModel : HabitDetailVMType
    private let disposeBag = DisposeBag()
    private var repeatDisposeBag = DisposeBag()
    private var hapticDisposeBag = DisposeBag()
    
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
        // MARK: - Bind UI - INPUT
        
        // edit 버튼 누르면 edit 모드 바꾸기
        self.onEdit.rx.tap
            .debounce(RxTimeInterval.milliseconds(800), scheduler: MainScheduler.instance)
            .debug("onEdit.rx.tap")
            .bind(to: self.viewModel.inputs.changeEditMode)
            .disposed(by: self.disposeBag)
        
        // --------------------------------
        //             OUTPUT
        // --------------------------------
        // MARK: - Bind UI - OUTPUT
        /*
         UI 요소 그리는 것을 한번에 합쳐버리기
         조건들
         1. current HabitDetailVO가 바뀌는 스트림은
         이것이 구독하여 UI를 그린다.
         HabitDetailVO + editMode 고려하기.
         2. 각각의 ui 요소들의 action (tap, gesture) 등등은 따로 뺀다. (INPUT)으로
         */
        
        // MARK: - OUTPUT - Data Sources
        // data source
        // MVVM+Rx의 핵심
        //   얘는 받아온 정보를 "그리기"만 한다.
        //   즉, 여기서 UI를 직접 어떤 값에 의해서 변경하는 로직은 좋은. 구조가. 아니다.
        self.viewModel.outputs.currentHabitDetailVO
            .debug("** 뷰모델에서 최신 데이터 가져오기 **")
            .withUnretained(self)
            .subscribe(onNext: { `self`, habitDetailVO in
                
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
                self.setAlarmHapticUI(habitDetailVO)
                
                // alarm button
                self.setAlarmButton(habitDetailVO)
                
                // alarm memo
                self.memo.text = habitDetailVO.memo

            })
            .disposed(by: self.disposeBag)
        
        // MARK: - OUTPUT - Edit Mode
        // edit mode 시 각 UI 요소들의 기능 같은 것
        // UI 요소만!
        self.viewModel.outputs.editMode // default mode is not editing mode
            .observe(on: MainScheduler.instance)
            .withUnretained(self)
            .subscribe(onNext: { `self`, editMode in
                
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
                
                // haptic
                self.alarmHapticTextField.isEnabled = editMode
                UIView.animate(withDuration: 0.3) {
                    self.alarmHapticDownButton.isHidden = !editMode
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
        
        self.initAlarmHaptic()
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
            self.alarmTimeLabel.isHidden = false
            self.alarmTimeSwitch.isOn = true
            self.alarmTimeLabel.text = convertAlarmTime(time: alarmTime!)
            self.alarmTimeField.text = convertAlarmTime(time: alarmTime!)
            self.alarmTimeLabel.textColor = color
        } else {
            self.alarmImg.isHidden = true
            self.alarmTimeLabel.isHidden = true
            self.alarmTimeSwitch.isOn = false
            self.alarmTimeField.text = "없음"
            self.alarmTimeField.textColor = .systemGray6
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
            self.alarmMusicTextField.text = alarmMusic
        } else {
            self.alarmMusicTextField.textColor = .systemGray6
            self.alarmMusicSwitch.isOn = false
            self.alarmMusicTextField.text = "없음"
        }
    }
    // MARK: - Alarm Haptic
    
    func setAlarmHapticActions() {
        
    }
    
    func setAlarmHapticUI(_ habitDetailVO: HabitDetailVO) {
        self.hapticDisposeBag = DisposeBag()
        /*
         가정
         1. alarmMusic은 nil이면 없는거
         2. nil이 아니면 무조건 뭐든 있어야 함.
         */
        
        if habitDetailVO.alarmHaptic != nil {
            self.alarmHapticTextField.textColor = .label
            self.alarmHapticSwitch.isOn = true
            self.alarmHapticTextField.text = habitDetailVO.alarmHaptic
        } else {
            self.alarmHapticTextField.textColor = .systemGray6
            self.alarmHapticSwitch.isOn = false
            self.alarmHapticTextField.text = "없음"
        }
        
        // rx
        self.alarmHapticSwitch.rx
            .isOn.changed
            .distinctUntilChanged()
            .debounce(RxTimeInterval.milliseconds(800), scheduler: MainScheduler.instance)
            .debug("alarmHapticSwitch 누른 후")
            .withUnretained(self)
            .subscribe(onNext: { `self`, alarmHapticOn in
                
                var nextHabitDetailVO = habitDetailVO
                if alarmHapticOn {
                    nextHabitDetailVO.alarmHaptic = "Basic Call"
                } else {
                    nextHabitDetailVO.alarmHaptic = nil
                }
                self.viewModel.inputs.updateHabitDetailVOOnEditMode.onNext(nextHabitDetailVO)
            })
            .disposed(by: self.hapticDisposeBag)
            
    }
    
    var hapticPickerView = UIPickerView()
    var doneButtonForAlarmHaptic = UIBarButtonItem()
    @IBOutlet weak var alarmHapticDownButton: UIButton!
    
    func initAlarmHaptic() {
        // make alarm haptic cursor color be clear
        self.alarmHapticTextField.tintColor = .clear
        
        // picker view settings
        self.hapticPickerView.delegate = self
        self.hapticPickerView.dataSource = self
        
        self.alarmHapticTextField.inputView = hapticPickerView

        // bar button item "done"
        self.doneButtonForAlarmHaptic.title = "done"
        self.doneButtonForAlarmHaptic.rx.tap
            .debounce(RxTimeInterval.milliseconds(800), scheduler: MainScheduler.instance)
            .withUnretained(self)
            .subscribe(onNext: { `self`, _ in
                self.view.endEditing(true)
            })
            .disposed(by: self.disposeBag)
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        // tool bar
        let toolBar = UIToolbar()
        toolBar.tintColor = .label
        toolBar.frame = CGRect(x: 0, y: 0, width: 0, height: 35)
        toolBar.setItems([flexSpace, self.doneButtonForAlarmHaptic], animated: true)
        
        self.alarmHapticTextField.inputAccessoryView = toolBar
    }
    
    // MARK: - Alarm Button
    
    func setAlarmButton(_ habitDetailVO: HabitDetailVO) {
        // to fix serious bugs
        self.repeatDisposeBag = DisposeBag()

        let buttons: [(UIButton, Bool)]
            = [(self.alarmRepeatMon, habitDetailVO.repeatMon!),
               (self.alarmRepeatTue, habitDetailVO.repeatTue!),
               (self.alarmRepeatWed, habitDetailVO.repeatWed!),
               (self.alarmRepeatThu, habitDetailVO.repeatThu!),
               (self.alarmRepeatFri, habitDetailVO.repeatFri!),
               (self.alarmRepeatSat, habitDetailVO.repeatSat!),
               (self.alarmRepeatSun, habitDetailVO.repeatSun!)]
        
        for (index, button) in buttons.enumerated() {
            
            let currentButton = button.0
            let currentRepeat = button.1

            // 모양
            currentButton.layer.cornerRadius = currentButton.frame.width / 2
            // 색
            if currentRepeat {
                currentButton.backgroundColor = habitDetailVO.color
            } else {
                currentButton.backgroundColor = .systemBackground
            }
            
            // - Rx -
            currentButton.rx.tap
                .debug("currentButton.rx.tap")
                .debounce(RxTimeInterval.milliseconds(800), scheduler: MainScheduler.instance)
                .withUnretained(self)
                .subscribe(onNext: { `self`, _ in
                
                var nextHabitDetailVO = habitDetailVO
                    
                switch index {
                case 0: nextHabitDetailVO.repeatMon = !nextHabitDetailVO.repeatMon!
                case 1: nextHabitDetailVO.repeatTue = !nextHabitDetailVO.repeatTue!
                case 2: nextHabitDetailVO.repeatWed = !nextHabitDetailVO.repeatWed!
                case 3: nextHabitDetailVO.repeatThu = !nextHabitDetailVO.repeatThu!
                case 4: nextHabitDetailVO.repeatFri = !nextHabitDetailVO.repeatFri!
                case 5: nextHabitDetailVO.repeatSat = !nextHabitDetailVO.repeatSat!
                case 6: nextHabitDetailVO.repeatSun = !nextHabitDetailVO.repeatSun!
                default: ()
                }
                
                self.viewModel.inputs.updateHabitDetailVOOnEditMode
                    .onNext(nextHabitDetailVO)
            })
            .disposed(by: self.repeatDisposeBag)
        }
        
    }
    
    func setAllAlarmButtonsEnablement(editMode: Bool) {
        for alarmRepeat in self.alarmRepeatButtons {
            alarmRepeat.isEnabled = editMode
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
    
    // MARK: - UIPickerView Delegate
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.viewModel.outputs.currentHabitDetailVO
            .observe(on: MainScheduler.instance)
            .take(1)
            .withUnretained(self)
            .subscribe(onNext: { `self`, habitDetailVO in
                
                var nextHabitDetailVO = habitDetailVO
                nextHabitDetailVO.alarmHaptic = self.haptics[row]
                self.viewModel.inputs.updateHabitDetailVOOnEditMode.onNext(nextHabitDetailVO)
            })
            .disposed(by: self.disposeBag)
    }
    
    // MARK: - UIPickerView DataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView === self.hapticPickerView {
            return self.haptics.count
        }
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView === self.hapticPickerView {
            return self.haptics[row]
        }
        else {
            return "error"
        }
    }
    
}


