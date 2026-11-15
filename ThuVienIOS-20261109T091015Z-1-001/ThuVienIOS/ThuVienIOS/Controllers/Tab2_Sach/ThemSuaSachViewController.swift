//
//  ThemSuaSachViewController.swift
//  ThuVienIOS
//
//  MÔ TẢ: Màn hình 2.2 - Form Thêm Mới / Chỉnh Sửa Đầu Sách & Tự Động Sinh Bản Sao
//  CÔNG NGHỆ: UIKit, Storyboard, UITableView Form Style, UIPickerView
//

import UIKit

enum SachFormMode {
    case them
    case sua(Sach)
}

class ThemSuaSachViewController: UIViewController {

    private let mode: SachFormMode

    // Form inputs
    private let txtTenSach = UITextField()
    private let txtTheLoai = UITextField()
    private let txtTacGia = UITextField()
    private let txtNXB = UITextField()
    private let txtNamXB = UITextField()
    private let segPhanLoai = UISegmentedControl(items: ["Truyện", "Thường", "Giáo trình", "Quý"])
    private let txtSoLuong = UITextField()
    private let txtViTriKe = UITextField()

    private let lblTienCoc = UILabel()
    private let lblPhiMuon = UILabel()

    private let phanLoaiValues = ["Truyện tranh", "Sách thường", "Giáo trình", "Sách quý"]

    init(mode: SachFormMode) {
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
        updateGiaTri()
    }

    private func setupUI() {
        switch mode {
        case .them: title = "Thêm Sách Mới"
        case .sua: title = "Sửa Đầu Sách"
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

        // Form Fields
        stack.addArrangedSubview(createCard(title: "TÊN ĐẦU SÁCH", view: setupTextField(txtTenSach, placeholder: "VD: Lập trình iOS với Swift")))
        stack.addArrangedSubview(createCard(title: "THỂ LOẠI (Gõ để chọn hoặc thêm mới)", view: setupTextField(txtTheLoai, placeholder: "VD: Công nghệ, Văn học...")))
        stack.addArrangedSubview(createCard(title: "TÁC GIẢ (Gõ để chọn hoặc thêm mới)", view: setupTextField(txtTacGia, placeholder: "VD: Nguyễn Nhật Ánh")))
        stack.addArrangedSubview(createCard(title: "NHÀ XUẤT BẢN", view: setupTextField(txtNXB, placeholder: "VD: NXB Trẻ, NXB Kim Đồng...")))

        txtNamXB.keyboardType = .numberPad
        stack.addArrangedSubview(createCard(title: "NĂM XUẤT BẢN", view: setupTextField(txtNamXB, placeholder: "VD: 2024")))

        // Phân loại giá trị
        segPhanLoai.selectedSegmentIndex = 1
        segPhanLoai.addTarget(self, action: #selector(phanLoaiChanged), for: .valueChanged)
        stack.addArrangedSubview(createCard(title: "PHÂN LOẠI GIÁ TRỊ (TỰ ĐỘNG TÍNH CỌC & PHÍ)", view: segPhanLoai))

        // Giá cọc và phí hiển thị
        let pricingStack = UIStackView(arrangedSubviews: [lblTienCoc, lblPhiMuon])
        pricingStack.axis = .horizontal
        pricingStack.distribution = .fillEqually
        lblTienCoc.font = .systemFont(ofSize: 14, weight: .semibold)
        lblTienCoc.textColor = .appPrimary
        lblPhiMuon.font = .systemFont(ofSize: 14, weight: .semibold)
        lblPhiMuon.textColor = .appWarning
        lblPhiMuon.textAlignment = .right
        stack.addArrangedSubview(createCard(title: "BẢNG GIÁ DỰ TÍNH", view: pricingStack))

        // Số lượng & Kệ sách
        if case .them = mode {
            txtSoLuong.keyboardType = .numberPad
            txtSoLuong.text = "3"
            stack.addArrangedSubview(createCard(title: "SỐ LƯỢNG BẢN SAO BAN ĐẦU", view: setupTextField(txtSoLuong, placeholder: "Số lượng bản sao (VD: 3)")))

            txtViTriKe.text = "Kệ A1"
            stack.addArrangedSubview(createCard(title: "VỊ TRÍ KỆ MẶC ĐỊNH", view: setupTextField(txtViTriKe, placeholder: "VD: Kệ A1, Tủ B2...")))
        }
    }

    private func createCard(title: String, view: UIView) -> UIView {
        let card = UIView()
        AppTheme.applyCardStyle(to: card)

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        titleLabel.textColor = .secondaryLabel

        let container = UIStackView(arrangedSubviews: [titleLabel, view])
        container.axis = .vertical
        container.spacing = 8
        container.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(container)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            container.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            container.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            container.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12)
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
        if case let .sua(sach) = mode {
            txtTenSach.text = sach.tenSach
            txtTheLoai.text = sach.theLoai?.tenTheLoai ?? ""
            txtTacGia.text = sach.tacGia?.tenTacGia ?? ""
            txtNXB.text = sach.nhaXuatBan?.tenNXB ?? ""
            txtNamXB.text = "\(sach.namXuatBan)"
            if let idx = phanLoaiValues.firstIndex(of: sach.phanLoaiGiaTri) {
                segPhanLoai.selectedSegmentIndex = idx
            }
        } else {
            txtNamXB.text = "\(Calendar.current.component(.year, from: Date()))"
        }
    }

    @objc private func phanLoaiChanged() {
        updateGiaTri()
    }

    private func updateGiaTri() {
        let phanLoai = phanLoaiValues[segPhanLoai.selectedSegmentIndex]
        let (coc, phi) = tinhTienCocVaPhi(phanLoai: phanLoai)
        lblTienCoc.text = "Cọc: \(AppTheme.formatVND(coc))"
        lblPhiMuon.text = "Phí: \(AppTheme.formatVND(phi))"
    }

    private func tinhTienCocVaPhi(phanLoai: String) -> (coc: Int, phi: Int) {
        switch phanLoai {
        case "Truyện tranh": return (30000, 5000)
        case "Sách thường": return (50000, 10000)
        case "Giáo trình": return (80000, 15000)
        case "Sách quý": return (150000, 30000)
        default: return (50000, 10000)
        }
    }

    @objc private func huyTapped() {
        dismiss(animated: true)
    }

    @objc private func luuTapped() {
        let ten = txtTenSach.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if ten.isEmpty {
            showAlert(message: "Vui lòng nhập tên sách")
            return
        }

        let dm = DataManager.shared
        let phanLoai = phanLoaiValues[segPhanLoai.selectedSegmentIndex]
        let (coc, phi) = tinhTienCocVaPhi(phanLoai: phanLoai)
        let namXB = Int(txtNamXB.text ?? "") ?? 2024

        // Tìm hoặc tạo Thể loại, Tác giả, NXB
        let tenTL = txtTheLoai.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let theLoai = !tenTL.isEmpty ? dm.layHoacTaoTheLoai(tenTL) : nil

        let tenTG = txtTacGia.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let tacGia = !tenTG.isEmpty ? dm.layHoacTaoTacGia(tenTG) : nil

        let tenNXB = txtNXB.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let nxb = !tenNXB.isEmpty ? dm.layHoacTaoNXB(tenNXB) : nil

        switch mode {
        case .them:
            let moi = Sach(
                tenSach: ten,
                namXuatBan: namXB,
                phanLoaiGiaTri: phanLoai,
                tienCoc: coc,
                phiMuon: phi,
                theLoai: theLoai,
                nhaXuatBan: nxb,
                tacGia: tacGia
            )

            // Tự động sinh bản sao vật lý
            let count = max(1, Int(txtSoLuong.text ?? "3") ?? 3)
            let ke = txtViTriKe.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Kệ A1"
            let prefix = ten.split(separator: " ").compactMap { $0.first }.prefix(3).map { String($0).uppercased() }.joined()
            let maPrefix = prefix.isEmpty ? "BK" : prefix

            for i in 1...count {
                let code = "\(maPrefix)-\(String(format: "%03d", i))"
                let bs = BanSaoSach(maDinhDanh: code, viTriKe: ke, tinhTrang: "SanSang", sach: moi)
                moi.dsBanSao.append(bs)
            }

            dm.themSach(moi)

        case let .sua(sach):
            sach.tenSach = ten
            sach.namXuatBan = namXB
            sach.phanLoaiGiaTri = phanLoai
            sach.tienCoc = coc
            sach.phiMuon = phi
            sach.theLoai = theLoai
            sach.tacGia = tacGia
            sach.nhaXuatBan = nxb
            dm.save()
        }

        dismiss(animated: true)
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Thông báo", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
