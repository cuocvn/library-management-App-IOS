//
//  DocGiaView.swift
//  ThuVienIOS
//

import SwiftUI

struct DocGiaView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "person.crop.rectangle.stack.fill")
                    .font(.system(size: 60))
                    .foregroundColor(AppTheme.primary)
                Text("Quản Lý Độc Giả")
                    .font(.title2.bold())
                Text("Tab 4 sẽ được hoàn thiện ở Giai đoạn tiếp theo")
                    .foregroundColor(AppTheme.textSecondary)
            }
            .navigationTitle("Độc Giả")
        }
    }
}
