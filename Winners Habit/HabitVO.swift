//
//  HabitVO.swift
//  Winners Habit
//
//  Created by 최동호 on 2021/05/07.
//

import OpenAPIClient
import UIKit

class HabitVO {
    var habit: Habit
    var habitImg: UIImage?
    
    init(habit: Habit, habitImg: UIImage? = nil){
        self.habit = habit
        self.habitImg = habitImg
    }
}
