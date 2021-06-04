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
    var updateHabitDetailVOOnEditMode: AnyObserver<HabitDetailVO> { get }
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
    
    let changeEditMode: AnyObserver<Void>
    var updateHabitDetailVOOnEditMode: AnyObserver<HabitDetailVO>
    
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
        let fetchHabitDetailVO$ = Observable<HabitVO>.just(currentHabitVO)
        let changeEditMode$ = PublishSubject<Void>()
        let editMode$ = BehaviorSubject(value: false)
        // for input
        let updateHabitDetailVOOnEditMode$ = PublishSubject<HabitDetailVO>()
        // for output
        let currentHabitDetailVO$ = BehaviorSubject<HabitDetailVO>(value: HabitDetailVO())
 
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
//            .debug("fetchHabitDetailVO$")
            .subscribe(onNext: currentHabitDetailVO$.onNext)
            .disposed(by: self.disposeBag)
        
        // editMode observable
        self.editMode = editMode$.asObservable()
        
        // toggle editmode
        changeEditMode$
            .withLatestFrom(self.editMode)
            .map { !$0 }
            .subscribe(onNext: editMode$.onNext)
            .disposed(by: self.disposeBag)
        
        // edit mode 에서 편집 할 때 마다 업데이트 되는 habitDetailVO 받는 녀석
        // 마지막으로 저장눌렀을 때는 (onComplete) 서버랑 통신
        updateHabitDetailVOOnEditMode$
            .debug("UI UPDATE 후 새로운 habitdetailVO")
            .do(onNext: currentHabitDetailVO$.onNext) // UI 업데이트용
            .takeLast(1) // 제일 마지막에 오는 놈이 가장 최신 버전의 HabitDetailVO 이므로
            .subscribe(onNext: { _ in
                /*
                 서버 통신
                 서버에 PUT
                 */
            })
            .disposed(by: self.disposeBag)
        
        // INPUT
        self.changeEditMode = changeEditMode$.asObserver()
        self.updateHabitDetailVOOnEditMode = updateHabitDetailVOOnEditMode$.asObserver()
        
        // OUTPUT
        self.currentHabitDetailVO = currentHabitDetailVO$.asObservable()
    }
}
