# HƯỚNG DẪN CÀI ĐẶT & CHẠY ỨNG DỤNG TRÊN XCODE

Dự án: **Hệ Thống Quản Lý Thư Viện (Library Management System - iOS)**  
Ngôn ngữ: **Swift, SwiftUI**  
Cơ sở dữ liệu: **SwiftData (Offline Local DB)**  
Hỗ trợ: **iOS 17.0+**

---

## 🚀 CÁC BƯỚC KHỞI CHẠY TRÊN XCODE

### Bước 1: Mở Project
1. Mở phần mềm **Xcode** trên máy Mac.
2. Chọn `Open Existing Project...` (hoặc nhấn `File > Open...`).
3. Điều hướng đến thư mục:
   ```
   ThuVienIOS-20261109T091015Z-1-001/ThuVienIOS/ThuVienIOS.xcodeproj
   ```
   và nhấn **Open**.

### Bước 2: Chọn Thiết Bị / Máy Ảo (Simulator)
- Trên thanh công cụ trên cùng của Xcode (Scheme Selector), bấm vào mục chọn thiết bị.
- Chọn một thiết bị **iOS 17 trở lên** (Ví dụ: `iPhone 15 Pro`, `iPhone 16`, `iPad Pro`).

### Bước 3: Build & Chạy (Run)
- Nhấn tổ hợp phím **`Cmd + R`** (hoặc bấm nút ▶️ **Run** ở góc trên bên trái).
- Ứng dụng sẽ tự động compile, liên kết SwiftData ModelContainer, tự động nạp dữ liệu mẫu ban đầu sinh động và hiển thị màn hình Dashboard.

---

## 📱 CẤU TRÚC 5 TAB ĐÃ HOÀN THIỆN

1. **Tab 1: Trang Chủ (Dashboard)**
   - 4 Thẻ KPI: Lượt mượn, Doanh thu phí mượn, Tiền cọc đang giữ, Phạt đã thu.
   - Biểu đồ Apple Charts theo tuần.
   - Top 10 Độc giả tích cực & Top 10 Tác giả.

2. **Tab 2: Kho Sách**
   - Danh sách sách với bộ lọc nhanh theo Thể loại (Pill Filter) và thanh tìm kiếm từ khóa.
   - Xem chi tiết đầu sách, **theo dõi từng cuốn bản sao vật lý trên giá kệ** (mã AI-001, vị trí kệ, tình trạng Sẵn sàng / Đang mượn / Hỏng).
   - Thêm & sửa sách, tự động áp giá cọc/phí theo loại giá trị và tự sinh mã bản sao.

3. **Tab 3: Mượn & Trả Sách (Fintech Mini)**
   - Danh sách phiếu mượn phân loại theo trạng thái (Đang mượn, Quá hạn, Đã trả).
   - Tạo phiếu mượn: Tự động miễn tiền cọc cho độc giả VIP, chọn thanh toán Tiền mặt hoặc Trừ ví số dư.
   - Trả sách & Thu phạt: Tính ngày quá hạn tự động, lưu Snapshot phạt vào DB, đối soát tiền hoàn lại khách (Cọc - Phạt).

4. **Tab 4: Quản Lý Độc Giả**
   - Danh sách độc giả kèm huy hiệu VIP.
   - Hồ sơ độc giả, thẻ số dư ví nội bộ, danh sách sách đang mượn.
   - Nạp tiền vào ví với các mệnh giá nhanh (50k, 100k, 200k, 500k).
   - Thêm & sửa thông tin độc giả, cấu hình hội viên VIP.

5. **Tab 5: Cài Đặt Thư Viện**
   - Cấu hình hạn mượn mặc định, mức phạt trễ hạn mỗi ngày qua `@AppStorage`.
   - Quản lý danh mục Thể loại, Nhà xuất bản, Tác giả.
