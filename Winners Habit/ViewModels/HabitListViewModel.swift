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
    
    struct Input {
        let checkHabit: AnyObserver<HabitVO>
        let fetchHabitList: AnyObserver<Date>
        let fetchHabitDetail: AnyObserver<HabitVO>
        let fetchChallenge: AnyObserver<Void>
    }
    
    struct Output {
        let allHabits: Driver<[HabitVO]>
        let errorMessage: Driver<String>
//        let challenge:
    }
    
    var input: Input
    var output: Output
    
    init() {
        // temp
        let habits = [
            Habit(habitId: 1, habitName: "새벽 기상", icon: "https://www.pngkit.com/png/full/1-19521_emoji-moon-png-transparent-background-moon-clipart.png", color: "F5D423", defaultAttributeValue: nil, attribute: "s/f", alarmFlag: true, alarmTime: "06:30:00"),
            Habit(habitId: 2, habitName: "운동", icon: "https://www.iconsdb.com/icons/preview/red/running-man-xxl.png", color: "FA331B", defaultAttributeValue: 20, attribute: "min", alarmFlag: true, alarmTime: "06:30:00"),
            Habit(habitId: 3, habitName: "독서", icon: "https://icons555.com/images/icons-blue/image_icon_book_pic_512x512.png", color: "2B42F5", defaultAttributeValue: 20, attribute: "pages", alarmFlag: false, alarmTime: nil),
        ]
    }
}
