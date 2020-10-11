//
//  MainProgressView.swift
//  Minutes
//
//  Created by Jonathan Bown on 8/20/20.
//

import SwiftUI

struct MainProgressView: View {

    @State private var showNewGoalForm: Bool = false
    var body: some View {
        NavigationView{
        VStack{
            
            ProgressRings().padding(10)
            
            GoalListView()
            
        }.navigationBarTitle(Text("Summary"), displayMode: .large).navigationBarItems(trailing: Button(action: {
            self.showNewGoalForm.toggle()
        }){
            Image(systemName: "plus").font(Font.system(size: 50, weight: .regular))
        }.popover(
            isPresented: self.$showNewGoalForm,
            arrowEdge: .bottom
        ) {
            
            NewGoalForm(isPresented: self.$showNewGoalForm)
            
        })
        }
        
    }
}

struct MainProgressView_Previews: PreviewProvider {
    static var previews: some View {
        MainProgressView()
    }
}
