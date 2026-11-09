//
//  AppTheme.swift
//  ThuVienIOS
//
//  MÔ TẢ: Hệ thống Bảng màu & Định dạng dùng chung cho toàn bộ Ứng Dụng
//  PHONG CÁCH: Apple Human Interface Guidelines (HIG), màu chủ đạo Indigo Blue `#4338CA`
//

import SwiftUI

enum AppTheme {
    // MARK: - Bảng màu chủ đạo (Primary Indigo)
    static let primary = Color(red: 0.263, green: 0.220, blue: 0.792) // Indigo Blue #4338CA
    static let primaryLight = Color(red: 0.380, green: 0.337, blue: 0.894)
    static let primaryBackground = Color(red: 0.949, green: 0.949, blue: 0.969) // Nền nhóm #F2F2F7
    
    // MARK: - Bảng màu trạng thái & Tài chính
    static let success = Color(red: 0.086, green: 0.639, blue: 0.290) // Xanh lá thành công #16A34A
    static let danger = Color(red: 0.863, green: 0.149, blue: 0.149)  // Đỏ cảnh báo quá hạn/phạt #DC2626
    static let warning = Color(red: 0.918, green: 0.345, blue: 0.047) // Cam doanh thu phí #EA580C
    static let cardBackground = Color.white
    static let textPrimary = Color(red: 0.102, green: 0.110, blue: 0.122) // Chữ chính đậm
    static let textSecondary = Color(red: 0.435, green: 0.431, blue: 0.490) // Chữ phụ mờ
    static let borderSubtle = Color(red: 0.898, green: 0.898, blue: 0.918) // Viền thẻ nhẹ
    
    // MARK: - Hàm tiện ích định dạng tiền tệ Việt Nam (VNĐ)
    // Ví dụ: 50000 -> "50.000 đ"
    static func formatVND(_ amount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        let formatted = formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
        return "\(formatted) đ"
    }
}