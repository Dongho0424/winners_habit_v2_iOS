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
import RxViewController

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
        self.tableView.separatorStyle = .none
        
        self.initUI()
        
        self.bindUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    // MARK: - set UI
    
    func initUI() {
        
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
        
        // back button title to nil
        let backBarButtonIten = UIBarButtonItem(title: nil, style: .plain, target: self, action: nil).then{
            $0.tintColor = .label
            self.navigationItem.backBarButtonItem = $0
        }
        
        // currentDate는 오늘로
        self.currentDate = Date()
        self.setTitleDate(date: dateStringDetail(date: self.currentDate), leftArrow: true, rightArrow: false)
    }
    
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
            let prevImg = UIImage(systemName: "chevron.left")
            $0.setImage(prevImg, for: .normal)
            $0.tintColor = .label
            $0.addTarget(self, action: #selector(goPrevDay(_:)), for: .touchUpInside)
        }
        
        self.postDay = UIButton().then {
            let postImg = UIImage(systemName: "chevron.right")
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
        } else {
            self.prevDay.removeFromSuperview()
        }
        
        if rightArrow {
            self.titleCtnView.addSubview(self.postDay)
            // use SnapKit to set auto layout settings
            self.postDay.snp.makeConstraints { make in
                make.left.equalTo(self.dateLabel.snp.right).offset(10)
                make.centerY.equalTo(titleCtnView.snp.centerY)
            }
        } else  {
            self.postDay.removeFromSuperview()
        }
    }
    
    @objc func goPrevDay(_ sender: UIButton){
        // let yesterday
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: self.currentDate)!
        self.currentDate = yesterday
        
        // set title and arrows
        self.setTitleDate(date: dateStringDetail(date: yesterday), leftArrow: true, rightArrow: true)
        
        // Business logic
        self.viewModel.inputs.fetchHabitList.onNext(yesterday)
    }
    
    @objc func goPostDay(_ sender: UIButton) {
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
    
    // MARK: - Bind UI
    
    func bindUI() {
        
        // --------------------------------
        //             INPUT
        // --------------------------------
        
        // 처음 로딩할 때, 습관 리스트 및 챌린지 정보 가져오기
        let firstLoad = self.rx.viewWillAppear
            .take(1)
            .map { _ in () }
            .share()
        
        firstLoad
            .subscribe(onNext: {
                self.viewModel.inputs.fetchHabitList.onNext(self.currentDate)
            })
            .disposed(by: self.disposeBag)
        
        firstLoad
            .bind(to: self.viewModel.inputs.fetchChallenge)
            .disposed(by: self.disposeBag)
        
        // --------------------------------
        //             OUTPUT
        // --------------------------------
        
        // table view 그리기
        // viewModel의 allHabits와 연결
        self.viewModel.outputs.allHabits
            .observeOn(MainScheduler.instance)
            .bind(to: self.tableView.rx.items(cellIdentifier: HabitCell.identifier, cellType: HabitCell.self)) {
                _, habitVO, cell in
                
                // iconImage network에서 불러오기
                cell.fetchImage
                    .map { habitVO }
                    .subscribe(onNext: self.viewModel.inputs.fetchHabitIconImage.onNext)
                    .disposed(by: cell.cellDisposeBag)
                
                // 특정 습관을 check 하면, habits 업데이트 됨
                cell.checked
                    .map { (habitVO, $0) }
                    .subscribe(onNext: self.viewModel.inputs.checkHabit.onNext)
                    .disposed(by: cell.cellDisposeBag)
                
                // HabitDetail View 불러올 때
                cell.getHabitDetailView
                    .map { habitVO }
                    .filter { $0.iconImage != nil }
                    .subscribe(onNext: self.viewModel.inputs.showHabitDetailView.onNext)
                    .disposed(by: self.disposeBag)
                
                // cell에 habitVO, viewModel 넣어서
                cell.initCell(habitVO: habitVO)
            }
            .disposed(by: self.disposeBag)
        
        // challenge 그리기
        self.viewModel.outputs.challenge
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
            .filter { $0.iconImage != nil }
            .subscribe(onNext: { [weak self] selectedHabitVO in
                
                guard let `self` = self,
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
