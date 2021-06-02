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
    var changeEditMode: AnyObserver<Void> { get }
//    var changeAlarmSWtich
}

protocol HabitDetailVMOutputs {
    var getHabitDetailVO: Observable<HabitDetailVO> { get }
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
    
    let changeEditMode: AnyObserver<Void>
    
    // MARK: - Output
    
    let getHabitDetailVO: Observable<HabitDetailVO>
    let editMode: Observable<Bool>
    
    // MARK: - Init
    init(currentHabitVO: HabitVO = HabitVO()) {
        let domain = Domain()
        
        // MARK: - Streams
        let habitDetailVO$ = Observable<HabitVO>.just(currentHabitVO)
        let changeEditMode$ = PublishSubject<Void>()
        let editMode$ = BehaviorSubject(value: false)
 
        // Set Streams
        
        // 화면 처음에 데이터 fetching
        self.getHabitDetailVO = habitDetailVO$
            .flatMap { habitVO -> Observable<HabitDetailVO> in
                let temp1 = domain._API.getHabitDetail(habitVO: habitVO) // server에서 받아온 정보를
                let temp2 = Observable.just(habitVO) // 원래 있는 정보
                
                let ob = Observable.zip(temp1, temp2) // 둘이 합쳐서 return
                    .map { HabitDetailVO.getHabitDetailVO(habitVO: $1, habitDetail: $0) }
                return ob
            }
            .asObservable()
        
        // editMode 토글
        self.editMode = editMode$.asObservable()
        
        changeEditMode$
            .withLatestFrom(self.editMode)
            .map { !$0 }
            .subscribe(onNext: editMode$.onNext)
            .disposed(by: self.disposeBag)
      
        // INPUT
        self.changeEditMode = changeEditMode$.asObserver()

    }
}
