//
//  JsonBuilderTrip.swift
//  TRoutes
//
//  Created by Adam Post on 7/2/26.
//

struct JsonBuilderTrip: Decodable, Equatable {
    let tripId: String
    let routeId: String
    let directionId: Int
    let patternId: String
    let serviceId: String
    let headsign: String
}
