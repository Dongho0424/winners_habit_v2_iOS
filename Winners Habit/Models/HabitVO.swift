//
//  HabitVO.swift
//  Winners Habit
//
//  Created by 최동호 on 2021/05/07.
//

import OpenAPIClient
import UIKit

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
                                  iconImage: UIImage())
            habitVOList.append(habitVO)
        }
        
        return habitVOList
    }
    
    func toggle() -> Self {
        var temp = self
        temp.doneFlag = !temp.doneFlag
        return temp
    }
}
