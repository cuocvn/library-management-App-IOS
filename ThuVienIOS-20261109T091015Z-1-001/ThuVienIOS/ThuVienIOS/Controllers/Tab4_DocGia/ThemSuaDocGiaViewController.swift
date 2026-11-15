//
//  ThemSuaDocGiaViewController.swift
//  ThuVienIOS
//
//  MÔ TẢ: Màn hình 4.2 - Form Thêm Mới / Sửa Thông Tin Độc Giả & Hạng Hội Viên VIP
//  CÔNG NGHỆ: UIKit, Storyboard, Form Style Auto Layout
//

import UIKit

enum DocGiaFormMode {
    case them
    case sua(DocGia)
}

class ThemSuaDocGiaViewController: UIViewController {

    private let mode: DocGiaFormMode

    private let txtHoTen = UITextField()
    private let txtSDT = UITextField()
    private let txtEmail = UITextField()
    private let txtLopKhoa = UITextField()
    private let segLoaiThe = UISegmentedControl(items: ["Thẻ Thường", "👑 Hội Viên VIP"])

    init(mode: DocGiaFormMode) {
        self.mode = mode
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.mode = .them
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        populateData()
    }

    private func setupUI() {
        switch mode {
        case .them: title = "Thêm Độc Giả"
        case .sua: title = "Sửa Độc Giả"
        }
        view.backgroundColor = .appBackground

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Hủy", style: .plain, target: self, action: #selector(huyTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Lưu", style: .done, target: self, action: #selector(luuTapped))

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

        stack.addArrangedSubview(createCard(title: "HỌ VÀ TÊN (*)", view: setupTextField(txtHoTen, placeholder: "VD: Nguyễn Văn A")))

        txtSDT.keyboardType = .phonePad
        stack.addArrangedSubview(createCard(title: "SỐ ĐIỆN THOẠI (*)", view: setupTextField(txtSDT, placeholder: "VD: 0912345678")))

        txtEmail.keyboardType = .emailAddress
        txtEmail.autocapitalizationType = .none
        stack.addArrangedSubview(createCard(title: "EMAIL", view: setupTextField(txtEmail, placeholder: "VD: docgia@gmail.com")))

        stack.addArrangedSubview(createCard(title: "LỚP / KHÓA / PHÒNG BAN", view: setupTextField(txtLopKhoa, placeholder: "VD: K64-CNTT, CNTT1...")))

        segLoaiThe.selectedSegmentIndex = 0
        stack.addArrangedSubview(createCard(title: "HẠNG THÀNH VIÊN (VIP ĐƯỢC MIỄN TIỀN CỌC)", view: segLoaiThe))
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

    private func setupTextField(_ tf: UITextField, placeholder: String) -> UITextField {
        tf.placeholder = placeholder
        tf.borderStyle = .roundedRect
        tf.font = .systemFont(ofSize: 15)
        tf.backgroundColor = .systemBackground
        return tf
    }

    private func populateData() {
        if case let .sua(dg) = mode {
            txtHoTen.text = dg.hoTen
            txtSDT.text = dg.soDienThoai
            txtEmail.text = dg.email
            txtLopKhoa.text = dg.lopKhoa
            segLoaiThe.selectedSegmentIndex = dg.loaiThe == "VIP" ? 1 : 0
        }
    }

    @objc private func huyTapped() {
        dismiss(animated: true)
    }

    @objc private func luuTapped() {
        let hoTen = txtHoTen.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let sdt = txtSDT.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if hoTen.isEmpty || sdt.isEmpty {
            let alert = UIAlertController(title: "Thông báo", message: "Vui lòng nhập họ tên và số điện thoại", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        let loaiThe = segLoaiThe.selectedSegmentIndex == 1 ? "VIP" : "Thuong"
        let email = txtEmail.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let lop = txtLopKhoa.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        switch mode {
        case .them:
            let moi = DocGia(hoTen: hoTen, email: email, soDienThoai: sdt, lopKhoa: lop, loaiThe: loaiThe)
            DataManager.shared.themDocGia(moi)
        case let .sua(dg):
            dg.hoTen = hoTen
            dg.soDienThoai = sdt
            dg.email = email
            dg.lopKhoa = lop
            dg.loaiThe = loaiThe
            DataManager.shared.save()
        }

        dismiss(animated: true)
    }
}
