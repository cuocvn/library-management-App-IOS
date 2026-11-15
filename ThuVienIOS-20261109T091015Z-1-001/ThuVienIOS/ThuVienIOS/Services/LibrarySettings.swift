//
//  LibrarySettings.swift
//  ThuVienIOS
//
//  MÔ TẢ: Quản lý cấu hình mặc định của Thư Viện (Lưu trữ cục bộ UserDefaults)
//  Tương thích: UIKit, Storyboard & SwiftUI
//

import Foundation

final class LibrarySettings {
    // Singleton pattern
    static let shared = LibrarySettings()
    
    private let defaults = UserDefaults.standard
    
    // Tên thư viện hiển thị
    var tenThuVien: String {
        get { defaults.string(forKey: "tenThuVien") ?? "Thư Viện Số iOS" }
        set { defaults.set(newValue, forKey: "tenThuVien") }
    }
    
    // Số ngày cho mượn mặc định khi lập phiếu (VD: 14 ngày)
    var soNgayMuonMacDinh: Int {
        get {
            let v = defaults.integer(forKey: "soNgayMuonMacDinh")
            return v > 0 ? v : 14
        }
        set { defaults.set(newValue, forKey: "soNgayMuonMacDinh") }
    }
    
    // Mức phạt quá hạn cho mỗi ngày trễ (VD: 5.000 đ/ngày)
    var mucPhatMoiNgay: Int {
        get {
            let v = defaults.integer(forKey: "mucPhatMoiNgay")
            return v > 0 ? v : 5000
        }
        set { defaults.set(newValue, forKey: "mucPhatMoiNgay") }
    }
    
    // Mức tiền cọc mặc định cho sách thường
    var mucCocMacDinh: Int {
        get {
            let v = defaults.integer(forKey: "mucCocMacDinh")
            return v > 0 ? v : 50000
        }
        set { defaults.set(newValue, forKey: "mucCocMacDinh") }
    }
    
    // Phí mượn sách mặc định
    var phiMuonMacDinh: Int {
        get {
            let v = defaults.integer(forKey: "phiMuonMacDinh")
            return v > 0 ? v : 10000
        }
        set { defaults.set(newValue, forKey: "phiMuonMacDinh") }
    }
    
    private init() {}
}
