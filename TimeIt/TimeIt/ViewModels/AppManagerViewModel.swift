//
//  AppManagerViewModel.swift
//  TimeIt
//
//  Created by Luke Hendriks on 05/07/2022.
//

class AppManagerViewModel {
    var isActive = true
    static var shared = AppManagerViewModel()
    private init() {}
}
