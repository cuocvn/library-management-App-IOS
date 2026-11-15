# HƯỚNG DẪN CÀI ĐẶT & CHẠY ỨNG DỤNG TRÊN XCODE

Dự án: **Hệ Thống Quản Lý Thư Viện (Library Management System - iOS)**  
Kiến trúc: **UIKit + Main.storyboard (100% Chuẩn Storyboard đồ án trường học & doanh nghiệp)**  
Ngôn ngữ: **Swift 5.0+**  
Cơ sở dữ liệu: **Offline Local JSON Database (`DataManager.swift`)**  
Tương thích: **iOS 16.0+ / Xcode 14.2+ (macOS 13 Ventura) & Xcode 15/16 (iOS 17/18+)**  

---

## 🚀 CÁC BƯỚC KHỞI CHẠY TRÊN XCODE

### Bước 1: Mở Project
1. Mở phần mềm **Xcode** trên máy Mac.
2. Nhấp đúp chuột trực tiếp vào file:
   ```
   ThuVienIOS-20261109T091015Z-1-001/ThuVienIOS/ThuVienIOS.xcodeproj
   ```
   *(Lưu ý: Không kéo thả thư mục vào icon Xcode, hãy nhấp đúp file `.xcodeproj`)*.

### Bước 2: Xem Storyboard
- Trong thanh Project Navigator bên trái, nhấp đúp vào:
  ```
  ThuVienIOS/Base.lproj/Main.storyboard
  ```
- Toàn bộ đồ thị giao diện gồm **UITabBarController, 5 UINavigationController** và các màn hình View Controller liên kết chặt chẽ sẽ hiển thị trực quan trên giao diện đồ họa Interface Builder.

### Bước 3: Chọn Thiết Bị / Máy Ảo (Simulator)
- Trên thanh công cụ trên cùng của Xcode (Scheme Selector), chọn Target **ThuVienIOS**.
- Chọn máy ảo: **iPhone 14**, **iPhone 14 Pro**, **iPhone 15**, hoặc bất kỳ simulator nào từ iOS 16.0 trở lên.

### Bước 4: Build & Chạy (Run)
- Nhấn tổ hợp phím **`Cmd + R`** (hoặc bấm nút ▶️ **Run** ở góc trên bên trái).
- Ứng dụng sẽ tự động compile từ `AppDelegate.swift`, nạp `Main.storyboard`, khởi tạo `DataManager` lưu trữ offline, tự động nạp dữ liệu mẫu ban đầu sinh động và hiển thị màn hình Dashboard.

---

## 📱 CẤU TRÚC 5 TAB & VIEW CONTROLLER CHUẨN STORYBOARD

1. **Tab 1: Trang Chủ (`DashboardViewController.swift`)**
   - 4 Thẻ KPI: Lượt mượn, Doanh thu phí mượn, Tiền cọc đang giữ, Phạt đã thu.
   - Biểu đồ Bar Chart hàng tuần trực quan.
   - Top 10 Độc giả tích cực & Top 10 Tác giả có sách mượn nhiều nhất.
   - Kéo vuốt để làm mới (Pull-to-refresh).

2. **Tab 2: Kho Sách (`KhoSachViewController.swift`, `ChiTietSachViewController.swift`, `ThemSuaSachViewController.swift`)**
   - Danh sách sách với thanh tìm kiếm `UISearchController` và bộ lọc nhanh Thể loại.
   - Chi tiết đầu sách: Theo dõi từng cuốn bản sao vật lý trên giá kệ (mã AI-001, vị trí kệ, tình trạng Sẵn sàng / Đang mượn / Hỏng), đổi trạng thái và thêm bản sao mới.
   - Form Thêm/Sửa sách: Tự động phân loại giá trị, tính tiền cọc & phí mượn, tự động sinh mã bản sao hàng loạt (VD: AI-001 -> AI-005).

3. **Tab 3: Mượn & Trả Sách (`MuonTraViewController.swift`, `TaoPhieuMuonViewController.swift`, `TraSachViewController.swift`)**
   - Phân loại trạng thái phiếu qua `UISegmentedControl` (Tất cả, Đang mượn, Quá hạn, Đã trả).
   - Tạo phiếu mượn: Chọn sách, bản sao khả dụng, độc giả (tự động miễn cọc cho hội viên VIP), thanh toán Tiền mặt hoặc Trừ ví số dư.
   - Trả sách & Thu phạt: Tính ngày quá hạn tự động, quyết toán Snapshot tài chính (Cọc hoàn lại - Phạt quá hạn), hỗ trợ hoàn tiền mặt hoặc cộng vào ví.

4. **Tab 4: Quản Lý Độc Giả (`DocGiaViewController.swift`, `ChiTietDocGiaViewController.swift`, `ThemSuaDocGiaViewController.swift`, `NapTienViewController.swift`)**
   - Danh sách độc giả, avatar chữ cái đầu, huy hiệu VIP vàng kim sang trọng.
   - Hồ sơ độc giả, thẻ số dư ví nội bộ, danh sách sách đang mượn & lịch sử mượn trả.
   - Nạp tiền vào ví nhanh với các mệnh giá 50k, 100k, 200k, 500k hoặc số tiền tùy chỉnh.

5. **Tab 5: Cài Đặt Thư Viện (`CaiDatViewController.swift`, `QuanLyTheLoaiViewController.swift`, `QuanLyNXBViewController.swift`, `QuanLyTacGiaViewController.swift`)**
   - Cấu hình hạn mượn mặc định, mức phạt trễ hạn mỗi ngày, tiền cọc cơ bản lưu trữ qua `UserDefaults`.
   - Quản lý danh mục Thể loại, Nhà xuất bản, Tác giả: Thêm mới bằng nút `+`, vuốt để xóa an toàn.
   - Nạp lại dữ liệu mẫu 10 cuốn sách hoặc xóa trắng dữ liệu để khởi động lại.


---

## 🎓 ĐỐI CHIẾU CHUẨN 4 CHƯƠNG GIẢNG DẠY CỦA THẦY

1. **Chương 1 (Mô hình MVC & Swift OOP)**:
   - Tách biệt rõ ràng 3 tầng: `Models/` (Dữ liệu), `Views/` (`Main.storyboard`), `Controllers/` (Điều khiển).
   - Áp dụng Protocol, Delegate, Closure (`getBackData`), Optional unwrap an toàn.

2. **Chương 2 (Giao diện Storyboard, Auto Layout, UITableView & Sự kiện)**:
   - Giao diện thiết kế 100% bằng **`Main.storyboard`** với Auto Layout constraints chuẩn xác.
   - Các danh sách sử dụng `UITableView`, `UITableViewDelegate`, `UITableViewDataSource`, vuốt xóa bằng `commit editingStyle`.
   - **Tích hợp `UIImagePickerController` & `UITapGestureRecognizer`**: Cho phép chạm vào ảnh bìa trong màn hình Thêm/Sửa sách (`ThemSuaSachViewController`) để tải ảnh từ thư viện máy ảnh (Photo Library).

3. **Chương 3 (Cơ sở dữ liệu trên iOS & DAL / DAO)**:
   - Tổ chức nhóm **`DAL/`** với file `LibraryDAO.swift` đóng vai trò là tầng truy xuất cơ sở dữ liệu (Database Access Layer) theo đúng bài giảng.
   - Hỗ trợ đầy đủ các hàm CRUD: `initDatabase`, `openDatabase`, `insertSach`, `updateSach`, `deleteSach`, `getAllDocGia`, `insertPhieuMuon`, `saveDatabase`.
   - Kiểm thử đơn vị **Unit Test** với framework `XCTest` trong `ThuVienIOSTests.swift` kiểm tra tính hợp lệ của Data Model và quy tắc tính cọc/phạt.

4. **Chương 4 (Bản đồ trực tuyến MapKit & CoreLocation)**:
   - Tích hợp màn hình **`MapController.swift`**:
     - Hiển thị bản đồ `MKMapView` và vị trí hiện tại của người dùng (`showsUserLocation = true`).
     - Đánh dấu các cơ sở thư viện bằng `MKPointAnnotation` (Thư viện Trung Tâm TDC - 53 Võ Văn Ngân, Thủ Đức và các chi nhánh).
     - Bắt sự kiện nhấn giữ `UILongPressGestureRecognizer` để ghim thêm điểm hẹn nhận sách mới.
     - Tính toán lộ trình và chỉ đường bằng `MKDirections` từ vị trí người dùng đến thư viện.
   - Khai báo quyền vị trí `NSLocationWhenInUseUsageDescription` trong `Info.plist`.
