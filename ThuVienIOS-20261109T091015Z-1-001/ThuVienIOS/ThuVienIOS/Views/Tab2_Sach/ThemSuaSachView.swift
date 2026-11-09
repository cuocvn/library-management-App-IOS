//
//  ThemSuaSachView.swift
//  ThuVienIOS
//

import SwiftUI
import SwiftData

struct ThemSuaSachView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // Sách cần chỉnh sửa (nếu nil là thêm mới)
    var sachCanSua: Sach?
    
    // Queries danh mục
    @Query private var dsTheLoai: [TheLoai]
    @Query private var dsNhaXuatBan: [NhaXuatBan]
    @Query private var dsTacGia: [TacGia]
    
    // Form States
    @State private var tenSach: String = ""
    @State private var namXuatBan: String = "\(Calendar.current.component(.year, from: Date()))"
    @State private var phanLoaiGiaTri: String = "Sách thường"
    @State private var tienCoc: String = "50000"
    @State private var phiMuon: String = "5000"
    
    @State private var selectedTheLoai: TheLoai?
    @State private var selectedNXB: NhaXuatBan?
    @State private var selectedTacGia: TacGia?
    
    // Tạo bản sao ban đầu khi thêm sách mới
    @State private var soLuongBanSao: Int = 1
    @State private var viTriKe: String = "Kệ A1"
    
    let danhSachPhanLoai = ["Truyện tranh", "Sách thường", "Giáo trình", "Sách quý"]
    
    var isEditMode: Bool {
        sachCanSua != nil
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Section 1: Thông tin cơ bản
                Section(header: Text("Thông tin sách")) {
                    TextField("Tên sách *", text: $tenSach)
                    
                    TextField("Năm xuất bản", text: $namXuatBan)
                        .keyboardType(.numberPad)
                    
                    // Thể loại
                    Picker("Thể loại", selection: $selectedTheLoai) {
                        Text("-- Chọn thể loại --").tag(nil as TheLoai?)
                        ForEach(dsTheLoai, id: \.maTheLoai) { tl in
                            Text(tl.tenTheLoai).tag(tl as TheLoai?)
                        }
                    }
                    
                    // Tác giả
                    Picker("Tác giả", selection: $selectedTacGia) {
                        Text("-- Chọn tác giả --").tag(nil as TacGia?)
                        ForEach(dsTacGia, id: \.maTacGia) { tg in
                            Text(tg.tenTacGia).tag(tg as TacGia?)
                        }
                    }
                    
                    // Nhà xuất bản
                    Picker("Nhà xuất bản", selection: $selectedNXB) {
                        Text("-- Chọn NXB --").tag(nil as NhaXuatBan?)
                        ForEach(dsNhaXuatBan, id: \.maNXB) { nxb in
                            Text(nxb.tenNXB).tag(nxb as NhaXuatBan?)
                        }
                    }
                }
                
                // Section 2: Định giá & Phân loại
                Section(header: Text("Định giá & Phân loại giá trị")) {
                    Picker("Phân loại", selection: $phanLoaiGiaTri) {
                        ForEach(danhSachPhanLoai, id: \.self) { loai in
                            Text(loai).tag(loai)
                        }
                    }
                    .onChange(of: phanLoaiGiaTri) { _, newValue in
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
                
                // Section 3: Khởi tạo bản sao vật lý (Chỉ hiển thị khi thêm mới)
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
                    .disabled(tenSach.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                napThongTinBanDau()
            }
        }
    }
    
    // Tự động gán cọc/phí theo phân loại giá trị chuẩn đặc tả
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
    
    private func napThongTinBanDau() {
        if let s = sachCanSua {
            tenSach = s.tenSach
            namXuatBan = "\(s.namXuatBan)"
            phanLoaiGiaTri = s.phanLoaiGiaTri
            tienCoc = "\(s.tienCoc)"
            phiMuon = "\(s.phiMuon)"
            selectedTheLoai = s.theLoai
            selectedNXB = s.nhaXuatBan
            selectedTacGia = s.tacGia
        } else {
            // Mặc định chọn thể loại, nxb, tác giả đầu tiên nếu có
            selectedTheLoai = dsTheLoai.first
            selectedNXB = dsNhaXuatBan.first
            selectedTacGia = dsTacGia.first
        }
    }
    
    private func luuSach() {
        let namXBInt = Int(namXuatBan) ?? Calendar.current.component(.year, from: Date())
        let tienCocInt = Int(tienCoc) ?? 50000
        let phiMuonInt = Int(phiMuon) ?? 5000
        
        if let s = sachCanSua {
            // Cập nhật sách hiện tại
            s.tenSach = tenSach
            s.namXuatBan = namXBInt
            s.phanLoaiGiaTri = phanLoaiGiaTri
            s.tienCoc = tienCocInt
            s.phiMuon = phiMuonInt
            s.theLoai = selectedTheLoai
            s.nhaXuatBan = selectedNXB
            s.tacGia = selectedTacGia
        } else {
            // Tạo mới sách
            let sachMoi = Sach(
                tenSach: tenSach,
                namXuatBan: namXBInt,
                phanLoaiGiaTri: phanLoaiGiaTri,
                tienCoc: tienCocInt,
                phiMuon: phiMuonInt,
                theLoai: selectedTheLoai,
                nhaXuatBan: selectedNXB,
                tacGia: selectedTacGia
            )
            modelContext.insert(sachMoi)
            
            // Tạo tiền tố mã định danh (Ví dụ: "Lập trình Swift" -> "LS")
            let words = tenSach.split(separator: " ").prefix(2)
            var prefix = words.compactMap { $0.first }.map { String($0).uppercased() }.joined()
            if prefix.isEmpty { prefix = "BK" }
            
            // Tự động sinh danh sách bản sao vật lý
            for i in 1...soLuongBanSao {
                let maCopy = String(format: "%@-%03d", prefix, i)
                let banSao = BanSaoSach(
                    maDinhDanh: maCopy,
                    viTriKe: viTriKe.isEmpty ? "Kệ A1" : viTriKe,
                    tinhTrang: "SanSang",
                    sach: sachMoi
                )
                modelContext.insert(banSao)
                sachMoi.dsBanSao.append(banSao)
            }
        }
        
        try? modelContext.save()
        dismiss()
    }
}
