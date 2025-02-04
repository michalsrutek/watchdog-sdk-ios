
import Foundation


class SearchVM: NSObject, WebViewMessagesDelegate {
    
    private(set) weak var search: MileusWatchdogSearch!
    
    lazy var messages: [WebViewMessage] = {
        [
            OpenSearchMessage(action: { [weak self] data in self?.openSearch(data: data) }),
            OpenTaxiRideMessage(action: { [weak self] in self?.openTaxiRide() }),
            OpenTaxiRideScreenAndFinishMessage(action: { [weak self] in self?.openTaxiRideAndFinish() }),
            CloseMarketValidationMessage(action: { [weak self] in self?.didFinish() }),
            LocationScanningMessage(action: { [weak self] in self?.startLocationScanning() })
        ]
    }()
    
    var updateCoordinates: (() -> Void)?
    let urlHandler: () -> URL
    
    private let inputSanitizer = InputSanitizer()
    private var mileusWatchdogLocationSync: MileusWatchdogLocationSync?
    
    init(search: MileusWatchdogSearch, urlHandler: @escaping () -> URL) {
        self.search = search
        self.urlHandler = urlHandler
        
        super.init()
    }
    
    deinit {
        debugPrint("DEINIT: \(String(describing: self))")
    }
    
    func getURL() -> URL {
        return urlHandler()
    }
    
    func getOrigin() -> String? {
        if let location = search.location(of: .origin) {
            return formatLocation(location: location)
        }
        return nil
    }
    
    func getDestination() -> String? {
        if let location = search.location(of: .destination) {
            return formatLocation(location: location)
        }
        return nil
    }
    
    func getHome() -> String? {
        if let location = search.location(of: .home) {
            return formatLocation(location: location)
        }
        return nil
    }
    
    func coordinatesUpdated() {
        updateCoordinates?()
    }
    
    func didFinish() {
        DispatchQueue.main.async { [unowned self] in
            self.search?.delegate?.mileusDidFinish(self.search)
        }
    }
    
    func openSearch(data: MileusWatchdogLabeledLocation) {
        let searchData = MileusWatchdogSearchData(
            type: data.label.searchType,
            location: data.data
        )
        DispatchQueue.main.async {
            self.search?.delegate?.mileus(self.search, showSearch: searchData)
        }
    }
    
    func openTaxiRide() {
        DispatchQueue.main.async {
            self.search?.delegate?.mileusShowTaxiRide(self.search)
        }
    }
    
    func openTaxiRideAndFinish() {
        DispatchQueue.main.async {
            self.search?.delegate?.mileusShowTaxiRideAndFinish(self.search)
        }
    }
    
    private func formatLocation(location: MileusWatchdogLocation) -> String {
        return "{'lat': \(location.latitude), 'lon': \(location.longitude), 'address_line_1': '\(inputSanitizer.sanitizeJS(location.address?.firstLine ?? ""))', 'address_line_2': '\(inputSanitizer.sanitizeJS(location.address?.secondLine ?? ""))', 'accuracy': \(location.accuracy)}"
    }
    
    private func startLocationScanning() {
        if mileusWatchdogLocationSync == nil {
            mileusWatchdogLocationSync = try? MileusWatchdogLocationSync()
        }
        mileusWatchdogLocationSync?.start(completion: { [weak self] in
            self?.mileusWatchdogLocationSync = nil
        })
    }
    
}
