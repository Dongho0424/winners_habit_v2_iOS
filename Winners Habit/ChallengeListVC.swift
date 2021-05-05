//
//  WinnersListVC.swift
//  Winners Habit
//
//  Created by 최동호 on 2021/05/05.
//

import Foundation
import UIKit
import OpenAPIClient
import Then

class ChallengeListVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let challenges = [
        Challenge(challengeId: 1, challengeName: "빌 게이츠", challengeImage: ""),
        Challenge(challengeId: 2, challengeName: "스티브 잡스", challengeImage: ""),
        Challenge(challengeId: 3, challengeName: "최동호", challengeImage: ""),
        Challenge(challengeId: 4, challengeName: "일론 머스크", challengeImage: "")
    ]
    
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.searchBar.delegate = self
        
        let xmarkImg = UIImage(named: "xmark.png")
//        let xmarkImg = UIImage(systemName: "xmark")?.withRenderingMode(.alwaysTemplate)
        self.searchBar.setImage(xmarkImg, for: .bookmark, state: .normal)
        
        if let textField = self.searchBar.value(forKey: "searchField") as? UITextField {
            
            textField.backgroundColor = .white
//            textField.placeholder = "롤모델을 검색하세요."
//            textField.attributedPlaceholder = NSAttributedString(
            self.searchBar.placeholder = "롤모델을 검색하세요."
            textField.font = UIFont.systemFont(ofSize: 13)
            textField.textColor = .black
            
            if let leftView = textField.leftView as? UIImageView {
//                leftView.image = leftView.image?.withRenderingMode(.alwaysOriginal)
                leftView.tintColor = .black
                print("hiasdasd")
            }
            
//
//            if let rightView = textField.rightView as? UIImageView {
//                rightView.image = rightView.image?.withRenderingMode(.alwaysTemplate)
//                print("hi")
//                rightView.tintColor = .black
//            }
//            textField.rightViewMode = .whileEditing
//            textField.rightView = UIImageView().then {
//                $0.image = xmarkImg
//                $0.tintColor = .black
//            }
        }
    }
    
    // MARK: - CollectionView Data Source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? ChallengeCell else {
            fatalError()
        }
        
        
        cell.label.text = "dongho"
        cell.label.textColor = .label
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.collectionView.frame.size.width / 2 - 5
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}
