# KẾ HOẠCH & TIẾN ĐỘ THỰC HIỆN ĐỒ ÁN
## Ứng Dụng Quản Lý Thư Viện (Library Management System - iOS)

- **Nền tảng**: iOS 17+ (Swift, SwiftUI, SwiftData Local Database Offline, Apple Charts).
- **Kiến trúc**: MVVM + Repository Pattern.
- **Phong cách UI**: Chuẩn Apple HIG Inset Grouped, Indigo Blue `#4338CA`.
- **Repository**: [https://github.com/cuocvn/library-management-App-IOS](https://github.com/cuocvn/library-management-App-IOS)

---

## 📌 BẢNG THEO DÕI TIẾN ĐỘ (STATUS TRACKER)

| Hạng mục | Chi tiết công việc | Trạng thái |
| :--- | :--- | :--- |
| **0. Chuẩn bị & Database** | Phân tích đặc tả, thiết kế schema SwiftData, seed data mẫu, đẩy GitHub | ✅ **Đã hoàn thành** |
| **1. Khung App & Tab 1** | Lifecycle SwiftUI App, Theme màu sắc, MainTabView, Dashboard KPI, Apple Charts, Top 10 | ✅ **Đã hoàn thành** |
| **2. Tab 2: Kho Sách** | 2.0 Quản lý Kho Sách, 2.1 Chi tiết & Bản sao vật lý, 2.2 Form Thêm/Sửa Sách | ✅ **Đã hoàn thành** |
| **3. Tab 3: Mượn & Trả** | 3.0 Danh sách mượn/trả, 3.1 Tạo phiếu mượn (VIP, ví tiền), 3.2 Trả sách & Phạt Snapshot | 🔄 **Đang thực hiện** |
| **4. Tab 4: Độc Giả** | 4.0 Danh sách độc giả, 4.1 Chi tiết độc giả & Ví tiền, 4.1.1 Nạp tiền, 4.2 Thêm/Sửa | ⏳ Chờ thực hiện |
| **5. Tab 5: Cài Đặt** | 5.0 Cài đặt thư viện (@AppStorage), 5.1 Thể loại, 5.2 NXB, 5.3 Tác giả | ⏳ Chờ thực hiện |
| **6. Kiểm thử & Hoàn thiện** | Review toàn bộ luồng, kiểm tra đối soát tài chính, cập nhật tài liệu báo cáo | ⏳ Chờ thực hiện |

---

## 📝 NHẬT KÝ CHI TIẾT CÁC CÔNG VIỆC

### ✅ GIAI ĐOẠN 0: Khởi tạo & Thiết kế SwiftData (ĐÃ HOÀN THÀNH)
1. **Phân tích tài liệu**: Trích xuất và phân tích toàn bộ đặc tả từ `ĐỒ ÁN_ ỨNG DỤNG QUẢN LÝ THƯ VIỆN (iOS).docx` và bộ mockup Stitch HTML.
2. **Khởi tạo Git & Repository GitHub**:
   - Tạo repo, liên kết remote `https://github.com/cuocvn/library-management-App-IOS.git`.
   - Commit & push file đặc tả, mã mockup và project cấu trúc ban đầu.
3. **Triển khai Models SwiftData chuẩn tiếng Việt không dấu**:
   - `TheLoai.swift`: Quản lý danh mục thể loại (UUID, tenTheLoai, quan hệ 1-N Sach).
   - `NhaXuatBan.swift`: Quản lý NXB (UUID, tenNXB, quan hệ 1-N Sach).
   - `TacGia.swift`: Quản lý Tác giả (UUID, tenTacGia, quan hệ 1-N Sach).
   - `Sach.swift`: Đầu sách metadata (phanLoaiGiaTri, tienCoc, phiMuon, daAn, hinhAnh, dsBanSao).
   - `BanSaoSach.swift`: Quản lý cuốn vật lý (maDinhDanh AI-001, viTriKe, tinhTrang SanSang/DangMuon/Hong).
   - `DocGia.swift`: Độc giả (hoTen, loaiThe Thuong/VIP, soDuTaiKhoan ví nội bộ, daAn).
   - `PhieuMuon.swift`: Giao dịch mượn trả, snapshot tài chính bất biến (soNgayTre, tienPhat, phuongThucThanhToan, phuongThucHoanTien).
4. **Cấu hình & Dữ liệu mẫu**:
   - `LibrarySettings.swift`: Lưu cấu hình qua `@AppStorage`.
   - `SampleDataService.swift`: Tự động nạp dữ liệu mẫu ban đầu sinh động để test ngay khi mở app.
   - Nâng Deployment Target lên `iOS 17.0`.

---

### 🔄 GIAI ĐOẠN 1: Khung App & Tab 1 - Trang Chủ (Dashboard) (ĐANG LÀM)
- [ ] Xây dựng App Lifecycle SwiftUI (`ThuVienIOSApp.swift`) cấu hình `modelContainer` cho SwiftData và gọi seed data khi khởi động lần đầu.
- [ ] Thiết lập bảng màu sắc Theme (`Color+Theme.swift` với màu Indigo `#4338CA`, Emerald, Crimson, Amber).
- [ ] Xây dựng `MainTabView.swift` liên kết 5 Tab điều hướng chuẩn Apple HIG.
- [ ] Thiết kế `DashboardView.swift` (Màn hình 1.0):
  - [ ] 4 Thẻ KPI tài chính (Tổng lượt mượn, Doanh thu phí mượn, Tiền cọc đang giữ, Phạt đã thu).
  - [ ] Biểu đồ cột Apple Charts hiển thị lượt mượn trong 7 ngày gần nhất.
  - [ ] Danh sách Top 10 Độc giả mượn nhiều nhất.
  - [ ] Danh sách Top 10 Tác giả được quan tâm nhất.
- [ ] Đẩy commit lên GitHub và cập nhật tiến độ.

---

### ⏳ GIAI ĐOẠN 2: Tab 2 - Quản Lý Kho Sách
- [ ] Màn hình 2.0: Danh sách sách, thanh tìm kiếm từ khóa, bộ lọc theo Thể loại, hiển thị badge tồn kho "Còn X/Y cuốn".
- [ ] Màn hình 2.1: Chi tiết sách, huy hiệu Cọc/Phí, nút "Cho mượn sách", danh sách bản sao vật lý cụ thể (mã định danh, kệ sách, trạng thái), lịch sử mượn của cuốn sách.
- [ ] Màn hình 2.2: Form Thêm/Sửa sách, tự động tính cọc/phí theo phân loại giá trị, tự động sinh mã bản sao hàng loạt (VD: AI-001 -> AI-010).

---

### ⏳ GIAI ĐOẠN 3: Tab 3 - Nghiệp Vụ Mượn & Trả (Core Fintech)
- [ ] Màn hình 3.0: Danh sách phiếu mượn phân loại theo trạng thái (Đang mượn, Quá hạn cảnh báo đỏ, Đã trả), hỗ trợ thao tác nhanh.
- [ ] Màn hình 3.1: Modal Tạo phiếu mượn (Chọn đầu sách -> chọn bản sao "SanSang" -> chọn độc giả -> tính tiền cọc/phí -> tự miễn cọc nếu là VIP -> chọn thanh toán Tiền mặt hoặc trừ Ví số dư).
- [ ] Màn hình 3.2: Modal Trả sách & Thu phạt (Tính số ngày trễ, áp đơn giá phạt snapshot, quyết toán Cọc hoàn lại - Phí - Phạt, xử lý nạp bù nếu âm tiền, hoàn tiền qua Tiền mặt hoặc cộng vào Ví).

---

### ⏳ GIAI ĐOẠN 4: Tab 4 - Quản Lý Độc Giả & Ví Điện Tử
- [ ] Màn hình 4.0: Danh sách độc giả, tìm kiếm theo tên/SĐT/lớp, badge VIP sang trọng.
- [ ] Màn hình 4.1: Chi tiết hồ sơ độc giả, thẻ số dư ví, danh sách sách đang mượn, lịch sử mượn cá nhân.
- [ ] Màn hình 4.1.1: Sheet Nạp tiền vào ví độc giả (chọn các mệnh giá nhanh 50k, 100k, 200k, 500k hoặc nhập tay).
- [ ] Màn hình 4.2: Form Thêm/Sửa thông tin độc giả, chọn loại thẻ Thường / VIP.

---

### ⏳ GIAI ĐOẠN 5: Tab 5 - Cài Đặt Thư Viện & Danh Mục
- [ ] Màn hình 5.0: Cài đặt quy định thư viện (Tên thư viện, số ngày mượn tối đa, mức phạt/ngày, mức cọc cơ bản).
- [ ] Màn hình 5.1: Quản lý Thể loại (Thêm, sửa, xóa với cảnh báo an toàn).
- [ ] Màn hình 5.2: Quản lý Nhà xuất bản.
- [ ] Màn hình 5.3: Quản lý Tác giả.

---

### ⏳ GIAI ĐOẠN 6: Hoàn Thiện & Nghiệm Thu
- [ ] Rà soát toàn bộ luồng trải nghiệm trên máy ảo iPhone.
- [ ] Kiểm tra tính toàn vẹn của dữ liệu SwiftData (không bị crash khi app tắt mở lại).
- [ ] Đóng gói mã nguồn sạch, tài liệu hướng dẫn chạy trên Xcode.
