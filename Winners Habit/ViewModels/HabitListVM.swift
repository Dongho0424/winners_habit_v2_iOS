//
//  HabitListViewModel.swift
//  Winners Habit
//
//  Created by 최동호 on 2021/05/27.
//

import UIKit
import Foundation
import RxSwift
import RxCocoa
import Alamofire
import WinnersHabitOAS

protocol HabitListVMInputs {
    var changeDate: AnyObserver<MoveDayType> { get }
    var checkHabit: AnyObserver<(HabitVO, Bool)> { get }
    var fetchHabitIconImage: AnyObserver<HabitVO> { get }
    var viewDidLoad: AnyObserver<Void> { get }
}

protocol HabitListVMOutputs {
    var currentDate: Observable<String> { get }
    var hasPostdayButton: Observable<Bool> { get }
    var currentHabitVOList: Observable<[HabitVO]> { get }
    var currentChallenge: Observable<ChallengeVO> { get }
}

protocol HabitListVMType {
    var inputs: HabitListVMInputs { get }
    var outputs: HabitListVMOutputs { get }
}

class HabitListVM: HabitListVMType, HabitListVMInputs, HabitListVMOutputs {
    
    // MARK: - Domain
    
    struct Domain {
        // 임시로 해놓은 API 호출용 변수
        let _API = API()
        
        /* 나중에는 이런식으로 OAS 이용해서
         let habitAPI = HabitAPI()
         let challengeAPI = ChallengeAPI()
         */
    }
    
    var inputs: HabitListVMInputs { return self }
    var outputs: HabitListVMOutputs { return self }
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Input
    
    var changeDate: AnyObserver<MoveDayType>
    var checkHabit: AnyObserver<(HabitVO, Bool)>
    var fetchHabitIconImage: AnyObserver<HabitVO>
    var viewDidLoad: AnyObserver<Void>
    
    // MARK: - Output
    
    var currentDate: Observable<String>
    var hasPostdayButton: Observable<Bool>
    var currentHabitVOList: Observable<[HabitVO]>
    var currentChallenge: Observable<ChallengeVO>
    
    // MARK: - Init
    
    init() {
        let domain = Domain()
        
        // MARK: - Streams
        
        let changeDate$ = PublishSubject<MoveDayType>()
        let checkHabit$ = PublishSubject<(HabitVO, Bool)>()
        let fetchHabitIconImage$ = PublishSubject<HabitVO>()
        let viewDidLoad$ = PublishSubject<Void>()
        
        let hasPostdayButton$ = BehaviorSubject(value: false)
        
        let currentHabitVOList$ = BehaviorSubject<[HabitVO]>(value: [])
        let currentChallenge$ = BehaviorSubject<ChallengeVO>(value: ChallengeVO())
        let currentDate$ = BehaviorSubject<Date>(value: Date())
        
        let fetchHabitList$ = PublishSubject<Date>()
        let fetchChallenge$ = PublishSubject<Void>()
        
        // Set Streams
        
        changeDate$
            .withLatestFrom(currentDate$) { moveDayType, date -> Date in
                var changingDate : Date = date
                switch moveDayType {
                case .prev:
                    changingDate = Calendar.current.date(byAdding: .day, value: -1, to: date)!
                case .post:
                    changingDate = Calendar.current.date(byAdding: .day, value: 1, to: date)!
                }
                return changingDate
            }
            .do(onNext: fetchHabitList$.onNext)
            .do(onNext: { hasPostdayButton$.onNext(!compareDate($0, Date())) })
            .bind(to: currentDate$)
            .disposed(by: disposeBag)
        
        checkHabit$
            .debug("checkHabit$")
            .map { $0.setDoneFlag($1) }
            .withLatestFrom(currentHabitVOList$) { (updated, originals) -> [HabitVO] in
                originals.map {
                    if updated.habitId == $0.habitId {
                        return updated
                    } else {
                        return $0
                    }
                }
            }
            .subscribe(onNext: currentHabitVOList$.onNext)
            .disposed(by: disposeBag)
        
        viewDidLoad$
            .withLatestFrom(currentDate$)
            .subscribe(onNext: { date in
                fetchHabitList$.onNext(date)
                fetchChallenge$.onNext(())
            })
            .disposed(by: disposeBag)
        
        fetchHabitList$ // may cause network error
            .flatMap { date -> Observable<[HabitVO]> in
                let _histories = domain._API.getHabitHistoriesFromDate(date: date)
                let _habits = domain._API.getHabits()
                
                let ob = Observable.zip(_habits, _histories)
                    .map { HabitVO.getHabitVOList(habits: $0, habitHistories: $1) }
                
                return ob
            }
            .bind(to: currentHabitVOList$)
            .disposed(by: disposeBag)
        
        fetchChallenge$ // may cause network error
            .flatMap { domain._API.getChallenge() }
            .map { ChallengeVO.ChallengeVOFromChallenge($0) }
            .bind(to: currentChallenge$)
            .disposed(by: disposeBag)
        
        // MARK: - TODO: 하드 코딩된거 고치기
        fetchHabitIconImage$
            .flatMap { $0.getHabitWithImage($0) } // for habit icon image caching
            .buffer(timeSpan: RxTimeInterval.never, count: 3, scheduler: MainScheduler.instance)
            .bind(to: currentHabitVOList$)
            .disposed(by: disposeBag)
        
        // INPUT
        changeDate = changeDate$.asObserver()
        checkHabit = checkHabit$.asObserver()
        fetchHabitIconImage = fetchHabitIconImage$.asObserver()
        viewDidLoad = viewDidLoad$.asObserver()
        
        // OUTPUT
        hasPostdayButton = hasPostdayButton$.asObservable()
        currentDate = currentDate$
            .map { dateStringDetail(date: $0) }
            .asObservable()
        currentHabitVOList = currentHabitVOList$.asObservable()
        currentChallenge = currentChallenge$.asObservable()
    }
}

