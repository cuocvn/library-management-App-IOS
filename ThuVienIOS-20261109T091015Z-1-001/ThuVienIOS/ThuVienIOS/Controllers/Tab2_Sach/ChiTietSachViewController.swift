//
//  ChiTietSachViewController.swift
//  ThuVienIOS
//
//  MÔ TẢ: Màn hình 2.1 - Chi tiết đầu sách & Quản lý bản sao vật lý cụ thể
//  CÔNG NGHỆ: UIKit, Storyboard, UITableView, Action Sheets
//

import UIKit

class ChiTietSachViewController: UIViewController {

    private let sach: Sach
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    init(sach: Sach) {
        self.sach = sach
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Chi Tiết Sách"
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

        let editBtn = UIBarButtonItem(title: "Sửa", style: .plain, target: self, action: #selector(suaSachTapped))
        let deleteBtn = UIBarButtonItem(image: UIImage(systemName: "trash"), style: .plain, target: self, action: #selector(xoaSachTapped))
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

    @objc private func suaSachTapped() {
        let vc = ThemSuaSachViewController(mode: .sua(sach))
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }

    @objc private func xoaSachTapped() {
        let alert = UIAlertController(title: "Xóa đầu sách", message: "Bạn có chắc muốn xóa đầu sách '\(sach.tenSach)'?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Hủy", style: .cancel))
        alert.addAction(UIAlertAction(title: "Xóa", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            DataManager.shared.xoaSach(self.sach)
            self.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }

    @objc private func choMuonTapped() {
        let vc = TaoPhieuMuonViewController(selectedSach: sach)
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }

    @objc private func themBanSaoTapped() {
        let count = sach.dsBanSao.count + 1
        let prefix = sach.tenSach.split(separator: " ").compactMap { $0.first }.prefix(3).map { String($0).uppercased() }.joined()
        let code = "\(prefix.isEmpty ? "BK" : prefix)-\(String(format: "%03d", count))"

        let alert = UIAlertController(title: "Thêm bản sao vật lý", message: "Nhập thông tin cuốn sách mới", preferredStyle: .alert)
        alert.addTextField { tf in
            tf.placeholder = "Mã định danh"
            tf.text = code
        }
        alert.addTextField { tf in
            tf.placeholder = "Vị trí kệ (VD: Kệ A1)"
            tf.text = "Kệ A1"
        }
        alert.addAction(UIAlertAction(title: "Hủy", style: .cancel))
        alert.addAction(UIAlertAction(title: "Thêm", style: .default) { [weak self] _ in
            guard let self = self else { return }
            let ma = alert.textFields?[0].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? code
            let ke = alert.textFields?[1].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Kệ A1"
            let newCopy = BanSaoSach(maDinhDanh: ma, viTriKe: ke, tinhTrang: "SanSang", sach: self.sach)
            DataManager.shared.themBanSao(newCopy)
            self.tableView.reloadData()
        })
        present(alert, animated: true)
    }
}

// MARK: - TableView DataSource & Delegate
extension ChiTietSachViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 5 // Thông tin metadata
        case 1: return 1 // Nút Cho Mượn
        case 2: return sach.dsBanSao.count + 1 // Danh sách bản sao + Nút Thêm
        case 3: // Lịch sử mượn
            let count = sach.dsBanSao.flatMap { $0.dsPhieuMuon }.count
            return max(count, 1)
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "THÔNG TIN ĐẦU SÁCH"
        case 1: return nil
        case 2: return "BẢN SAO VẬT LÝ (\(sach.dsBanSao.count) CUỐN)"
        case 3: return "LỊCH SỬ MƯỢN TRẢ"
        default: return nil
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = UITableViewCell(style: .value1, reuseIdentifier: "MetaCell")
            cell.selectionStyle = .none
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Tên sách"
                cell.detailTextLabel?.text = sach.tenSach
                cell.detailTextLabel?.font = .systemFont(ofSize: 15, weight: .bold)
            case 1:
                cell.textLabel?.text = "Tác giả"
                cell.detailTextLabel?.text = sach.tacGia?.tenTacGia ?? "Chưa rõ"
            case 2:
                cell.textLabel?.text = "Thể loại / NXB"
                let cat = sach.theLoai?.tenTheLoai ?? "Khác"
                let pub = sach.nhaXuatBan?.tenNXB ?? "Khác"
                cell.detailTextLabel?.text = "\(cat) • \(pub) (\(sach.namXuatBan))"
            case 3:
                cell.textLabel?.text = "Phân loại"
                cell.detailTextLabel?.text = sach.phanLoaiGiaTri
            case 4:
                cell.textLabel?.text = "Tiền cọc / Phí"
                cell.detailTextLabel?.text = "\(AppTheme.formatVND(sach.tienCoc)) / \(AppTheme.formatVND(sach.phiMuon))"
                cell.detailTextLabel?.textColor = .appPrimary
                cell.detailTextLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
            default: break
            }
            return cell

        case 1:
            let cell = UITableViewCell()
            cell.backgroundColor = .clear
            let btn = UIButton(type: .system)
            btn.setTitle("📖 Cho Mượn Cuốn Sách Này", for: .normal)
            btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
            btn.backgroundColor = .appPrimary
            btn.setTitleColor(.white, for: .normal)
            btn.layer.cornerRadius = 12
            btn.translatesAutoresizingMaskIntoConstraints = false
            btn.addTarget(self, action: #selector(choMuonTapped), for: .touchUpInside)
            cell.contentView.addSubview(btn)

            NSLayoutConstraint.activate([
                btn.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 4),
                btn.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
                btn.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
                btn.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -4),
                btn.heightAnchor.constraint(equalToConstant: 48)
            ])
            return cell

        case 2:
            if indexPath.row < sach.dsBanSao.count {
                let copy = sach.dsBanSao[indexPath.row]
                let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "CopyCell")
                cell.textLabel?.text = "Mã: \(copy.maDinhDanh)"
                cell.textLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
                cell.detailTextLabel?.text = "Vị trí: \(copy.viTriKe)"
                cell.detailTextLabel?.textColor = .secondaryLabel

                let statusLabel = UILabel()
                statusLabel.font = .systemFont(ofSize: 12, weight: .bold)
                statusLabel.layer.cornerRadius = 6
                statusLabel.layer.masksToBounds = true
                if copy.tinhTrang == "SanSang" {
                    statusLabel.text = " Sẵn sàng "
                    statusLabel.textColor = .appSuccess
                    statusLabel.backgroundColor = UIColor.appSuccess.withAlphaComponent(0.12)
                } else if copy.tinhTrang == "DangMuon" {
                    statusLabel.text = " Đang mượn "
                    statusLabel.textColor = .appWarning
                    statusLabel.backgroundColor = UIColor.appWarning.withAlphaComponent(0.12)
                } else {
                    statusLabel.text = " Hỏng / Mất "
                    statusLabel.textColor = .appDanger
                    statusLabel.backgroundColor = UIColor.appDanger.withAlphaComponent(0.12)
                }
                statusLabel.sizeToFit()
                cell.accessoryView = statusLabel
                return cell
            } else {
                let cell = UITableViewCell(style: .default, reuseIdentifier: "AddCopyCell")
                cell.textLabel?.text = "➕ Thêm Bản Sao Vật Lý Mới"
                cell.textLabel?.textColor = .appPrimary
                cell.textLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
                return cell
            }

        case 3:
            let allPM = sach.dsBanSao.flatMap { $0.dsPhieuMuon }.sorted { $0.ngayMuon > $1.ngayMuon }
            if allPM.isEmpty {
                let cell = UITableViewCell()
                cell.textLabel?.text = "Chưa có lượt mượn nào"
                cell.textLabel?.textColor = .secondaryLabel
                cell.selectionStyle = .none
                return cell
            }
            let pm = allPM[indexPath.row]
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "HistoryCell")
            let readerName = pm.docGia?.hoTen ?? "Khách"
            cell.textLabel?.text = "\(readerName) • \(pm.banSao?.maDinhDanh ?? "")"
            cell.textLabel?.font = .systemFont(ofSize: 14, weight: .medium)
            let status = pm.ngayTra != nil ? "Đã trả ngày \(AppTheme.formatDate(pm.ngayTra!))" : "Hạn trả: \(AppTheme.formatDate(pm.hanTra))"
            cell.detailTextLabel?.text = "\(AppTheme.formatDate(pm.ngayMuon)) ➔ \(status)"
            cell.detailTextLabel?.textColor = pm.ngayTra == nil && pm.hanTra < Date() ? .appDanger : .secondaryLabel
            return cell

        default:
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 2 && indexPath.row == sach.dsBanSao.count {
            themBanSaoTapped()
        } else if indexPath.section == 2 && indexPath.row < sach.dsBanSao.count {
            // Đổi trạng thái bản sao
            let copy = sach.dsBanSao[indexPath.row]
            let sheet = UIAlertController(title: "Đổi trạng thái bản sao", message: "Mã: \(copy.maDinhDanh)", preferredStyle: .actionSheet)
            sheet.addAction(UIAlertAction(title: "Sẵn sàng (SanSang)", style: .default) { [weak self] _ in
                copy.tinhTrang = "SanSang"
                DataManager.shared.save()
                self?.tableView.reloadData()
            })
            sheet.addAction(UIAlertAction(title: "Đang mượn (DangMuon)", style: .default) { [weak self] _ in
                copy.tinhTrang = "DangMuon"
                DataManager.shared.save()
                self?.tableView.reloadData()
            })
            sheet.addAction(UIAlertAction(title: "Hỏng / Mất (Hong)", style: .destructive) { [weak self] _ in
                copy.tinhTrang = "Hong"
                DataManager.shared.save()
                self?.tableView.reloadData()
            })
            sheet.addAction(UIAlertAction(title: "Hủy", style: .cancel))
            present(sheet, animated: true)
        }
    }
}
