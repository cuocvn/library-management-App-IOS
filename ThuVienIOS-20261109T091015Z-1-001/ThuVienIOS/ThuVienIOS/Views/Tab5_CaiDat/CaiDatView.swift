//
//  CaiDatView.swift
//  ThuVienIOS
//

import SwiftUI
import SwiftData

struct CaiDatView: View {
    @Environment(\.modelContext) private var modelContext
    
    @AppStorage("tenThuVien") private var tenThuVien: String = "Thư Viện Số iOS"
    @AppStorage("soNgayMuonMacDinh") private var soNgayMuonMacDinh: Int = 14
    @AppStorage("mucPhatMoiNgay") private var mucPhatMoiNgay: Int = 5000
    @AppStorage("mucCocMacDinh") private var mucCocMacDinh: Int = 50000
    
    @State private var showingActionAlert: Bool = false
    @State private var alertMessage: String = ""
    
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
                
                // Section 3: Quản lý Dữ liệu Mẫu & Thử nghiệm
                Section(header: Text("Dữ liệu mẫu & Thử nghiệm"), footer: Text("Dữ liệu mẫu chuẩn gồm 10 đầu sách, 3 độc giả và 6 phiếu mượn khớp doanh thu 100%.")) {
                    Button {
                        SampleDataService.napDuLieuChuan10Sach(modelContext: modelContext)
                        alertMessage = "Đã nạp thành công bộ dữ liệu mẫu chuẩn gồm 10 Đầu Sách, 3 Độc Giả và 6 Phiếu Mượn!"
                        showingActionAlert = true
                    } label: {
                        Label("Nạp Dữ Liệu Mẫu Chuẩn (10 Sách, 3 Độc Giả)", systemImage: "sparkles")
                            .foregroundColor(AppTheme.primary)
                    }
                    
                    Button(role: .destructive) {
                        SampleDataService.xoaToanBoDuLieu(modelContext: modelContext)
                        alertMessage = "Đã xóa toàn bộ dữ liệu. Ứng dụng đã trở về trạng thái trống hoàn toàn!"
                        showingActionAlert = true
                    } label: {
                        Label("Xóa Sạch Dữ Liệu (Reset về App trống)", systemImage: "trash.fill")
                            .foregroundColor(AppTheme.danger)
                    }
                }
                
                // Section 4: Thông tin đồ án & Hệ thống
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
            .alert("Thông Báo", isPresented: $showingActionAlert) {
                Button("Đã hiểu", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
        }
    }
}