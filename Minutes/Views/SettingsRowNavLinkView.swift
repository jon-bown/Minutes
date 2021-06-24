//
//  SettingsRowNavLinkView.swift
//  Minutes
//
//  Created by Jonathan Bown on 3/2/21.
//

import SwiftUI

struct SettingsRowNavLinkView: View {
    
    var navView: AnyView
    var label: String
    var disabled: Bool
    
    var body: some View {
        Divider().padding(.vertical,4)
        NavigationLink(destination: EmptyView()){
            EmptyView()
        }
        NavigationLink(destination: navView){
            Text(label).foregroundColor(disabled ? Color.gray:Color.white)
            Spacer()
            Image(systemName: "chevron.right")
        }
    }
}

//struct SettingsRowNavLinkView_Previews: PreviewProvider {
//    static var previews: some View {
//        SettingsRowNavLinkView()
//    }
//}
