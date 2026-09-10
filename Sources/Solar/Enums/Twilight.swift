//
//  Twilight.swift
//  Solar
//

import Foundation

/// The three twilights, by how far the sun is below the horizon.
///
/// The definitions are the International Astronomical Union's and every
/// almanac agrees on them, which is rarer than it sounds: civil is the
/// light you can still read a newspaper by, nautical is the last of the
/// horizon a navigator can shoot a star against, astronomical is the sky
/// being fully dark for an observatory.
public enum Twilight: String, CaseIterable, Sendable, Codable {

    /// Sun between the horizon and 6° below it.
    case civil

    /// Sun between 6° and 12° below the horizon.
    case nautical

    /// Sun between 12° and 18° below the horizon.
    case astronomical

    /// The altitude of the sun's centre that ends this twilight, in degrees.
    public var altitude: Double {
        switch self {
        case .civil:        -6
        case .nautical:     -12
        case .astronomical: -18
        }
    }
}
