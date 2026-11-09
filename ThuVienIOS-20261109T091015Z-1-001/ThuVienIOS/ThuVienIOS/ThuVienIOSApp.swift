//
//  ThuVienIOSApp.swift
//  ThuVienIOS
//
//  MÔ TẢ: Điểm khởi động (Entry Point) của ứng dụng SwiftUI trên iOS 17+
//  NHIỆM VỤ: Khởi tạo ModelContainer của SwiftData và nạp MainTabView
//

import SwiftUI
import SwiftData

@main
struct ThuVienIOSApp: App {
    // MARK: - Khởi tạo SwiftData ModelContainer
    // Đăng ký toàn bộ 7 Model vào Schema để SwiftData quản lý cơ sở dữ liệu SQLite offline
    let sharedModelContainer: ModelContainer = {
        let schema = Schema([
            TheLoai.self,
            NhaXuatBan.self,
            TacGia.self,
            Sach.self,
            BanSaoSach.self,
            DocGia.self,
            PhieuMuon.self
        ])
        
        // isStoredInMemoryOnly: false nghĩa là dữ liệu được lưu bền vững vào bộ nhớ máy,
        // khi tắt app hoặc khởi động lại máy thì dữ liệu vẫn còn nguyên vẹn.
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Không thể khởi tạo ModelContainer của SwiftData: \(error)")
        }
    }()

    // MARK: - Giao diện chính của ứng dụng
    var body: some Scene {
        WindowGroup {
            // Khởi động trực tiếp vào MainTabView (thanh điều hướng 5 Tab)
            MainTabView()
        }
        // Gắn modelContainer vào toàn bộ cây view SwiftUI
        .modelContainer(sharedModelContainer)
    }
}