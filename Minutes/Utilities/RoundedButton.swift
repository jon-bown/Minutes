//
//  RoundedButton.swift
//  Minutes
//
//  Created by Jonathan Bown on 8/20/20.
//

import SwiftUI


struct RoundedButton : View {
    var body: some View {
        Button(action: {}) {
            HStack {
                Spacer()
                Text("Save")
                    .font(.headline)
                    .foregroundColor(Color.white)
                Spacer()
            }
        }
        .padding(.vertical, 10.0)
        .background(Color.red)
        .cornerRadius(4.0)
        .padding(.horizontal, 50)
    }
}

struct RoundedButton_Previews: PreviewProvider {
    static var previews: some View {
        RoundedButton()
    }
}
