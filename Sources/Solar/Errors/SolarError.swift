//
//  SolarError.swift
//  Solar
//

import Foundation

/// What went wrong, in words a caller can print unchanged.
public enum SolarError: Error, LocalizedError, Equatable, Sendable {

    /// A latitude outside ±90 or a longitude outside ±180.
    ///
    /// The two are easy to swap — "51.5, -0.1" is London and "-0.1, 51.5"
    /// is the Gulf of Guinea, both valid — so the only thing that can be
    /// refused is a number no coordinate system uses at all.
    case invalidCoordinate(latitude: Double, longitude: Double)

    /// The message, with the fix on its second line.
    public var errorDescription: String? {
        switch self {
        case .invalidCoordinate(let latitude, let longitude):
            return """
                not a coordinate: \(latitude), \(longitude)
                latitude runs from -90 to 90 and longitude from -180 to 180, latitude first
                """
        }
    }
}
