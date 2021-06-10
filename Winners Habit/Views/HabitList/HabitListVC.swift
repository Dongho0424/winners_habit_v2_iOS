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

enum MoveDayType{
    case prev, post
}

class HabitListVC: UIViewController {
    
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
        viewModel = HabitListVM()
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
    
    private func initUI() {
        initTableView()
        setNavigationBarClear()
        initTitleView()
    }
    
    /// table view initial settings
    func initTableView() {
        tableView.delegate = self
        tableView.separatorStyle = .none
    }
    
    /// default navigation bar clear
    func setNavigationBarClear() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.view.backgroundColor = UIColor.clear
    }
    
    /// set title by today date
    func initTitleView() {
        
        let stackView = UIStackView().then {
            $0.axis = .horizontal
            $0.distribution = .equalSpacing
            $0.spacing = 15
            $0.alignment = .center
        }
        
        dateLabel = UILabel().then {
            $0.textColor = .label
            $0.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        }
        
        prevDay = UIButton().then { (btn: UIButton) in
            let prevImg = UIImage(systemName: "chevron.left")
            btn.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(scale: .large), forImageIn: .normal)
            btn.setImage(prevImg, for: .normal)
            btn.tintColor = .label
        }
        
        postDay = UIButton().then { btn in
            let postImg = UIImage(systemName: "chevron.right")
            btn.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(scale: .large), forImageIn: .normal)
            btn.setImage(postImg, for: .normal)
            btn.tintColor = .label
        }
        
        stackView.addArrangedSubview(prevDay)
        stackView.addArrangedSubview(dateLabel)
        stackView.addArrangedSubview(postDay)
        
        navigationItem.titleView = stackView
    }
    
    // MARK: - Bind UI
    
    func bindViewModel() {
        
        // MARK: - INPUT

        viewModel.inputs.viewDidLoad.onNext(())
        
        tableView.rx.longPressGesture()
            .withUnretained(self)
            .subscribe(onNext: { `self`, tapGesture in
                let point = tapGesture.location(in: self.tableView)
                if let indexPath = self.tableView.indexPathForRow(at: point),
                   let cell = self.tableView.cellForRow(at: indexPath) as? HabitCell
                {
                    switch tapGesture.state {
                    // 꾹 누르면 check!
                    case .began:
                        cell.toggleChecking.onNext(())
                    default:
                        ()
                    }
                }
            })
            .disposed(by: disposeBag)
    
        prevDay.rx.tap
            .map { .prev }
            .bind(to: viewModel.inputs.changeDate)
            .disposed(by: disposeBag)

        postDay.rx.tap
            .map { .post }
            .bind(to: viewModel.inputs.changeDate)
            .disposed(by: disposeBag)
        
        // Reactive wrapper for delegate tableView(:didSelectRowAtIndexPath:)
        tableView.rx.itemSelected
            .withUnretained(self)
            .subscribe(onNext: { `self`, indexPath in
                guard let cell = self.tableView.cellForRow(at: indexPath) as? HabitCell else {
                    fatalError("tableView.rx.itemSelected")
                }
                
                cell.showHabitDetailView.onNext(())
            })
            .disposed(by: disposeBag)
        
        // MARK: - OUTPUT
        
        // table view 그리기
        // viewModel의 allHabits와 연결
        viewModel.outputs.currentHabitVOList
            .observe(on: MainScheduler.instance)
            .distinctUntilChanged()
            .bind(to: tableView.rx.items(cellIdentifier: HabitCell.identifier, cellType: HabitCell.self)) {
                [weak self] _, habitVO, cell in
                guard let self = self else { return }
                
                // iconImage network에서 get
                cell.fetchImage
                    .map { habitVO }
                    .subscribe(onNext: self.viewModel.inputs.fetchHabitIconImage.onNext)
                    .disposed(by: cell.cellDisposeBag)
                
                // 특정 습관을 check 하면, habits 업데이트 됨
                cell.checked
                    .debug("cell.checked")
                    .delay(RxTimeInterval.milliseconds(700), scheduler: MainScheduler.instance)
                    .map { (habitVO, $0) }
                    .subscribe(onNext: self.viewModel.inputs.checkHabit.onNext)
                    .disposed(by: cell.cellDisposeBag)
                
                // 화면 전환
                cell.getHabitDetailView
                    .map { habitVO }
                    .withUnretained(self)
                    .subscribe(onNext: { `self`, habitVO in
                        guard let habitDetailVC = self.storyboard?.instantiateViewController(identifier: HabitDetailVC.identifier) as? HabitDetailVC
                        else {
                            fatalError("instantiateViewController")
                        }

                        // habitDetailVC 에 현재 HabitDetailVO injected 된 뷰모델 넘기기
                        habitDetailVC.viewModel = HabitDetailVM(currentHabitVO: habitVO)

                        // 화면 전환
                        self.navigationController?.pushViewController(habitDetailVC, animated: true)
                    })
                    .disposed(by: cell.cellDisposeBag)
                
                cell.initCell(habitVO: habitVO)
            }
            .disposed(by: self.disposeBag)
        
        // challenge 그리기
        viewModel.outputs.currentChallenge
            .withUnretained(self)
            .subscribe(onNext: { `self`, challengeVO in
                self.challengeName.text  = challengeVO.challengeName
                self.challengeImage.image = challengeVO.challengeImage
                self.challengeDDay.text = challengeVO.challengeDDay != nil
                    ? "D - \(challengeVO.challengeDDay!)"
                    : ""
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.currentDate
            .bind(to: dateLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.outputs.hasPostdayButton
            .withUnretained(self)
            .subscribe(onNext: { `self`, has in
                self.postDay.isEnabled = has
                self.postDay.tintColor = has ? .label : .systemBackground
            })
            .disposed(by: disposeBag)
    }
}

extension HabitListVC: UITableViewDelegate {
    // MARK: - TableView Delegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        guard let cell = tableView.cellForRow(at: indexPath) as? HabitCell else {
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
            cell.toggleChecking.onNext(())
        }.then {
            $0.image = UIImage(systemName: "checkmark")
            $0.backgroundColor = .systemBackground
        }
        
        return UISwipeActionsConfiguration(actions: [editAction, checkAction]).then {
            $0.performsFirstActionWithFullSwipe = false
        }
    }
}
