//
//  LibrarySettings.swift
//  ThuVienIOS
//
//  MÔ TẢ: Quản lý cấu hình mặc định của Thư Viện
//  CÔNG NGHỆ: Sử dụng @AppStorage (Lưu trữ cục bộ vào UserDefaults của iOS)
//

import SwiftUI

final class LibrarySettings: ObservableObject {
    // Singleton pattern để truy xuất cài đặt ở mọi nơi
    static let shared = LibrarySettings()
    
    // Tên thư viện hiển thị
    @AppStorage("tenThuVien") var tenThuVien: String = "Thư Viện Số iOS"
    
    // Số ngày cho mượn mặc định khi lập phiếu (VD: 14 ngày)
    @AppStorage("soNgayMuonMacDinh") var soNgayMuonMacDinh: Int = 14
    
    // Mức phạt quá hạn cho mỗi ngày trễ (VD: 5.000 đ/ngày)
    @AppStorage("mucPhatMoiNgay") var mucPhatMoiNgay: Int = 5000
    
    // Mức tiền cọc mặc định cho sách thường
    @AppStorage("mucCocMacDinh") var mucCocMacDinh: Int = 50000
    
    // Phí mượn sách mặc định
    @AppStorage("phiMuonMacDinh") var phiMuonMacDinh: Int = 10000
    
    private init() {}
}