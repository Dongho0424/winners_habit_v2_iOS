//
//  ChallengeVO.swift
//  Winners Habit
//
//  Created by 최동호 on 2021/05/27.
//

import Foundation
import UIKit
import WinnersHabitOAS

struct ChallengeVO {
    let challengeId: Int
    let challengeImage: UIImage
    let challengeName: String
    let challengeDDay: Int?
    let totalCompleteRatio: Int
    let todayCompleteRatio: Int
    
    init() {
        self.challengeId = 0
        self.challengeImage = UIImage()
        self.challengeName = ""
        self.challengeDDay = nil
        self.totalCompleteRatio = 0
        self.todayCompleteRatio = 0
    }
    
    init(
        challengeId: Int,
        challengeImage: UIImage,
        challengeName: String,
        challengeDDay: Int?,
        totalCompleteRatio: Int,
        todayCompleteRatio: Int
    ) {
        self.challengeId = challengeId
        self.challengeImage = challengeImage
        self.challengeName = challengeName
        self.challengeDDay = challengeDDay
        self.totalCompleteRatio = totalCompleteRatio
        self.todayCompleteRatio = todayCompleteRatio
    }
}

extension ChallengeVO {
    
    static func ChallengeVOFromChallenge(_ challenge: Challenge) -> Self {
        return ChallengeVO(challengeId: challenge.challengeId,
                           challengeImage: UIImage(named: "billgates.png")!,
                           challengeName: challenge.challengeName,
                           challengeDDay: challenge.challengeDDay,
                           totalCompleteRatio: 70,
                           todayCompleteRatio: 88)
    }
}
