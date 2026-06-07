//
//  RouteReviewView.swift
//  MBTAFlow
//
//  Created by Adam Post on 5/31/26.
//

import ComposableArchitecture
import SwiftUI

struct RouteReviewView: View {
    @Bindable var store: StoreOf<RouteReviewFeature>

    var body: some View {
        List {
            Section {
                Text(store.route.name)
                    .font(.headline)
            }

            Section(header: Text("Legs")) {
                ForEach(
                    store.scope(state: \.legRows, action: \.legRows)
                ) { childStore in
                    LegRowView(store: childStore)
                }
            }
        }
        .navigationTitle("Review Route")
    }
}
