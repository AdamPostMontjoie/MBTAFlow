//
//  RouteReviewFeature.swift
//  MBTAFlow
//
//  Created by Adam Post on 5/31/26.
//

import ComposableArchitecture
import Foundation

@Reducer
struct RouteReviewFeature {
    @ObservableState
    struct State: Equatable {
        var route: RouteStruct
        var legRows: IdentifiedArrayOf<LegRowFeature.State> = []

        init(route: RouteStruct) {
            self.route = route
            self.legRows = IdentifiedArray(
                uniqueElements: route.legs.map { LegRowFeature.State(leg: $0) }
            )
        }
    }

    enum Action: Equatable {
        case editNameButtonTapped(String)
        case deleteRouteButtonTapped
        case delegate(Delegate)
        case legRows(IdentifiedActionOf<LegRowFeature>)

        enum Delegate: Equatable {
            case deleteRoute(UUID)
            case updateRoute(RouteStruct)
        }
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .editNameButtonTapped(newName):
                state.route.name = newName
                return .send(.delegate(.updateRoute(state.route)))

            case .deleteRouteButtonTapped:
                return .send(.delegate(.deleteRoute(state.route.id)))

            case .delegate:
                return .none

            case .legRows:
                return .none
            }
        }
        .forEach(\.legRows, action: \.legRows) {
            LegRowFeature()
        }
    }
}
