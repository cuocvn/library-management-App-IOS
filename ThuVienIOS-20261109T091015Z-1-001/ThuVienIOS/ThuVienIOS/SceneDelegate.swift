//
//  SceneDelegate.swift
//  ThuVienIOS
//
//  MÔ TẢ: Quản lý vòng đời UIWindowScene & Tải Main.storyboard
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // Đảm bảo khởi tạo rootViewController từ Main.storyboard nếu chưa có
        if window == nil {
            let win = UIWindow(windowScene: windowScene)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let rootVC = storyboard.instantiateInitialViewController() {
                win.rootViewController = rootVC
            }
            self.window = win
            win.makeKeyAndVisible()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Tự động lưu dữ liệu bền vững khi thoát app hoặc ra nền
        DataManager.shared.save()
    }
}
