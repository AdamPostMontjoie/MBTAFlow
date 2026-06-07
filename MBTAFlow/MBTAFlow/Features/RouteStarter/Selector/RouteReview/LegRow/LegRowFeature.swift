//
//  LegRowFeature.swift
//  MBTAFlow
//
//  Created by Adam Post on 6/7/26.
//

import ComposableArchitecture
import Foundation

@Reducer
struct LegRowFeature {
    @ObservableState
    struct State: Equatable, Identifiable {
        var id: UUID
        var leg: Leg

        init(id: UUID = UUID(), leg: Leg) {
            self.id = id
            self.leg = leg
        }
    }

    enum Action: Equatable {}

    var body: some ReducerOf<Self> {
        Reduce { _, _ in
            .none
        }
    }
}
