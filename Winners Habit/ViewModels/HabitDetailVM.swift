//
//  HabitDetailVM.swift
//  Winners Habit
//
//  Created by 최동호 on 2021/05/30.
//

import Foundation
import WinnersHabitOAS
import RxSwift
import RxCocoa
import UIKit

protocol HabitDetailVMInputs {
    var toggleEditMode: PublishSubject<Void> { get }
    
    var changeAlarmTime: AnyObserver<Date> { get }
    var changeAlarmMusic: AnyObserver<String> { get }
    var changeAlarmHaptic: AnyObserver<String> { get }
    var changeRepeatButton: AnyObserver<Day> { get }
    var changeAlarmSwitch: AnyObserver<(isOn: Bool, alarmSwitch: SwitchType)> { get }
    var changeMemo: AnyObserver<String?> { get }
}

protocol HabitDetailVMOutputs {
    var currentHabitDetailVO: Observable<HabitDetailVO> { get }
    var editMode: Observable<Bool> { get }
}

protocol HabitDetailVMType {
    var inputs: HabitDetailVMInputs { get }
    var outputs: HabitDetailVMOutputs { get }
}

class HabitDetailVM: HabitDetailVMType, HabitDetailVMInputs, HabitDetailVMOutputs {
    
    // MARK: - Domain
    struct Domain {
        // 임시로 해놓은 API 호출용 변수
        let _API = API()
        
        /* 나중에는 이런식으로 OAS 이용해서
         let habitAPI = HabitAPI()
         let challengeAPI = ChallengeAPI()
         */
    }
    
    var inputs: HabitDetailVMInputs { return self }
    var outputs: HabitDetailVMOutputs { return self }
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Input
    
    let toggleEditMode: PublishSubject<Void>
    let changeAlarmTime: AnyObserver<Date>
    let changeAlarmMusic: AnyObserver<String>
    let changeAlarmHaptic: AnyObserver<String>
    let changeRepeatButton: AnyObserver<Day>
    let changeAlarmSwitch: AnyObserver<(isOn: Bool, alarmSwitch: SwitchType)>
    let changeMemo: AnyObserver<String?>
    
    // MARK: - Output
    
    // 어떤 경우에도 UI를 그리는 요소들은 얘를 거쳐서 나감
    // 이런 구조가 예쁘지
    // 서버에서 통신하는거 잘 처리해서 얘로 넘기고
    // 딴거에서 뭐 업데이트되면 잘 처리해서 얘로 넘기고 이런 느낌.
    let currentHabitDetailVO: Observable<HabitDetailVO>
    let editMode: Observable<Bool>
    
    // MARK: - Init
    init(currentHabitVO: HabitVO = HabitVO()) {
        let domain = Domain()
        
        // MARK: - Streams
        
        // 서버에서 받기 용
        let fetchHabitDetailVO$ = Observable<HabitVO>.just(currentHabitVO)
        // for editmode
        let editMode$ = BehaviorSubject(value: false)
        toggleEditMode = PublishSubject<Void>()
        // for input
        let changeAlarmTime$ = PublishSubject<Date>()
        let changeAlarmMusic$ = PublishSubject<String>()
        let changeAlarmHaptic$ = PublishSubject<String>()
        let changeRepeatButton$ = PublishSubject<Day>()
        let changeAlarmSwitch$ = PublishSubject<(isOn: Bool, alarmSwitch: SwitchType)>()
        let changeMemo$ = PublishSubject<String?>()
        // for output
        let currentHabitDetailVO$ = BehaviorSubject<HabitDetailVO>(value: HabitDetailVO())
        // for push updated habitDetailVO to server "HTTP PUT"
        let pushUpdatedHabitDetailVOToServer$ = PublishSubject<Void>()
 
        // ---------------------------------
        //            Set Streams
        // ---------------------------------
        
        // 서버에서 데이터 가져오기
        fetchHabitDetailVO$
            .flatMap { habitVO -> Observable<HabitDetailVO> in
                
                let temp1 = domain._API.getHabitDetail(habitVO: habitVO) // server에서 받아온 정보를
                let temp2 = Observable.just(habitVO) // 원래 있는 정보
                
                let ob = Observable.zip(temp1, temp2) // 둘이 합쳐서 return
                    .map { HabitDetailVO.getHabitDetailVO(habitVO: $1, habitDetail: $0) }
                return ob
            }
            .subscribe(onNext: currentHabitDetailVO$.onNext)
            .disposed(by: disposeBag)
        
        // toggle editmode
        toggleEditMode
            .withLatestFrom(editMode$)
            // editMode가 true 였으면
            // 서버에 전송
            .do(onNext: { editModeBeforeChanged in
                if editModeBeforeChanged {
                    pushUpdatedHabitDetailVOToServer$.onNext(())
                }
            })
            .map { !$0 }
            .bind(to: editMode$)
            .disposed(by: disposeBag)
        
        // alarm time
        changeAlarmTime$
            .withLatestFrom(currentHabitDetailVO$) { date, habitDetailVO in
                var nextHabitDetailVO = habitDetailVO
                let df = DateFormatter()
                df.dateFormat = "HH:mm:ss"
                nextHabitDetailVO.alarmTime = df.string(from: date)
                return nextHabitDetailVO
            }
            .bind(to: currentHabitDetailVO$)
            .disposed(by: disposeBag)
        
        // alarm music
        changeAlarmMusic$
            .withLatestFrom(currentHabitDetailVO$) { music, habitDetailVO in
                var nextHabitDetailVO = habitDetailVO
                nextHabitDetailVO.alarmMusic = music
                return nextHabitDetailVO
            }
            .bind(to: currentHabitDetailVO$)
            .disposed(by: disposeBag)
            
        // alarm haptic
        changeAlarmHaptic$
            .withLatestFrom(currentHabitDetailVO$) { haptic, habitDetailVO in
                var nextHabitDetailVO = habitDetailVO
                nextHabitDetailVO.alarmHaptic = haptic
                return nextHabitDetailVO
            }
            .bind(to: currentHabitDetailVO$)
            .disposed(by: disposeBag)
        
        // alarm switch
        changeAlarmSwitch$
            .withLatestFrom(currentHabitDetailVO$) { tuple, habitDetailVO in
                var nextHabitDetailVO = habitDetailVO
                let isOn = tuple.isOn
                let alarmSwitch = tuple.alarmSwitch
                
                switch alarmSwitch {
                case .alarmTime:
                    nextHabitDetailVO.alarmFlag = isOn
                    nextHabitDetailVO.alarmMusic = isOn ? "Basic Call" : nil
                    nextHabitDetailVO.alarmHaptic = isOn ? "Basic Call" : nil
                case .alarmMusic:
                    nextHabitDetailVO.alarmMusic = isOn ? "Basic Call" : nil
                case .alarmHaptic:
                    nextHabitDetailVO.alarmHaptic = isOn ? "Basic Call" : nil
                }
                return nextHabitDetailVO
            }
            .bind(to: currentHabitDetailVO$)
            .disposed(by: disposeBag)
        
        // alarm repeat button
        changeRepeatButton$
            .withLatestFrom(currentHabitDetailVO$) { button, habitDetailVO in
                var nextHabitDetailVO = habitDetailVO
                switch button {
                case .Mon: nextHabitDetailVO.repeatMon = !nextHabitDetailVO.repeatMon!
                case .Tue: nextHabitDetailVO.repeatTue = !nextHabitDetailVO.repeatTue!
                case .Wed: nextHabitDetailVO.repeatWed = !nextHabitDetailVO.repeatWed!
                case .Thu: nextHabitDetailVO.repeatThu = !nextHabitDetailVO.repeatThu!
                case .Fri: nextHabitDetailVO.repeatFri = !nextHabitDetailVO.repeatFri!
                case .Sat: nextHabitDetailVO.repeatSat = !nextHabitDetailVO.repeatSat!
                case .Sun: nextHabitDetailVO.repeatSun = !nextHabitDetailVO.repeatSun!
                case .error: fatalError("changeRepeatButton$")
                }
                return nextHabitDetailVO
            }
            .bind(to: currentHabitDetailVO$)
            .disposed(by: disposeBag)
        
        // alarm memo
        changeMemo$
            .withLatestFrom(currentHabitDetailVO$) { memo, habitDetailVO in
                var nextHabitDetailVO = habitDetailVO
                nextHabitDetailVO.memo = memo
                return nextHabitDetailVO
            }
            .bind(to: currentHabitDetailVO$)
            .disposed(by: disposeBag)
        
        // push brand-new habitdetailVO to server
        pushUpdatedHabitDetailVOToServer$
            .withLatestFrom(currentHabitDetailVO$) // 제일 최신의 HabitDetailVO를 엮어서
            .distinctUntilChanged() // 변경이 있는 경우만 서버로
            .subscribe(onNext: { _ in
                print("****************************")
                print("서버에 새로운 habitdetail 정보들 업데이트")
                print("****************************")
            })
            .disposed(by: disposeBag)
        
        // INPUT
        changeAlarmTime = changeAlarmTime$.asObserver()
        changeAlarmMusic = changeAlarmMusic$.asObserver()
        changeAlarmHaptic = changeAlarmHaptic$.asObserver()
        changeRepeatButton = changeRepeatButton$.asObserver()
        changeAlarmSwitch = changeAlarmSwitch$.asObserver()
        changeMemo = changeMemo$.asObserver()
        
        // OUTPUT
        currentHabitDetailVO = currentHabitDetailVO$.asObservable()
        editMode = editMode$.asObservable()
    }
}
