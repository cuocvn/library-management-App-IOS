//
//  TaoPhieuMuonView.swift
//  ThuVienIOS
//
//  MÔ TẢ: Màn hình 3.1 - Modal Tạo Phiếu Mượn Sách (Nghiệp vụ cốt lõi Fintech)
//  LUỒNG NGHIỆP VỤ NÂNG CAO:
//  1. Chọn Đầu sách & Bản sao vật lý cụ thể ("SanSang")
//  2. Chọn Độc giả -> Tự động nhận diện VIP (số dư > 0 đ) để MIỄN CỌC 100% (cọc = 0đ)
//  3. Thiết lập Gói Mượn: 3 ngày, 7 ngày, 10 ngày, 20 ngày, 1 tháng (30 ngày)
//  4. Mức giá: Hệ thống tự gợi ý theo gói ngày VÀ cho phép TỰ ĐIỀN / SỬA TAY mức phí & tiền cọc
//  5. Thanh toán TIỀN MẶT: Tách bạch rõ Tiền Cọc (đã thu trước) + Phí Mượn, tự động ghi chú (Note) vào phiếu
//  6. Thanh toán VÍ: Kiểm tra số dư ví và trừ tiền tự động
//

import SwiftUI
import SwiftData

struct TaoPhieuMuonView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // MARK: - SwiftData Queries
    @Query(filter: #Predicate<Sach> { !$0.daAn }, sort: \Sach.tenSach)
    private var dsSach: [Sach]
    
    @Query(filter: #Predicate<DocGia> { !$0.daAn }, sort: \DocGia.hoTen)
    private var dsDocGia: [DocGia]
    
    // Tham số khởi tạo tùy chọn (khi mở từ Chi tiết Sách hoặc Chi tiết Độc Giả)
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
    @State private var soNgayMuon: Int = 7
    
    // Trường nhập tay giá tiền (Linh hoạt: tự động gợi ý hoặc tự điền số tiền)
    @State private var phiMuonNhapTay: String = ""
    @State private var tienCocNhapTay: String = ""
    @State private var ghiChuNhapTay: String = ""
    
    @State private var phuongThucThanhToan: String = "TienMat" // "TienMat" hoặc "TaiKhoan"
    
    // Cảnh báo lỗi
    @State private var thongBaoLoi: String?
    @State private var showingErrorAlert: Bool = false
    
    // Các gói thời hạn mượn định sẵn
    let cacGoiThoiHan: [(ten: String, soNgay: Int, heSo: Double)] = [
        ("3 ngày", 3, 0.7),
        ("7 ngày", 7, 1.0),
        ("10 ngày", 10, 1.3),
        ("20 ngày", 20, 2.0),
        ("1 tháng", 30, 2.5)
    ]
    
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
    
    // Danh sách bản sao có tình trạng "SanSang"
    private var dsBanSaoKhaDung: [BanSaoSach] {
        guard let s = selectedSach else { return [] }
        return s.dsBanSao.filter { $0.tinhTrang == "SanSang" }
    }
    
    // Ngày hẹn trả dự kiến = Ngày mượn + Số ngày mượn
    private var hanTraDuKien: Date {
        Calendar.current.date(byAdding: .day, value: soNgayMuon, to: ngayMuon) ?? ngayMuon
    }
    
    // Phí mượn hiệu lực (ưu tiên số người dùng nhập tay, nếu trống thì tính theo gợi ý)
    private var phiMuonHieuLuc: Int {
        if let custom = Int(phiMuonNhapTay) {
            return max(0, custom)
        }
        guard let sach = selectedSach else { return 0 }
        // Tỷ lệ theo ngày mượn: 7 ngày là chuẩn (hệ số 1.0)
        let heSo = max(0.5, Double(soNgayMuon) / 7.0)
        return max(1000, Int(round(Double(sach.phiMuon) * heSo / 1000) * 1000))
    }
    
    // Tiền cọc hiệu lực (Hội viên VIP tự động = 0đ, hoặc người dùng nhập tay)
    private var tienCocHieuLuc: Int {
        if let custom = Int(tienCocNhapTay) {
            return max(0, custom)
        }
        guard let sach = selectedSach else { return 0 }
        if selectedDocGia?.isVIP == true {
            return 0 // Miễn 100% tiền cọc cho Hội viên VIP
        }
        return sach.tienCoc
    }
    
    // Tổng số tiền cần thanh toán ban đầu = Cọc + Phí mượn
    private var tongThanhToan: Int {
        tienCocHieuLuc + phiMuonHieuLuc
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
                    .onChange(of: selectedSach) { _, newSach in
                        selectedBanSao = dsBanSaoKhaDung.first
                        capNhatGiaGoi(soNgay: soNgayMuon)
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
                
                // MARK: BƯỚC 2: Chọn Độc giả & Nhận diện VIP (Viền Vàng / Thường Viền Xám)
                Section(header: Text("2. Thông tin Độc giả")) {
                    Picker("Độc giả", selection: $selectedDocGia) {
                        Text("-- Chọn độc giả --").tag(nil as DocGia?)
                        ForEach(dsDocGia, id: \.maDocGia) { dg in
                            Text("\(dg.hoTen) \(dg.isVIP ? "🌟 [VIP]" : "")").tag(dg as DocGia?)
                        }
                    }
                    .onChange(of: selectedDocGia) { _, newDg in
                        if newDg?.isVIP == true {
                            tienCocNhapTay = "0"
                        } else if let s = selectedSach {
                            tienCocNhapTay = String(s.tienCoc)
                        }
                    }
                    
                    if let dg = selectedDocGia {
                        HStack {
                            Text("Hạng độc giả:")
                            Spacer()
                            if dg.isVIP {
                                HStack(spacing: 4) {
                                    Image(systemName: "crown.fill")
                                        .foregroundColor(.orange)
                                    Text("VIP (Viền vàng - Miễn cọc)")
                                        .font(.subheadline.bold())
                                        .foregroundColor(.orange)
                                }
                            } else {
                                Text("Thẻ thường (Viền xám - Có cọc)")
                                    .font(.subheadline)
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                        }
                        
                        HStack {
                            Text("Số dư ví nội bộ:")
                            Spacer()
                            Text(AppTheme.formatVND(dg.soDuTaiKhoan))
                                .font(.subheadline.bold())
                                .foregroundColor(dg.isVIP ? .orange : AppTheme.primary)
                        }
                    }
                }
                
                // MARK: BƯỚC 3: Chọn Gói Thời Hạn Mượn (3 ngày, 7 ngày, 10 ngày, 20 ngày, 1 tháng)
                Section(header: Text("3. Gói thời hạn mượn"), footer: Text("Bấm chọn gói mượn nhanh hoặc tùy chỉnh số ngày. Hệ thống sẽ tự động cập nhật mức giá tương ứng.")) {
                    DatePicker("Ngày bắt đầu mượn", selection: $ngayMuon, displayedComponents: .date)
                    
                    // Chips chọn nhanh các gói ngày
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Chọn gói mượn nhanh:")
                            .font(.caption)
                            .foregroundColor(AppTheme.textSecondary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(cacGoiThoiHan, id: \.soNgay) { goi in
                                    Button {
                                        soNgayMuon = goi.soNgay
                                        capNhatGiaGoi(soNgay: goi.soNgay)
                                    } label: {
                                        Text(goi.ten)
                                            .font(.caption.bold())
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 8)
                                            .background(soNgayMuon == goi.soNgay ? AppTheme.primary : Color.gray.opacity(0.12))
                                            .foregroundColor(soNgayMuon == goi.soNgay ? .white : AppTheme.textPrimary)
                                            .cornerRadius(10)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                    
                    Stepper("Số ngày mượn: \(soNgayMuon) ngày", value: $soNgayMuon, in: 1...90)
                        .onChange(of: soNgayMuon) { _, newVal in
                            capNhatGiaGoi(soNgay: newVal)
                        }
                    
                    HStack {
                        Text("Hạn trả dự kiến:")
                        Spacer()
                        Text(hanTraDuKien.formatted(date: .long, time: .omitted))
                            .font(.subheadline.bold())
                            .foregroundColor(AppTheme.primary)
                    }
                }
                
                // MARK: BƯỚC 4: Bảng Thanh Toán & Cho Phép Tự Điền Giá
                Section(header: Text("4. Quyết toán chi phí (Có thể tự điền giá)"), footer: Text("Bạn có thể để giá gợi ý theo gói hoặc TỰ ĐIỀN số tiền theo mong muốn.")) {
                    // Ô tự điền hoặc xem phí mượn
                    HStack {
                        Text("Phí thuê mượn:")
                        Spacer()
                        TextField("0", text: $phiMuonNhapTay)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .font(.subheadline.bold())
                            .foregroundColor(AppTheme.textPrimary)
                            .frame(maxWidth: 120)
                        Text("đ")
                    }
                    
                    // Ô tự điền hoặc xem tiền cọc
                    HStack {
                        Text("Tiền cọc giữ lại:")
                        Spacer()
                        if selectedDocGia?.isVIP == true && tienCocNhapTay.isEmpty {
                            Text("0 đ (Miễn cọc VIP)")
                                .foregroundColor(AppTheme.success)
                        } else {
                            TextField("0", text: $tienCocNhapTay)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .font(.subheadline.bold())
                                .foregroundColor(AppTheme.textPrimary)
                                .frame(maxWidth: 120)
                            Text("đ")
                        }
                    }
                    
                    Divider()
                    
                    // Phương thức thanh toán
                    Picker("Phương thức thanh toán", selection: $phuongThucThanhToan) {
                        Text("💵 Tiền mặt").tag("TienMat")
                        Text("💳 Trừ ví tài khoản").tag("TaiKhoan")
                    }
                    .pickerStyle(.segmented)
                    
                    // Chi tiết thanh toán Tiền Mặt / Ví
                    if phuongThucThanhToan == "TienMat" {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("• Tiền cọc đã thu trước:")
                                Spacer()
                                Text(AppTheme.formatVND(tienCocHieuLuc))
                                    .fontWeight(.medium)
                            }
                            HStack {
                                Text("• Phí mượn thu ngay:")
                                Spacer()
                                Text(AppTheme.formatVND(phiMuonHieuLuc))
                                    .fontWeight(.medium)
                            }
                            HStack {
                                Text("Tổng tiền mặt thu lúc giao sách:")
                                    .font(.headline)
                                Spacer()
                                Text(AppTheme.formatVND(tongThanhToan))
                                    .font(.headline)
                                    .foregroundColor(AppTheme.primary)
                            }
                        }
                        .padding(10)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(10)
                    } else {
                        HStack {
                            Text("Tổng trừ từ ví nội bộ:")
                                .font(.headline)
                            Spacer()
                            Text(AppTheme.formatVND(tongThanhToan))
                                .font(.headline)
                                .foregroundColor(AppTheme.primary)
                        }
                    }
                }
                
                // MARK: BƯỚC 5: Ghi Chú / Note Phiếu Mượn
                Section(header: Text("5. Ghi chú phiếu mượn (Lưu vào hồ sơ)"), footer: Text("Ghi chú này sẽ được lưu cố định vào phiếu mượn để quản lý và đối soát sau này.")) {
                    TextField("Nhập ghi chú thêm (VD: Đã thu cọc tiền mặt)", text: $ghiChuNhapTay)
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
                
                // Khởi tạo mức giá ban đầu
                capNhatGiaGoi(soNgay: soNgayMuon)
                if selectedDocGia?.isVIP == true {
                    tienCocNhapTay = "0"
                } else if let s = selectedSach {
                    tienCocNhapTay = String(s.tienCoc)
                }
            }
        }
    }
    
    // MARK: - Hàm cập nhật giá gợi ý theo số ngày mượn
    private func capNhatGiaGoi(soNgay: Int) {
        guard let s = selectedSach else { return }
        // Tỷ lệ gợi ý theo gói ngày
        let heSo: Double
        switch soNgay {
        case ...3:
            heSo = 0.7
        case 4...7:
            heSo = 1.0
        case 8...10:
            heSo = 1.3
        case 11...20:
            heSo = 2.0
        default: // 21...30+
            heSo = 2.5
        }
        let giaGoiY = max(1000, Int(round(Double(s.phiMuon) * heSo / 1000) * 1000))
        phiMuonNhapTay = String(giaGoiY)
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
        
        // 4. Tạo ghi chú phiếu mượn tự động
        var note = ghiChuNhapTay.trimmingCharacters(in: .whitespaces)
        if phuongThucThanhToan == "TienMat" {
            let noteTienMat = "Tiền mặt: Thu cọc \(AppTheme.formatVND(tienCocHieuLuc)) + Phí \(AppTheme.formatVND(phiMuonHieuLuc)) (Gói \(soNgayMuon) ngày)."
            note = note.isEmpty ? noteTienMat : "\(note) | \(noteTienMat)"
        } else {
            let noteVí = "Trừ ví: \(AppTheme.formatVND(tongThanhToan)) (Gói \(soNgayMuon) ngày)."
            note = note.isEmpty ? noteVí : "\(note) | \(noteVí)"
        }
        
        // 5. Khởi tạo đối tượng Phiếu Mượn và lưu vào SwiftData
        let phieuMoi = PhieuMuon(
            ngayMuon: ngayMuon,
            hanTra: hanTraDuKien,
            tienCocThucTe: tienCocHieuLuc,
            phiMuonThucTe: phiMuonHieuLuc,
            phuongThucThanhToan: phuongThucThanhToan,
            ghiChu: note,
            daBaoMatSach: false,
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
