//
//  GroupBoxLabelButton.swift
//  Minutes
//
//  Created by Jonathan Bown on 3/5/21.
//

import SwiftUI

struct GroupBoxLabelButton: View {
    var label: String
    @Binding var isEditable: Bool
    var action: () -> Bool

    var body: some View {
        HStack{
            Text(label).bold()
            Spacer()
            Button(action: {
                self.isEditable = self.action()
            }){
                if(self.isEditable){
                    Text("Done").foregroundColor(.white)
                }
                else {
                    Text("Select").foregroundColor(.white)
                }
            }
            
        }
    }
}

//struct GroupBoxLabelButton_Previews: PreviewProvider {
//    static var previews: some View {
//        GroupBoxLabelButton(label: "Test", action: {return false})
//    }
//}
