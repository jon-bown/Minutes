//
//  ContentView.swift
//  Watch Minutes Extension
//
//  Created by Jonathan Bown on 1/14/21.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.appDelegate) var delegate


    var body: some View {
        GoalDashboard().environment(\.appDelegate, delegate)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
