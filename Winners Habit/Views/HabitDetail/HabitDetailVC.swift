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

enum SwitchType {
    case alarmTime, alarmMusic, alarmHaptic
}


class HabitDetailVC: UIViewController {
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
    
    // MARK: - Init
    
    required init?(coder: NSCoder) {
        viewModel = HabitDetailVM()
        super.init(coder: coder)
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    // MARK: - Init UI
    
    /// Things which is not proper in bindUI() method
    /// Because, in bindUI() method, things are repeatedly changed whenever
    /// new habitDetailVO comes.
    private func initUI() {
        initBackButton()
        initOnEditButton()
        initAlarmTime()
        initAlarmMusic()
        initAlarmHaptic()
        initPickerViewAccessories()
        initFSCalendar()
    }
    
    // MARK: - Back Button
    
    func initBackButton() {
        
        let backButton = UIButton().then {
            $0.tintColor = .label
            $0.setImage(UIImage(systemName: "arrow.backward"), for: .normal)
            $0.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(scale: .large), forImageIn: .normal)
            $0.rx.tap
                .withUnretained(self)
                .subscribe(onNext: { `self`, _ in
                    self.navigationController?.popViewController(animated: true)
                })
                .disposed(by: disposeBag)
        }
        
        let backBarButtonItem = UIBarButtonItem().then {
            $0.customView = backButton
        }
        navigationItem.leftBarButtonItem = backBarButtonItem
    }
    
    // MARK: - onEdit
    
    func initOnEditButton() {
        // edit mode button initialize
        self.onEdit = UIBarButtonItem().then {
            $0.image = UIImage(systemName: "pencil")
            $0.tintColor = .label
            navigationItem.rightBarButtonItem = $0
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
        
        alarmTimeTextField.tintColor = .clear
        
        alarmTimeTextField.inputView = datePicker
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
        
        alarmImg.isHidden = !alarmFlag
        alarmTimeLabel.isHidden = !alarmFlag
   
        alarmTimeSwitch.isOn = alarmFlag
        
        if alarmFlag {
            alarmTimeLabel.text = convertAlarmTime(time: alarmTime!)
            alarmTimeLabel.textColor = color
       
            alarmTimeTextField.text = convertAlarmTime(time: alarmTime!)
            alarmTimeTextField.textColor = .label
        } else {
            alarmTimeTextField.text = "없음"
            alarmTimeTextField.textColor = .systemGray6
        }
    }
    
    // MARK: - Alarm Music
    
    var musicPickerView = UIPickerView()
    @IBOutlet weak var alarmMusicDownButton: UIButton!
    
    func initAlarmMusic() {
        // make alarm haptic cursor color be clear
        alarmMusicTextField.tintColor = .clear
        
        // picker view settings
        musicPickerView.delegate = self
        musicPickerView.dataSource = self
        
        // make inputView pickerview
        alarmMusicTextField.inputView = musicPickerView
        
        // add alarmMusicDownButton tap event -> picker view
        alarmMusicDownButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { `self`, _ in
                self.alarmMusicTextField.becomeFirstResponder()
            })
            .disposed(by: disposeBag)
    }
    
    /**
     가정
     1. alarmMusic은 nil이면 없는거
     2. nil이 아니면 무조건 뭐든 있어야 함.
     */
    func setAlarmMusicUI(_ habitDetailVO: HabitDetailVO) {
        if habitDetailVO.alarmMusic != nil {
            alarmMusicTextField.textColor = .label
            alarmMusicSwitch.isOn = true
            alarmMusicTextField.text = habitDetailVO.alarmMusic
        } else {
            alarmMusicTextField.textColor = .systemGray6
            alarmMusicSwitch.isOn = false
            alarmMusicTextField.text = "없음"
        }
    }
    
    // MARK: - Alarm Haptic
    
    var hapticPickerView = UIPickerView()
    @IBOutlet weak var alarmHapticDownButton: UIButton!
    
    func initAlarmHaptic() {
        // make alarm haptic cursor color be clear
        alarmHapticTextField.tintColor = .clear
        
        // picker view settings
        hapticPickerView.delegate = self
        hapticPickerView.dataSource = self
        
        // make inputView pickerview
        alarmHapticTextField.inputView = hapticPickerView
        
        // add alarmMusicDownButton tap event -> picker view
        alarmHapticDownButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { `self`, _ in
                self.alarmHapticTextField.becomeFirstResponder()
            })
            .disposed(by: self.disposeBag)
    }
    
    /**
     가정
     1. alarmHaptic은 nil이면 없는거
     2. nil이 아니면 무조건 뭐든 있어야 함.
     */
    func setAlarmHapticUI(_ habitDetailVO: HabitDetailVO) {
        if habitDetailVO.alarmHaptic != nil {
            alarmHapticTextField.textColor = .label
            alarmHapticSwitch.isOn = true
            alarmHapticTextField.text = habitDetailVO.alarmHaptic
        } else {
            alarmHapticTextField.textColor = .systemGray6
            alarmHapticSwitch.isOn = false
            alarmHapticTextField.text = "없음"
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
            .subscribe(onNext: { `self`, _ in self.view.endEditing(true) })
            .disposed(by: self.disposeBag)
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        // tool bar
        let toolBar = UIToolbar()
        toolBar.tintColor = .label
        toolBar.frame = CGRect(x: 0, y: 0, width: 0, height: 35)
        toolBar.setItems([flexSpace, doneButton], animated: true)
        
        alarmTimeTextField.inputAccessoryView = toolBar
        alarmMusicTextField.inputAccessoryView = toolBar
        alarmHapticTextField.inputAccessoryView = toolBar
        memo.inputAccessoryView = toolBar
    }
    
    // MARK: - Alarm Button
    
    func setAlarmRepeatButton(_ habitDetailVO: HabitDetailVO) {
        let buttons: [(UIButton, Bool)]
            = [(alarmRepeatMon, habitDetailVO.repeatMon!),
               (alarmRepeatTue, habitDetailVO.repeatTue!),
               (alarmRepeatWed, habitDetailVO.repeatWed!),
               (alarmRepeatThu, habitDetailVO.repeatThu!),
               (alarmRepeatFri, habitDetailVO.repeatFri!),
               (alarmRepeatSat, habitDetailVO.repeatSat!),
               (alarmRepeatSun, habitDetailVO.repeatSun!)]
        
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
        for alarmRepeat in alarmRepeatButtons {
            alarmRepeat.isEnabled = editMode
        }
    }
    
    // MARK: - Memo
    
    @IBOutlet weak var eraseButton: UIButton!
    
    // MARK: - Bind ViewModel
    
    private func bindViewModel() {

        // INPUT
        
        bindOnEditButton()
        bindAlarmTimeField()
        bindAlarmMusicSwitch()
        bindAlarmHapticSwitch()
        bindAlarmRepeatButton()
        bindMemo()
        
        // OUTPUT
        
        bindMainUI()
        bindEditModeUI()
    }
    
    // MARK: - INPUT
    
    /// edit 버튼 누르면 edit 모드 바꾸기
    func bindOnEditButton() {
        onEdit.rx.tap
            .throttle(RxTimeInterval.milliseconds(300), latest: false, scheduler: MainScheduler.instance)
            .bind(to: viewModel.inputs.toggleEditMode)
            .disposed(by: disposeBag)
    }
    
    /// 1. bind date picker to viewModel
    /// 2. when alarmTimeSwitch tap
    func bindAlarmTimeField() {
        // 알람 시간 변경
        // 시간 고르기
        datePicker.rx.date.changed
            .distinctUntilChanged()
            .bind(to: viewModel.inputs.changeAlarmTime)
            .disposed(by: disposeBag)
        
        // 알람 스위치 눌렀을 때
        alarmTimeSwitch.rx
            .isOn.changed
            .distinctUntilChanged()
            .throttle(RxTimeInterval.milliseconds(300), latest: false, scheduler: MainScheduler.instance)
            .map { (isOn: $0, alarmSwitch: .alarmTime) }
            .bind(to: viewModel.inputs.changeAlarmSwitch)
            .disposed(by: disposeBag)
    }
    
    /// 1. bind music picker view to viewModel
    /// 2. when alarmMusicSwitch tap
    func bindAlarmMusicSwitch() {
        musicPickerView.rx.itemSelected
            .withUnretained(self)
            .map { `self`, tuple in
                self.musics[tuple.0]
            }
            .bind(to: viewModel.inputs.changeAlarmMusic)
            .disposed(by: disposeBag)

        alarmMusicSwitch.rx
            .isOn.changed
            .distinctUntilChanged()
            .throttle(RxTimeInterval.milliseconds(300), latest: false, scheduler: MainScheduler.instance)
            .map { (isOn: $0, alarmSwitch: .alarmMusic) }
            .bind(to: viewModel.inputs.changeAlarmSwitch)
            .disposed(by: disposeBag)
    }
    
    /// 1. bind haptic picker view to viewModel
    /// 2. when alarmHapticSwitch tap
    func bindAlarmHapticSwitch() {
        hapticPickerView.rx.itemSelected
            .withUnretained(self)
            .map { `self`, tuple in
                self.haptics[tuple.0]
            }
            .bind(to: viewModel.inputs.changeAlarmHaptic)
            .disposed(by: disposeBag)
        
        alarmHapticSwitch.rx
            .isOn.changed
            .distinctUntilChanged()
            .throttle(RxTimeInterval.milliseconds(300), latest: false, scheduler: MainScheduler.instance)
            .map { (isOn: $0, alarmSwitch: .alarmHaptic) }
            .bind(to: viewModel.inputs.changeAlarmSwitch)
            .disposed(by: disposeBag)
    }
    
    func bindAlarmRepeatButton() {
        for (index, currentButton) in alarmRepeatButtons.enumerated() {
            
            currentButton.rx.tap
                .throttle(RxTimeInterval.milliseconds(300), latest: false, scheduler: MainScheduler.instance)
                .withUnretained(self)
                .subscribe(onNext: { `self`, _ in
                    var day = Day.error
                    
                    switch index {
                    case 0: day = .Mon
                    case 1: day = .Tue
                    case 2: day = .Wed
                    case 3: day = .Thu
                    case 4: day = .Fri
                    case 5: day = .Sat
                    case 6: day = .Sun
                    default: ()
                    }
                    
                    self.viewModel.inputs.changeRepeatButton.onNext(day)
                })
                .disposed(by: disposeBag)
        }
    }
    
    /// 1. text 입력할 때마다 viewModel로 보내기
    /// 2. erase -> set memo `nil`and send to view model
    func bindMemo() {
        memo.rx
            .text.changed
            .distinctUntilChanged()
            .bind(to: viewModel.inputs.changeMemo)
            .disposed(by: disposeBag)
        
        eraseButton.rx.tap
            .map { nil }
            .bind(to: viewModel.inputs.changeMemo)
            .disposed(by: disposeBag)
    }
    
    // MARK: - OUTPUT
    
    /// bind main UI
    /// viewModel의 output에서 오는 최신 정보들을 받아 "그리기"만 한다.
    func bindMainUI() {
        viewModel.outputs.currentHabitDetailVO
            .withUnretained(self)
            .subscribe(onNext: { `self`, habitDetailVO in
                
                self.habitImg.image = habitDetailVO.habitImg
                
                // alarm time
                self.setAlarmTimeFieldUI(habitDetailVO)
                
                // alarm music
                self.setAlarmMusicUI(habitDetailVO)
                
                // alarm haptic
                self.setAlarmHapticUI(habitDetailVO)
                
                // alarm button
                self.setAlarmRepeatButton(habitDetailVO)
            })
            .disposed(by: self.disposeBag)
        
        // 처음 한번만 받으면 되는 애들
        viewModel.outputs.currentHabitDetailVO
            .take(1)
            .withUnretained(self)
            .subscribe(onNext: { `self`, habitDetailVO in
                self.challengeName.text = habitDetailVO.challengeName
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
                
                // alarm memo
                self.memo.text = habitDetailVO.memo
            })
            .disposed(by: self.disposeBag)
    }
    
    // MARK: - OUTPUT
    
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
        fsCalendar.delegate = self
        fsCalendar.dataSource = self
        fsCalendar.allowsSelection = false
        fsCalendar.scrollEnabled = true
        fsCalendar.scrollDirection = .horizontal
        fsCalendar.register(FSCalendarCell.self, forCellReuseIdentifier: "cell")
    }
    
    // MARK: - FS Calendar Delegate
    
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        var _habitDetailVO: HabitDetailVO? = nil
        
        viewModel.outputs.currentHabitDetailVO
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
    
    // MARK: - UIPickerView DataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView === hapticPickerView {
            return haptics.count
        }
        else {
            return musics.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView === hapticPickerView {
            return haptics[row]
        }
        else {
            return musics[row]
        }
    }
}
