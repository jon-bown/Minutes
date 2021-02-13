//
//  HalfCapsuleShape.swift
//  Minutes
//
//  Created by Jonathan Bown on 2/2/21.
//

import SwiftUI


struct HalfCapsuleShape: Shape {
    func path(in rect: CGRect) -> Path {
        
        let bezPath = UIBezierPath(roundedRect: rect, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 100, height: 100))
        
        let path = Path(bezPath.cgPath)
        return path
    }
}

struct ShapeView: View {
    var body: some View {
        VStack{
            HalfCapsuleShape().foregroundColor(.white).rotationEffect(.degrees(90))
            
            Text("Half Capsule")
            
            Spacer()
        }
    }
}

struct HalfCapsuleShape_Previews: PreviewProvider {
    static var previews: some View {
        ShapeView()
    }
}
