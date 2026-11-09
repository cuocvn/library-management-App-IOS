//
//  MainTabView.swift
//  ThuVienIOS
//
//  MÔ TẢ: Màn hình điều hướng chính dạng Tab Bar (5 Tabs) theo chuẩn Apple HIG
//  5 TAB: 1. Trang Chủ | 2. Kho Sách | 3. Mượn Trả | 4. Độc Giả | 5. Cài Đặt
//

import SwiftUI

struct MainTabView: View {
    // Quản lý tab đang được chọn (0: Trang Chủ, 1: Sách, 2: Mượn Trả, 3: Độc Giả, 4: Cài Đặt)
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // TAB 1: TRANG CHỦ (Dashboard thống kê & biểu đồ Apple Charts)
            DashboardView()
                .tabItem {
                    Label("Trang Chủ", systemImage: "chart.pie.fill")
                }
                .tag(0)
            
            // TAB 2: KHO SÁCH (Quản lý đầu sách & từng bản sao vật lý trên kệ)
            KhoSachView()
                .tabItem {
                    Label("Kho Sách", systemImage: "books.vertical.fill")
                }
                .tag(1)
            
            // TAB 3: MƯỢN & TRẢ SÁCH (Lập phiếu, trả sách, thu phạt snapshot)
            MuonTraView()
                .tabItem {
                    Label("Mượn Trả", systemImage: "arrow.triangle.2.circlepath")
                }
                .tag(2)
            
            // TAB 4: ĐỘC GIẢ (Quản lý bạn đọc, thẻ VIP, ví điện tử nội bộ)
            DocGiaView()
                .tabItem {
                    Label("Độc Giả", systemImage: "person.crop.rectangle.stack.fill")
                }
                .tag(3)
            
            // TAB 5: CÀI ĐẶT THƯ VIỆN (Quy định hạn mượn, mức phạt, danh mục metadata)
            CaiDatView()
                .tabItem {
                    Label("Cài Đặt", systemImage: "gearshape.fill")
                }
                .tag(4)
        }
        // Màu sắc nổi bật của biểu tượng tab khi đang chọn
        .tint(AppTheme.primary)
    }
}