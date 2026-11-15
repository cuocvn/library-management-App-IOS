//
//  TaoPhieuMuonViewController.swift
//  ThuVienIOS
//
//  MÔ TẢ: Màn hình 3.1 - Modal Tạo Phiếu Mượn Sách (Hỗ trợ VIP Miễn Cọc, Trừ Ví Số Dư)
//  CÔNG NGHỆ: UIKit, Storyboard, Auto Layout, UIPickerView / ActionSheet
//

import UIKit

class TaoPhieuMuonViewController: UIViewController {

    private var selectedSach: Sach?
    private var selectedBanSao: BanSaoSach?
    private var selectedDocGia: DocGia?
    private var soNgayMuon: Int = LibrarySettings.shared.soNgayMuonMacDinh
    private var phuongThuc: String = "TienMat" // "TienMat" hoặc "TaiKhoan"

    // UI Controls
    private let btnChonSach = UIButton(type: .system)
    private let btnChonBanSao = UIButton(type: .system)
    private let btnChonDocGia = UIButton(type: .system)
    private let segThoiHan = UISegmentedControl(items: ["3N", "7N", "10N", "14N", "20N", "30N"])
    private let segThanhToan = UISegmentedControl(items: ["Tiền mặt", "Trừ ví tài khoản"])
    private let txtGhiChu = UITextField()

    // Financial labels
    private let lblTienCoc = UILabel()
    private let lblPhiMuon = UILabel()
    private let lblTongTien = UILabel()
    private let lblVIPDiscount = UILabel()
    private let lblSoDuVi = UILabel()

    private let thoiHanValues = [3, 7, 10, 14, 20, 30]

    init(selectedSach: Sach? = nil) {
        self.selectedSach = selectedSach
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Tạo Phiếu Mượn"
        view.backgroundColor = .appBackground

        setupNavigation()
        setupUI()

        if let s = selectedSach {
            // Tự động chọn bản sao đầu tiên khả dụng
            selectedBanSao = s.dsBanSao.first { $0.tinhTrang == "SanSang" }
        }
        updateFormDisplay()
    }

    private func setupNavigation() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Hủy", style: .plain, target: self, action: #selector(huyTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Xác nhận", style: .done, target: self, action: #selector(xacNhanTapped))
    }

    private func setupUI() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -24),
            stack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])

        // 1. Chọn Đầu Sách
        configurePickerButton(btnChonSach, title: "Chọn đầu sách...", action: #selector(chonSachTapped))
        stack.addArrangedSubview(createCard(title: "1. ĐẦU SÁCH", view: btnChonSach))

        // 2. Chọn Bản Sao Vật Lý
        configurePickerButton(btnChonBanSao, title: "Chọn cuốn sách (Mã định danh)...", action: #selector(chonBanSaoTapped))
        stack.addArrangedSubview(createCard(title: "2. BẢN SAO VẬT LÝ KHẢ DỤNG", view: btnChonBanSao))

        // 3. Chọn Độc Giả
        configurePickerButton(btnChonDocGia, title: "Chọn độc giả...", action: #selector(chonDocGiaTapped))
        let dgStack = UIStackView(arrangedSubviews: [btnChonDocGia, lblSoDuVi])
        dgStack.axis = .vertical
        dgStack.spacing = 6
        lblSoDuVi.font = .systemFont(ofSize: 12)
        lblSoDuVi.textColor = .secondaryLabel
        stack.addArrangedSubview(createCard(title: "3. ĐỘC GIẢ & HẠNG THÀNH VIÊN", view: dgStack))

        // 4. Chọn Thời Hạn Mượn
        segThoiHan.selectedSegmentIndex = 3 // 14 ngày
        segThoiHan.addTarget(self, action: #selector(thoiHanChanged), for: .valueChanged)
        stack.addArrangedSubview(createCard(title: "4. THỜI HẠN MƯỢN SÁCH", view: segThoiHan))

        // 5. Bảng Tính Tài Chính
        setupFinancialCard(stack: stack)

        // 6. Phương thức thanh toán
        segThanhToan.selectedSegmentIndex = 0
        segThanhToan.addTarget(self, action: #selector(thanhToanChanged), for: .valueChanged)
        stack.addArrangedSubview(createCard(title: "6. PHƯƠNG THỨC THANH TOÁN", view: segThanhToan))

        // 7. Ghi chú
        txtGhiChu.placeholder = "Ghi chú thêm (VD: Khách đặt cọc thêm...)"
        txtGhiChu.borderStyle = .roundedRect
        txtGhiChu.font = .systemFont(ofSize: 14)
        stack.addArrangedSubview(createCard(title: "7. GHI CHÚ", view: txtGhiChu))
    }

    private func setupFinancialCard(stack: UIStackView) {
        let card = UIView()
        AppTheme.applyCardStyle(to: card)

        let titleLabel = UILabel()
        titleLabel.text = "5. CHI TIẾT TÀI CHÍNH"
        titleLabel.font = .systemFont(ofSize: 12, weight: .bold)
        titleLabel.textColor = .secondaryLabel

        lblTienCoc.font = .systemFont(ofSize: 14)
        lblTienCoc.text = "Tiền cọc: 0 đ"

        lblPhiMuon.font = .systemFont(ofSize: 14)
        lblPhiMuon.text = "Phí mượn: 0 đ"

        lblVIPDiscount.font = .systemFont(ofSize: 12, weight: .semibold)
        lblVIPDiscount.textColor = .appSuccess
        lblVIPDiscount.text = "👑 Thành viên VIP: Miễn 100% tiền cọc"
        lblVIPDiscount.isHidden = true

        let divider = UIView()
        divider.backgroundColor = .separator
        divider.heightAnchor.constraint(equalToConstant: 0.5).isActive = true

        lblTongTien.font = .systemFont(ofSize: 16, weight: .bold)
        lblTongTien.textColor = .appPrimary
        lblTongTien.text = "Tổng thanh toán: 0 đ"

        let cStack = UIStackView(arrangedSubviews: [titleLabel, lblTienCoc, lblVIPDiscount, lblPhiMuon, divider, lblTongTien])
        cStack.axis = .vertical
        cStack.spacing = 8
        cStack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(cStack)

        NSLayoutConstraint.activate([
            cStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            cStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            cStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            cStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14)
        ])

        stack.addArrangedSubview(card)
    }

    private func configurePickerButton(_ btn: UIButton, title: String, action: Selector) {
        btn.setTitle("  \(title)", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        btn.contentHorizontalAlignment = .left
        btn.backgroundColor = .systemBackground
        btn.layer.cornerRadius = 8
        btn.layer.borderWidth = 0.5
        btn.layer.borderColor = UIColor.separator.cgColor
        btn.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
        btn.addTarget(self, action: action, for: .touchUpInside)
    }

    private func createCard(title: String, view: UIView) -> UIView {
        let card = UIView()
        AppTheme.applyCardStyle(to: card)

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        titleLabel.textColor = .secondaryLabel

        let cStack = UIStackView(arrangedSubviews: [titleLabel, view])
        cStack.axis = .vertical
        cStack.spacing = 8
        cStack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(cStack)

        NSLayoutConstraint.activate([
            cStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            cStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            cStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            cStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12)
        ])
        return card
    }

    // MARK: - Actions
    @objc private func chonSachTapped() {
        let books = DataManager.shared.dsSach.filter { !$0.daAn }
        let sheet = UIAlertController(title: "Chọn đầu sách", message: nil, preferredStyle: .actionSheet)
        for b in books {
            let available = b.dsBanSao.filter { $0.tinhTrang == "SanSang" }.count
            sheet.addAction(UIAlertAction(title: "\(b.tenSach) (Còn \(available))", style: .default) { [weak self] _ in
                self?.selectedSach = b
                self?.selectedBanSao = b.dsBanSao.first { $0.tinhTrang == "SanSang" }
                self?.updateFormDisplay()
            })
        }
        sheet.addAction(UIAlertAction(title: "Hủy", style: .cancel))
        present(sheet, animated: true)
    }

    @objc private func chonBanSaoTapped() {
        guard let s = selectedSach else {
            showAlert(message: "Vui lòng chọn đầu sách trước")
            return
        }
        let availableCopies = s.dsBanSao.filter { $0.tinhTrang == "SanSang" }
        if availableCopies.isEmpty {
            showAlert(message: "Đầu sách này hiện đã hết bản sao khả dụng")
            return
        }
        let sheet = UIAlertController(title: "Chọn cuốn sách vật lý", message: nil, preferredStyle: .actionSheet)
        for c in availableCopies {
            sheet.addAction(UIAlertAction(title: "Mã: \(c.maDinhDanh) - Kệ: \(c.viTriKe)", style: .default) { [weak self] _ in
                self?.selectedBanSao = c
                self?.updateFormDisplay()
            })
        }
        sheet.addAction(UIAlertAction(title: "Hủy", style: .cancel))
        present(sheet, animated: true)
    }

    @objc private func chonDocGiaTapped() {
        let readers = DataManager.shared.dsDocGia.filter { !$0.daAn }
        let sheet = UIAlertController(title: "Chọn độc giả", message: nil, preferredStyle: .actionSheet)
        for r in readers {
            let isVIP = r.loaiThe == "VIP"
            let tag = isVIP ? "👑 VIP" : "Thường"
            sheet.addAction(UIAlertAction(title: "\(r.hoTen) (\(tag) - Ví: \(AppTheme.formatVND(r.soDuTaiKhoan)))", style: .default) { [weak self] _ in
                self?.selectedDocGia = r
                self?.updateFormDisplay()
            })
        }
        sheet.addAction(UIAlertAction(title: "Hủy", style: .cancel))
        present(sheet, animated: true)
    }

    @objc private func thoiHanChanged() {
        soNgayMuon = thoiHanValues[segThoiHan.selectedSegmentIndex]
        updateFormDisplay()
    }

    @objc private func thanhToanChanged() {
        phuongThuc = segThanhToan.selectedSegmentIndex == 0 ? "TienMat" : "TaiKhoan"
    }

    private func updateFormDisplay() {
        if let s = selectedSach {
            btnChonSach.setTitle(s.tenSach, for: .normal)
            btnChonSach.setTitleColor(.label, for: .normal)
        } else {
            btnChonSach.setTitle("Chọn đầu sách...", for: .normal)
            btnChonSach.setTitleColor(.secondaryLabel, for: .normal)
        }

        if let c = selectedBanSao {
            btnChonBanSao.setTitle("Mã: \(c.maDinhDanh) (Kệ: \(c.viTriKe))", for: .normal)
            btnChonBanSao.setTitleColor(.label, for: .normal)
        } else {
            btnChonBanSao.setTitle("Chọn cuốn sách (Mã định danh)...", for: .normal)
            btnChonBanSao.setTitleColor(.secondaryLabel, for: .normal)
        }

        if let dg = selectedDocGia {
            let isVIP = dg.loaiThe == "VIP"
            btnChonDocGia.setTitle("\(dg.hoTen) (\(isVIP ? "👑 VIP" : "Thường"))", for: .normal)
            btnChonDocGia.setTitleColor(.label, for: .normal)
            lblSoDuVi.text = "Số dư ví hiện tại: \(AppTheme.formatVND(dg.soDuTaiKhoan))"
        } else {
            btnChonDocGia.setTitle("Chọn độc giả...", for: .normal)
            btnChonDocGia.setTitleColor(.secondaryLabel, for: .normal)
            lblSoDuVi.text = ""
        }

        // Tính tiền cọc & phí
        let s = selectedSach
        let isVIP = selectedDocGia?.loaiThe == "VIP"
        let rawCoc = s?.tienCoc ?? 50000
        let thucTeCoc = isVIP ? 0 : rawCoc
        let phi = s?.phiMuon ?? 10000
        let tong = thucTeCoc + phi

        lblTienCoc.text = "Tiền cọc: \(AppTheme.formatVND(thucTeCoc)) \(isVIP ? "(Gốc \(AppTheme.formatVND(rawCoc)))" : "")"
        lblVIPDiscount.isHidden = !isVIP
        lblPhiMuon.text = "Phí mượn (\(soNgayMuon) ngày): \(AppTheme.formatVND(phi))"
        lblTongTien.text = "Tổng thanh toán: \(AppTheme.formatVND(tong))"
    }

    @objc private func huyTapped() {
        dismiss(animated: true)
    }

    @objc private func xacNhanTapped() {
        guard let s = selectedSach, let c = selectedBanSao, let dg = selectedDocGia else {
            showAlert(message: "Vui lòng chọn đầy đủ Sách, Bản sao và Độc giả")
            return
        }

        let isVIP = dg.loaiThe == "VIP"
        let thucTeCoc = isVIP ? 0 : s.tienCoc
        let phi = s.phiMuon
        let tongThu = thucTeCoc + phi

        // Kiểm tra số dư nếu chọn thanh toán trừ ví
        if phuongThuc == "TaiKhoan" {
            if dg.soDuTaiKhoan < tongThu {
                showAlert(message: "Số dư tài khoản ví của độc giả (\(AppTheme.formatVND(dg.soDuTaiKhoan))) không đủ để thanh toán \(AppTheme.formatVND(tongThu)). Vui lòng nạp thêm tiền hoặc chọn thanh toán Tiền mặt.")
                return
            }
            // Trừ tiền ví
            dg.soDuTaiKhoan -= tongThu
        }

        // Cập nhật tình trạng bản sao sang DangMuon
        c.tinhTrang = "DangMuon"

        let calendar = Calendar.current
        let ngayMuon = Date()
        let hanTra = calendar.date(byAdding: .day, value: soNgayMuon, to: ngayMuon) ?? ngayMuon

        let pm = PhieuMuon(
            ngayMuon: ngayMuon,
            hanTra: hanTra,
            tienCocThucTe: thucTeCoc,
            phiMuonThucTe: phi,
            phuongThucThanhToan: phuongThuc,
            ghiChu: txtGhiChu.text,
            banSao: c,
            docGia: dg
        )

        DataManager.shared.themPhieuMuon(pm)
        dismiss(animated: true)
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Thông báo", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
