//
//  Coordinate.swift
//  Solar
//

import Foundation

/// A place on Earth, latitude first, in decimal degrees.
///
/// North and east are positive, which is the convention every map API and
/// GPS receiver uses; Sydney is `-33.87, 151.21`. Validated on construction
/// so nothing downstream has to check again — see
/// ``SolarError/invalidCoordinate(latitude:longitude:)``.
public struct Coordinate: Sendable, Hashable, Codable {

    /// Degrees north of the equator; negative is south. -90 to 90.
    public let latitude: Double

    /// Degrees east of Greenwich; negative is west. -180 to 180.
    public let longitude: Double

    /// Makes a coordinate, refusing numbers no coordinate system uses.
    ///
    /// - Throws: ``SolarError/invalidCoordinate(latitude:longitude:)`` when
    ///   either value is out of range.
    public init(latitude: Double, longitude: Double) throws {
        guard (-90...90).contains(latitude), (-180...180).contains(longitude),
              latitude.isFinite, longitude.isFinite else {
            throw SolarError.invalidCoordinate(latitude: latitude, longitude: longitude)
        }
        self.latitude = latitude
        self.longitude = longitude
    }
}
