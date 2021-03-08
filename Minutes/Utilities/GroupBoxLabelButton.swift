//
//  GroupBoxLabelButton.swift
//  Minutes
//
//  Created by Jonathan Bown on 3/5/21.
//

import SwiftUI

struct GroupBoxLabelButton: View {
    var label: String
    var action: () -> Void
    var body: some View {
        HStack{
            Text(label).bold()
            Spacer()
            Button(action: {
                self.action()
            }){
                Image(systemName: "plus")
            }
            
        }
    }
}

struct GroupBoxLabelButton_Previews: PreviewProvider {
    static var previews: some View {
        GroupBoxLabelButton(label: "Test", action: {})
    }
}
