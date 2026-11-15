//
//  CaiDatViewController.swift
//  ThuVienIOS
//
//  MÔ TẢ: Tab 5 - Cài Đặt Quy Định Thư Viện, Điều Hướng Danh Mục & Quản Lý Dữ Liệu
//  CÔNG NGHỆ: UIKit, Storyboard, UITableView Grouped Style, UserDefaults
//

import UIKit

class CaiDatViewController: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Cài Đặt"
        view.backgroundColor = .appBackground

        setupNavigation()
        setupTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    private func setupNavigation() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Cài Đặt"
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

    private func editSettingText(title: String, message: String, currentValue: String, keyboardType: UIKeyboardType = .default, onSave: @escaping (String) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField { tf in
            tf.text = currentValue
            tf.keyboardType = keyboardType
        }
        alert.addAction(UIAlertAction(title: "Hủy", style: .cancel))
        alert.addAction(UIAlertAction(title: "Lưu", style: .default) { _ in
            let text = alert.textFields?[0].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if !text.isEmpty {
                onSave(text)
            }
        })
        present(alert, animated: true)
    }
}

// MARK: - TableView DataSource & Delegate
extension CaiDatViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 5 // Quy định thư viện
        case 1: return 3 // Danh mục (Thể loại, NXB, Tác giả)
        case 2: return 2 // Quản lý dữ liệu (Nạp mẫu, Reset)
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "QUY ĐỊNH & THAM SỐ THƯ VIỆN"
        case 1: return "QUẢN LÝ DANH MỤC PHÂN LOẠI"
        case 2: return "CƠ SỞ DỮ LIỆU & HỆ THỐNG"
        default: return nil
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let settings = LibrarySettings.shared
        let dm = DataManager.shared

        switch indexPath.section {
        case 0:
            let cell = UITableViewCell(style: .value1, reuseIdentifier: "SettingCell")
            cell.accessoryType = .disclosureIndicator
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Tên thư viện"
                cell.detailTextLabel?.text = settings.tenThuVien
            case 1:
                cell.textLabel?.text = "Hạn mượn mặc định"
                cell.detailTextLabel?.text = "\(settings.soNgayMuonMacDinh) ngày"
            case 2:
                cell.textLabel?.text = "Mức phạt trễ / ngày"
                cell.detailTextLabel?.text = AppTheme.formatVND(settings.mucPhatMoiNgay)
            case 3:
                cell.textLabel?.text = "Mức cọc cơ bản"
                cell.detailTextLabel?.text = AppTheme.formatVND(settings.mucCocMacDinh)
            case 4:
                cell.textLabel?.text = "Phí mượn cơ bản"
                cell.detailTextLabel?.text = AppTheme.formatVND(settings.phiMuonMacDinh)
            default: break
            }
            return cell

        case 1:
            let cell = UITableViewCell(style: .value1, reuseIdentifier: "CatCell")
            cell.accessoryType = .disclosureIndicator
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "📂 Quản lý Thể Loại"
                cell.detailTextLabel?.text = "\(dm.dsTheLoai.count) mục"
            case 1:
                cell.textLabel?.text = "🏢 Quản lý Nhà Xuất Bản"
                cell.detailTextLabel?.text = "\(dm.dsNXB.count) mục"
            case 2:
                cell.textLabel?.text = "✍️ Quản lý Tác Giả"
                cell.detailTextLabel?.text = "\(dm.dsTacGia.count) mục"
            default: break
            }
            return cell

        case 2:
            let cell = UITableViewCell(style: .default, reuseIdentifier: "ActionCell")
            if indexPath.row == 0 {
                cell.textLabel?.text = "📥 Nạp 10 Sách & Dữ Liệu Mẫu Chuẩn"
                cell.textLabel?.textColor = .appPrimary
                cell.textLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
            } else {
                cell.textLabel?.text = "🗑️ Xóa Toàn Bộ Dữ Liệu (Khôi Phục Gốc)"
                cell.textLabel?.textColor = .appDanger
                cell.textLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
            }
            return cell

        default:
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let settings = LibrarySettings.shared

        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                editSettingText(title: "Tên thư viện", message: "Nhập tên thư viện hiển thị:", currentValue: settings.tenThuVien) { [weak self] val in
                    settings.tenThuVien = val
                    self?.tableView.reloadData()
                }
            case 1:
                editSettingText(title: "Hạn mượn mặc định", message: "Nhập số ngày (VD: 14):", currentValue: "\(settings.soNgayMuonMacDinh)", keyboardType: .numberPad) { [weak self] val in
                    if let n = Int(val), n > 0 { settings.soNgayMuonMacDinh = n }
                    self?.tableView.reloadData()
                }
            case 2:
                editSettingText(title: "Mức phạt trễ", message: "Nhập mức phạt VNĐ/ngày (VD: 5000):", currentValue: "\(settings.mucPhatMoiNgay)", keyboardType: .numberPad) { [weak self] val in
                    if let n = Int(val), n >= 0 { settings.mucPhatMoiNgay = n }
                    self?.tableView.reloadData()
                }
            case 3:
                editSettingText(title: "Tiền cọc cơ bản", message: "Nhập tiền cọc VNĐ (VD: 50000):", currentValue: "\(settings.mucCocMacDinh)", keyboardType: .numberPad) { [weak self] val in
                    if let n = Int(val), n >= 0 { settings.mucCocMacDinh = n }
                    self?.tableView.reloadData()
                }
            case 4:
                editSettingText(title: "Phí mượn cơ bản", message: "Nhập phí mượn VNĐ (VD: 10000):", currentValue: "\(settings.phiMuonMacDinh)", keyboardType: .numberPad) { [weak self] val in
                    if let n = Int(val), n >= 0 { settings.phiMuonMacDinh = n }
                    self?.tableView.reloadData()
                }
            default: break
            }

        case 1:
            switch indexPath.row {
            case 0:
                let vc = QuanLyTheLoaiViewController()
                navigationController?.pushViewController(vc, animated: true)
            case 1:
                let vc = QuanLyNXBViewController()
                navigationController?.pushViewController(vc, animated: true)
            case 2:
                let vc = QuanLyTacGiaViewController()
                navigationController?.pushViewController(vc, animated: true)
            default: break
            }

        case 2:
            if indexPath.row == 0 {
                let alert = UIAlertController(title: "Nạp dữ liệu mẫu", message: "Hệ thống sẽ nạp 10 đầu sách, độc giả mẫu và phiếu mượn thực tế.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Hủy", style: .cancel))
                alert.addAction(UIAlertAction(title: "Nạp ngay", style: .default) { [weak self] _ in
                    DataManager.shared.napDuLieuMau()
                    self?.tableView.reloadData()
                })
                present(alert, animated: true)
            } else {
                let alert = UIAlertController(title: "CẢNH BÁO XÓA DỮ LIỆU", message: "Toàn bộ sách, độc giả và phiếu mượn sẽ bị xóa sạch hoàn toàn!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Hủy", style: .cancel))
                alert.addAction(UIAlertAction(title: "Xóa sạch", style: .destructive) { [weak self] _ in
                    DataManager.shared.xoaToanBoDuLieu()
                    self?.tableView.reloadData()
                })
                present(alert, animated: true)
            }

        default: break
        }
    }
}
