//
//  HabitDetailVC.swift
//  Winners Habit
//
//  Created by 최동호 on 2021/05/07.

import Foundation
import UIKit

import WinnersHabitOAS
import FSCalendar
import RxSwift
import RxCocoa
import RxGesture

class HabitDetailVC: UIViewController, UITextViewDelegate {
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
    @IBOutlet weak var alarmTimeTextField: UITextField!
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
    private var musicDisposeBag = DisposeBag()
    private var hapticDisposeBag = DisposeBag()
    private var alarmTimeDisposeBag = DisposeBag()
    private var memoDisposeBag = DisposeBag()
    
    // MARK: - Init
    
    required init?(coder: NSCoder) {
        self.viewModel = HabitDetailVM()
        super.init(coder: coder)
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initUI()
        self.bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    // MARK: - Init UI
    
    /// Things which is not proper in bindUI() method
    /// Because, in bindUI() method, things are repeatedly changed whenever
    /// new habitDetailVO comes.
    private func initUI() {
        self.initBackButton()
        self.initOnEditButton()
        self.initAlarmTime()
        self.initAlarmMusic()
        self.initAlarmHaptic()
        self.initPickerViewAccessories()
        self.initFSCalendar()
    }
    
    // MARK: - Back Button
    
    func initBackButton() {
        
        let backButton = UIButton().then {
            $0.tintColor = .label
            $0.setImage(UIImage(systemName: "arrow.backward"), for: .normal)
            $0.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(scale: .large), forImageIn: .normal)
            $0.rx.tap
                .asDriver()
                .drive(onNext: {
                    print("hi")
                    self.navigationController?.popViewController(animated: true)
                })
                .disposed(by: self.disposeBag)
        }
        
        let backBarButtonItem = UIBarButtonItem().then {
            $0.customView = backButton
        }
        self.navigationItem.leftBarButtonItem = backBarButtonItem
    }
    
    // MARK: - onEdit
    
    func initOnEditButton() {
        // edit mode button initialize
        self.onEdit = UIBarButtonItem().then {
            $0.image = UIImage(systemName: "pencil")
            $0.tintColor = .label
            self.navigationItem.rightBarButtonItem = $0
        }
    }
    
    // MARK: - Alarm Time
    
    let datePicker = UIDatePicker()
    
    func initAlarmTime() {
        _ = datePicker.then {
            $0.preferredDatePickerStyle = .wheels
            $0.datePickerMode = .time
            $0.locale = Locale(identifier: "ko-KR")
            $0.timeZone = .autoupdatingCurrent
            $0.minuteInterval = 1
            $0.tintColor = .label
        }
        
        self.alarmTimeTextField.tintColor = .clear
        
        self.alarmTimeTextField.inputView = datePicker
    }
    
    /**
     가정
     1. alarmFlag가 true면 alarmMusic이랑 alarmHaptic은 알아서
     2. alarmFlag가 false면 alarmMusic이랑 alarmHaptic은 무조건 nil
     */
    func setAlarmTimeFieldUI(_ habitDetailVO: HabitDetailVO) {
        let alarmFlag = habitDetailVO.alarmFlag
        let alarmTime = habitDetailVO.alarmTime
        let color = habitDetailVO.color
        
        self.alarmImg.isHidden = !alarmFlag
        self.alarmTimeLabel.isHidden = !alarmFlag
        
        self.alarmTimeSwitch.isOn = alarmFlag
        
        if alarmFlag {
            self.alarmTimeLabel.text = convertAlarmTime(time: alarmTime!)
            self.alarmTimeLabel.textColor = color
            
            self.alarmTimeTextField.text = convertAlarmTime(time: alarmTime!)
            self.alarmTimeTextField.textColor = .label
        } else {
            self.alarmTimeTextField.text = "없음"
            self.alarmTimeTextField.textColor = .systemGray6
        }
    }
    
    // MARK: - Alarm Music
    
    var musicPickerView = UIPickerView()
    @IBOutlet weak var alarmMusicDownButton: UIButton!
    
    func initAlarmMusic() {
        // make alarm haptic cursor color be clear
        self.alarmMusicTextField.tintColor = .clear
        
        // picker view settings
        self.musicPickerView.delegate = self
        self.musicPickerView.dataSource = self
        
        // make inputView pickerview
        self.alarmMusicTextField.inputView = musicPickerView
        
        // add alarmMusicDownButton tap event -> picker view
        self.alarmMusicDownButton.rx.tap
            .subscribe(onNext: { self.alarmMusicTextField.becomeFirstResponder() })
            .disposed(by: self.disposeBag)
    }
    
    /**
     가정
     1. alarmMusic은 nil이면 없는거
     2. nil이 아니면 무조건 뭐든 있어야 함.
     */
    func setAlarmMusicUI(_ habitDetailVO: HabitDetailVO) {
        if habitDetailVO.alarmMusic != nil {
            self.alarmMusicTextField.textColor = .label
            self.alarmMusicSwitch.isOn = true
            self.alarmMusicTextField.text = habitDetailVO.alarmMusic
        } else {
            self.alarmMusicTextField.textColor = .systemGray6
            self.alarmMusicSwitch.isOn = false
            self.alarmMusicTextField.text = "없음"
        }
    }
    
    // MARK: - Alarm Haptic
    
    var hapticPickerView = UIPickerView()
    @IBOutlet weak var alarmHapticDownButton: UIButton!
    
    func initAlarmHaptic() {
        // make alarm haptic cursor color be clear
        self.alarmHapticTextField.tintColor = .clear
        
        // picker view settings
        self.hapticPickerView.delegate = self
        self.hapticPickerView.dataSource = self
        
        // make inputView pickerview
        self.alarmHapticTextField.inputView = hapticPickerView
        
        // add alarmMusicDownButton tap event -> picker view
        self.alarmHapticDownButton.rx.tap
            .subscribe(onNext: { self.alarmHapticTextField.becomeFirstResponder() })
            .disposed(by: self.disposeBag)
    }
    
    /**
     가정
     1. alarmHaptic은 nil이면 없는거
     2. nil이 아니면 무조건 뭐든 있어야 함.
     */
    func setAlarmHapticUI(_ habitDetailVO: HabitDetailVO) {
        if habitDetailVO.alarmHaptic != nil {
            self.alarmHapticTextField.textColor = .label
            self.alarmHapticSwitch.isOn = true
            self.alarmHapticTextField.text = habitDetailVO.alarmHaptic
        } else {
            self.alarmHapticTextField.textColor = .systemGray6
            self.alarmHapticSwitch.isOn = false
            self.alarmHapticTextField.text = "없음"
        }
    }
    
    // MARK: - Init Picker View Accessories
    
    func initPickerViewAccessories() {
        // bar button item "done"
        let doneButton = UIBarButtonItem()
        doneButton.title = "done"
        doneButton.rx.tap
            .throttle(RxTimeInterval.milliseconds(300), latest: false, scheduler: MainScheduler.instance)
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
        toolBar.setItems([flexSpace, doneButton], animated: true)
        
        self.alarmTimeTextField.inputAccessoryView = toolBar
        self.alarmMusicTextField.inputAccessoryView = toolBar
        self.alarmHapticTextField.inputAccessoryView = toolBar
        self.memo.inputAccessoryView = toolBar
    }
    
    // MARK: - Alarm Button
    
    func setAlarmButton(_ habitDetailVO: HabitDetailVO) {
        let buttons: [(UIButton, Bool)]
            = [(self.alarmRepeatMon, habitDetailVO.repeatMon!),
               (self.alarmRepeatTue, habitDetailVO.repeatTue!),
               (self.alarmRepeatWed, habitDetailVO.repeatWed!),
               (self.alarmRepeatThu, habitDetailVO.repeatThu!),
               (self.alarmRepeatFri, habitDetailVO.repeatFri!),
               (self.alarmRepeatSat, habitDetailVO.repeatSat!),
               (self.alarmRepeatSun, habitDetailVO.repeatSun!)]
        
        for button in buttons {
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
        }
    }
    
    func setAllAlarmButtonsEnablement(editMode: Bool) {
        for alarmRepeat in self.alarmRepeatButtons {
            alarmRepeat.isEnabled = editMode
        }
    }
    
    // MARK: - Memo
    
    @IBOutlet weak var eraseButton: UIButton!
    
    // MARK: - BindUI
    
    private func bindViewModel() {
        
        // MARK: - Bind UI - INPUT
        /// things to go to viewModel.inputs
        
        self.bindOnEditButton()
        
        // things which needs up-to-date habitDetailVO
        self.viewModel.outputs.currentHabitDetailVO
            .withUnretained(self)
            .subscribe(onNext: { `self`, habitDetailVO in
                
                self.bindAlarmTimeField(habitDetailVO)
                self.bindAlarmMusicSwitch(habitDetailVO)
                self.bindAlarmHapticSwitch(habitDetailVO)
                self.bindAlarmRepeatButton(habitDetailVO)
                self.bindMemo(habitDetailVO)
            })
            .disposed(by: self.disposeBag)
        
        // MARK: - Bind UI - OUTPUT
        /**
         UI 요소 그리는 것을 한번에 합쳐버리기
         
         1. current HabitDetailVO가 바뀌는 스트림은
         이것이 구독하여 UI를 그린다.
         2. 각각의 ui 요소들의 action (tap, gesture) 등등은 따로 뺀다. (INPUT)으로
         */
        self.bindMainUI()
        self.bindEditModeUI()
    }
    
    // MARK: - INPUT - onEdit
    
    /// edit 버튼 누르면 edit 모드 바꾸기
    func bindOnEditButton() {
        self.onEdit.rx.tap
            .throttle(RxTimeInterval.milliseconds(300), latest: false, scheduler: MainScheduler.instance)
            .debug("onEdit.rx.tap")
            .bind(to: self.viewModel.inputs.changeEditMode)
            .disposed(by: self.disposeBag)
    }
    
    // MARK: - INPUT - AlarmTime
    
    func bindAlarmTimeField(_ habitDetailVO: HabitDetailVO) {
        self.alarmTimeDisposeBag = DisposeBag()
        
        // 알람 시간 변경
        // 시간 고르기
        self.datePicker.rx.date.changed
            .distinctUntilChanged()
            .withUnretained(self)
            .debug("date picker")
            .subscribe(onNext: { `self`, date in
                
                var nextHabitDetailVO = habitDetailVO
                let df = DateFormatter()
                df.dateFormat = "HH:mm:ss"
                nextHabitDetailVO.alarmTime = df.string(from: date)
                
                self.viewModel.inputs.updateHabitDetailVOOnEditMode.onNext(nextHabitDetailVO)
            })
            .disposed(by: self.alarmTimeDisposeBag)
        
        // 알람 스위치 눌렀을 때
        self.alarmTimeSwitch.rx
            .isOn.changed
            .distinctUntilChanged()
            .throttle(RxTimeInterval.milliseconds(300), latest: false, scheduler: MainScheduler.instance)
            .withUnretained(self)
            .subscribe(onNext: { `self`, alarmOn in
                
                var nextHabitDetailVO = habitDetailVO
                nextHabitDetailVO.alarmFlag = alarmOn
                // 기본 값
                if alarmOn {
                    nextHabitDetailVO.alarmMusic = "Basic Call"
                    nextHabitDetailVO.alarmHaptic = "Basic Call"
                }
                // alarm을 끈 것이라면 알람음과 진동은 무조건 nil: 서비스 정책
                else {
                    nextHabitDetailVO.alarmMusic = nil
                    nextHabitDetailVO.alarmHaptic = nil
                }
                self.viewModel.inputs.updateHabitDetailVOOnEditMode.onNext(nextHabitDetailVO)
            })
            .disposed(by: self.alarmTimeDisposeBag)
    }
    
    // MARK: - INPUT - MusicSwitch
    
    /// alarmMusicSwitch tap
    func bindAlarmMusicSwitch(_ habitDetailVO: HabitDetailVO) {
        self.musicDisposeBag = DisposeBag()
        
        self.alarmMusicSwitch.rx
            .isOn.changed
            .distinctUntilChanged()
            .throttle(RxTimeInterval.milliseconds(300), latest: false, scheduler: MainScheduler.instance)
            .withUnretained(self)
            .subscribe(onNext: { `self`, alarmMusicOn in
                
                var nextHabitDetailVO = habitDetailVO
                if alarmMusicOn {
                    nextHabitDetailVO.alarmMusic = "Basic Call"
                } else {
                    nextHabitDetailVO.alarmMusic = nil
                }
                self.viewModel.inputs.updateHabitDetailVOOnEditMode.onNext(nextHabitDetailVO)
            })
            .disposed(by: self.musicDisposeBag)
    }
    
    // MARK: - INPUT - HapticSwitch
    
    // alarmHapticSwitch를 누르면
    func bindAlarmHapticSwitch(_ habitDetailVO: HabitDetailVO) {
        self.hapticDisposeBag = DisposeBag()
        
        self.alarmHapticSwitch.rx
            .isOn.changed
            .distinctUntilChanged()
            .throttle(RxTimeInterval.milliseconds(300), latest: false, scheduler: MainScheduler.instance)
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
    
    // MARK: - INPUT - RepeatButtons
    
    func bindAlarmRepeatButton(_ habitDetailVO: HabitDetailVO) {
        // to fix serious bugs
        self.repeatDisposeBag = DisposeBag()
        
        for (index, currentButton) in self.alarmRepeatButtons.enumerated() {
            
            currentButton.rx.tap
                .debug("currentButton.rx.tap")
                .throttle(RxTimeInterval.milliseconds(300), latest: false, scheduler: MainScheduler.instance)
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
    
    // MARK: - INPUT - Memo
    
    func bindMemo(_ habitDetailVO: HabitDetailVO) {
        self.memoDisposeBag = DisposeBag()
        
        // text 입력할 때마다 viewModel로 보내기
        self.memo.rx
            .text.changed
            .distinctUntilChanged()
            .withUnretained(self)
            .subscribe(onNext: { `self`, text in
                var nextHabitDetailVO = habitDetailVO
                nextHabitDetailVO.memo = text
                self.viewModel.inputs.updateHabitDetailVOOnEditMode.onNext(nextHabitDetailVO)
            })
            .disposed(by: self.memoDisposeBag)
        
        // erase 버튼 누르면
        // 삭제해서 viewModel로 보내기
        self.eraseButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { `self`, _ in
                var nextHabitDetailVO = habitDetailVO
                nextHabitDetailVO.memo = nil
                self.viewModel.inputs.updateHabitDetailVOOnEditMode.onNext(nextHabitDetailVO)
            })
            .disposed(by: self.memoDisposeBag)
    }
    
    // MARK: - OUTPUT - Bind UI
    
    /// bind main UI
    /// viewModel의 output에서 오는 최신 정보들을 받아 "그리기"만 한다.
    func bindMainUI() {
        self.viewModel.outputs.currentHabitDetailVO
            .debug("** fetch current habitDetailVO **")
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
                self.setAlarmTimeFieldUI(habitDetailVO)
                
                // alarm music
                self.setAlarmMusicUI(habitDetailVO)
                
                // alarm haptic
                self.setAlarmHapticUI(habitDetailVO)
                
                // alarm button
                self.setAlarmButton(habitDetailVO)
                
                // alarm memo
                self.memo.text = habitDetailVO.memo
                
            })
            .disposed(by: self.disposeBag)
    }
    
    // MARK: - OUTPUT - Bind EditMode UI
    
    /// edit mode 시 각 UI 요소들의 기능 같은 것
    /// UI 요소만!
    /// ## open editing Mode ###
    /// 1. 각 알람 스위치 enable
    /// 2. edit 버튼 바뀌기
    /// 3. 알람 시간, 알람음, 알람 진동 고를 수 있게 하는 창 나오기
    ///    - 알람 on: 위에 해결, 알람 시간 바꾸면 위에 부분도 해결하기
    ///    - 알람 off: 위에 알람시계랑 라벨도 떼고
    ///    - 알람 시간: 없음
    ///    - 알람 음, 진동: 없음
    /// 4. 각 알람 버튼 선택할 수 있게 하기
    /// 5. 메모 편집할 수 있도록 + 현재 자/최대 50자 + 지우개 버튼 나오기
    /// ## not editing Mode
    /// 1. 각 알람 스위치 not enable
    /// 2. edit 버튼 바뀌기
    /// 3. 알람 시간, 알람음, 알람 진동 고를 수 있게 하는 삭제
    /// 4. 각 알람 버튼 선택할 수 없게 하기
    /// 5. 메모 편집할 수 없도록 + 현재 자/최대 50자(삭제) + 지우개 버튼 나오기(삭제)
    func bindEditModeUI() {
        self.viewModel.outputs.editMode // default mode is not editing mode
            .observe(on: MainScheduler.instance)
            .withUnretained(self)
            .subscribe(onNext: { `self`, editMode in
                
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
                
                // alarmtime field
                self.alarmTimeTextField.isEnabled = editMode
                
                // music
                self.alarmMusicTextField.isEnabled = editMode
                UIView.animate(withDuration: 0.3) {
                    self.alarmMusicDownButton.isHidden = !editMode
                }
                
                // haptic
                self.alarmHapticTextField.isEnabled = editMode
                UIView.animate(withDuration: 0.3) {
                    self.alarmHapticDownButton.isHidden = !editMode
                }
                
                // alarm buttons
                self.setAllAlarmButtonsEnablement(editMode: editMode)
                
                // memo
                self.memo.isEditable = editMode
                UIView.animate(withDuration: 0.3) {
                    self.eraseButton.isHidden = !editMode
                }
            })
            .disposed(by: self.disposeBag)
    }
}

extension HabitDetailVC: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    
    // MARK: - Init FsCalendar
    
    func initFSCalendar() {
        self.fsCalendar.delegate = self
        self.fsCalendar.dataSource = self
        self.fsCalendar.allowsSelection = false
        self.fsCalendar.scrollEnabled = true
        self.fsCalendar.scrollDirection = .horizontal
        self.fsCalendar.register(FSCalendarCell.self, forCellReuseIdentifier: "cell")
    }
    
    // MARK: - FS Calendar Delegate
    
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        var _habitDetailVO: HabitDetailVO? = nil
        
        self.viewModel.outputs.currentHabitDetailVO
            .take(1)
            .subscribe(onNext: { _habitDetailVO = $0 })
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

extension HabitDetailVC: UIPickerViewDelegate, UIPickerViewDataSource {
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
        else {
            return self.musics.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView === self.hapticPickerView {
            return self.haptics[row]
        }
        else {
            return self.musics[row]
        }
    }
}
