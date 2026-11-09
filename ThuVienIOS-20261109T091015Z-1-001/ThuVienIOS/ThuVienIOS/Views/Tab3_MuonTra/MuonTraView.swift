//
//  MuonTraView.swift
//  ThuVienIOS
//

import SwiftUI

struct MuonTraView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 60))
                    .foregroundColor(AppTheme.primary)
                Text("Quản Lý Mượn Trả")
                    .font(.title2.bold())
                Text("Tab 3 sẽ được hoàn thiện ở Giai đoạn tiếp theo")
                    .foregroundColor(AppTheme.textSecondary)
            }
            .navigationTitle("Mượn Trả")
        }
    }
}
