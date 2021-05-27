//
//  ChallengeVO.swift
//  Winners Habit
//
//  Created by 최동호 on 2021/05/27.
//

import Foundation
import UIKit
import OpenAPIClient

struct ChallengeVO {
    let challengeId: Int
    let challengeImage: UIImage
    let challengeName: String
    let challengeDDay: Int?
    let totalCompleteRatio: Int
    let todayCompleteRatio: Int
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
