//
//  QuanLyTheLoaiViewController.swift
//  ThuVienIOS
//
//  MÔ TẢ: Màn hình 5.1 - Quản lý Danh mục Thể Loại Sách (Thêm, Sửa, Xóa)
//  CÔNG NGHỆ: UIKit, Storyboard, UITableView
//

import UIKit

class QuanLyTheLoaiViewController: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var dsTheLoai: [TheLoai] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Quản Lý Thể Loại"
        view.backgroundColor = .appBackground

        setupNavigation()
        setupTableView()
        reloadCategories()
    }

    private func setupNavigation() {
        navigationItem.largeTitleDisplayMode = .never
        let addBtn = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(themTheLoaiTapped))
        navigationItem.rightBarButtonItem = addBtn
    }

    private func setupTableView() {
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CatCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func reloadCategories() {
        dsTheLoai = DataManager.shared.dsTheLoai
        tableView.reloadData()
    }

    @objc private func themTheLoaiTapped() {
        let alert = UIAlertController(title: "Thêm thể loại", message: "Nhập tên thể loại sách mới:", preferredStyle: .alert)
        alert.addTextField { tf in tf.placeholder = "VD: Trinh thám, Kỹ năng sống..." }
        alert.addAction(UIAlertAction(title: "Hủy", style: .cancel))
        alert.addAction(UIAlertAction(title: "Thêm", style: .default) { [weak self] _ in
            let text = alert.textFields?[0].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if !text.isEmpty {
                _ = DataManager.shared.layHoacTaoTheLoai(text)
                self?.reloadCategories()
            }
        })
        present(alert, animated: true)
    }
}

extension QuanLyTheLoaiViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dsTheLoai.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "CatCell")
        let tl = dsTheLoai[indexPath.row]
        cell.textLabel?.text = tl.tenTheLoai
        cell.textLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        cell.detailTextLabel?.text = "\(tl.dsSach.count) đầu sách"
        cell.detailTextLabel?.textColor = .secondaryLabel
        return cell
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let tl = dsTheLoai[indexPath.row]
        let delete = UIContextualAction(style: .destructive, title: "Xóa") { [weak self] _, _, completion in
            let alert = UIAlertController(title: "Xóa thể loại", message: "Bạn có chắc muốn xóa thể loại '\(tl.tenTheLoai)'?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Hủy", style: .cancel) { _ in completion(false) })
            alert.addAction(UIAlertAction(title: "Xóa", style: .destructive) { _ in
                DataManager.shared.xoaTheLoai(tl)
                self?.reloadCategories()
                completion(true)
            })
            self?.present(alert, animated: true)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
}
