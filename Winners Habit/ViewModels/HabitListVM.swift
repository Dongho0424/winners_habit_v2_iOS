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
    var checkHabit: AnyObserver<(HabitVO, Bool)> { get }
    var fetchHabitList: AnyObserver<Date> { get }
    var fetchChallenge: AnyObserver<Void> { get }
    var showHabitDetailView: AnyObserver<HabitVO> { get }
    var fetchHabitIconImage: AnyObserver<HabitVO> { get }
}

protocol HabitListVMOutputs {
    var allHabits: Observable<[HabitVO]> { get }
    var errorMessage: Observable<NSError> { get }
    var challenge: Observable<ChallengeVO> { get }
    var ad: Observable<String> { get }
    var getHabitDetailView: Observable<HabitVO> { get }
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
    
    var checkHabit: AnyObserver<(HabitVO, Bool)>
    var fetchHabitList: AnyObserver<Date>
    var fetchChallenge: AnyObserver<Void>
    var showHabitDetailView: AnyObserver<HabitVO>
    var fetchHabitIconImage: AnyObserver<HabitVO>
    
    // MARK: - Output
    
    var allHabits: Observable<[HabitVO]>
    var challenge: Observable<ChallengeVO>
    var errorMessage: Observable<NSError>
    var ad: Observable<String>
    var getHabitDetailView: Observable<HabitVO>
//    var getHabitIconImage: Observable<UIImage>
    
    // MARK: - Init
    
    init() {
        let domain = Domain()
        
        // MARK: - Streams
        
        let checkHabit$ = PublishSubject<(HabitVO, Bool)>()
        let fetchHabitList$ = PublishSubject<Date>()
        let fetchChallenge$ = BehaviorSubject<Void>(value: ())
        let showHabitDetailView$ = PublishSubject<HabitVO>()
        let fetchHabitIconImage$ = PublishSubject<HabitVO>()
        let allHabits$ = BehaviorSubject<[HabitVO]>(value: [])
        let errorMessage$ = PublishSubject<NSError>()
        let ad$ = BehaviorSubject<String>(value: "")
        
        // Set Streams
        
        checkHabit$
            .map { $0.setDoneFlag($1) }
            .withLatestFrom(allHabits$) { (updated, originals) -> [HabitVO] in
                originals.map {
                    if updated.habitId == $0.habitId {
                        return updated
                    } else {
                        return $0
                    }
                }
            }
            .do(onError: { err in errorMessage$.onNext(err as NSError) })
            .subscribe(onNext: allHabits$.onNext)
            .disposed(by: self.disposeBag)
        
        fetchHabitList$ // may cause network error
            /*
             생각해보니까 잘못 짠 코드
             이유: 로직상 날짜 변경에 대한 인풋이 와도
             habits을 일일이 불러올 필요는 없다.
             기존 [habitVO]에 doneflag만 덮어서 내보내면 되지
             일일이 API 통신을 할 필요는 없으니까.
             */
//            .debug("ViewModel: fetchHabitList STREAM")
            .flatMap { date -> Observable<[HabitVO]> in
                let _histories = domain._API.getHabitHistoriesFromDate(date: date)
                let _habits = domain._API.getHabits()
                
                let ob = Observable.zip(_habits, _histories)
                    .map { HabitVO.getHabitVOList(habits: $0, habitHistories: $1) }
                
                return ob
            }
            .do(onError: { err in errorMessage$.onNext(err as NSError) })
            .subscribe(onNext: allHabits$.onNext)
            .disposed(by: self.disposeBag)
        
        // 그냥 HabitDetailVM 에 값만 전달하는 역할
        self.getHabitDetailView = showHabitDetailView$.asObservable()
        
        self.challenge = fetchChallenge$ // may cause network error
            .flatMap { domain._API.getChallenge() }
            .map { ChallengeVO.ChallengeVOFromChallenge($0) }
            .do(onError: { err in errorMessage$.onNext(err as NSError) })
            .asObservable()
        
        // MARK: - TODO: 하드 코딩된거 고치기
        fetchHabitIconImage$
            .flatMap { $0.getHabitWithImage($0) } // for habit icon image caching
//            .debug("ViewModel: fetchHabitIconImage$ ** before buffer **")
            .buffer(timeSpan: RxTimeInterval.never, count: 3, scheduler: MainScheduler.instance)
//            .debug("ViewModel: fetchHabitIconImage$ ** after buffer **")
            .subscribe(onNext: allHabits$.onNext)
            .disposed(by: self.disposeBag)
        
        ad$.onNext("심리 상담을 받아보세요!")
        
        // INPUT
        
        self.checkHabit = checkHabit$.asObserver()
        self.fetchHabitList = fetchHabitList$.asObserver()
        self.fetchChallenge = fetchChallenge$.asObserver()
        self.fetchHabitIconImage = fetchHabitIconImage$.asObserver()
        self.showHabitDetailView = showHabitDetailView$.asObserver()
        
        // OUTPUT
        
        self.allHabits = allHabits$.asObservable()
        self.errorMessage = errorMessage$.asObservable()
        self.ad = ad$.asObservable()
    }
}

