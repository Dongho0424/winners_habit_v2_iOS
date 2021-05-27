//
//  Utils.swift
//  Winners Habit
//
//  Created by 최동호 on 2021/05/03.
//

import Foundation
import UIKit

extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }

   convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
}

func hexToUIColor(hex: String) -> UIColor {
    return UIColor(rgb: Int(hex, radix: 16)!)
}

func getWeekDayKor(date: Int?) -> String {
    switch date {
    case 1:
        return "일"
    case 2:
        return "월"
    case 3:
        return "화"
    case 4:
        return "수"
    case 5:
        return "목"
    case 6:
        return "금"
    case 7:
        return "토"
    default:
        return "날짜 변환 오류"
    }
}

// 06:30:00 -> 오전 6:30
func convertAlarmTime(time: String) -> String {
    // convert "HH:mm:ss" -> "오전 h:mm"
    let dateString = time as NSString
    let hPart = dateString.substring(with: NSMakeRange(0, 2))
    let df = DateFormatter()
    df.dateFormat = "HH:mm:ss"
    let alarmDate = df.date(from: dateString as String)
    df.dateFormat = "h:mm"
    let alarm = df.string(from: alarmDate!)
    if hPart.hasPrefix("0") || (Int(hPart)!) < 12 {
        return "오전 \(alarm)"
    } else {
        return "오후 \(alarm)"
    }
}

// 2021-04-24 -> 4월 24일 (월)
func dateSring(date: String) -> String {
    let dateDf = DateFormatter().then {
        $0.dateFormat = "yyyy-MM-dd"
    }
    let tempDate = dateDf.date(from: date)!
    return dateStringDetail(date: tempDate)
}

// return 4월 24일 (월)
func dateStringDetail(date: Date) -> String {
    let strDf = DateFormatter().then {
        $0.dateFormat = "M'월' d'일'"
    }
    let weekDayKor = Calendar.current.dateComponents([.weekday], from: date).weekday
    return "\(strDf.string(from: date)) (\(getWeekDayKor(date: weekDayKor)))"
}

// 2021-04-24 -> Date
func stringDate(date: String) -> Date {
    let df = DateFormatter()
    df.dateFormat = "yyyy-MM-dd"
    return df.date(from: date)!
}

// 2021-01-03 -> 2021.01.03
func convertDate1(date: String) -> String {
    let df = DateFormatter()
    df.dateFormat = "yyyy-MM-dd"
    let tempDate = df.date(from: date)
    df.dateFormat = "yyyy.MM.dd"
    return df.string(from: tempDate!)
}

// 2021-04-24 -> 4
// 2021-12-24 -> 12
func getMonth(date: String) -> String {
    let temp = date as NSString
    if temp.substring(from: 5) == "0" {
        return temp.substring(from: 6)
    } else {
        return temp.substring(with: NSMakeRange(5, 7))
    }
}
