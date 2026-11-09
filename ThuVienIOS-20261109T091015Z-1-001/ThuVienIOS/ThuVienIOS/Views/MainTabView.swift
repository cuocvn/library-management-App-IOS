//
//  MainTabView.swift
//  ThuVienIOS
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Trang Chủ", systemImage: "chart.pie.fill")
                }
                .tag(0)
            
            KhoSachView()
                .tabItem {
                    Label("Kho Sách", systemImage: "books.vertical.fill")
                }
                .tag(1)
            
            MuonTraView()
                .tabItem {
                    Label("Mượn Trả", systemImage: "arrow.triangle.2.circlepath")
                }
                .tag(2)
            
            DocGiaView()
                .tabItem {
                    Label("Độc Giả", systemImage: "person.crop.rectangle.stack.fill")
                }
                .tag(3)
            
            CaiDatView()
                .tabItem {
                    Label("Cài Đặt", systemImage: "gearshape.fill")
                }
                .tag(4)
        }
        .tint(AppTheme.primary)
    }
}
