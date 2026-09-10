//
//  SunPositionTests.swift
//  Solar
//
//  Where the sun stands, and whether that counts as daylight.
//

import XCTest
@testable import Solar

final class SunPositionTests: XCTestCase {

    func testAtNoonOnTheSolsticeGreenwichSeesTheSunAtSixtyTwoDegreesDueSouth() {
        // 90 - 51.48 + 23.44: the geometry every textbook draws.
        let day = Solar.day(localNoon("2026-06-21", in: london), at: Place.greenwich, in: london)
        let position = Solar.position(at: day.solarNoon, coordinate: Place.greenwich)
        XCTAssertEqual(position.altitude, 61.96, accuracy: 0.05)
        XCTAssertEqual(position.azimuth, 180, accuracy: 0.1)
    }

    func testAtNoonOnTheEquinoxQuitoHasTheSunOverhead() {
        let day = Solar.day(localNoon("2026-03-20", in: guayaquil), at: Place.quito, in: guayaquil)
        let position = Solar.position(at: day.solarNoon, coordinate: Place.quito)
        XCTAssertGreaterThan(position.altitude, 89.5)
        XCTAssertEqual(position.apparentAltitude, position.altitude, "no refraction above 85°")
    }

    func testAtTheEquinoxTheSunRisesDueEast() throws {
        let day = Solar.day(localNoon("2026-03-20", in: utc), at: Place.equator, in: utc)
        let position = Solar.position(at: try XCTUnwrap(day.sunrise.date), coordinate: Place.equator)
        XCTAssertEqual(position.azimuth, 90, accuracy: 1)
        XCTAssertEqual(position.altitude, -0.833, accuracy: 0.05)
    }

    func testAtMidnightTheSunIsWellBelowTheHorizon() {
        let position = Solar.position(at: wall("2026-12-21 00:00", in: london), coordinate: Place.greenwich)
        XCTAssertLessThan(position.altitude, -50)
    }

    func testRefractionLiftsTheSunAboutHalfADegreeAtTheHorizon() throws {
        let day = Solar.day(localNoon("2026-06-21", in: london), at: Place.greenwich, in: london)
        let position = Solar.position(at: try XCTUnwrap(day.sunrise.date), coordinate: Place.greenwich)
        let lift = position.apparentAltitude - position.altitude
        XCTAssertGreaterThan(lift, 0.3)
        XCTAssertLessThan(lift, 0.6)
    }

    func testAtTheNorthPoleInJuneTheSunCirclesAtTheDeclination() {
        for hour in ["00:00", "06:00", "12:00", "18:00"] {
            let position = Solar.position(at: wall("2026-06-21 \(hour)", in: utc), coordinate: Place.northPole)
            XCTAssertEqual(position.altitude, 23.44, accuracy: 0.1, hour)
            XCTAssertTrue((0..<360).contains(position.azimuth))
        }
    }

    func testASunPositionRoundTripsThroughCodable() throws {
        let position = SunPosition(altitude: 10.5, apparentAltitude: 10.6, azimuth: 123.4)
        XCTAssertEqual(try roundTrip(position), position)
    }

    // MARK: - isDaylight

    func testNoonIsDaylightAndMidnightIsNot() {
        XCTAssertTrue(Solar.isDaylight(at: wall("2026-06-21 12:00", in: london), coordinate: Place.greenwich))
        XCTAssertFalse(Solar.isDaylight(at: wall("2026-06-21 00:00", in: london), coordinate: Place.greenwich))
    }

    func testDaylightFlipsAcrossSunrise() throws {
        let day = Solar.day(localNoon("2026-06-21", in: london), at: Place.greenwich, in: london)
        let sunrise = try XCTUnwrap(day.sunrise.date)
        XCTAssertFalse(Solar.isDaylight(at: sunrise.addingTimeInterval(-120), coordinate: Place.greenwich))
        XCTAssertTrue(Solar.isDaylight(at: sunrise.addingTimeInterval(120), coordinate: Place.greenwich))
    }

    func testPolarDayAndNightAnswerAtAnyHour() {
        XCTAssertTrue(Solar.isDaylight(at: wall("2026-06-21 00:30", in: oslo), coordinate: Place.tromso))
        XCTAssertFalse(Solar.isDaylight(at: wall("2026-12-21 12:00", in: oslo), coordinate: Place.tromso))
    }
}
