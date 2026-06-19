//
//  JourneyEngine.swift
//  MBTAFlow
//
//  Created by Adam Post on 6/17/26.
//

import ComposableArchitecture

//rename?
enum LocationEvent: Equatable {
    case enteredStop(stopId: String)
    case exitedStop(stopId: String)
    case authorizationDenied
    case monitoringFailed(stopId: String, error: locationError)
}

///Manages Reacting to Journey Events
actor JourneyEngine {
    
    ///Singleton
    static let shared = JourneyEngine()
    
    @Dependency(\.userDefaultsClient) var userDefaultsClient
    @Dependency(\.locationClient) var locationClient
    @Dependency(\.notificationsClient) var notificationsClient
    @Dependency(\.mbtaClient) var mbtaClient
    
    init(){
        
    }
    
    func startListeningToLocationEvents() {
        //listen to stream
        //each event will send to a func that determines what it is, like .locationsupdatereceived
        
    }
    
    func locationEventReceived(_ event: LocationEvent) {
        
    }
    
    
    
    
}

