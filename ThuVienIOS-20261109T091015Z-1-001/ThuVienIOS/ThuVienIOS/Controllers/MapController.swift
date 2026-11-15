//
//  MapController.swift
//  ThuVienIOS
//
//  MÔ TẢ: Chương 4 - Bản Đồ Trực Tuyến & Định Vị Chi Nhánh Thư Viện (MapKit & CoreLocation)
//  GIẢNG VIÊN: Tiêu Kim Cương - Lập trình Di động trên iOS
//

import UIKit
import MapKit
import CoreLocation

class MapController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var mapView: MKMapView!
    
    private let locationManager = CLLocationManager()
    private var currentRoute: MKRoute?

    // Tọa độ Thư viện Trung Tâm TDC (53 Võ Văn Ngân, TP. Thủ Đức, TP.HCM)
    private let centralLibraryCoordinate = CLLocationCoordinate2D(latitude: 10.85172, longitude: 106.77205)
    // Tọa độ Thư viện Chi nhánh 2
    private let branch2Coordinate = CLLocationCoordinate2D(latitude: 10.85820, longitude: 106.76530)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Bản Đồ Thư Viện"
        view.backgroundColor = .systemBackground

        setupNavigationBar()
        setupMapView()
        setupLocationManager()
        addLibraryAnnotations()
        setupLongPressGesture()
    }

    // MARK: - Setup Navigation Bar
    private func setupNavigationBar() {
        navigationItem.title = "Bản Đồ Thư Viện"
        
        let closeBtn = UIBarButtonItem(title: "Đóng", style: .plain, target: self, action: #selector(backToPrevious))
        navigationItem.leftBarButtonItem = closeBtn

        let directionBtn = UIBarButtonItem(image: UIImage(systemName: "arrow.triangle.turn.up.right.diamond.fill"), style: .plain, target: self, action: #selector(timDuongDenThuVien))
        navigationItem.rightBarButtonItem = directionBtn
    }

    // MARK: - Setup MapView
    private func setupMapView() {
        if mapView == nil {
            let map = MKMapView()
            map.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(map)
            NSLayoutConstraint.activate([
                map.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                map.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                map.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                map.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
            self.mapView = map
        }

        mapView.delegate = self
        mapView.showsUserLocation = true

        // Di chuyển camera tới Thư viện trung tâm
        let region = MKCoordinateRegion(center: centralLibraryCoordinate, latitudinalMeters: 2500, longitudinalMeters: 2500)
        mapView.setRegion(region, animated: true)
    }

    // MARK: - Setup Location Manager
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    // MARK: - Đánh dấu các địa điểm Thư viện (Annotation - Slide Chương 4)
    private func addLibraryAnnotations() {
        // 1. Thư viện Trung Tâm TDC
        let ann1 = MKPointAnnotation()
        ann1.title = "Thư Viện Trung Tâm TDC"
        ann1.subtitle = "53 Võ Văn Ngân, P. Linh Chiểu, TP. Thủ Đức"
        ann1.coordinate = centralLibraryCoordinate
        mapView.addAnnotation(ann1)

        // 2. Chi nhánh 2 - Thư viện Khoa học Công nghệ
        let ann2 = MKPointAnnotation()
        ann2.title = "Thư Viện Chi Nhánh 2 (Sách Công Nghệ)"
        ann2.subtitle = "Cơ sở thực hành & đọc sách số"
        ann2.coordinate = branch2Coordinate
        mapView.addAnnotation(ann2)
    }

    // MARK: - Sự kiện nhấn giữ để ghim thêm điểm hẹn / chi nhánh (LongPressGesture - Slide Chương 4)
    private func setupLongPressGesture() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPress.minimumPressDuration = 1.0 // Giữ 1 giây
        mapView.addGestureRecognizer(longPress)
    }

    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            let touchPoint = gesture.location(in: mapView)
            let coord = mapView.convert(touchPoint, toCoordinateFrom: mapView)

            let alert = UIAlertController(title: "Ghim Địa Điểm Mới", message: "Nhập tên điểm hẹn mượn/trả sách:", preferredStyle: .alert)
            alert.addTextField { tf in tf.placeholder = "VD: Điểm nhận sách KTX..." }
            alert.addAction(UIAlertAction(title: "Hủy", style: .cancel))
            alert.addAction(UIAlertAction(title: "Ghim", style: .default) { [weak self] _ in
                let title = alert.textFields?[0].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Điểm hẹn nhận sách"
                let newAnn = MKPointAnnotation()
                newAnn.title = title
                newAnn.subtitle = "Tọa độ: \(String(format: "%.4f", coord.latitude)), \(String(format: "%.4f", coord.longitude))"
                newAnn.coordinate = coord
                self?.mapView.addAnnotation(newAnn)
            })
            present(alert, animated: true)
        }
    }

    // MARK: - Chỉ đường (MKDirections - Slide Chương 4)
    @objc private func timDuongDenThuVien() {
        guard let userCoord = locationManager.location?.coordinate else {
            let alert = UIAlertController(title: "Vị trí", message: "Đang xác định vị trí của bạn, hoặc bạn có thể mở Cài đặt để cho phép quyền vị trí.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        // Tạo yêu cầu chỉ đường từ vị trí người dùng đến Thư viện trung tâm
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: userCoord))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: centralLibraryCoordinate))
        request.transportType = .automobile

        let directions = MKDirections(request: request)
        directions.calculate { [weak self] response, error in
            guard let self = self, let response = response, let route = response.routes.first else {
                let alert = UIAlertController(title: "Lỗi", message: "Không thể tìm tuyến đường lúc này", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
                return
            }

            // Xóa đường cũ nếu có
            if let old = self.currentRoute {
                self.mapView.removeOverlay(old.polyline)
            }

            self.currentRoute = route
            self.mapView.addOverlay(route.polyline, level: .aboveRoads)

            // Zoom khung nhìn bao quát toàn bộ lộ trình
            self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 80, left: 40, bottom: 80, right: 40), animated: true)

            let km = String(format: "%.1f km", route.distance / 1000.0)
            let phut = Int(route.expectedTravelTime / 60.0)
            let alert = UIAlertController(title: "Đã Tìm Thấy Đường Đi", message: "Khoảng cách đến Thư viện TDC: \(km)\nThời gian dự kiến: khoảng \(phut) phút", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Bắt đầu", style: .default))
            self.present(alert, animated: true)
        }
    }

    // MARK: - Quay về màn hình trước
    @IBAction func backToPrevious(_ sender: Any) {
        if presentingViewController != nil {
            dismiss(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
}

// MARK: - MKMapViewDelegate
extension MapController: MKMapViewDelegate {
    // Tùy chỉnh hiển thị Annotation View (Ghim vị trí)
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }

        let identifier = "LibraryPin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView

        if pinView == nil {
            pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            pinView?.canShowCallout = true
            pinView?.markerTintColor = .appPrimary
            pinView?.glyphImage = UIImage(systemName: "book.fill")
            let btn = UIButton(type: .detailDisclosure)
            pinView?.rightCalloutAccessoryView = btn
        } else {
            pinView?.annotation = annotation
        }

        return pinView
    }

    // Vẽ đường đi trên bản đồ (Overlay)
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = .systemBlue
            renderer.lineWidth = 5.0
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}

// MARK: - CLLocationManagerDelegate
extension MapController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Cập nhật vị trí hiện tại thành công
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Lỗi định vị: \(error.localizedDescription)")
    }
}
