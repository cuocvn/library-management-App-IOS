//
//  ChiTietDocGiaViewController.swift
//  ThuVienIOS
//
//  MÔ TẢ: Màn hình 4.1 - Chi Tiết Độc Giả, Thẻ Ví Điện Tử & Lịch Sử Mượn Trả
//  CÔNG NGHỆ: UIKit, Storyboard, UITableView, Grouped Sections
//

import UIKit

class ChiTietDocGiaViewController: UIViewController {

    private let docGia: DocGia
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    init(docGia: DocGia) {
        self.docGia = docGia
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Hồ Sơ Độc Giả"
        view.backgroundColor = .appBackground

        setupNavigation()
        setupTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    private func setupNavigation() {
        navigationItem.largeTitleDisplayMode = .never

        let editBtn = UIBarButtonItem(title: "Sửa", style: .plain, target: self, action: #selector(suaDocGiaTapped))
        let deleteBtn = UIBarButtonItem(image: UIImage(systemName: "trash"), style: .plain, target: self, action: #selector(xoaDocGiaTapped))
        deleteBtn.tintColor = .appDanger
        navigationItem.rightBarButtonItems = [deleteBtn, editBtn]
    }

    private func setupTableView() {
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    @objc private func suaDocGiaTapped() {
        let vc = ThemSuaDocGiaViewController(mode: .sua(docGia))
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }

    @objc private func xoaDocGiaTapped() {
        let alert = UIAlertController(title: "Xóa độc giả", message: "Bạn có chắc muốn xóa độc giả '\(docGia.hoTen)'?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Hủy", style: .cancel))
        alert.addAction(UIAlertAction(title: "Xóa", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            DataManager.shared.xoaDocGia(self.docGia)
            self.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }

    @objc private func napTienTapped() {
        let vc = NapTienViewController(docGia: docGia)
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
}

// MARK: - TableView DataSource & Delegate
extension ChiTietDocGiaViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 4 // Thông tin cá nhân
        case 1: return 1 // Thẻ Ví & Nạp tiền
        case 2: // Sách đang mượn
            let active = docGia.dsPhieuMuon.filter { $0.ngayTra == nil }
            return max(active.count, 1)
        case 3: // Lịch sử trả
            let returned = docGia.dsPhieuMuon.filter { $0.ngayTra != nil }
            return max(returned.count, 1)
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "THÔNG TIN CÁ NHÂN"
        case 1: return "VÍ TÀI KHOẢN NỘI BỘ"
        case 2:
            let count = docGia.dsPhieuMuon.filter { $0.ngayTra == nil }.count
            return "SÁCH ĐANG MƯỢN (\(count))"
        case 3: return "LỊCH SỬ ĐÃ TRẢ"
        default: return nil
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = UITableViewCell(style: .value1, reuseIdentifier: "InfoCell")
            cell.selectionStyle = .none
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Họ và tên"
                cell.detailTextLabel?.text = docGia.hoTen
                cell.detailTextLabel?.font = .systemFont(ofSize: 15, weight: .bold)
            case 1:
                cell.textLabel?.text = "Hạng thành viên"
                let isVIP = docGia.loaiThe == "VIP"
                cell.detailTextLabel?.text = isVIP ? "👑 Hội Viên VIP (Miễn cọc)" : "Thành viên Thường"
                cell.detailTextLabel?.textColor = isVIP ? .appGold : .secondaryLabel
            case 2:
                cell.textLabel?.text = "Số điện thoại"
                cell.detailTextLabel?.text = docGia.soDienThoai
            case 3:
                cell.textLabel?.text = "Lớp / Khóa / Email"
                cell.detailTextLabel?.text = "\(docGia.lopKhoa) • \(docGia.email)"
            default: break
            }
            return cell

        case 1:
            let cell = UITableViewCell()
            cell.backgroundColor = .clear

            let card = UIView()
            AppTheme.applyCardStyle(to: card)
            card.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(card)

            let lblTitle = UILabel()
            lblTitle.text = "Số dư khả dụng"
            lblTitle.font = .systemFont(ofSize: 12)
            lblTitle.textColor = .secondaryLabel

            let lblBalance = UILabel()
            lblBalance.text = AppTheme.formatVND(docGia.soDuTaiKhoan)
            lblBalance.font = .systemFont(ofSize: 22, weight: .bold)
            lblBalance.textColor = .appSuccess

            let btnNap = UIButton(type: .system)
            btnNap.setTitle("💳 Nạp Tiền", for: .normal)
            btnNap.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
            btnNap.backgroundColor = .appPrimary
            btnNap.setTitleColor(.white, for: .normal)
            btnNap.layer.cornerRadius = 8
            btnNap.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
            btnNap.addTarget(self, action: #selector(napTienTapped), for: .touchUpInside)

            let textStack = UIStackView(arrangedSubviews: [lblTitle, lblBalance])
            textStack.axis = .vertical
            textStack.spacing = 4

            let hStack = UIStackView(arrangedSubviews: [textStack, btnNap])
            hStack.axis = .horizontal
            hStack.alignment = .center
            hStack.distribution = .equalSpacing
            hStack.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview(hStack)

            NSLayoutConstraint.activate([
                card.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 4),
                card.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
                card.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
                card.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -4),

                hStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
                hStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
                hStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
                hStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14)
            ])
            return cell

        case 2:
            let active = docGia.dsPhieuMuon.filter { $0.ngayTra == nil }
            if active.isEmpty {
                let cell = UITableViewCell()
                cell.textLabel?.text = "Không có sách nào đang mượn"
                cell.textLabel?.textColor = .secondaryLabel
                cell.selectionStyle = .none
                return cell
            }
            let pm = active[indexPath.row]
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "ActiveBorrowCell")
            cell.textLabel?.text = "\(pm.banSao?.sach?.tenSach ?? "") (\(pm.banSao?.maDinhDanh ?? ""))"
            cell.textLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
            let isOverdue = pm.hanTra < Date()
            cell.detailTextLabel?.text = "Hạn trả: \(AppTheme.formatDate(pm.hanTra))\(isOverdue ? " (⚠️ Quá hạn)" : "")"
            cell.detailTextLabel?.textColor = isOverdue ? .appDanger : .secondaryLabel
            return cell

        case 3:
            let returned = docGia.dsPhieuMuon.filter { $0.ngayTra != nil }
            if returned.isEmpty {
                let cell = UITableViewCell()
                cell.textLabel?.text = "Chưa có lịch sử trả sách"
                cell.textLabel?.textColor = .secondaryLabel
                cell.selectionStyle = .none
                return cell
            }
            let pm = returned[indexPath.row]
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "ReturnedCell")
            cell.textLabel?.text = pm.banSao?.sach?.tenSach ?? ""
            cell.textLabel?.font = .systemFont(ofSize: 14, weight: .medium)
            cell.detailTextLabel?.text = "Đã trả ngày: \(AppTheme.formatDate(pm.ngayTra!))"
            cell.detailTextLabel?.textColor = .secondaryLabel
            return cell

        default:
            return UITableViewCell()
        }
    }
}
