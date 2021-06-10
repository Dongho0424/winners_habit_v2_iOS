//
//  HabitVO.swift
//  Winners Habit
//
//  Created by 최동호 on 2021/05/07.
//

import WinnersHabitOAS
import UIKit
import RxSwift
import Alamofire

// Model
struct HabitVO {
    let habitId: Int64
    let habitName: String
    let icon: String
    let color: UIColor
    let defaultAttributeValue: Int64?
    let attribute: String
    var alarmFlag: Bool
    var alarmTime: String?
    var doneFlag: Bool
    var iconImage: UIImage?
    
    init() {
        self.habitId = 1
        self.habitName = ""
        self.icon = ""
        self.color = .clear
        self.defaultAttributeValue = nil
        self.attribute = ""
        self.alarmFlag = false
        self.alarmTime = nil
        self.doneFlag = false
        self.iconImage = nil
    }
    
    init(habitId: Int64,
         habitName: String,
         icon: String,
         color: UIColor,
         defaultAttributeValue: Int64?,
         attribute: String,
         alarmFlag: Bool,
         alarmTime: String?,
         doneFlag: Bool,
         iconImage: UIImage?)
    {
        self.habitId = habitId
        self.habitName = habitName
        self.icon = icon
        self.color = color
        self.defaultAttributeValue = defaultAttributeValue
        self.attribute = attribute
        self.alarmFlag = alarmFlag
        self.alarmTime = alarmTime
        self.doneFlag = doneFlag
        self.iconImage = iconImage
    }
}

extension HabitVO {
    //    static func HabitVOFromHabit(habit: Habit) -> HabitVO {
    //        return HabitVO(habitId: habit.habitId,
    //                       habitName: habit.habitName,
    //                       icon: habit.icon,
    //                       color: hexToUIColor(hex: habit.color),
    //                       defaultAttributeValue: habit.defaultAttributeValue,
    //                       attribute: habit.attribute ?? "",
    //                       alarmFlag: habit.alarmFlag,
    //                       alarmTime: habit.alarmTime,
    //                       iconImage: UIImage())
    //    }
    
    static func getHabitVOList(habits: [Habit], habitHistories: [HabitHistory]) -> [HabitVO] {
        guard habits.count == habitHistories.count else {
            fatalError("getHabitVOList")
        }
        
        var habitVOList = [HabitVO]()
        
        for i in 0 ..< habits.count {
            let habit = habits[i]
            let habitHistory = habitHistories[i]
            let habitVO = HabitVO(habitId: habit.habitId,
                                  habitName: habit.habitName,
                                  icon: habit.icon,
                                  color: hexToUIColor(hex: habit.color),
                                  defaultAttributeValue: habit.defaultAttributeValue,
                                  attribute: habit.attribute ?? "",
                                  alarmFlag: habit.alarmFlag,
                                  alarmTime: habit.alarmTime,
                                  doneFlag: habitHistory.doneFlag,
                                  iconImage: nil)
            habitVOList.append(habitVO)
        }
        
        return habitVOList
    }
    
    func setDoneFlag(_ done: Bool) -> Self {
        var temp = self
        temp.doneFlag = done
        return temp
    }
    
    func setImage(_ image: UIImage) -> Self {
        var temp = self
        temp.iconImage = image
        return temp
    }
}

extension HabitVO: Equatable {
    // id랑 image가 같아야 두 HabitVO는 같은 것이라고 정의.
    static func ==(lhs: HabitVO, rhs: HabitVO) -> Bool {
        return lhs.habitId == rhs.habitId &&
            lhs.habitName == rhs.habitName &&
            lhs.icon == rhs.icon &&
            lhs.color == rhs.color &&
            lhs.defaultAttributeValue == rhs.defaultAttributeValue &&
            lhs.attribute == rhs.attribute &&
            lhs.alarmFlag == rhs.alarmFlag &&
            lhs.alarmTime == rhs.alarmTime &&
            lhs.doneFlag == rhs.doneFlag &&
            lhs.iconImage == rhs.iconImage
    }
}

extension HabitVO {
    func getHabitWithImage() -> Observable<HabitVO> {
        
        return Observable.create { observer in
            
            guard let url = URL(string: icon) else {
                observer.onError(NSError(domain: "no icon image url", code: 1, userInfo: nil))
                return Disposables.create()
            }
            
            AF.request(url).responseData { res in
                if let imgData = res.data,
                   let img = UIImage(data: imgData) {
                    var nextHabitVO = self
                    nextHabitVO.iconImage = img
                    observer.onNext(nextHabitVO)
                }
                else {
                    observer.onError(NSError(domain: "network error", code: 2))
                }
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
}
