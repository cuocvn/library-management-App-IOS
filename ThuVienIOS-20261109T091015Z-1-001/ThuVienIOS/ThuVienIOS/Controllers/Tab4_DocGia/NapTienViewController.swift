//
//  NapTienViewController.swift
//  ThuVienIOS
//
//  MÔ TẢ: Màn hình 4.1.1 - Nạp Tiền Vào Ví Điện Tử Độc Giả (Mệnh Giá Nhanh 50k - 500k)
//  CÔNG NGHỆ: UIKit, Storyboard, Auto Layout, Fintech Transaction
//

import UIKit

class NapTienViewController: UIViewController {

    private let docGia: DocGia

    private let txtSoTien = UITextField()
    private let txtGhiChu = UITextField()
    private let lblSoDuHienTai = UILabel()
    private let lblSoDuSauNap = UILabel()

    private let menhGia = [50000, 100000, 200000, 500000]

    init(docGia: DocGia) {
        self.docGia = docGia
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Nạp Tiền Vào Ví"
        view.backgroundColor = .appBackground

        setupNavigation()
        setupUI()
        updatePreview()
    }

    private func setupNavigation() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Hủy", style: .plain, target: self, action: #selector(huyTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Nạp ngay", style: .done, target: self, action: #selector(napTienTapped))
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

        // 1. Thẻ Số Dư Hiện Tại
        setupBalanceCard(stack: stack)

        // 2. Mệnh giá nhanh (2 hàng x 2 cột)
        setupQuickAmounts(stack: stack)

        // 3. Nhập số tiền tùy chọn
        txtSoTien.placeholder = "Hoặc nhập số tiền khác (VNĐ)..."
        txtSoTien.keyboardType = .numberPad
        txtSoTien.borderStyle = .roundedRect
        txtSoTien.font = .systemFont(ofSize: 15)
        txtSoTien.addTarget(self, action: #selector(soTienChanged), for: .editingChanged)
        stack.addArrangedSubview(createCard(title: "NHẬP SỐ TIỀN TÙY CHỈNH", view: txtSoTien))

        // 4. Ghi chú nạp tiền
        txtGhiChu.placeholder = "Ghi chú (VD: Chuyển khoản, tiền mặt...)"
        txtGhiChu.borderStyle = .roundedRect
        txtGhiChu.font = .systemFont(ofSize: 15)
        stack.addArrangedSubview(createCard(title: "GHI CHÚ GIAO DỊCH", view: txtGhiChu))

        // 5. Nút Xác Nhận Nạp
        let btnConfirm = UIButton(type: .system)
        btnConfirm.setTitle("💳 Xác Nhận Nạp Tiền", for: .normal)
        btnConfirm.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        btnConfirm.backgroundColor = .appSuccess
        btnConfirm.setTitleColor(.white, for: .normal)
        btnConfirm.layer.cornerRadius = 12
        btnConfirm.translatesAutoresizingMaskIntoConstraints = false
        btnConfirm.heightAnchor.constraint(equalToConstant: 50).isActive = true
        btnConfirm.addTarget(self, action: #selector(napTienTapped), for: .touchUpInside)
        stack.addArrangedSubview(btnConfirm)
    }

    private func setupBalanceCard(stack: UIStackView) {
        let card = UIView()
        AppTheme.applyCardStyle(to: card)

        let titleLabel = UILabel()
        titleLabel.text = "ĐỘC GIẢ: \(docGia.hoTen)"
        titleLabel.font = .systemFont(ofSize: 13, weight: .bold)
        titleLabel.textColor = .label

        lblSoDuHienTai.text = "Số dư hiện tại: \(AppTheme.formatVND(docGia.soDuTaiKhoan))"
        lblSoDuHienTai.font = .systemFont(ofSize: 14)
        lblSoDuHienTai.textColor = .secondaryLabel

        lblSoDuSauNap.font = .systemFont(ofSize: 16, weight: .bold)
        lblSoDuSauNap.textColor = .appSuccess

        let cStack = UIStackView(arrangedSubviews: [titleLabel, lblSoDuHienTai, lblSoDuSauNap])
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

    private func setupQuickAmounts(stack: UIStackView) {
        let card = UIView()
        AppTheme.applyCardStyle(to: card)

        let titleLabel = UILabel()
        titleLabel.text = "CHỌN MỆNH GIÁ NHANH"
        titleLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        titleLabel.textColor = .secondaryLabel

        let btn50k = createAmountButton(amount: 50000)
        let btn100k = createAmountButton(amount: 100000)
        let btn200k = createAmountButton(amount: 200000)
        let btn500k = createAmountButton(amount: 500000)

        let row1 = UIStackView(arrangedSubviews: [btn50k, btn100k])
        row1.axis = .horizontal
        row1.distribution = .fillEqually
        row1.spacing = 10

        let row2 = UIStackView(arrangedSubviews: [btn200k, btn500k])
        row2.axis = .horizontal
        row2.distribution = .fillEqually
        row2.spacing = 10

        let grid = UIStackView(arrangedSubviews: [titleLabel, row1, row2])
        grid.axis = .vertical
        grid.spacing = 10
        grid.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(grid)

        NSLayoutConstraint.activate([
            grid.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            grid.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            grid.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            grid.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12)
        ])
        stack.addArrangedSubview(card)
    }

    private func createAmountButton(amount: Int) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle("+\(AppTheme.formatVND(amount))", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        btn.backgroundColor = UIColor.appPrimary.withAlphaComponent(0.08)
        btn.setTitleColor(.appPrimary, for: .normal)
        btn.layer.cornerRadius = 8
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.appPrimary.withAlphaComponent(0.3).cgColor
        btn.heightAnchor.constraint(equalToConstant: 40).isActive = true
        btn.tag = amount
        btn.addTarget(self, action: #selector(quickAmountTapped(_:)), for: .touchUpInside)
        return btn
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

    @objc private func quickAmountTapped(_ sender: UIButton) {
        txtSoTien.text = "\(sender.tag)"
        updatePreview()
    }

    @objc private func soTienChanged() {
        updatePreview()
    }

    private func updatePreview() {
        let amount = Int(txtSoTien.text ?? "") ?? 0
        let newTotal = docGia.soDuTaiKhoan + amount
        lblSoDuSauNap.text = "➔ Số dư sau nạp: \(AppTheme.formatVND(newTotal))"
    }

    @objc private func huyTapped() {
        dismiss(animated: true)
    }

    @objc private func napTienTapped() {
        guard let amount = Int(txtSoTien.text ?? ""), amount > 0 else {
            let alert = UIAlertController(title: "Lỗi", message: "Vui lòng nhập số tiền hợp lệ lớn hơn 0", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        docGia.soDuTaiKhoan += amount
        // Tự động nâng hạng VIP nếu nạp số dư lớn (VD >= 100.000 đ)
        if docGia.soDuTaiKhoan >= 100000 && docGia.loaiThe != "VIP" {
            docGia.loaiThe = "VIP"
        }

        DataManager.shared.save()
        dismiss(animated: true)
    }
}
