//
//  AppTheme.swift
//  ThuVienIOS
//

import SwiftUI

enum AppTheme {
    // Primary Indigo Palette
    static let primary = Color(red: 0.263, green: 0.220, blue: 0.792) // #4338CA
    static let primaryLight = Color(red: 0.380, green: 0.337, blue: 0.894)
    static let primaryBackground = Color(red: 0.949, green: 0.949, blue: 0.969) // #F2F2F7 System Grouped
    
    // Status & Financial Colors
    static let success = Color(red: 0.086, green: 0.639, blue: 0.290) // #16A34A
    static let danger = Color(red: 0.863, green: 0.149, blue: 0.149)  // #DC2626
    static let warning = Color(red: 0.918, green: 0.345, blue: 0.047) // #EA580C
    static let cardBackground = Color.white
    static let textPrimary = Color(red: 0.102, green: 0.110, blue: 0.122) // #1A1C1F
    static let textSecondary = Color(red: 0.435, green: 0.431, blue: 0.490) // #6F6E7D
    static let borderSubtle = Color(red: 0.898, green: 0.898, blue: 0.918) // #E5E5EA
    
    // Formatting currency VNĐ
    static func formatVND(_ amount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        let formatted = formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
        return "\(formatted) đ"
    }
}
