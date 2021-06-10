//
//  HabitCell.swift
//  Winners Habit
//
//  Created by 최동호 on 2021/05/03.
//

import Foundation
import UIKit
import RxSwift

class HabitCell: UITableViewCell {
    static let identifier = "habitCell"
    
    var cellDisposeBag = DisposeBag()
    private let disposeBag = DisposeBag()
    
    // MARK: - Stream

    private let fetchImage$: PublishSubject<Void>
    private let showHabitDetailView$: PublishSubject<Void>
    let isChecked$ : BehaviorSubject<Bool>
    
    // MARK: - Input
    
    let toggleChecking : PublishSubject<Void>
    let showHabitDetailView: AnyObserver<Void>
    
    // MARK: - Output
    
    let checked: Observable<Bool>
    let fetchImage: Observable<Void>
    let getHabitDetailView: Observable<Void>
    
    // MARK: - Init
    
    /*
     새로 구독하게 되면
     기존에 구독하던 것은 dispose 됨.
     이때 dispose 된다는 것은
     같은 disposeBag에 들어있는 애들 전부다 dispose 된다는 뜻
     */
    required init?(coder: NSCoder) {
        isChecked$ = BehaviorSubject<Bool>(value: false)
        toggleChecking = PublishSubject<Void>()
        
        toggleChecking
            .withLatestFrom(isChecked$)
            .map { !$0 }
            .bind(to: isChecked$)
            .disposed(by: disposeBag)

        checked = isChecked$.asObservable()
        
        fetchImage$ = PublishSubject<Void>()
        fetchImage = fetchImage$.asObservable()
   
        showHabitDetailView$ = PublishSubject<Void>()
        showHabitDetailView = showHabitDetailView$.asObserver()
        getHabitDetailView = showHabitDetailView$.asObservable()
        
        super.init(coder: coder)
    }
    
    // MARK: - UI Components
    
    @IBOutlet weak var habitImg: UIImageView!
    @IBOutlet weak var habitTitle: UILabel!
    @IBOutlet weak var habitAlarmTime: UILabel!
    @IBOutlet weak var habitAttr: UILabel!
    @IBOutlet weak var alarmImg: UIImageView!
    @IBOutlet weak var hView: UIView!
    
    // MARK: - UI
    
    lazy var checkBGView = UIView().then {
        $0.backgroundColor = UIColor(rgb: 0x363636)
        $0.layer.cornerRadius = 15
    }
    lazy var checkView = UIImageView().then {
        let checkImg = UIImage(systemName: "checkmark")
        $0.image = checkImg
        $0.tintColor = UIColor(rgb: 0x525252)
    }
    
    func setChecking(done: Bool, date: Date) {
        // 오늘만 check 바꿀 수 있음.
        guard compareDate(date, Date()) else { return }
        if done {
            hView.addSubview(checkBGView)
            checkBGView.addSubview(checkView)
            checkBGView.snp.makeConstraints { make in
                make.size.equalTo(hView.snp.size)
                make.center.equalTo(hView.snp.center)
            }
            checkView.snp.makeConstraints { make in
                make.size.equalTo(CGSize(width: 50, height: 50))
                make.center.equalTo(checkBGView.snp.center)
            }
        } else {
            checkBGView.removeFromSuperview()
        }
    }
    
    func initCell(habitVO: HabitVO) {
        let cellColor = habitVO.color
        
        habitTitle.text = habitVO.habitName

        if habitVO.iconImage == nil {
            fetchImage$.onNext(())
        } else {
            habitImg.image = habitVO.iconImage
        }
        
        if habitVO.alarmFlag {
            habitAlarmTime.text = convertAlarmTime(time: habitVO.alarmTime!)
            habitAlarmTime.textColor = cellColor
        } else {
            alarmImg.isHidden = true
            habitAlarmTime.isHidden = true
        }
        
        switch habitVO.attribute {
        case "s/f":
            habitAttr.text = "성공/실패"
        case "min":
            habitAttr.text = "0/\(habitVO.defaultAttributeValue!) min"
        case "pages":
            habitAttr.text = "0/\(habitVO.defaultAttributeValue!) 장"
        default:
            ()
        }
        habitAttr.textColor = cellColor
        
        selectedBackgroundView = UIView()
        
        hView.layer.cornerRadius = 15
        hView.backgroundColor = UIColor(rgb: 0x464646)
        
        setChecking(done: habitVO.doneFlag, date: Date())
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cellDisposeBag = DisposeBag()
    }
}
