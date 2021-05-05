//
//  ViewController.swift
//  Winners' habit
//
//  Created by 최동호 on 2021/04/23.
//

import UIKit
import Then
import SnapKit
import OpenAPIClient

class MainVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var challengeImage: UIImageView!
    @IBOutlet weak var challengeDDay: UILabel!
    @IBOutlet weak var challengeName: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var dateLabel: UILabel!
    var prevDay: UIButton!
    var postDay: UIButton!
    var titleCtnView : UIView!
    
    var currentDate: Date!
    
    // temp
    let habits = [
        Habit(habitId: 1, habitName: "새벽 기상", icon: "https://cpng.pikpng.com/pngl/s/61-610145_half-moon-transparent-yellow-half-moon-png-clipart.png", color: "F5D423", defaultAttributeValue: nil, attribute: "s/f", alarmFlag: false, alarmTime: "06:30:00"),
        Habit(habitId: 2, habitName: "운동", icon: "https://w7.pngwing.com/pngs/416/969/png-transparent-kaatsu-exercise-pictogram-strength-training-others-thumbnail.png", color: "FA331B", defaultAttributeValue: 20, attribute: "min", alarmFlag: false, alarmTime: "06:30:00"),
        Habit(habitId: 3, habitName: "독서", icon: "https://icons555.com/images/icons-blue/image_icon_book_pic_512x512.png", color: "2B42F5", defaultAttributeValue: 20, attribute: "pages", alarmFlag: false, alarmTime: "17:30:00"),
    ]
    
    let challenge = Challenge(challengeId: 1, challengeName: "빌 게이츠", challengeImage: "", challengeDDay: 35)
    
    // 2021-05-04
    // given by order which is same with habits
    let habitHistories = [
        HabitHistory(habitId: 1, doneFlag: true),
        HabitHistory(habitId: 2, doneFlag: false),
        HabitHistory(habitId: 3, doneFlag: true),
    ]
    
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // table view initial settings
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        
        // challenge initial settings
        self.challengeImage.image = UIImage(named: "billgates.png")
        self.challengeName.text = self.challenge.challengeName
        self.challengeDDay.text = "D-\(self.challenge.challengeDDay!)"
        
        // default navigation bar clear
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
        
        // set title by today date
        self.initTitle()
        
        // long press recognizer
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        self.tableView.addGestureRecognizer(longPressRecognizer)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // set title to default - today
        self.currentDate = Date()
        self.setTitleDate(date: dateStringDetail(date: self.currentDate), leftArrow: true, rightArrow: false)
    }
    
    // MARK: - Actions
    
    func initTitle() {
        
        self.titleCtnView = UIView().then {
            $0.frame.size = CGSize(width: 200, height: 44)
            self.navigationItem.titleView = $0
        }
        
        self.dateLabel = UILabel().then {
            $0.textColor = .label
            $0.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
            $0.sizeToFit()
            titleCtnView.addSubview($0)
            $0.snp.makeConstraints { make in
                make.center.equalTo(titleCtnView.snp.center)
            }
        }

        self.prevDay = UIButton().then {
            let prevImg = UIImage(systemName: "arrowtriangle.left")
            $0.setImage(prevImg, for: .normal)
            $0.tintColor = .label
            $0.addTarget(self, action: #selector(goPrevDay(_:)), for: .touchUpInside)
        }
        
        self.postDay = UIButton().then {
            let postImg = UIImage(systemName: "arrowtriangle.right")
            $0.setImage(postImg, for: .normal)
            $0.tintColor = .label
            $0.addTarget(self, action: #selector(goPostDay(_:)), for: .touchUpInside)
        }
    }
    
    func setTitleDate(date: String, leftArrow: Bool, rightArrow: Bool) {
        self.dateLabel.text = date
        
        if leftArrow {
            self.titleCtnView.addSubview(self.prevDay)
            // use SnapKit to set auto layout settings
            self.prevDay.snp.makeConstraints { make in
                make.right.equalTo(self.dateLabel.snp.left).offset(-10)
                make.centerY.equalTo(titleCtnView.snp.centerY)
            }
        }
        
        if rightArrow {
            self.titleCtnView.addSubview(self.postDay)
            // use SnapKit to set auto layout settings
            self.postDay.snp.makeConstraints { make in
                make.left.equalTo(self.dateLabel.snp.right).offset(10)
                make.centerY.equalTo(titleCtnView.snp.centerY)
            }
        }
    }
    
    @objc func goPrevDay(_ sender: UIButton){
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: self.currentDate)!
        self.currentDate = yesterday
        
         /**
         call api (/habit-history)
         using dateSring(date:)
         and save to habitHistories
         */
        
        // set title and arrows
        self.setTitleDate(date: dateStringDetail(date: yesterday), leftArrow: true, rightArrow: true)
        
        // reload table
        if let cells = self.tableView.visibleCells as? [HabitCell] {
            for cell in cells {
                cell.clearChecking()
            }
        }
        
        // set done flags by habit-histories
        for i in 0 ..< self.habits.count {
            guard let cell = self.tableView.visibleCells[i] as? HabitCell else {
                fatalError("cell type wrong!")
            }
            
            cell.setChecking(done: self.habitHistories[i].doneFlag)
        }
    }
    
    @objc func goPostDay(_ sender: UIButton) {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: self.currentDate)!
        self.currentDate = tomorrow
        
         /**
         call api (/habit-history)
         using dateSring(date:)
         and save to habitHistories
         */
        
        // set title and arrows
        if tomorrow == Date() {
            self.setTitleDate(date: dateStringDetail(date: tomorrow), leftArrow: true, rightArrow: false)
        } else {
            self.setTitleDate(date: dateStringDetail(date: tomorrow), leftArrow: true, rightArrow: true)
        }
        
        // reload table
        if let cells = self.tableView.visibleCells as? [HabitCell] {
            for cell in cells {
                cell.clearChecking()
            }
        }
        
        // set done flags by habit-histories
        for i in 0 ..< self.habits.count {
            guard let cell = self.tableView.visibleCells[i] as? HabitCell else {
                fatalError("cell type wrong!")
            }
            
            cell.setChecking(done: self.habitHistories[i].doneFlag)
        }
    }
    
    @objc func longPress(_ sender: UILongPressGestureRecognizer){
        
        let point = sender.location(in: self.tableView)
        if let indexPath = self.tableView.indexPathForRow(at: point),
           let cell = self.tableView.cellForRow(at: indexPath) as? HabitCell
        {
            switch sender.state {
            case .began:
                cell.toggleChecking()
            default:
                ()
            }
        }
    }

    
    // MARK: - TableView Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.habits.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "habitCell") as? HabitCell else {
            fatalError("habit cell fucked up")
        }

        let habit = self.habits[indexPath.row]
        let cellColor = hexToUIColor(hex: habit.color)
        cell.habitTitle.text = habit.habitName
        let url = URL(string: habit.icon)
        cell.habitImg.image = (try? UIImage(data: Data(contentsOf: url!))) ?? UIImage()
        
        // convert "HH:mm:ss" -> "오전 h:mm"
        let dateString = habit.alarmTime! as NSString
        let hPart = dateString.substring(with: NSMakeRange(0, 2))
        let df = DateFormatter()
        df.dateFormat = "HH:mm:ss"
        let alarmDate = df.date(from: dateString as String)
        df.dateFormat = "h:mm"
        let alarm = df.string(from: alarmDate!)
        if hPart.hasPrefix("0") || (Int(hPart)!) < 12 {
            cell.habitAlarmTime.text = "오전 \(alarm)"
        } else {
            cell.habitAlarmTime.text = "오후 \(alarm)"
        }
        
        cell.habitAlarmTime.textColor = cellColor
        switch habit.attribute {
        case "s/f":
            cell.habitAttr.text = "성공/실패"
        case "min":
            cell.habitAttr.text = "0/\(habit.defaultAttributeValue!) min"
        case "pages":
            cell.habitAttr.text = "0/\(habit.defaultAttributeValue!) 장"
        default:
            ()
        }
        cell.habitAttr.textColor = cellColor
        
        cell.selectedBackgroundView = UIView()
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        guard let cell = self.tableView.cellForRow(at: indexPath) as? HabitCell else {
            fatalError("trailingSwipeActionsConfigurationForRowAt error")
        }
        
        let editAction = UIContextualAction(style: .normal, title: nil) { action, view, completion in
            completion(true)
        }.then {
            $0.image = UIImage(systemName: "pencil")
            $0.backgroundColor = .systemBackground
        }
        
        let checkAction = UIContextualAction(style: .normal, title: nil) { action, view, completion in
            completion(true)
            cell.toggleChecking()
        }.then {
            $0.image = UIImage(systemName: "checkmark")
            $0.backgroundColor = .systemBackground
        }
        
        return UISwipeActionsConfiguration(actions: [editAction, checkAction]).then {
            $0.performsFirstActionWithFullSwipe = false
        }
    }
}
