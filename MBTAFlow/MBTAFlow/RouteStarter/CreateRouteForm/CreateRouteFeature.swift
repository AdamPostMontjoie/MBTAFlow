//
//  CreateStepFeature.swift
//  MBTAFlow
//
//  Created by Adam Post on 5/25/26.
//

import ComposableArchitecture
import Dependencies

@Reducer
struct CreateRouteFeature {
    @ObservableState
    struct State: Equatable {
        var typeOptions: [TransitType] = TransitType.allCases
        var selectedType: TransitType?
        //TODO define
        var branchOptions: [String] = ["Green line branch example"]
        var selectedBranch: String?
        //TODO define
        var directionOptions: [String] = ["Northbound", "Southbound"] //whatever direction api returns
        var selectedDirection: String?
        //TODO define
        var stopOptions: [String] = ["Stop 1", "Stop 2"]
        var selectedStop: String?
        
        var routeId: String?
        var currentFormStep:FormStep = .selectType
    }
    
    //the loaded features will also need to set the options, ommitting for now
    enum Action: Equatable {
        case createButtonTapped
        case transitTypeSelected(TransitType)
        case branchesLoaded(String)
        case branchSelected(String)
        case directionsLoaded(String)
        case directionSelected(String, String)
        case stopsLoaded(String)
        case stopSelected(String)
        
    }
    @Dependency(\.mbtaClient) var mbtaClient: MBTAClient
    @Dependency(\.databaseClient) var databaseClient: DatabaseClient
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .createButtonTapped:
                return .none
            case let .transitTypeSelected(type):
                state.selectedType = type
                switch type.apiStrategy {
                    case let .skipToDirection(routeId):
                        // (Red Line Path)
                        // We already know the ID. Save it, and jump the UI straight to Step 3.
                        state.routeId = routeId
                        state.currentFormStep = .selectDirection
                        //fetch direction
                        return .run { send in
                            let directions = try await mbtaClient.fetchDirections(routeId)
                            await send(.directionsLoaded(directions))
                        }
                        
                    case let .fetchRoutes(filterKey, filterValue):
                        // (Green Line Path)
                        // We need more info. Show a loading state and ask the dumb API client for the data.
                        return .run { send in
                            let branches = try await mbtaClient.fetchRoutes(filterKey, filterValue)
                            await send(.branchesLoaded(branches))
                    }
                }
            case .branchesLoaded:
                state.currentFormStep = .selectBranch
                return .none
            case let .branchSelected(branch):
                state.selectedBranch = branch
                return .run { send in
                    let directions = try await mbtaClient.fetchDirections(branch)
                    await send(.directionsLoaded(directions))
                }
            case .directionsLoaded:
                state.currentFormStep = .selectDirection
                return .none
            case let .directionSelected(direction, routeId):
                state.selectedDirection = direction
                return .run { send in
                    let stops = try await mbtaClient.fetchStops(direction, routeId)
                    await send(.stopsLoaded(stops))
                }
            case .stopsLoaded:
                state.currentFormStep = .selectStop
                return .none
            case let .stopSelected(stop):
                state.selectedStop = stop
                return .none
    
            }
        }
    }
}

enum FormStep: Equatable {
    case selectType
    case selectBranch
    case selectDirection
    case selectStop
}
