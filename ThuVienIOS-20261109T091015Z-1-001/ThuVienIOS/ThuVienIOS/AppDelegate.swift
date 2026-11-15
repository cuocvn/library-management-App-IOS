//
//  AppDelegate.swift
//  ThuVienIOS
//
//  MÔ TẢ: Điểm khởi động ứng dụng UIKit (Lifecycle Application)
//  Tương thích: iOS 16.0+ / Xcode 14.2+ / Storyboard
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Tùy chỉnh màu sắc toàn cục cho Navigation Bar & Tab Bar
        UINavigationBar.appearance().tintColor = .appPrimary
        UITabBar.appearance().tintColor = .appPrimary
        
        // Khởi tạo DataManager nạp dữ liệu nếu cần
        _ = DataManager.shared
        
        return true
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}
