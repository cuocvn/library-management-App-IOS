//
//  TraSachViewController.swift
//  ThuVienIOS
//
//  MÔ TẢ: Màn hình 3.2 - Trả Sách, Tính Phạt Snapshot & Quyết Toán Dòng Tiền (Check-in & Refund)
//  CÔNG NGHỆ: UIKit, Storyboard, Auto Layout, Snapshot Financial Calculations
//

import UIKit

class TraSachViewController: UIViewController {

    private let phieuMuon: PhieuMuon

    private var ngayTraThucTe: Date = Date()
    private var soNgayTre: Int = 0
    private var tienPhat: Int = 0
    private var tienHoanLai: Int = 0
    private var phuongThucHoan: String = "TienMat" // "TienMat" hoặc "TaiKhoan"

    // UI Controls
    private let dpNgayTra = UIDatePicker()
    private let segHoanTien = UISegmentedControl(items: ["Tiền mặt", "Cộng vào ví độc giả"])
    private let txtGhiChu = UITextField()

    // Financial Display Labels
    private let lblNgayTre = UILabel()
    private let lblTienCoc = UILabel()
    private let lblTienPhat = UILabel()
    private let lblQuyetToan = UILabel()
    private let btnXacNhan = UIButton(type: .system)

    init(phieuMuon: PhieuMuon) {
        self.phieuMuon = phieuMuon
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Trả Sách & Quyết Toán"
        view.backgroundColor = .appBackground

        setupNavigation()
        setupUI()
        tinhToanTaiChinh()
    }

    private func setupNavigation() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Đóng", style: .plain, target: self, action: #selector(dongTapped))
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

        // 1. Thẻ Thông Tin Phiếu
        setupInfoCard(stack: stack)

        // Nếu đã trả rồi thì chỉ hiển thị thông tin snapshot
        if phieuMuon.ngayTra != nil {
            setupDaTraCard(stack: stack)
            return
        }

        // 2. Chọn Ngày Trả Thực Tế
        dpNgayTra.datePickerMode = .date
        dpNgayTra.preferredDatePickerStyle = .compact
        dpNgayTra.date = Date()
        dpNgayTra.addTarget(self, action: #selector(ngayTraChanged), for: .valueChanged)
        stack.addArrangedSubview(createCard(title: "NGÀY TRẢ SÁCH THỰC TẾ", view: dpNgayTra))

        // 3. Khối Quyết Toán Tài Chính
        setupSettlementCard(stack: stack)

        // 4. Phương thức hoàn tiền
        segHoanTien.selectedSegmentIndex = 0
        segHoanTien.addTarget(self, action: #selector(hoanTienChanged), for: .valueChanged)
        stack.addArrangedSubview(createCard(title: "PHƯƠNG THỨC HOÀN TIỀN CỌC / NỘP PHẠT", view: segHoanTien))

        // 5. Ghi chú
        txtGhiChu.placeholder = "Ghi chú trả sách (VD: Sách còn nguyên vẹn...)"
        txtGhiChu.borderStyle = .roundedRect
        txtGhiChu.font = .systemFont(ofSize: 14)
        stack.addArrangedSubview(createCard(title: "GHI CHÚ", view: txtGhiChu))

        // 6. Nút Xác Nhận
        btnXacNhan.setTitle("✓ Xác Nhận Trả Sách & Hoàn Cọc", for: .normal)
        btnXacNhan.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        btnXacNhan.backgroundColor = .appSuccess
        btnXacNhan.setTitleColor(.white, for: .normal)
        btnXacNhan.layer.cornerRadius = 12
        btnXacNhan.translatesAutoresizingMaskIntoConstraints = false
        btnXacNhan.heightAnchor.constraint(equalToConstant: 50).isActive = true
        btnXacNhan.addTarget(self, action: #selector(xacNhanTraTapped), for: .touchUpInside)
        stack.addArrangedSubview(btnXacNhan)
    }

    private func setupInfoCard(stack: UIStackView) {
        let card = UIView()
        AppTheme.applyCardStyle(to: card)

        let bookTitle = phieuMuon.banSao?.sach?.tenSach ?? "Chưa rõ sách"
        let copyCode = phieuMuon.banSao?.maDinhDanh ?? ""
        let readerName = phieuMuon.docGia?.hoTen ?? "Khách"
        let ngayMuonStr = AppTheme.formatDate(phieuMuon.ngayMuon)
        let hanTraStr = AppTheme.formatDate(phieuMuon.hanTra)

        let lblTitle = UILabel()
        lblTitle.text = bookTitle
        lblTitle.font = .systemFont(ofSize: 16, weight: .bold)
        lblTitle.numberOfLines = 2

        let lblMeta = UILabel()
        lblMeta.text = "Mã bản sao: \(copyCode) • Độc giả: \(readerName)\nNgày mượn: \(ngayMuonStr) ➔ Hạn trả: \(hanTraStr)"
        lblMeta.font = .systemFont(ofSize: 13)
        lblMeta.textColor = .secondaryLabel
        lblMeta.numberOfLines = 2

        let cStack = UIStackView(arrangedSubviews: [lblTitle, lblMeta])
        cStack.axis = .vertical
        cStack.spacing = 6
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

    private func setupSettlementCard(stack: UIStackView) {
        let card = UIView()
        AppTheme.applyCardStyle(to: card)

        let titleLabel = UILabel()
        titleLabel.text = "QUYẾT TOÁN TÀI CHÍNH (SNAPSHOT BẤT BIẾN)"
        titleLabel.font = .systemFont(ofSize: 12, weight: .bold)
        titleLabel.textColor = .secondaryLabel

        lblTienCoc.font = .systemFont(ofSize: 14)
        lblNgayTre.font = .systemFont(ofSize: 14)
        lblTienPhat.font = .systemFont(ofSize: 14)

        let divider = UIView()
        divider.backgroundColor = .separator
        divider.heightAnchor.constraint(equalToConstant: 0.5).isActive = true

        lblQuyetToan.font = .systemFont(ofSize: 16, weight: .bold)

        let cStack = UIStackView(arrangedSubviews: [titleLabel, lblTienCoc, lblNgayTre, lblTienPhat, divider, lblQuyetToan])
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

    private func setupDaTraCard(stack: UIStackView) {
        let card = UIView()
        AppTheme.applyCardStyle(to: card)

        let icon = UIImageView(image: UIImage(systemName: "checkmark.seal.fill"))
        icon.tintColor = .appSuccess
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.heightAnchor.constraint(equalToConstant: 44).isActive = true

        let lbl = UILabel()
        lbl.text = "Phiếu này đã hoàn tất trả sách\nNgày trả: \(AppTheme.formatDate(phieuMuon.ngayTra!))\nPhạt: \(AppTheme.formatVND(phieuMuon.tienPhat ?? 0))"
        lbl.font = .systemFont(ofSize: 14, weight: .medium)
        lbl.textAlignment = .center
        lbl.numberOfLines = 3

        let cStack = UIStackView(arrangedSubviews: [icon, lbl])
        cStack.axis = .vertical
        cStack.spacing = 8
        cStack.alignment = .center
        cStack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(cStack)

        NSLayoutConstraint.activate([
            cStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            cStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            cStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            cStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])
        stack.addArrangedSubview(card)
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

    // MARK: - Calculations
    @objc private func ngayTraChanged() {
        ngayTraThucTe = dpNgayTra.date
        tinhToanTaiChinh()
    }

    @objc private func hoanTienChanged() {
        phuongThucHoan = segHoanTien.selectedSegmentIndex == 0 ? "TienMat" : "TaiKhoan"
    }

    private func tinhToanTaiChinh() {
        let mucPhatMoiNgay = LibrarySettings.shared.mucPhatMoiNgay
        let calendar = Calendar.current
        let d1 = calendar.startOfDay(for: phieuMuon.hanTra)
        let d2 = calendar.startOfDay(for: ngayTraThucTe)

        let diff = calendar.dateComponents([.day], from: d1, to: d2).day ?? 0
        soNgayTre = max(0, diff)
        tienPhat = soNgayTre * mucPhatMoiNgay
        tienHoanLai = phieuMuon.tienCocThucTe - tienPhat

        lblTienCoc.text = "1. Tiền cọc đã giữ: +\(AppTheme.formatVND(phieuMuon.tienCocThucTe))"
        if soNgayTre > 0 {
            lblNgayTre.text = "2. Trễ hạn: \(soNgayTre) ngày (Mức phạt: \(AppTheme.formatVND(mucPhatMoiNgay))/ngày)"
            lblNgayTre.textColor = .appDanger
            lblTienPhat.text = "3. Tiền phạt khấu trừ: -\(AppTheme.formatVND(tienPhat))"
            lblTienPhat.textColor = .appDanger
        } else {
            lblNgayTre.text = "2. Đúng hạn (0 ngày trễ)"
            lblNgayTre.textColor = .appSuccess
            lblTienPhat.text = "3. Tiền phạt: 0 đ"
            lblTienPhat.textColor = .appSuccess
        }

        if tienHoanLai >= 0 {
            lblQuyetToan.text = "➔ HOÀN LẠI KHÁCH: \(AppTheme.formatVND(tienHoanLai))"
            lblQuyetToan.textColor = .appSuccess
            btnXacNhan.setTitle("✓ Hoàn lại \(AppTheme.formatVND(tienHoanLai)) & Nhận sách", for: .normal)
            btnXacNhan.backgroundColor = .appSuccess
        } else {
            let noptThem = abs(tienHoanLai)
            lblQuyetToan.text = "➔ KHÁCH CẦN NỘP THÊM: \(AppTheme.formatVND(noptThem))"
            lblQuyetToan.textColor = .appDanger
            btnXacNhan.setTitle("⚠️ Thu thêm \(AppTheme.formatVND(noptThem)) & Nhận sách", for: .normal)
            btnXacNhan.backgroundColor = .appDanger
        }
    }

    @objc private func dongTapped() {
        dismiss(animated: true)
    }

    @objc private func xacNhanTraTapped() {
        let alert = UIAlertController(title: "Xác nhận trả sách", message: "Quyết toán hoàn tiền: \(AppTheme.formatVND(tienHoanLai)). Xác nhận hoàn tất phiếu mượn?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Hủy", style: .cancel))
        alert.addAction(UIAlertAction(title: "Xác nhận", style: .default) { [weak self] _ in
            self?.thucHienTraSach()
        })
        present(alert, animated: true)
    }

    private func thucHienTraSach() {
        // Ghi snapshot tài chính bất biến vào Phiếu mượn
        phieuMuon.ngayTra = ngayTraThucTe
        phieuMuon.soNgayTre = soNgayTre
        phieuMuon.tienPhat = tienPhat
        phieuMuon.phuongThucHoanTien = phuongThucHoan
        if let note = txtGhiChu.text, !note.isEmpty {
            phieuMuon.ghiChu = (phieuMuon.ghiChu ?? "") + " [Trả sách: \(note)]"
        }

        // Đổi trạng thái bản sao sách về "SanSang"
        phieuMuon.banSao?.tinhTrang = "SanSang"

        // Xử lý hoàn tiền vào ví nếu chọn ví
        if phuongThucHoan == "TaiKhoan", let dg = phieuMuon.docGia {
            dg.soDuTaiKhoan += tienHoanLai
        }

        DataManager.shared.save()
        dismiss(animated: true)
    }
}
