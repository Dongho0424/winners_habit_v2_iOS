//
//  HabitDetailVO.swift
//  Winners Habit
//
//  Created by 최동호 on 2021/05/30.
//

import WinnersHabitOAS
import Foundation
import UIKit

struct HabitDetailVO {
    
    // 기존에 있는 걸로 합칠 수 있는 정보들
    var challengeName: String
    var habitImg: UIImage?
    var habitTitle: String
    var attribute: String
    var defaultAttributeValue: Int64?
    var color: UIColor
    
    // 새로 받아와야 하는 정보들
    var userHabitId: Int
    var createDate: String
    var alarmFlag: Bool
    var alarmTime: String?
    var alarmMusic: String?
    var alarmHaptic: String?
    var repeatMon: Bool?
    var repeatTue: Bool?
    var repeatWed: Bool?
    var repeatThu: Bool?
    var repeatFri: Bool?
    var repeatSat: Bool?
    var repeatSun: Bool?
    var memo: String?
    var habitHistories: [HabitHistory]?
    
    init() {
        self.challengeName = ""
        self.habitImg = UIImage()
        self.habitTitle = ""
        self.attribute = ""
        self.defaultAttributeValue = nil
        self.color = .clear
        
        self.userHabitId = 0
        self.createDate = ""
        self.alarmFlag = false
        self.alarmTime = nil
        self.alarmMusic = nil
        self.alarmHaptic = nil
        self.repeatMon = nil
        self.repeatTue = nil
        self.repeatWed = nil
        self.repeatThu = nil
        self.repeatFri = nil
        self.repeatSat = nil
        self.repeatSun = nil
        self.memo = nil
        self.habitHistories = nil
    }
    
    init(challengeName: String,
         habitImg: UIImage?,
         habitTitle: String,
         attribute: String,
         defaultAttributeValue: Int64?,
         color: UIColor,
         
         userHabitId: Int,
         createDate: String,
         alarmFlag: Bool,
         alarmTime: String?,
         alarmMusic: String?,
         alarmHaptic: String?,
         repeatMon: Bool?,
         repeatTue: Bool?,
         repeatWed: Bool?,
         repeatThu: Bool?,
         repeatFri: Bool?,
         repeatSat: Bool?,
         repeatSun: Bool?,
         memo: String?,
         habitHistories: [HabitHistory]? )
    {
        self.challengeName = challengeName
        self.habitImg = habitImg
        self.habitTitle = habitTitle
        self.attribute = attribute
        self.defaultAttributeValue = defaultAttributeValue
        self.color = color
        
        self.userHabitId =  userHabitId
        self.createDate =  createDate
        self.alarmFlag = alarmFlag
        self.alarmTime = alarmTime
        self.alarmMusic = alarmMusic
        self.alarmHaptic = alarmHaptic
        self.repeatMon = repeatMon
        self.repeatTue = repeatTue
        self.repeatWed = repeatWed
        self.repeatThu = repeatThu
        self.repeatFri = repeatFri
        self.repeatSat = repeatSat
        self.repeatSun = repeatSun
        self.memo = memo
        self.habitHistories = habitHistories
    }
    
}

extension HabitDetailVO {
    static func getHabitDetailVO(habitVO: HabitVO, habitDetail: HabitDetail) -> HabitDetailVO {
        return HabitDetailVO(challengeName: "빌 게이츠", // 서버에서 받아왔다고 가정
                             habitImg: habitVO.iconImage,
                             habitTitle: habitVO.habitName,
                             attribute: habitVO.attribute,
                             defaultAttributeValue: habitVO.defaultAttributeValue,
                             color: habitVO.color,
                             
                             userHabitId: habitDetail.userHabitId,
                             createDate: habitDetail.createDate,
                             alarmFlag: habitDetail.alarmFlag,
                             alarmTime: habitDetail.alarmTime,
                             alarmMusic: habitDetail.alarmMusic,
                             alarmHaptic: habitDetail.alarmHaptic,
                             repeatMon: habitDetail.repeatMon,
                             repeatTue: habitDetail.repeatTue,
                             repeatWed: habitDetail.repeatWed,
                             repeatThu: habitDetail.repeatThu,
                             repeatFri: habitDetail.repeatFri,
                             repeatSat: habitDetail.repeatSat,
                             repeatSun: habitDetail.repeatSun,
                             memo: habitDetail.memo,
                             habitHistories: habitDetail.habitHistories)
    }
}
