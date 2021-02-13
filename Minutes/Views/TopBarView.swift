//
//  TopBarView.swift
//  Minutes
//
//  Created by Jonathan Bown on 1/12/21.
//

import Foundation
import SwiftUI

struct TopBarView : View {
    
    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            
            VStack(alignment: .leading) {
                Text(getCurrentDate().uppercased())
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("Today")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
            }
            Spacer()
        }
        
    }
    func getCurrentDate(with format: String = "EEEE, MMM d") -> String { let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: Date())
    }
}

