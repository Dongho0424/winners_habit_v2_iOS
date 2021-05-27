//
//  ViewModelType.swift
//  Winners Habit
//
//  Created by 최동호 on 2021/05/27.
//

public protocol ViewModelType {
    associatedtype Domain
    associatedtype Input
    associatedtype Output
    
    var domain: Domain { get }
    
    var input: Input { get }
    var output: Output { get }
    
    init(domain: Domain)
}
