//
//  TaoPhieuMuonView.swift
//  ThuVienIOS
//
//  MÔ TẢ: Màn hình 3.1 - Modal Tạo Phiếu Mượn Sách (Nghiệp vụ cốt lõi Fintech)
//  LUỒNG NGHIỆP VỤ:
//  1. Chọn Đầu sách -> Hệ thống tự động lọc ra các bản sao vật lý "Sẵn sàng"
//  2. Chọn Độc giả -> Tự động nhận diện VIP để MIỄN CỌC 100% (cọc = 0đ)
//  3. Thiết lập hạn mượn (mặc định lấy theo cấu hình thư viện @AppStorage)
//  4. Quyết toán tài chính: Phí mượn + Tiền cọc = Tổng thu ban đầu
//  5. Chọn thanh toán: Tiền mặt hoặc Trừ ví tài khoản (kiểm tra số dư trước khi trừ)
//  6. Cập nhật bản sao sách sang "DangMuon" và lưu phiếu mượn vào SwiftData
//

import SwiftUI
import SwiftData

struct TaoPhieuMuonView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // MARK: - SwiftData Queries
    // Danh sách sách chưa bị ẩn, sắp xếp A-Z
    @Query(filter: #Predicate<Sach> { !$0.daAn }, sort: \Sach.tenSach)
    private var dsSach: [Sach]
    
    // Danh sách độc giả chưa bị ẩn, sắp xếp A-Z
    @Query(filter: #Predicate<DocGia> { !$0.daAn }, sort: \DocGia.hoTen)
    private var dsDocGia: [DocGia]
    
    // Tham số khởi tạo tùy chọn (khi được gọi từ Chi tiết Sách hoặc Chi tiết Độc Giả)
    var sachBanDau: Sach?
    var banSaoBanDau: BanSaoSach?
    var docGiaBanDau: DocGia?
    
    // Hạn mượn mặc định lấy từ cài đặt hệ thống
    @AppStorage("soNgayMuonMacDinh") private var soNgayMuonMacDinh: Int = 14
    
    // MARK: - Các lựa chọn trên Form
    @State private var selectedSach: Sach?
    @State private var selectedBanSao: BanSaoSach?
    @State private var selectedDocGia: DocGia?
    
    @State private var ngayMuon: Date = Date()
    @State private var soNgayMuon: Int = 14
    @State private var phuongThucThanhToan: String = "TienMat" // "TienMat" hoặc "TaiKhoan"
    
    // Cảnh báo lỗi
    @State private var thongBaoLoi: String?
    @State private var showingErrorAlert: Bool = false
    
    // Constructor hỗ trợ điền sẵn dữ liệu nếu có
    init(sachBanDau: Sach? = nil, banSaoBanDau: BanSaoSach? = nil, docGiaBanDau: DocGia? = nil) {
        self.sachBanDau = sachBanDau
        self.banSaoBanDau = banSaoBanDau
        self.docGiaBanDau = docGiaBanDau
        _selectedSach = State(initialValue: sachBanDau)
        _selectedBanSao = State(initialValue: banSaoBanDau ?? sachBanDau?.dsBanSao.first(where: { $0.tinhTrang == "SanSang" }))
        _selectedDocGia = State(initialValue: docGiaBanDau)
    }
    
    // MARK: - Thuộc tính tính toán (Computed Properties)
    
    // Lọc ra danh sách bản sao vật lý đang có tình trạng "SanSang" của đầu sách được chọn
    private var dsBanSaoKhaDung: [BanSaoSach] {
        guard let s = selectedSach else { return [] }
        return s.dsBanSao.filter { $0.tinhTrang == "SanSang" }
    }
    
    // Ngày hẹn trả dự kiến = Ngày mượn + Số ngày mượn
    private var hanTraDuKien: Date {
        Calendar.current.date(byAdding: .day, value: soNgayMuon, to: ngayMuon) ?? ngayMuon
    }
    
    // Phí mượn thực tế lấy từ sách
    private var phiMuonThucTe: Int {
        selectedSach?.phiMuon ?? 0
    }
    
    // Tiền cọc thực tế: ĐẶC QUYỀN VIP - Nếu độc giả là VIP thì tiền cọc = 0đ
    private var tienCocThucTe: Int {
        guard let sach = selectedSach else { return 0 }
        if selectedDocGia?.isVIP == true {
            return 0 // Miễn 100% tiền cọc cho Hội viên VIP
        }
        return sach.tienCoc
    }
    
    // Tổng số tiền cần thanh toán ban đầu = Cọc + Phí mượn
    private var tongThanhToan: Int {
        tienCocThucTe + phiMuonThucTe
    }

    var body: some View {
        NavigationStack {
            Form {
                // MARK: BƯỚC 1: Chọn Đầu sách & Bản sao vật lý cụ thể
                Section(header: Text("1. Chọn Sách & Bản sao")) {
                    Picker("Đầu sách", selection: $selectedSach) {
                        Text("-- Chọn đầu sách --").tag(nil as Sach?)
                        ForEach(dsSach, id: \.maSach) { s in
                            Text("\(s.tenSach) (\(s.soLuongKhaDung) còn)").tag(s as Sach?)
                        }
                    }
                    // Khi đổi đầu sách, tự động chọn bản sao sẵn sàng đầu tiên
                    .onChange(of: selectedSach) { _, _ in
                        selectedBanSao = dsBanSaoKhaDung.first
                    }
                    
                    if let sach = selectedSach {
                        if dsBanSaoKhaDung.isEmpty {
                            Text("⚠️ Hiện tại đầu sách này đã hết bản sao sẵn sàng!")
                                .font(.caption)
                                .foregroundColor(AppTheme.danger)
                        } else {
                            Picker("Bản sao vật lý", selection: $selectedBanSao) {
                                ForEach(dsBanSaoKhaDung, id: \.maDinhDanh) { bs in
                                    Text("\(bs.maDinhDanh) - \(bs.viTriKe)").tag(bs as BanSaoSach?)
                                }
                            }
                        }
                    }
                }
                
                // MARK: BƯỚC 2: Chọn Độc giả & Kiểm tra VIP / Ví tiền
                Section(header: Text("2. Thông tin Độc giả")) {
                    Picker("Độc giả", selection: $selectedDocGia) {
                        Text("-- Chọn độc giả --").tag(nil as DocGia?)
                        ForEach(dsDocGia, id: \.maDocGia) { dg in
                            Text("\(dg.hoTen) \(dg.isVIP ? "[VIP]" : "")").tag(dg as DocGia?)
                        }
                    }
                    
                    if let dg = selectedDocGia {
                        HStack {
                            Text("Hạng thẻ:")
                            Spacer()
                            Text(dg.isVIP ? "🌟 HỘI VIÊN VIP (Miễn cọc)" : "Thẻ thường")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(dg.isVIP ? .orange : AppTheme.textSecondary)
                        }
                        
                        HStack {
                            Text("Số dư ví nội bộ:")
                            Spacer()
                            Text(AppTheme.formatVND(dg.soDuTaiKhoan))
                                .font(.subheadline.bold())
                                .foregroundColor(AppTheme.primary)
                        }
                    }
                }
                
                // MARK: BƯỚC 3: Thiết lập Thời hạn mượn
                Section(header: Text("3. Thời hạn mượn")) {
                    DatePicker("Ngày bắt đầu mượn", selection: $ngayMuon, displayedComponents: .date)
                    
                    Stepper("Số ngày mượn: \(soNgayMuon) ngày", value: $soNgayMuon, in: 1...60)
                    
                    HStack {
                        Text("Hạn trả dự kiến:")
                        Spacer()
                        Text(hanTraDuKien.formatted(date: .long, time: .omitted))
                            .font(.subheadline.bold())
                            .foregroundColor(AppTheme.primary)
                    }
                }
                
                // MARK: BƯỚC 4: Bảng Thanh toán (Fintech Mini)
                Section(header: Text("4. Quyết toán chi phí")) {
                    HStack {
                        Text("Phí thuê mượn:")
                        Spacer()
                        Text(AppTheme.formatVND(phiMuonThucTe))
                    }
                    
                    HStack {
                        Text("Tiền cọc:")
                        Spacer()
                        if selectedDocGia?.isVIP == true {
                            Text("0 đ (Miễn cọc VIP)")
                                .foregroundColor(AppTheme.success)
                        } else {
                            Text(AppTheme.formatVND(tienCocThucTe))
                        }
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Tổng thu ban đầu:")
                            .font(.headline)
                        Spacer()
                        Text(AppTheme.formatVND(tongThanhToan))
                            .font(.headline)
                            .foregroundColor(AppTheme.primary)
                    }
                    
                    // Lựa chọn phương thức thanh toán
                    Picker("Phương thức thanh toán", selection: $phuongThucThanhToan) {
                        Text("💵 Tiền mặt").tag("TienMat")
                        Text("💳 Trừ ví tài khoản").tag("TaiKhoan")
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("Tạo Phiếu Mượn")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Hủy") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Xác Nhận Mượn") {
                        thucHienTaoPhieu()
                    }
                    .fontWeight(.bold)
                    .disabled(selectedSach == nil || selectedBanSao == nil || selectedDocGia == nil)
                }
            }
            .alert("Lỗi", isPresented: $showingErrorAlert) {
                Button("Đã hiểu", role: .cancel) {}
            } message: {
                Text(thongBaoLoi ?? "")
            }
            .onAppear {
                // Điền sẵn sách / độc giả nếu được truyền vào từ màn hình trước
                if let s = sachBanDau, selectedSach == nil {
                    selectedSach = s
                    selectedBanSao = banSaoBanDau ?? s.dsBanSao.first(where: { $0.tinhTrang == "SanSang" })
                }
                if let dg = docGiaBanDau, selectedDocGia == nil {
                    selectedDocGia = dg
                }
                // Đồng bộ hạn mượn theo cài đặt thư viện
                if soNgayMuon == 14 && soNgayMuonMacDinh != 14 {
                    soNgayMuon = soNgayMuonMacDinh
                }
            }
        }
    }
    
    // MARK: - Hàm nghiệp vụ cốt lõi: Tạo phiếu mượn & Xử lý thanh toán
    private func thucHienTaoPhieu() {
        guard let banSao = selectedBanSao, let docGia = selectedDocGia else {
            return
        }
        
        // 1. Kiểm tra tồn kho vật lý
        guard banSao.tinhTrang == "SanSang" else {
            thongBaoLoi = "Bản sao này không còn sẵn sàng để cho mượn."
            showingErrorAlert = true
            return
        }
        
        // 2. Nếu thanh toán qua ví nội bộ: Kiểm tra số dư tài khoản
        if phuongThucThanhToan == "TaiKhoan" {
            if docGia.soDuTaiKhoan < tongThanhToan {
                thongBaoLoi = "Số dư ví độc giả không đủ (Cần \(AppTheme.formatVND(tongThanhToan)), hiện có \(AppTheme.formatVND(docGia.soDuTaiKhoan))). Vui lòng nạp thêm tiền hoặc chọn thanh toán Tiền mặt."
                showingErrorAlert = true
                return
            }
            // Trừ số dư ví của độc giả
            docGia.soDuTaiKhoan -= tongThanhToan
        }
        
        // 3. Cập nhật trạng thái cuốn sách thành "DangMuon" (không cho mượn trùng)
        banSao.tinhTrang = "DangMuon"
        
        // 4. Khởi tạo đối tượng Phiếu Mượn và lưu vào SwiftData
        let phieuMoi = PhieuMuon(
            ngayMuon: ngayMuon,
            hanTra: hanTraDuKien,
            tienCocThucTe: tienCocThucTe,
            phiMuonThucTe: phiMuonThucTe,
            phuongThucThanhToan: phuongThucThanhToan,
            banSao: banSao,
            docGia: docGia
        )
        
        modelContext.insert(phieuMoi)
        banSao.dsPhieuMuon.append(phieuMoi)
        docGia.dsPhieuMuon.append(phieuMoi)
        
        try? modelContext.save()
        dismiss()
    }
}