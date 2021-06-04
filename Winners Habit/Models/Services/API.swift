//
//  Domain.swift
//  Winners Habit
//
//  Created by 최동호 on 2021/05/27.
//

import Foundation
import RxSwift
import WinnersHabitOAS

// 임시 클래스
// OpenAPI 의 API 클래스들이 이 역할을 맡을 것이다.
class API {
    
    // temp data from server
    private let _habits = [
        Habit(habitId: 1, habitName: "새벽 기상", icon: "https://www.pngkit.com/png/full/1-19521_emoji-moon-png-transparent-background-moon-clipart.png", color: "F5D423", defaultAttributeValue: nil, attribute: "s/f", alarmFlag: true, alarmTime: "06:30:00"),
        Habit(habitId: 2, habitName: "운동", icon: "https://www.iconsdb.com/icons/preview/red/running-man-xxl.png", color: "FA331B", defaultAttributeValue: 20, attribute: "min", alarmFlag: true, alarmTime: "06:30:00"),
        Habit(habitId: 3, habitName: "독서", icon: "https://icons555.com/images/icons-blue/image_icon_book_pic_512x512.png", color: "2B42F5", defaultAttributeValue: 20, attribute: "pages", alarmFlag: false, alarmTime: nil),
    ]
    private let _challenge = Challenge(challengeId: 1, challengeName: "빌 게이츠", challengeImage: "", challengeDDay: 35)
    private let _habitHistories_1 = [
        HabitHistory(habitId: 1, doneFlag: false),
        HabitHistory(habitId: 2, doneFlag: false),
        HabitHistory(habitId: 3, doneFlag: false),
    ]
    private let _habitHistories_2 = [
        HabitHistory(habitId: 1, doneFlag: true),
        HabitHistory(habitId: 2, doneFlag: false),
        HabitHistory(habitId: 3, doneFlag: true),
    ]
    private let _habitHistories_3 = [
        HabitHistory(habitId: 1, doneFlag: true),
        HabitHistory(habitId: 2, doneFlag: true),
        HabitHistory(habitId: 3, doneFlag: false),
    ]
    private let _habitDetail_1 = HabitDetail(userHabitId: 1, createDate: "2021-01-03", alarmFlag: true, alarmTime: "06:30:00", alarmMusic: "Oh my god", alarmHaptic: "Basic call", repeatMon: true, repeatTue: true, repeatWed: true, repeatThu: true, repeatFri: true, repeatSat: false, repeatSun: false, memo: "아침에 일어나서 하는 명상은 정말 중요합니다.", habitHistories: [
        HabitHistory(habitId: 1, date: "2021-05-24", doneFlag: true),
        HabitHistory(habitId: 1, date: "2021-05-25", doneFlag: true),
        HabitHistory(habitId: 1, date: "2021-05-26", doneFlag: false),
        HabitHistory(habitId: 1, date: "2021-05-27", doneFlag: true),
        HabitHistory(habitId: 1, date: "2021-05-28", doneFlag: true),
        HabitHistory(habitId: 1, date: "2021-05-29", doneFlag: false),
        HabitHistory(habitId: 1, date: "2021-05-30", doneFlag: true),
    ])
    private let _habitDetail_2 = HabitDetail(userHabitId: 1, createDate: "2021-01-03", alarmFlag: true, alarmTime: "06:30:00", alarmMusic: nil, alarmHaptic: "Basic call", repeatMon: true, repeatTue: true, repeatWed: true, repeatThu: true, repeatFri: true, repeatSat: true, repeatSun: true, memo: "아침 운동", habitHistories: [
        HabitHistory(habitId: 2, date: "2021-05-24", doneFlag: false),
        HabitHistory(habitId: 2, date: "2021-05-25", doneFlag: true),
        HabitHistory(habitId: 2, date: "2021-05-26", doneFlag: false),
        HabitHistory(habitId: 2, date: "2021-05-27", doneFlag: true),
        HabitHistory(habitId: 2, date: "2021-05-28", doneFlag: false),
        HabitHistory(habitId: 2, date: "2021-05-29", doneFlag: false),
        HabitHistory(habitId: 2, date: "2021-05-30", doneFlag: false),
    ])
    private let _habitDetail_3 = HabitDetail(userHabitId: 1, createDate: "2021-01-03", alarmFlag: false, alarmTime: nil, alarmMusic: nil, alarmHaptic: nil, repeatMon: true, repeatTue: true, repeatWed: true, repeatThu: false, repeatFri: false, repeatSat: false, repeatSun: false, memo: "월든 1회독", habitHistories: [
        HabitHistory(habitId: 3, date: "2021-05-24", doneFlag: true),
        HabitHistory(habitId: 3, date: "2021-05-25", doneFlag: true),
        HabitHistory(habitId: 3, date: "2021-05-26", doneFlag: false),
        HabitHistory(habitId: 3, date: "2021-05-27", doneFlag: false),
        HabitHistory(habitId: 3, date: "2021-05-28", doneFlag: true),
        HabitHistory(habitId: 3, date: "2021-05-29", doneFlag: false),
        HabitHistory(habitId: 3, date: "2021-05-30", doneFlag: true),
    ])
    
    
    
    // temp functions
    func getHabits() -> Observable<[Habit]> {
        return Observable.just(_habits)
    }
    func getHabitHistoriesFromDate(date: Date) -> Observable<[HabitHistory]> {
        let temp: [HabitHistory]
        switch dateStringDetail(date: date) {
        case "5월 30일 (일)":
            temp = _habitHistories_1
        case "5월 29일 (토)":
            temp = _habitHistories_2
        case "5월 28일 (금)":
            temp = _habitHistories_1
        case "5월 27일 (목)":
            temp = _habitHistories_2
        case "5월 26일 (수)":
            temp = _habitHistories_3
        case "5월 25일 (화)":
            temp = _habitHistories_2
        default:
            temp = _habitHistories_1
        }
        return Observable.just(temp)
    }
    func getChallenge() -> Observable<Challenge> {
        return Observable.just(_challenge)
    }
    func getHabitDetail(habitVO: HabitVO) -> Observable<HabitDetail> {
        switch habitVO.habitId {
        case 1:
            return Observable.just(_habitDetail_1)
        case 2:
            return Observable.just(_habitDetail_2)
        case 3:
            return Observable.just(_habitDetail_3)
        default:
            return Observable.just(_habitDetail_1)
        }
    }
}
