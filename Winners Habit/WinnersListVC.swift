//
//  WinnersListVC.swift
//  Winners Habit
//
//  Created by 최동호 on 2021/05/05.
//

import Foundation
import UIKit

class ChallengeListVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    // MARK: - CollectionView Data Source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? ChallengeCell else {
            fatalError()
        }
        
        cell.contentView.backgroundColor = .orange
        cell.label.text = "dongho"
        cell.label.textColor = .label
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.collectionView.frame.size.width / 2
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
