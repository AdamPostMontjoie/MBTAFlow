//
//  LocationClient.swift
//  MBTAFlow
//
//  Created by Adam Post on 5/31/26.
//

import ComposableArchitecture
import CoreLocation

//this will use core location monitoring

enum LocationEvent: Equatable {
    case enteredStop(stopId: String)
    case exitedStop(stopId: String)
    case authorizationDenied
    case monitoringFailed(stopId: String, error: locationError)
}

enum locationError:Error, Equatable {
    case unknown
}

struct LocationClient {
    var startMonitoring: @Sendable (RouteStruct) async throws -> AsyncStream<LocationEvent>
    var stopMonitoring: @Sendable () async throws -> Void
    
}

private actor LocationActor {
    var manager: RegionManager?
    
    func start(route: RouteStruct) async -> AsyncStream<LocationEvent> {
        let stops = route.legs.flatMap { [$0.startStop, $0.endStop] }
        let manager =  await RegionManager(stopSequence: stops)
        self.manager = manager
        await manager.startMonitoring()
        return await manager.eventStream
    }
    
    func stop() {
        manager = nil // triggers onTermination which calls stopAll()
    }
}

private let actor = LocationActor()

extension LocationClient: DependencyKey {
    static let liveValue = Self(
        startMonitoring: { route in
            return await actor.start(route: route)
        },
        stopMonitoring: {
            await actor.stop()
        }
    )
}

extension DependencyValues {
    var locationClient: LocationClient {
        get { self[LocationClient.self] }
        set { self[LocationClient.self] = newValue }
    }
}
