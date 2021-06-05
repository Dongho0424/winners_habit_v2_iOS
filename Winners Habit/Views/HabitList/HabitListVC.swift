//
//  ViewController.swift
//  Winners' habit
//
//  Created by 최동호 on 2021/04/23.
//

import UIKit
import Then
import SnapKit
import WinnersHabitOAS
import RxSwift

class HabitListVC: UIViewController, UITableViewDelegate {
    
    // MARK: - UI Components
    
    @IBOutlet weak var challengeImage: UIImageView!
    @IBOutlet weak var challengeDDay: UILabel!
    @IBOutlet weak var challengeName: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var dateLabel: UILabel!
    var prevDay: UIButton!
    var postDay: UIButton!
    var titleCtnView : UIView!
    var currentDate: Date!
    
    // MARK: - MVVM Components
    
    private let viewModel : HabitListVMType
    private let disposeBag = DisposeBag()
    
    // MARK: - Init
    required init?(coder: NSCoder) {
        self.viewModel = HabitListVM()
        super.init(coder: coder)
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // table view initial settings
        self.tableView.delegate = self
//        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        
        self.initUI()
        
        self.bindUIWithViewModel()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("viewWillAppear")
    }
    
    // MARK: - set UI
    
    func initUI() {
        
        // default navigation bar clear
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
        
        // set title by today date
        self.initTitleView()
        
        // long press recognizer
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        self.tableView.addGestureRecognizer(longPressRecognizer)
        
        // back button title to nil
        _ = UIBarButtonItem(title: nil, style: .plain, target: self, action: nil).then { [unowned self] in
            $0.tintColor = .label
            self.navigationItem.backBarButtonItem = $0
        }
        
        // currentDate는 오늘로
        self.currentDate = Date()
        self.setTitleDate(date: dateStringDetail(date: self.currentDate), leftArrow: true, rightArrow: false)
    }
    
    func initTitleView() {
        
        self.titleCtnView = UIView().then {
            $0.frame.size = CGSize(width: 300, height: 44)
        }
        
        self.dateLabel = UILabel().then {
            $0.textColor = .label
            $0.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        }
        
        self.prevDay = UIButton().then { (btn: UIButton) in
            // UI
            let prevImg = UIImage(systemName: "chevron.left")
            btn.setImage(prevImg, for: .normal)
            btn.tintColor = .label

            // RX
            btn.rx.tap
                .debug("prevDay")
                .subscribe(onNext: { [weak self] in
                    guard let self = self else { return }
                    
                    // let yesterday
                    let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: self.currentDate)!
                    self.currentDate = yesterday
                    
                    // set title and arrows
                    self.setTitleDate(date: dateStringDetail(date: yesterday), leftArrow: true, rightArrow: true)
                    
                    // Business Logic
                    self.viewModel.inputs.fetchHabitList.onNext(yesterday)
                    
                }, onCompleted: {print("completed")}, onDisposed: {print("disposed")}
                )
                .disposed(by: self.disposeBag)
        }
        
        
        self.postDay = UIButton().then { btn in
            // UI
            let postImg = UIImage(systemName: "chevron.right")
            btn.setImage(postImg, for: .normal)
            btn.tintColor = .label

            // RX
            btn.rx.tap
                .subscribe(onNext: { [weak self] in
                    guard let self = self else { return }
                    
                    // let tommorrow
                    let tommorrow = Calendar.current.date(byAdding: .day, value: 1, to: self.currentDate)!
                    self.currentDate = tommorrow
                    
                    // set title view and arrows
                    if compareDate(tommorrow, Date()) {
                        self.setTitleDate(date: dateStringDetail(date: tommorrow), leftArrow: true, rightArrow: false)
                    } else {
                        self.setTitleDate(date: dateStringDetail(date: tommorrow), leftArrow: true, rightArrow: true)
                    }
                    
                    // Business Logic
                    self.viewModel.inputs.fetchHabitList.onNext(tommorrow)
                })
                .disposed(by: self.disposeBag)
        }
        
        self.titleCtnView.addSubview(self.dateLabel)
        self.titleCtnView.addSubview(self.prevDay)
        self.titleCtnView.addSubview(self.postDay)
        
        self.navigationItem.titleView = self.titleCtnView
        
    }
    
    func setTitleDate(date: String, leftArrow: Bool, rightArrow: Bool) {
        
        let OFFSET: CGFloat = 15
        
        self.dateLabel.text = date
        self.dateLabel.sizeToFit()
        self.dateLabel.center = self.titleCtnView.center
        
        self.prevDay.isHidden = !leftArrow
        self.prevDay.frame.size = CGSize(width: 15, height: 44)
        self.prevDay.frame.origin.x = self.dateLabel.frame.origin.x - self.prevDay.frame.width - OFFSET
        self.prevDay.center.y = self.dateLabel.center.y
        
        self.postDay.isHidden = !rightArrow
        self.postDay.frame.size = CGSize(width: 15, height: 44)
        self.postDay.frame.origin.x = self.dateLabel.frame.origin.x + self.dateLabel.frame.width + OFFSET
        self.postDay.center.y = self.dateLabel.center.y
    }
    
    
    
    @objc func longPress(_ sender: UILongPressGestureRecognizer){
        
        let point = sender.location(in: self.tableView)
        if let indexPath = self.tableView.indexPathForRow(at: point),
           let cell = self.tableView.cellForRow(at: indexPath) as? HabitCell
        {
            switch sender.state {
            // 꾹 누르면 check!
            case .began:
                cell.check.onNext(!cell.isChecked)
            default:
                ()
            }
        }
    }
    /* temp temp temp */
    @objc func goLeft(_ sender: UIButton) {
        
        // let yesterday
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: self.currentDate)!
        self.currentDate = yesterday
        // set title and arrows
        self.setTitleDate(date: dateStringDetail(date: yesterday), leftArrow: true, rightArrow: true)
        // Business logic
        self.viewModel.inputs.fetchHabitList.onNext(yesterday)
    }
    /* temp temp temp */
    
    
    // MARK: - Bind UI
    
    func bindUIWithViewModel() {
        
        // --------------------------------
        //             INPUT
        // --------------------------------

        self.viewModel.inputs.fetchHabitList.onNext(self.currentDate)
        self.viewModel.inputs.fetchChallenge.onNext(())
        
        // --------------------------------
        //             OUTPUT
        // --------------------------------
        
        // table view 그리기
        // viewModel의 allHabits와 연결
        /*
         6/1 오늘의 정보.
         allHabits의 새로운 이벤트가 들어가는 순간,
         이를 구독하는 self.tableView.rx.items의 기존 cell들은 disposed 된다.
         */
        self.viewModel.outputs.allHabits
//            .debug("ViewController: allHabits")
            .observe(on: MainScheduler.instance)
            .bind(to: self.tableView.rx.items(cellIdentifier: HabitCell.identifier, cellType: HabitCell.self)) {
                _, habitVO, cell in
                
                // iconImage network에서 get
                cell.fetchImage
//                    .debug("ViewController: cell.fetchImage")
                    .map { habitVO }
                    .subscribe(onNext: self.viewModel.inputs.fetchHabitIconImage.onNext)
                    .disposed(by: cell.cellDisposeBag)

                // 특정 습관을 check 하면, habits 업데이트 됨
                cell.checked
                    .delay(RxTimeInterval.milliseconds(700), scheduler: MainScheduler.instance)
                    .map { (habitVO, $0) }
//                    .debug("ViewController: cell.checked")
                    .subscribe(onNext: self.viewModel.inputs.checkHabit.onNext)
                    .disposed(by: cell.cellDisposeBag)

                // HabitDetail View 불러올 때
                cell.getHabitDetailView
                    .map { habitVO }
                    .filter { $0.iconImage != nil }
//                    .debug("ViewController: cell.getHabitDetailView")
                    .subscribe(onNext: self.viewModel.inputs.showHabitDetailView.onNext)
                    .disposed(by: cell.cellDisposeBag)
                
                cell.initCell(habitVO: habitVO)
            }
            .disposed(by: self.disposeBag)
        
        // challenge 그리기
        self.viewModel.outputs.challenge
//            .debug("ViewController: challenge")
            .subscribe(onNext: { challengeVO in
                self.challengeName.text  = challengeVO.challengeName
                self.challengeImage.image = challengeVO.challengeImage
                self.challengeDDay.text = challengeVO.challengeDDay != nil ? "D - \(challengeVO.challengeDDay!)" : ""
            })
            .disposed(by: self.disposeBag)
        
        // --------------------------------
        //           NAVIGATION
        // --------------------------------
        
        self.viewModel.outputs.getHabitDetailView
//            .debug("화면 전환!")
            .filter { $0.iconImage != nil }
            .subscribe(onNext: { [weak self] selectedHabitVO in
                
                guard let self = self,
                      let habitDetailVC = self.storyboard?.instantiateViewController(identifier: HabitDetailVC.identifier) as? HabitDetailVC
                else {
                    fatalError("MainVC: tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)")
                }

                // habitDetailVC 에 현재 HabitDetailVO injected 된 뷰모델 넘기기
                habitDetailVC.viewModel = HabitDetailVM(currentHabitVO: selectedHabitVO)
                
                // 화면 전환
                self.navigationController?.pushViewController(habitDetailVC, animated: true)
            })
            .disposed(by: self.disposeBag)
    }
    
    // MARK: - TableView Delegate
    
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
            cell.check.onNext(!cell.isChecked)
        }.then {
            $0.image = UIImage(systemName: "checkmark")
            $0.backgroundColor = .systemBackground
        }
        
        return UISwipeActionsConfiguration(actions: [editAction, checkAction]).then {
            $0.performsFirstActionWithFullSwipe = false
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let cell = self.tableView.cellForRow(at: indexPath) as? HabitCell else {
            fatalError("MainVC: tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)")
        }
        
        cell.showHabitDetailView.onNext(())
    }
}
