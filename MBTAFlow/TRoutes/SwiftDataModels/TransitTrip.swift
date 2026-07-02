//
//  TransitTrip.swift
//  TRoutes
//
//  Created by Adam Post on 6/28/26.
//

import Foundation
import SwiftData

@Model
final class TransitTripPattern {
    @Attribute(.unique) var tripId: String
    var patternId: String
    var routeId: String
    var directionId: Int
    var serviceId: String
    var headsign: String
    var pattern: TransitPattern?

    init(
        tripId: String,
        patternId: String,
        routeId: String,
        directionId: Int,
        serviceId: String,
        headsign: String,
        pattern: TransitPattern? = nil
    ) {
        self.tripId = tripId
        self.patternId = patternId
        self.routeId = routeId
        self.directionId = directionId
        self.serviceId = serviceId
        self.headsign = headsign
        self.pattern = pattern
    }
}
