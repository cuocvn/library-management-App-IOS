//
//  ThuVienIOSApp.swift
//  ThuVienIOS
//

import SwiftUI
import SwiftData

@main
struct ThuVienIOSApp: App {
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
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Không thể khởi tạo ModelContainer của SwiftData: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .onAppear {
                    // Tự động nạp dữ liệu mẫu ban đầu nếu database trống
                    SampleDataService.createSampleData(modelContext: sharedModelContainer.mainContext)
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
