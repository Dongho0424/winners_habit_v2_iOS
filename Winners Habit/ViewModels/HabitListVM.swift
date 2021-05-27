//
//  HabitListViewModel.swift
//  Winners Habit
//
//  Created by 최동호 on 2021/05/27.
//

import Foundation
import OpenAPIClient
import RxSwift
import RxCocoa


class HabitListVM: ViewModelType {

    struct Domain {
        // 임시로 해놓은 API 호출용 변수
        let API: API
        
        /* 나중에는 이런식으로 OAS 이용해서
         let habitAPI = HabitAPI()
         let challengeAPI = ChallengeAPI()
         */
    }
    
    struct Input {
        var checkHabit: AnyObserver<HabitVO>
        var fetchHabitList: AnyObserver<Date>
        var fetchChallenge: AnyObserver<Void>
//        var fetchHabitDetail: AnyObserver<HabitVO>
    }
    
    struct Output {
        var allHabits: Driver<[HabitVO]>
        var errorMessage: Observable<NSError>
        var challenge: Driver<ChallengeVO>
        var ad: Signal<String>
    }
    
    let domain: Domain
    let input: Input
    let output: Output
    private let disposeBag = DisposeBag()
    
    required init(domain: Domain = Domain(API: API())) {
        self.domain = domain
        
        // Stream
        let checkingHabit = PublishSubject<HabitVO>()
        let fetchingHabitList = PublishSubject<Date>()
        let fetchingChallenge = PublishSubject<Void>()
//        let fetchingHabitDetail = PublishSubject<HabitVO>()
        let habits = BehaviorSubject<[HabitVO]>(value: [])
        let error = PublishSubject<NSError>()
        let ad$ = BehaviorSubject<String>(value: "")
        
        checkingHabit
            .map { $0.toggle() }
            .withLatestFrom(habits) { (updated, originals) -> [HabitVO] in
                originals.map {
                    if updated.habitId == $0.habitId {
                        return updated
                    } else {
                        return $0
                    }
                }
            }
            .do(onError: { err in error.onNext(err as NSError) })
            .subscribe(onNext: habits.onNext)
            .disposed(by: self.disposeBag)
        
        fetchingHabitList // may cause network error
            /*
             생각해보니까 잘못 짠 코드
             이유: 로직상 날짜 변경에 대한 인풋이 와도
             habits을 일일이 불러올 필요는 없다.
             기존 [habitVO]에 doneflag만 덮어서 내보내면 되지
             일일이 API 통신을 할 필요는 없으니까.
             */
            .flatMap { date -> Observable<[HabitVO]> in
                let _histories = domain.API.getHabitHistoriesFromDate(date: date)
                let _habits = domain.API.getHabits()
                
                let ob = Observable.zip(_habits, _histories)
                    .map { HabitVO.getHabitVOList(habits: $0, habitHistories: $1) }
                
                return ob
            }
            .do(onError: { err in error.onNext(err as NSError) })
            .subscribe(onNext: habits.onNext)
            .disposed(by: self.disposeBag)
        
        let challengeOutput = fetchingChallenge // may cause network error
            .flatMap { domain.API.getChallenge() }
            .map { ChallengeVO.ChallengeVOFromChallenge($0) }
            .do(onError: { err in error.onNext(err as NSError) })
            .asDriver(onErrorJustReturn: ChallengeVO(challengeId: 0, challengeImage: UIImage(), challengeName: "", challengeDDay: nil, totalCompleteRatio: 0, todayCompleteRatio: 0))
            
        ad$.onNext("심리 상담을 받아보세요!")
        
        // INPUT and OUTPUT
        
        self.input = Input(checkHabit: checkingHabit.asObserver(),
                           fetchHabitList: fetchingHabitList.asObserver(),
                           fetchChallenge: fetchingChallenge.asObserver())
        
        self.output = Output(allHabits: habits.asDriver(onErrorJustReturn: []),
                             errorMessage: error,
                             challenge: challengeOutput,
                             ad: ad$.asSignal(onErrorJustReturn: ""))
        
    }
    
}

