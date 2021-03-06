//
// Habit.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation

/** 홈 페이지에서 보여주는 용. 자세한 정보는 없음 */
public struct Habit: Codable {

    public var habitId: Int64
    public var habitName: String
    public var icon: String
    public var color: String
    public var defaultAttributeValue: Int64?
    /** 습관 고유 성질. 예로 기상 습관은 성공/실패, 운동 습관은 0/20분 등등 */
    public var attribute: String?
    public var alarmFlag: Bool
    /** form; 06:30:20 */
    public var alarmTime: String?

    public init(habitId: Int64, habitName: String, icon: String, color: String, defaultAttributeValue: Int64? = nil, attribute: String? = nil, alarmFlag: Bool, alarmTime: String? = nil) {
        self.habitId = habitId
        self.habitName = habitName
        self.icon = icon
        self.color = color
        self.defaultAttributeValue = defaultAttributeValue
        self.attribute = attribute
        self.alarmFlag = alarmFlag
        self.alarmTime = alarmTime
    }

}
