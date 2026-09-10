//
//  CoordinateTests.swift
//  Solar
//
//  The edges of the globe, and one step past each of them.
//

import XCTest
@testable import Solar

final class CoordinateTests: XCTestCase {

    func testAnOrdinaryCoordinateIsAccepted() throws {
        let place = try Coordinate(latitude: 51.5, longitude: -0.1)
        XCTAssertEqual(place.latitude, 51.5)
        XCTAssertEqual(place.longitude, -0.1)
    }

    func testBothPolesAreValidLatitudes() throws {
        XCTAssertEqual(try Coordinate(latitude: 90, longitude: 0).latitude, 90)
        XCTAssertEqual(try Coordinate(latitude: -90, longitude: 0).latitude, -90)
    }

    func testBothSidesOfTheDateLineAreValidLongitudes() throws {
        XCTAssertEqual(try Coordinate(latitude: 0, longitude: 180).longitude, 180)
        XCTAssertEqual(try Coordinate(latitude: 0, longitude: -180).longitude, -180)
    }

    func testOneStepPastEitherPoleIsRefused() {
        XCTAssertThrowsError(try Coordinate(latitude: 90.0001, longitude: 0))
        XCTAssertThrowsError(try Coordinate(latitude: -90.0001, longitude: 0))
    }

    func testOneStepPastTheDateLineIsRefused() {
        XCTAssertThrowsError(try Coordinate(latitude: 0, longitude: 180.0001))
        XCTAssertThrowsError(try Coordinate(latitude: 0, longitude: -180.0001))
    }

    func testNotANumberAndInfinityAreRefused() {
        XCTAssertThrowsError(try Coordinate(latitude: .nan, longitude: 0))
        XCTAssertThrowsError(try Coordinate(latitude: 0, longitude: .infinity))
        XCTAssertThrowsError(try Coordinate(latitude: -.infinity, longitude: 0))
    }

    func testTheErrorCarriesBothNumbersAndSaysWhichComesFirst() {
        XCTAssertThrowsError(try Coordinate(latitude: 151.2, longitude: -33.9)) { error in
            XCTAssertEqual(error as? SolarError, .invalidCoordinate(latitude: 151.2, longitude: -33.9))
            let text = error.localizedDescription
            XCTAssertTrue(text.contains("151.2"), text)
            XCTAssertTrue(text.contains("latitude first"), text)
        }
    }

    func testACoordinateRoundTripsThroughCodable() throws {
        XCTAssertEqual(try roundTrip(Place.sydney), Place.sydney)
    }
}
