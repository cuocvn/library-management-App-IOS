//
//  KhoSachView.swift
//  ThuVienIOS
//

import SwiftUI

struct KhoSachView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "books.vertical.fill")
                    .font(.system(size: 60))
                    .foregroundColor(AppTheme.primary)
                Text("Quản Lý Kho Sách")
                    .font(.title2.bold())
                Text("Tab 2 sẽ được hoàn thiện ở Giai đoạn tiếp theo")
                    .foregroundColor(AppTheme.textSecondary)
            }
            .navigationTitle("Kho Sách")
        }
    }
}
