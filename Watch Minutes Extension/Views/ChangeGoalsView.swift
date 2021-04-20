//
//  ChangeGoalsView.swift
//  Watch Minutes Extension
//
//  Created by Jonathan Bown on 4/11/21.
//

import SwiftUI

struct ChangeGoalsView: View {
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        NavigationView {
            VStack{
                Text("Goal Name").padding()
       
                HStack{
                    Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/){
                        Image(systemName: "minus")
                    }
                    Text("Goal Minutes")
                    Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/){
                        Image(systemName: "plus")
                    }
                    
                }
                Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/){
                    Text("Save")
                }.background(Capsule().foregroundColor(Color.blue))
                //Button
            }
        }
        
    }
}

struct ChangeGoalsView_Previews: PreviewProvider {
    static var previews: some View {
        ChangeGoalsView()
    }
}
