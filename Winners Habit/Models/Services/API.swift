//
//  Domain.swift
//  Winners Habit
//
//  Created by 최동호 on 2021/05/27.
//

import Foundation
import RxSwift
import OpenAPIClient

// 임시 클래스
// OpenAPI 의 API 클래스들이 이 역할을 맡을 것이다.
class API {
    
    // temp data from server
    let _habits = [
        Habit(habitId: 1, habitName: "새벽 기상", icon: "https://www.pngkit.com/png/full/1-19521_emoji-moon-png-transparent-background-moon-clipart.png", color: "F5D423", defaultAttributeValue: nil, attribute: "s/f", alarmFlag: true, alarmTime: "06:30:00"),
        Habit(habitId: 2, habitName: "운동", icon: "https://www.iconsdb.com/icons/preview/red/running-man-xxl.png", color: "FA331B", defaultAttributeValue: 20, attribute: "min", alarmFlag: true, alarmTime: "06:30:00"),
        Habit(habitId: 3, habitName: "독서", icon: "https://icons555.com/images/icons-blue/image_icon_book_pic_512x512.png", color: "2B42F5", defaultAttributeValue: 20, attribute: "pages", alarmFlag: false, alarmTime: nil),
    ]
    let _challenge = Challenge(challengeId: 1, challengeName: "빌 게이츠", challengeImage: "", challengeDDay: 35)
    let _habitHistories = [
        HabitHistory(habitId: 1, doneFlag: true),
        HabitHistory(habitId: 2, doneFlag: false),
        HabitHistory(habitId: 3, doneFlag: true),
    ]
    
    // temp functions
    func getHabits() -> Observable<[Habit]> {
        return Observable.just(_habits)
    }
    func getHabitHistoriesFromDate(date: Date) -> Observable<[HabitHistory]> {
        return Observable.just(_habitHistories)
    }
    func getChallenge() -> Observable<Challenge> {
        return Observable.just(_challenge)
    }
}
