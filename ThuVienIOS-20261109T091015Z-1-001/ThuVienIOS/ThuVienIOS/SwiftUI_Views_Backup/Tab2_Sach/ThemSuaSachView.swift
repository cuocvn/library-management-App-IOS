//
//  ThemSuaSachView.swift
//  ThuVienIOS
//
//  MÔ TẢ: Màn hình 2.2 - Form Thêm Mới hoặc Chỉnh Sửa Sách
//  TÍNH NĂNG ĐẶC BIỆT CHO SINH VIÊN:
//  - Tự động gợi ý mức Tiền cọc & Phí mượn theo phân loại giá trị (Truyện tranh, Sách thường, Giáo trình, Sách quý)
//  - Tự động sinh hàng loạt mã bản sao vật lý ban đầu (VD: người dùng chọn 3 cuốn -> tự tạo CC-001, CC-002, CC-003)
//

import SwiftUI

struct ThemSuaSachView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var dataManager: DataManager
    
    // Sách cần chỉnh sửa (nếu nil là thêm mới hoàn toàn)
    var sachCanSua: Sach?
    
    // Danh mục có sẵn để người dùng chọn Picker
    private var dsTheLoai: [TheLoai] { dataManager.dsTheLoai }
    private var dsNhaXuatBan: [NhaXuatBan] { dataManager.dsNXB }
    private var dsTacGia: [TacGia] { dataManager.dsTacGia }
    
    // MARK: - Các trường nhập liệu của Form
    @State private var tenSach: String = ""
    @State private var namXuatBan: String = "\(Calendar.current.component(.year, from: Date()))"
    @State private var phanLoaiGiaTri: String = "Sách thường"
    @State private var tienCoc: String = "50000"
    @State private var phiMuon: String = "5000"
    
    @State private var selectedTheLoai: TheLoai?
    @State private var selectedNXB: NhaXuatBan?
    @State private var selectedTacGia: TacGia?
    
    // Nhập nhanh trực tiếp Thể loại / Tác giả / NXB mới bằng tay
    @State private var theLoaiMoiNhapTay: String = ""
    @State private var tacGiaMoiNhapTay: String = ""
    @State private var nxbMoiNhapTay: String = ""
    
    // Khởi tạo số lượng bản sao ban đầu khi thêm sách mới
    @State private var soLuongBanSao: Int = 1
    @State private var viTriKe: String = "Kệ A1"
    
    let danhSachPhanLoai = ["Truyện tranh", "Sách thường", "Giáo trình", "Sách quý"]
    
    // Kiểm tra xem đang ở chế độ Sửa hay Thêm mới
    var isEditMode: Bool {
        sachCanSua != nil
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // MARK: Section 1 - Thông tin cơ bản
                Section(header: Text("Thông tin sách")) {
                    TextField("Tên sách *", text: $tenSach)
                    
                    TextField("Năm xuất bản", text: $namXuatBan)
                        .keyboardType(.numberPad)
                    
                    // Chọn Thể loại
                    VStack(alignment: .leading, spacing: 6) {
                        Picker("Thể loại", selection: $selectedTheLoai) {
                            Text("-- Chọn thể loại --").tag(nil as TheLoai?)
                            ForEach(dsTheLoai, id: \.maTheLoai) { tl in
                                Text(tl.tenTheLoai).tag(tl as TheLoai?)
                            }
                        }
                        
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(AppTheme.primary)
                                .font(.subheadline)
                            TextField("Hoặc gõ tên thể loại mới...", text: $theLoaiMoiNhapTay)
                                .font(.subheadline)
                            if !theLoaiMoiNhapTay.trimmingCharacters(in: .whitespaces).isEmpty {
                                Button("Thêm") {
                                    let tl = dataManager.layHoacTaoTheLoai(theLoaiMoiNhapTay)
                                    selectedTheLoai = tl
                                    theLoaiMoiNhapTay = ""
                                }
                                .font(.caption.bold())
                                .buttonStyle(.borderless)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(AppTheme.primary)
                                .foregroundColor(.white)
                                .cornerRadius(6)
                            }
                        }
                        .padding(.top, 2)
                    }
                    
                    // Chọn Tác giả
                    VStack(alignment: .leading, spacing: 6) {
                        Picker("Tác giả", selection: $selectedTacGia) {
                            Text("-- Chọn tác giả --").tag(nil as TacGia?)
                            ForEach(dsTacGia, id: \.maTacGia) { tg in
                                Text(tg.tenTacGia).tag(tg as TacGia?)
                            }
                        }
                        
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(AppTheme.primary)
                                .font(.subheadline)
                            TextField("Hoặc gõ tên tác giả mới...", text: $tacGiaMoiNhapTay)
                                .font(.subheadline)
                            if !tacGiaMoiNhapTay.trimmingCharacters(in: .whitespaces).isEmpty {
                                Button("Thêm") {
                                    let tg = dataManager.layHoacTaoTacGia(tacGiaMoiNhapTay)
                                    selectedTacGia = tg
                                    tacGiaMoiNhapTay = ""
                                }
                                .font(.caption.bold())
                                .buttonStyle(.borderless)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(AppTheme.primary)
                                .foregroundColor(.white)
                                .cornerRadius(6)
                            }
                        }
                        .padding(.top, 2)
                    }
                    
                    // Chọn Nhà xuất bản
                    VStack(alignment: .leading, spacing: 6) {
                        Picker("Nhà xuất bản", selection: $selectedNXB) {
                            Text("-- Chọn NXB --").tag(nil as NhaXuatBan?)
                            ForEach(dsNhaXuatBan, id: \.maNXB) { nxb in
                                Text(nxb.tenNXB).tag(nxb as NhaXuatBan?)
                            }
                        }
                        
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(AppTheme.primary)
                                .font(.subheadline)
                            TextField("Hoặc gõ tên NXB mới...", text: $nxbMoiNhapTay)
                                .font(.subheadline)
                            if !nxbMoiNhapTay.trimmingCharacters(in: .whitespaces).isEmpty {
                                Button("Thêm") {
                                    let nxb = dataManager.layHoacTaoNXB(nxbMoiNhapTay)
                                    selectedNXB = nxb
                                    nxbMoiNhapTay = ""
                                }
                                .font(.caption.bold())
                                .buttonStyle(.borderless)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(AppTheme.primary)
                                .foregroundColor(.white)
                                .cornerRadius(6)
                            }
                        }
                        .padding(.top, 2)
                    }
                }
                
                // MARK: Section 2 - Định giá & Phân loại giá trị
                Section(header: Text("Định giá & Phân loại giá trị")) {
                    Picker("Phân loại", selection: $phanLoaiGiaTri) {
                        ForEach(danhSachPhanLoai, id: \.self) { loai in
                            Text(loai).tag(loai)
                        }
                    }
                    // Tự động gán mức cọc và phí mượn khi phân loại giá trị thay đổi
                    .onChange(of: phanLoaiGiaTri) { newValue in
                        tuDongGanGia(theo: newValue)
                    }
                    
                    HStack {
                        Text("Tiền cọc:")
                        Spacer()
                        TextField("VNĐ", text: $tienCoc)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        Text("đ")
                    }
                    
                    HStack {
                        Text("Phí mượn:")
                        Spacer()
                        TextField("VNĐ", text: $phiMuon)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        Text("đ")
                    }
                }
                
                // MARK: Section 3 - Khởi tạo bản sao vật lý (Chỉ hiển thị khi thêm mới)
                if !isEditMode {
                    Section(header: Text("Khởi tạo bản sao vật lý ban đầu"), footer: Text("Hệ thống sẽ tự động sinh mã bản sao (VD: CC-001, CC-002...) tương ứng.")) {
                        Stepper("Số lượng bản sao: \(soLuongBanSao)", value: $soLuongBanSao, in: 1...50)
                        
                        TextField("Vị trí kệ ban đầu (VD: Kệ A1, Dãy B2)", text: $viTriKe)
                    }
                }
            }
            .navigationTitle(isEditMode ? "Sửa Sách" : "Thêm Sách Mới")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Hủy") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Lưu") {
                        luuSach()
                    }
                    .fontWeight(.semibold)
                    // Bắt buộc phải có tên sách mới cho lưu
                    .disabled(tenSach.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                napThongTinBanDau()
            }
        }
    }
    
    // MARK: - Hàm tự động gán cọc/phí theo phân loại giá trị sách chuẩn quy định
    private func tuDongGanGia(theo loai: String) {
        switch loai {
        case "Truyện tranh":
            tienCoc = "60000"
            phiMuon = "8000"
        case "Giáo trình":
            tienCoc = "120000"
            phiMuon = "15000"
        case "Sách quý":
            tienCoc = "200000"
            phiMuon = "30000"
        default: // Sách thường
            tienCoc = "50000"
            phiMuon = "5000"
        }
    }
    
    // MARK: - Nạp dữ liệu ban đầu vào các ô Text
    private func napThongTinBanDau() {
        if let s = sachCanSua {
            // Nạp dữ liệu cũ của sách cần sửa
            tenSach = s.tenSach
            namXuatBan = "\(s.namXuatBan)"
            phanLoaiGiaTri = s.phanLoaiGiaTri
            tienCoc = "\(s.tienCoc)"
            phiMuon = "\(s.phiMuon)"
            selectedTheLoai = s.theLoai
            selectedNXB = s.nhaXuatBan
            selectedTacGia = s.tacGia
        } else {
            // Khi tạo mới: Mặc định chọn mục đầu tiên nếu có
            selectedTheLoai = dsTheLoai.first
            selectedNXB = dsNhaXuatBan.first
            selectedTacGia = dsTacGia.first
        }
    }
    
    // MARK: - Lưu sách vào DataManager (Lưu file JSON)
    private func luuSach() {
        let namXBInt = Int(namXuatBan) ?? Calendar.current.component(.year, from: Date())
        let tienCocInt = Int(tienCoc) ?? 50000
        let phiMuonInt = Int(phiMuon) ?? 5000
        
        // Tự động kiểm tra: Nếu người dùng có gõ Thể loại mới thì tạo ngay và ưu tiên dùng
        var finalTheLoai = selectedTheLoai
        if !theLoaiMoiNhapTay.trimmingCharacters(in: .whitespaces).isEmpty {
            finalTheLoai = dataManager.layHoacTaoTheLoai(theLoaiMoiNhapTay)
        }
        
        // Tự động kiểm tra: Nếu người dùng có gõ Tác giả mới thì tạo ngay và ưu tiên dùng
        var finalTacGia = selectedTacGia
        if !tacGiaMoiNhapTay.trimmingCharacters(in: .whitespaces).isEmpty {
            finalTacGia = dataManager.layHoacTaoTacGia(tacGiaMoiNhapTay)
        }
        
        // Tự động kiểm tra: Nếu người dùng có gõ NXB mới thì tạo ngay và ưu tiên dùng
        var finalNXB = selectedNXB
        if !nxbMoiNhapTay.trimmingCharacters(in: .whitespaces).isEmpty {
            finalNXB = dataManager.layHoacTaoNXB(nxbMoiNhapTay)
        }
        
        if let s = sachCanSua {
            // Bước 1: Cập nhật thông tin sách hiện tại
            s.tenSach = tenSach
            s.namXuatBan = namXBInt
            s.phanLoaiGiaTri = phanLoaiGiaTri
            s.tienCoc = tienCocInt
            s.phiMuon = phiMuonInt
            s.theLoai = finalTheLoai
            s.nhaXuatBan = finalNXB
            s.tacGia = finalTacGia
            dataManager.save()
        } else {
            // Bước 2: Tạo đối tượng Sách mới
            let sachMoi = Sach(
                tenSach: tenSach,
                namXuatBan: namXBInt,
                phanLoaiGiaTri: phanLoaiGiaTri,
                tienCoc: tienCocInt,
                phiMuon: phiMuonInt,
                theLoai: finalTheLoai,
                nhaXuatBan: finalNXB,
                tacGia: finalTacGia
            )
            
            // Bước 3: Tạo tiền tố mã định danh từ 2 từ đầu (VD: "Lập trình" -> "LT")
            let words = tenSach.split(separator: " ").prefix(2)
            var prefix = words.compactMap { $0.first }.map { String($0).uppercased() }.joined()
            if prefix.isEmpty { prefix = "BK" }
            
            // Bước 4: Tự động sinh hàng loạt các cuốn bản sao vật lý ban đầu
            for i in 1...soLuongBanSao {
                let maCopy = String(format: "%@-%03d", prefix, i)
                let banSao = BanSaoSach(
                    maDinhDanh: maCopy,
                    viTriKe: viTriKe.isEmpty ? "Kệ A1" : viTriKe,
                    tinhTrang: "SanSang",
                    sach: sachMoi
                )
                sachMoi.dsBanSao.append(banSao)
            }
            dataManager.themSach(sachMoi)
        }
        
        dismiss()
    }
}