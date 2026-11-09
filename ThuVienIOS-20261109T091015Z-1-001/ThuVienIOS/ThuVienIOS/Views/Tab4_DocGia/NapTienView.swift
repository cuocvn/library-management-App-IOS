//
//  NapTienView.swift
//  ThuVienIOS
//
//  MÔ TẢ: Màn hình 4.1.1 - Nạp Tiền Vào Ví Độc Giả (Fintech Mini)
//  CHỨC NĂNG:
//  - Hiển thị số dư ví hiện tại của độc giả
//  - Ô nhập số tiền tùy ý
//  - 4 nút chọn nhanh các mệnh giá phổ biến: 50k, 100k, 200k, 500k
//  - Nút "Xác Nhận Nạp Tiền": Cộng trực tiếp tiền vào docGia.soDuTaiKhoan và lưu SwiftData
//

import SwiftUI
import SwiftData

struct NapTienView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // Độc giả cần nạp tiền
    @Bindable var docGia: DocGia
    
    // Số tiền nạp mặc định gợi ý: 100.000 VNĐ
    @State private var soTienNap: String = "100000"
    let cacMenhGiaNhanh = [50000, 100000, 200000, 500000]

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                
                // MARK: 1. Thẻ hiển thị số dư ví hiện tại
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
                
                // MARK: 2. Ô nhập số tiền nạp tùy ý
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
                
                // MARK: 3. Lưới 4 nút chọn nhanh mệnh giá
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
                
                // MARK: 4. Nút bấm Xác nhận nạp tiền
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