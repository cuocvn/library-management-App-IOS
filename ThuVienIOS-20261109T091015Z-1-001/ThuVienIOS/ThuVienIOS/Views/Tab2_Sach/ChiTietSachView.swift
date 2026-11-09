//
//  ChiTietSachView.swift
//  ThuVienIOS
//

import SwiftUI
import SwiftData

struct ChiTietSachView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var sach: Sach
    
    @State private var showingEditSheet: Bool = false
    @State private var showingAddCopyAlert: Bool = false
    @State private var maBanSaoMoi: String = ""
    @State private var viTriKeMoi: String = "Kệ A1"
    
    // Bản sao cần sửa trạng thái
    @State private var banSaoCanSua: BanSaoSach?
    @State private var showingTrangThaiSheet: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // Card 1: Thẻ thông tin tổng quan đầu sách
                VStack(spacing: 14) {
                    HStack(alignment: .top, spacing: 16) {
                        // Icon bìa sách
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(AppTheme.primary.opacity(0.1))
                                .frame(width: 80, height: 110)
                            Image(systemName: "book.closed.fill")
                                .font(.system(size: 40))
                                .foregroundColor(AppTheme.primary)
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text(sach.tenSach)
                                .font(.headline.weight(.bold))
                                .foregroundColor(AppTheme.textPrimary)
                                .lineLimit(2)
                            
                            HStack(spacing: 4) {
                                Image(systemName: "person.fill")
                                    .font(.caption2)
                                Text(sach.tacGia?.tenTacGia ?? "Chưa rõ tác giả")
                                    .font(.subheadline)
                            }
                            .foregroundColor(AppTheme.textSecondary)
                            
                            HStack(spacing: 4) {
                                Image(systemName: "building.2.fill")
                                    .font(.caption2)
                                Text(sach.nhaXuatBan?.tenNXB ?? "NXB Chưa cập nhật")
                                    .font(.caption)
                            }
                            .foregroundColor(AppTheme.textSecondary)
                            
                            HStack(spacing: 6) {
                                Text(sach.theLoai?.tenTheLoai ?? "Thể loại chung")
                                    .font(.caption2.weight(.medium))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(6)
                                
                                Text(sach.phanLoaiGiaTri)
                                    .font(.caption2.weight(.medium))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(Color.purple.opacity(0.1))
                                    .foregroundColor(.purple)
                                    .cornerRadius(6)
                            }
                        }
                        Spacer()
                    }
                    
                    Divider()
                    
                    // Huy hiệu tài chính & Tồn kho
                    HStack(spacing: 12) {
                        VStack(spacing: 2) {
                            Text("Tiền cọc")
                                .font(.caption2)
                                .foregroundColor(AppTheme.textSecondary)
                            Text(AppTheme.formatVND(sach.tienCoc))
                                .font(.subheadline.bold())
                                .foregroundColor(AppTheme.primary)
                        }
                        .frame(maxWidth: .infinity)
                        
                        Divider().frame(height: 24)
                        
                        VStack(spacing: 2) {
                            Text("Phí mượn")
                                .font(.caption2)
                                .foregroundColor(AppTheme.textSecondary)
                            Text(AppTheme.formatVND(sach.phiMuon))
                                .font(.subheadline.bold())
                                .foregroundColor(AppTheme.warning)
                        }
                        .frame(maxWidth: .infinity)
                        
                        Divider().frame(height: 24)
                        
                        VStack(spacing: 2) {
                            Text("Khả dụng")
                                .font(.caption2)
                                .foregroundColor(AppTheme.textSecondary)
                            Text("\(sach.soLuongKhaDung)/\(sach.tongSoBanSao)")
                                .font(.subheadline.bold())
                                .foregroundColor(sach.soLuongKhaDung > 0 ? AppTheme.success : AppTheme.danger)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(16)
                .background(AppTheme.cardBackground)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppTheme.borderSubtle, lineWidth: 0.5)
                )
                .padding(.horizontal)
                
                // Section 2: Quản lý Bản Sao Vật Lý (USP cốt lõi của đồ án)
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Bản Sao Vật Lý")
                                .font(.headline)
                                .foregroundColor(AppTheme.textPrimary)
                            Text("Quản lý vị trí từng cuốn sách thực tế")
                                .font(.caption)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        Spacer()
                        Button {
                            // Tạo mã tự động gợi ý cho bản sao mới
                            let count = sach.dsBanSao.count + 1
                            let prefix = String(sach.tenSach.prefix(2)).uppercased()
                            maBanSaoMoi = String(format: "%@-%03d", prefix, count)
                            showingAddCopyAlert = true
                        } label: {
                            Label("Thêm bản", systemImage: "plus.circle.fill")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(AppTheme.primary)
                        }
                    }
                    
                    if sach.dsBanSao.isEmpty {
                        Text("Chưa có bản sao vật lý nào cho đầu sách này.")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
                            .padding(.vertical, 8)
                    } else {
                        ForEach(sach.dsBanSao, id: \.maDinhDanh) { banSao in
                            HStack(spacing: 12) {
                                Image(systemName: "barcode.viewfinder")
                                    .font(.title3)
                                    .foregroundColor(AppTheme.primary)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    HStack(spacing: 8) {
                                        Text(banSao.maDinhDanh)
                                            .font(.subheadline.weight(.bold))
                                            .foregroundColor(AppTheme.textPrimary)
                                        
                                        BadgeTinhTrang(tinhTrang: banSao.tinhTrang)
                                    }
                                    
                                    HStack(spacing: 4) {
                                        Image(systemName: "mappin.and.ellipse")
                                            .font(.caption2)
                                        Text(banSao.viTriKe)
                                            .font(.caption)
                                    }
                                    .foregroundColor(AppTheme.textSecondary)
                                }
                                
                                Spacer()
                                
                                // Menu đổi trạng thái bản sao
                                Menu {
                                    Button("Sẵn sàng") {
                                        banSao.tinhTrang = "SanSang"
                                        try? modelContext.save()
                                    }
                                    Button("Đang mượn") {
                                        banSao.tinhTrang = "DangMuon"
                                        try? modelContext.save()
                                    }
                                    Button("Hỏng / Thất lạc") {
                                        banSao.tinhTrang = "Hong"
                                        try? modelContext.save()
                                    }
                                    Divider()
                                    Button("Xóa bản sao này", role: .destructive) {
                                        if let index = sach.dsBanSao.firstIndex(where: { $0.maDinhDanh == banSao.maDinhDanh }) {
                                            sach.dsBanSao.remove(at: index)
                                        }
                                        modelContext.delete(banSao)
                                        try? modelContext.save()
                                    }
                                } label: {
                                    Image(systemName: "ellipsis.circle")
                                        .font(.title3)
                                        .foregroundColor(AppTheme.textSecondary)
                                        .padding(4)
                                }
                            }
                            .padding(.vertical, 6)
                            
                            if banSao.maDinhDanh != sach.dsBanSao.last?.maDinhDanh {
                                Divider()
                            }
                        }
                    }
                }
                .padding(16)
                .background(AppTheme.cardBackground)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppTheme.borderSubtle, lineWidth: 0.5)
                )
                .padding(.horizontal)
                
                // Section 3: Lịch sử các lần mượn của đầu sách này
                VStack(alignment: .leading, spacing: 12) {
                    Text("Lịch Sử Mượn Đầu Sách")
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    let lichSuMuon = sach.dsBanSao.flatMap { $0.dsPhieuMuon }
                    
                    if lichSuMuon.isEmpty {
                        Text("Chưa có lịch sử mượn trả nào cho cuốn sách này.")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
                            .padding(.vertical, 4)
                    } else {
                        ForEach(lichSuMuon, id: \.maPhieu) { pm in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(pm.docGia?.hoTen ?? "Độc giả không xác định")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundColor(AppTheme.textPrimary)
                                    Text("Bản: \(pm.banSao?.maDinhDanh ?? "") • Hạn: \(pm.hanTra.formatted(date: .numeric, time: .omitted))")
                                        .font(.caption)
                                        .foregroundColor(AppTheme.textSecondary)
                                }
                                Spacer()
                                Text(pm.tinhTrangHienThi)
                                    .font(.caption.weight(.medium))
                                    .foregroundColor(pm.daTra ? AppTheme.success : (pm.isQuaHan ? AppTheme.danger : AppTheme.primary))
                            }
                            .padding(.vertical, 4)
                            Divider()
                        }
                    }
                }
                .padding(16)
                .background(AppTheme.cardBackground)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppTheme.borderSubtle, lineWidth: 0.5)
                )
                .padding(.horizontal)
                
                Spacer(minLength: 20)
            }
            .padding(.vertical)
        }
        .background(AppTheme.primaryBackground.ignoresSafeArea())
        .navigationTitle("Chi Tiết Sách")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Sửa") {
                    showingEditSheet = true
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            ThemSuaSachView(sachCanSua: sach)
        }
        // Alert thêm bản sao vật lý mới
        .alert("Thêm Bản Sao Mới", isPresented: $showingAddCopyAlert) {
            TextField("Mã bản sao (VD: CC-004)", text: $maBanSaoMoi)
            TextField("Vị trí kệ (VD: Kệ A1-04)", text: $viTriKeMoi)
            Button("Thêm") {
                if !maBanSaoMoi.trimmingCharacters(in: .whitespaces).isEmpty {
                    let moi = BanSaoSach(
                        maDinhDanh: maBanSaoMoi.trimmingCharacters(in: .whitespaces).uppercased(),
                        viTriKe: viTriKeMoi.isEmpty ? "Kệ A1" : viTriKeMoi,
                        tinhTrang: "SanSang",
                        sach: sach
                    )
                    modelContext.insert(moi)
                    sach.dsBanSao.append(moi)
                    try? modelContext.save()
                }
            }
            Button("Hủy", role: .cancel) {}
        }
    }
}

// Widget Badge Trạng Thái Bản Sao
struct BadgeTinhTrang: View {
    let tinhTrang: String
    
    var body: some View {
        Group {
            switch tinhTrang {
            case "SanSang":
                Text("Sẵn sàng")
                    .font(.system(size: 11, weight: .semibold))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(AppTheme.success.opacity(0.12))
                    .foregroundColor(AppTheme.success)
            case "DangMuon":
                Text("Đang mượn")
                    .font(.system(size: 11, weight: .semibold))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(AppTheme.primary.opacity(0.12))
                    .foregroundColor(AppTheme.primary)
            default: // Hong
                Text("Hỏng")
                    .font(.system(size: 11, weight: .semibold))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(AppTheme.danger.opacity(0.12))
                    .foregroundColor(AppTheme.danger)
            }
        }
        .cornerRadius(4)
    }
}
