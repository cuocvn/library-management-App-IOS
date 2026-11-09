//
//  CaiDatView.swift
//  ThuVienIOS
//

import SwiftUI

struct CaiDatView: View {
    @AppStorage("tenThuVien") private var tenThuVien: String = "Thư Viện Số iOS"
    @AppStorage("soNgayMuonMacDinh") private var soNgayMuonMacDinh: Int = 14
    @AppStorage("mucPhatMoiNgay") private var mucPhatMoiNgay: Int = 5000
    @AppStorage("mucCocMacDinh") private var mucCocMacDinh: Int = 50000
    
    var body: some View {
        NavigationStack {
            Form {
                // Section 1: Cấu hình quy định mượn & phạt
                Section(header: Text("Quy định mượn trả & Tài chính")) {
                    HStack {
                        Text("Tên thư viện:")
                        Spacer()
                        TextField("Tên", text: $tenThuVien)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    Stepper("Hạn mượn mặc định: \(soNgayMuonMacDinh) ngày", value: $soNgayMuonMacDinh, in: 1...90)
                    
                    HStack {
                        Text("Mức phạt trễ / ngày:")
                        Spacer()
                        Text(AppTheme.formatVND(mucPhatMoiNgay))
                            .fontWeight(.semibold)
                            .foregroundColor(AppTheme.danger)
                    }
                    
                    Stepper(value: $mucPhatMoiNgay, in: 1000...50000, step: 1000) {
                        Text("Điều chỉnh mức phạt")
                    }
                }
                
                // Section 2: Quản lý danh mục metadata
                Section(header: Text("Quản lý danh mục")) {
                    NavigationLink {
                        QuanLyTheLoaiView()
                    } label: {
                        Label("Danh mục Thể Loại", systemImage: "square.grid.2x2.fill")
                    }
                    
                    NavigationLink {
                        QuanLyNXBView()
                    } label: {
                        Label("Danh mục Nhà Xuất Bản", systemImage: "building.2.fill")
                    }
                    
                    NavigationLink {
                        QuanLyTacGiaView()
                    } label: {
                        Label("Danh mục Tác Giả", systemImage: "pencil.and.outline")
                    }
                }
                
                // Section 3: Thông tin đồ án & Hệ thống
                Section(header: Text("Thông tin đồ án")) {
                    HStack {
                        Text("Đồ án:")
                        Spacer()
                        Text("Ứng Dụng Quản Lý Thư Viện")
                            .font(.footnote)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    
                    HStack {
                        Text("Nền tảng:")
                        Spacer()
                        Text("SwiftUI • SwiftData (iOS 17+)")
                            .font(.footnote)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    
                    HStack {
                        Text("Chế độ:")
                        Spacer()
                        Text("Offline Local DB")
                            .font(.footnote)
                            .foregroundColor(AppTheme.success)
                    }
                }
            }
            .navigationTitle("Cài Đặt Hệ Thống")
        }
    }
}
