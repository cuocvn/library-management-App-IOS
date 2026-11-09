//
//  CaiDatView.swift
//  ThuVienIOS
//

import SwiftUI

struct CaiDatView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "gearshape.2.fill")
                    .font(.system(size: 60))
                    .foregroundColor(AppTheme.primary)
                Text("Cài Đặt Thư Viện")
                    .font(.title2.bold())
                Text("Tab 5 sẽ được hoàn thiện ở Giai đoạn tiếp theo")
                    .foregroundColor(AppTheme.textSecondary)
            }
            .navigationTitle("Cài Đặt")
        }
    }
}
