//
//  Route.swift
//  MBTAFlow
//
//  Created by Adam Post on 5/30/26.
//

import Foundation
import SwiftData

@Model
final class Route{
    var stops: [Stop]
    var name: String
    var localRouteId:UUID
    var timeStamp: Date
    

    init(routeId: UUID, name: String, stops: [Stop], timeStamp:Date)
    {
        self.localRouteId = routeId
        self.name = name
        self.stops = stops
        self.timeStamp = timeStamp
    }
    
}
