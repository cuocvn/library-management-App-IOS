//
//  NapTienView.swift
//  ThuVienIOS
//

import SwiftUI
import SwiftData

struct NapTienView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Bindable var docGia: DocGia
    
    @State private var soTienNap: String = "100000"
    let cacMenhGiaNhanh = [50000, 100000, 200000, 500000]

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                
                // Card Số Dư Hiện Tại
                VStack(spacing: 8) {
                    Text("Số Dư Ví Hiện Tại")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary)
                    Text(AppTheme.formatVND(docGia.soDuTaiKhoan))
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.primary)
                    Text("Độc giả: \(docGia.hoTen)")
                        .font(.footnote)
                        .foregroundColor(AppTheme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(20)
                .background(AppTheme.cardBackground)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppTheme.borderSubtle, lineWidth: 0.5)
                )
                .padding(.horizontal)
                
                // Nhập số tiền nạp
                VStack(alignment: .leading, spacing: 10) {
                    Text("Nhập số tiền nạp (VNĐ)")
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    HStack {
                        TextField("Số tiền", text: $soTienNap)
                            .font(.title2.bold())
                            .keyboardType(.numberPad)
                        Text("đ")
                            .font(.title2.bold())
                            .foregroundColor(AppTheme.primary)
                    }
                    .padding()
                    .background(AppTheme.cardBackground)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppTheme.primary.opacity(0.3), lineWidth: 1)
                    )
                }
                .padding(.horizontal)
                
                // Mệnh giá nhanh
                VStack(alignment: .leading, spacing: 10) {
                    Text("Chọn nhanh mệnh giá")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(AppTheme.textSecondary)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(cacMenhGiaNhanh, id: \.self) { mg in
                            Button {
                                soTienNap = "\(mg)"
                            } label: {
                                Text("+ \(AppTheme.formatVND(mg))")
                                    .font(.subheadline.bold())
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(soTienNap == "\(mg)" ? AppTheme.primary : AppTheme.cardBackground)
                                    .foregroundColor(soTienNap == "\(mg)" ? .white : AppTheme.textPrimary)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(AppTheme.borderSubtle, lineWidth: 0.5)
                                    )
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Nút Xác nhận nạp
                Button {
                    let amount = Int(soTienNap) ?? 0
                    if amount > 0 {
                        docGia.soDuTaiKhoan += amount
                        try? modelContext.save()
                        dismiss()
                    }
                } label: {
                    Text("Xác Nhận Nạp Tiền")
                        .font(.headline.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppTheme.primary)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                }
                .padding(.horizontal)
                .disabled((Int(soTienNap) ?? 0) <= 0)
            }
            .padding(.vertical)
            .background(AppTheme.primaryBackground.ignoresSafeArea())
            .navigationTitle("Nạp Tiền Vào Ví")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Hủy") {
                        dismiss()
                    }
                }
            }
        }
    }
}
