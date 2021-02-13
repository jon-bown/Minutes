//
//  DropDownMenu.swift
//  Minutes
//
//  Created by Jonathan Bown on 1/27/21.
//

import SwiftUI

struct DropDownMenu: View {
    @Binding var selection: String
    @State var expand = false
    var body: some View {
        VStack() {
            VStack(spacing: 20){
                HStack {
                    Text(self.selection).fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/).foregroundColor(.white)
                    Image(systemName: expand ? "chevron.up":"chevron.down").resizable().frame(width: 13, height: 6).foregroundColor(.gray)
                }.onTapGesture {
                    self.expand.toggle()
                }
                if expand {
                    
                    DropDownMenuButton(selectionString: self.$selection, expanding: self.$expand, description: "Today")
                    
                    DropDownMenuButton(selectionString: self.$selection, expanding: self.$expand, description: "All")

                }
            }
        }.padding().cornerRadius(15).animation(.spring())
    }
}



struct DropDownMenuButton: View {
    @Binding var selectionString: String
    @Binding var expanding: Bool
    var description: String
    var body: some View {
        Button(action:{
            self.expanding.toggle()
            self.selectionString = self.description
        }){
            Text(self.description).padding()
            if self.selectionString == self.description{
                Image(systemName: "checkmark").resizable().frame(width: 13, height: 6).foregroundColor(.gray)
            }

        }.foregroundColor(.white)
    }
}
//struct DropDownMenu_Previews: PreviewProvider {
//    static var previews: some View {
//        DropDownMenu()
//    }
//}
