//
//  Extensions.swift
//  Daily Minutes
//
//  Created by Jonathan Bown on 8/13/20.
//

import Foundation
import CoreData
import UIKit
import SwiftUI



// 1. Subclass from `NSSecureUnarchiveFromDataTransformer`
@objc(UIColorValueTransformer)
final class UIColorValueTransformer: NSSecureUnarchiveFromDataTransformer {

    /// The name of the transformer. This is the name used to register the transformer using `ValueTransformer.setValueTrandformer(_"forName:)`.
    static let name = NSValueTransformerName(rawValue: String(describing: UIColorValueTransformer.self))

    // 2. Make sure `UIColor` is in the allowed class list.
    override static var allowedTopLevelClasses: [AnyClass] {
        return [UIColor.self]
    }

    /// Registers the transformer.
    public static func register() {
        let transformer = UIColorValueTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }
}


