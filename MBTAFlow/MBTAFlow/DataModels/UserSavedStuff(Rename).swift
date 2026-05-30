//
//  Locations.swift
//  MBTAFlow
//
//  Created by Adam Post on 5/30/26.
//
import Foundation

struct Stop: Codable, Equatable {
    var stopName: String
    var longitude: String
    var latitude: String
    var lastStop: Bool
}

struct RouteStruct {
    var stops: [Stop]
    var routeId: UUID
    var name:String
}
