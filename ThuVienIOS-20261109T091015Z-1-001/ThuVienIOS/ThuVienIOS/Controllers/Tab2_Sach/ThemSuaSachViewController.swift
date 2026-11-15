//
//  ThemSuaSachViewController.swift
//  ThuVienIOS
//
//  MÔ TẢ: Màn hình 2.2 - Form Thêm Mới / Sửa Đầu Sách, Chọn Ảnh Bìa (UIImagePickerController)
//  GIẢNG VIÊN: Tiêu Kim Cương - Lập trình Di động trên iOS (Chương 2)
//

import UIKit

enum SachFormMode {
    case them
    case sua(Sach)
}

class ThemSuaSachViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: - Properties
    private let mode: SachFormMode

    // Ảnh bìa sách và Gesture chọn ảnh (Chương 2 - Slide 34)
    private let imgCover = UIImageView()
    private var selectedImage: UIImage?

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

    // Callback trả dữ liệu về màn hình trước (chuẩn getBackData trong slide thầy)
    var getBackData: ((Sach) -> Void)?

    init(mode: SachFormMode) {
        self.mode = mode
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.mode = .them
        super.init(coder: coder)
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        populateData()
        updateGiaTri()
    }

    // MARK: - Setup UI
    private func setupUI() {
        switch mode {
        case .them: title = "Thêm Sách Mới"
        case .sua: title = "Sửa Đầu Sách"
        }
        view.backgroundColor = .appBackground

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Hủy", style: .plain, target: self, action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Lưu", style: .done, target: self, action: #selector(saveTapped))

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

        // 1. Thẻ chọn ảnh bìa sách (UITapGestureRecognizer + UIImagePickerController)
        setupCoverImageCard(stack: stack)

        // 2. Form Fields
        stack.addArrangedSubview(createCard(title: "TÊN ĐẦU SÁCH (*)", view: setupTextField(txtTenSach, placeholder: "VD: Lập trình iOS với Swift")))
        stack.addArrangedSubview(createCard(title: "THỂ LOẠI (Gõ để chọn hoặc thêm mới)", view: setupTextField(txtTheLoai, placeholder: "VD: Công nghệ thông tin, Kinh tế...")))
        stack.addArrangedSubview(createCard(title: "TÁC GIẢ (Gõ để chọn hoặc thêm mới)", view: setupTextField(txtTacGia, placeholder: "VD: Robert C. Martin, Nguyễn Nhật Ánh...")))
        stack.addArrangedSubview(createCard(title: "NHÀ XUẤT BẢN", view: setupTextField(txtNXB, placeholder: "VD: NXB Trẻ, NXB Kim Đồng...")))

        txtNamXB.keyboardType = .numberPad
        stack.addArrangedSubview(createCard(title: "NĂM XUẤT BẢN", view: setupTextField(txtNamXB, placeholder: "VD: 2024")))

        // 3. Phân loại giá trị
        segPhanLoai.selectedSegmentIndex = 1
        segPhanLoai.addTarget(self, action: #selector(phanLoaiChanged), for: .valueChanged)
        stack.addArrangedSubview(createCard(title: "PHÂN LOẠI GIÁ TRỊ (TỰ ĐỘNG TÍNH CỌC & PHÍ)", view: segPhanLoai))

        // 4. Bảng giá cọc & phí
        let pricingStack = UIStackView(arrangedSubviews: [lblTienCoc, lblPhiMuon])
        pricingStack.axis = .horizontal
        pricingStack.distribution = .fillEqually
        lblTienCoc.font = .systemFont(ofSize: 14, weight: .semibold)
        lblTienCoc.textColor = .appPrimary
        lblPhiMuon.font = .systemFont(ofSize: 14, weight: .semibold)
        lblPhiMuon.textColor = .appWarning
        lblPhiMuon.textAlignment = .right
        stack.addArrangedSubview(createCard(title: "BẢNG GIÁ DỰ TÍNH", view: pricingStack))

        // 5. Số lượng bản sao (khi thêm mới)
        if case .them = mode {
            txtSoLuong.keyboardType = .numberPad
            txtSoLuong.text = "3"
            stack.addArrangedSubview(createCard(title: "SỐ LƯỢNG BẢN SAO BAN ĐẦU", view: setupTextField(txtSoLuong, placeholder: "Số lượng bản sao (VD: 3)")))

            txtViTriKe.text = "Kệ A1"
            stack.addArrangedSubview(createCard(title: "VỊ TRÍ KỆ MẶC ĐỊNH", view: setupTextField(txtViTriKe, placeholder: "VD: Kệ A1, Tủ B2...")))
        }
    }

    // MARK: - Thiết kế Card Ảnh Bìa (Chương 2 - Slide 34)
    private func setupCoverImageCard(stack: UIStackView) {
        let card = UIView()
        AppTheme.applyCardStyle(to: card)

        let titleLabel = UILabel()
        titleLabel.text = "ẢNH BÌA SÁCH (CHẠM ĐỂ CHỌN TỪ THƯ VIỆN ẢNH)"
        titleLabel.font = .systemFont(ofSize: 12, weight: .bold)
        titleLabel.textColor = .secondaryLabel

        imgCover.image = UIImage(systemName: "book.closed.fill")
        imgCover.tintColor = .appPrimary
        imgCover.contentMode = .scaleAspectFit
        imgCover.backgroundColor = .systemGray6
        imgCover.layer.cornerRadius = 8
        imgCover.layer.masksToBounds = true
        imgCover.isUserInteractionEnabled = true
        imgCover.translatesAutoresizingMaskIntoConstraints = false
        imgCover.heightAnchor.constraint(equalToConstant: 140).isActive = true

        // Gắn UITapGestureRecognizer vào UIImageView (Slide Chương 2)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imagePickerTapped(_:)))
        imgCover.addGestureRecognizer(tapGesture)

        let hintLabel = UILabel()
        hintLabel.text = "📷 Nhấn vào đây để tải ảnh bìa lên"
        hintLabel.font = .systemFont(ofSize: 12)
        hintLabel.textColor = .secondaryLabel
        hintLabel.textAlignment = .center

        let cStack = UIStackView(arrangedSubviews: [titleLabel, imgCover, hintLabel])
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

        stack.addArrangedSubview(card)
    }

    // MARK: - Hàm Xử Lý Chọn Ảnh (UIImagePickerController - Slide Chương 2)
    @objc private func imagePickerTapped(_ sender: UITapGestureRecognizer) {
        // Ẩn bàn phím nếu đang mở
        view.endEditing(true)

        // Tạo đối tượng UIImagePickerController (Slide Chương 2 - Slide 34)
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }

    // MARK: - Các hàm ủy quyền ImagePicker (UIImagePickerControllerDelegate)
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let edited = info[.editedImage] as? UIImage {
            imgCover.image = edited
            imgCover.contentMode = .scaleAspectFill
            selectedImage = edited
        } else if let original = info[.originalImage] as? UIImage {
            imgCover.image = original
            imgCover.contentMode = .scaleAspectFill
            selectedImage = original
        }
        dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }

    // MARK: - Các hàm ủy quyền TextField (UITextFieldDelegate - Slide Chương 2)
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
        tf.delegate = self
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

    // MARK: - Navigation Actions
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }

    @objc private func saveTapped() {
        let ten = txtTenSach.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if ten.isEmpty {
            let alert = UIAlertController(title: "Thông báo", message: "Vui lòng nhập tên sách", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        let dao = LibraryDAO.shared
        let dm = DataManager.shared
        let phanLoai = phanLoaiValues[segPhanLoai.selectedSegmentIndex]
        let (coc, phi) = tinhTienCocVaPhi(phanLoai: phanLoai)
        let namXB = Int(txtNamXB.text ?? "") ?? 2024

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

            let count = max(1, Int(txtSoLuong.text ?? "3") ?? 3)
            let ke = txtViTriKe.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Kệ A1"
            let prefix = ten.split(separator: " ").compactMap { $0.first }.prefix(3).map { String($0).uppercased() }.joined()
            let maPrefix = prefix.isEmpty ? "BK" : prefix

            for i in 1...count {
                let code = "\(maPrefix)-\(String(format: "%03d", i))"
                let bs = BanSaoSach(maDinhDanh: code, viTriKe: ke, tinhTrang: "SanSang", sach: moi)
                moi.dsBanSao.append(bs)
            }

            // Ghi vào cơ sở dữ liệu thông qua tầng DAL (Slide Chương 3)
            dao.insertSach(moi)
            getBackData?(moi)

        case let .sua(sach):
            sach.tenSach = ten
            sach.namXuatBan = namXB
            sach.phanLoaiGiaTri = phanLoai
            sach.tienCoc = coc
            sach.phiMuon = phi
            sach.theLoai = theLoai
            sach.tacGia = tacGia
            sach.nhaXuatBan = nxb
            dao.updateSach(sach)
            getBackData?(sach)
        }

        dismiss(animated: true)
    }
}
