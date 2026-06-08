//
//  LocationManager.swift
//  MBTAFlow
//
//  Created by Adam Post on 6/7/26.
//

import CoreLocation

@MainActor
class RegionManager: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var continuation: AsyncStream<LocationEvent>.Continuation?
    private var stopSequence: [Stop] = []
    private var currentIndex: Int = 0
    
    // Stream is created once, continuation stored for delegate use
    lazy var eventStream: AsyncStream<LocationEvent> = {
        AsyncStream { [weak self] continuation in
            self?.continuation = continuation
            continuation.onTermination = { [weak self] _ in
                Task {
                    await self?.stopAll()
                }
            }
        }
    }()
    
    init(stopSequence: [Stop]) {
        super.init()
        self.stopSequence = stopSequence
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
    }
    
    func startMonitoring() {
        guard !stopSequence.isEmpty else { return }
        registerRegion(for: stopSequence[0])
    }
    
    private func registerRegion(for stop: Stop) {
        let coordinate = CLLocationCoordinate2D(
            latitude: stop.latitude,
            longitude: stop.longitude
        )
        let region = CLCircularRegion(
            center: coordinate,
            radius: 100,
            identifier: stop.stopName
        )
        region.notifyOnEntry = true
        region.notifyOnExit = true
        
        guard CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) else { return }
        locationManager.startMonitoring(for: region)
    }
    
    private func stopAll() {
        locationManager.monitoredRegions.forEach {
            locationManager.stopMonitoring(for: $0)
        }
        continuation?.finish()
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        continuation?.yield(.enteredStop(stopId: region.identifier))
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        continuation?.yield(.exitedStop(stopId: region.identifier))
        
        // Stop monitoring the region we just left
        if let exitedRegion = manager.monitoredRegions.first(where: { $0.identifier == region.identifier }) {
            manager.stopMonitoring(for: exitedRegion)
        }
        
        // Advance to next stop in sequence
        currentIndex += 1
        if currentIndex < stopSequence.count {
            registerRegion(for: stopSequence[currentIndex])
        } else {
            // Commute complete
            continuation?.finish()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: locationError) {
        if let id = region?.identifier {
            continuation?.yield(.monitoringFailed(stopId: id, error: error))
        }
    }
}
