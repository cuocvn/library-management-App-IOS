//
//  AppTheme.swift
//  ThuVienIOS
//
//  MÔ TẢ: Hệ thống Bảng màu & Định dạng dùng chung cho toàn bộ Ứng Dụng (UIKit + Storyboard)
//  PHONG CÁCH: Apple Human Interface Guidelines (HIG), màu chủ đạo Indigo Blue `#4338CA`
//

import UIKit

// MARK: - Bảng màu mở rộng cho UIColor
extension UIColor {
    /// Màu chủ đạo: Indigo Blue #4338CA
    static let appPrimary = UIColor(red: 0.263, green: 0.220, blue: 0.792, alpha: 1.0)
    /// Màu Indigo nhạt
    static let appPrimaryLight = UIColor(red: 0.380, green: 0.337, blue: 0.894, alpha: 1.0)
    /// Nền xám nhóm Apple HIG
    static let appBackground = UIColor.systemGroupedBackground
    /// Thẻ trắng nền
    static let appCardBg = UIColor.secondarySystemGroupedBackground
    /// Màu xanh lá thành công / Hoàn tiền
    static let appSuccess = UIColor(red: 0.086, green: 0.639, blue: 0.290, alpha: 1.0)
    /// Màu đỏ cảnh báo quá hạn / Phạt
    static let appDanger = UIColor(red: 0.863, green: 0.149, blue: 0.149, alpha: 1.0)
    /// Màu cam doanh thu phí
    static let appWarning = UIColor(red: 0.918, green: 0.345, blue: 0.047, alpha: 1.0)
    /// Màu vàng kim cho VIP
    static let appGold = UIColor(red: 0.85, green: 0.65, blue: 0.13, alpha: 1.0)
}

// MARK: - Tiện ích giao diện & Định dạng
enum AppTheme {
    /// Định dạng số tiền thành VNĐ (VD: 50000 -> "50.000 đ")
    static func formatVND(_ amount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        let formatted = formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
        return "\(formatted) đ"
    }
    
    /// Định dạng ngày tháng VN (VD: 15/11/2026)
    static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }
    
    /// Áp dụng style Card bo góc và đổ bóng nhẹ chuẩn Apple HIG
    static func applyCardStyle(to view: UIView, cornerRadius: CGFloat = 12) {
        view.backgroundColor = .appCardBg
        view.layer.cornerRadius = cornerRadius
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.04
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 6
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor.separator.cgColor
    }
    
    /// Tạo Badge trạng thái bo tròn
    static func createBadge(text: String, textColor: UIColor, bgColor: UIColor) -> UILabel {
        let label = UILabel()
        label.text = "  \(text)  "
        label.font = .systemFont(ofSize: 11, weight: .semibold)
        label.textColor = textColor
        label.backgroundColor = bgColor
        label.layer.cornerRadius = 6
        label.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
}
