//
//  SavedBox.swift
//  Minutes
//
//  Created by Jonathan Bown on 2/10/21.
//

import SwiftUI



struct Toast<Presenting>: View where Presenting: View {
    
    /// The binding that decides the appropriate drawing in the body.
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var isShowing: Bool
    /// The view that will be "presenting" this toast
    let presenting: () -> Presenting
    /// The text to show
    let text: Text
    
    var body: some View {
        if self.isShowing {             DispatchQueue.main.asyncAfter(deadline: .now() + 1) {                 self.isShowing = false             }         }
        return GeometryReader { geometry in
            
            ZStack(alignment: .center) {
                
                self.presenting()
                    .blur(radius: self.isShowing ? 0 : 0)
                
                VStack {
                    Image(systemName: "checkmark").font(.system(size: 40, weight: .bold)).padding()
                    self.text
                }
                .frame(width: geometry.size.width / 2,
                       height: geometry.size.height / 5)
                .background(Color.blue)
                //.background(Color.secondary.colorInvert())
                .foregroundColor(Color.primary)
                .cornerRadius(20)
                .transition(.slide)
                .opacity(self.isShowing ? 1 : 0)
                
            }
            
        }
        
    }
    
}


extension View {
    
    func toast(isShowing: Binding<Bool>, text: Text) -> some View {
        Toast(isShowing: isShowing,
              presenting: { self },
              text: text)
    }
    
}


