//
//  ThuVienIOSApp.swift
//  ThuVienIOS
//
//  MÔ TẢ: Điểm khởi động (Entry Point) của ứng dụng SwiftUI trên iOS 16+
//  Tương thích: iOS 16.0+ / Xcode 14.2+
//

import SwiftUI

@main
struct ThuVienIOSApp: App {
    @StateObject private var dataManager = DataManager.shared

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(dataManager)
        }
    }
}
