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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.initSearchBar()
    }
    
    // custom UISearchBar clear button image with tint color of its imageView to black
    func initSearchBar() {
        self.searchBar.delegate = self
        self.searchBar.setImage(UIImage(systemName: "xmark"), for: .clear, state: .normal)
        
        if let textfield = self.searchBar.value(forKey: "searchField") as? UITextField,
           let clearButton = textfield.value(forKey: "clearButton") as? UIButton {
            clearButton.tintColor = .black
        }
    }

    
    // MARK: - CollectionView Data Source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.challenges.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? ChallengeCell else {
            fatalError()
        }

        cell.label.text = self.challenges[indexPath.row].challengeName
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
