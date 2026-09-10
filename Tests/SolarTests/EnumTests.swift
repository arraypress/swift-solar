//
//  EnumTests.swift
//  Solar
//
//  Every case of every public enum, its label, and its trip through JSON.
//

import XCTest
@testable import Solar

final class EnumTests: XCTestCase {

    // MARK: - SolarEvent

    func testAnEventThatHappenedExposesItsDate() {
        let date = instant("2026-06-21T03:42:44Z")
        XCTAssertEqual(SolarEvent.at(date).date, date)
        XCTAssertTrue(SolarEvent.at(date).occurred)
    }

    func testPolarEventsHaveNoDate() {
        XCTAssertNil(SolarEvent.polarDay.date)
        XCTAssertNil(SolarEvent.polarNight.date)
        XCTAssertFalse(SolarEvent.polarDay.occurred)
        XCTAssertFalse(SolarEvent.polarNight.occurred)
    }

    func testEveryEventCaseRoundTripsThroughCodable() throws {
        let cases: [SolarEvent] = [.at(instant("2026-06-21T03:42:44Z")), .polarDay, .polarNight]
        for event in cases {
            XCTAssertEqual(try roundTrip(event), event)
        }
    }

    // MARK: - Twilight

    func testTheThreeTwilightsHaveTheAlmanacAltitudes() {
        XCTAssertEqual(Twilight.civil.altitude, -6)
        XCTAssertEqual(Twilight.nautical.altitude, -12)
        XCTAssertEqual(Twilight.astronomical.altitude, -18)
        XCTAssertEqual(Twilight.allCases.count, 3)
    }

    func testEveryTwilightRoundTripsThroughCodable() throws {
        for twilight in Twilight.allCases {
            XCTAssertEqual(try roundTrip(twilight), twilight)
        }
    }

    // MARK: - MoonPhaseName

    func testTheEightPhasesRunFromNewBackToNewInOrder() {
        XCTAssertEqual(MoonPhaseName.allCases, [
            .new, .waxingCrescent, .firstQuarter, .waxingGibbous,
            .full, .waningGibbous, .lastQuarter, .waningCrescent,
        ])
    }

    func testEveryPhaseHasACalendarLabel() {
        let labels = MoonPhaseName.allCases.map(\.label)
        XCTAssertEqual(labels, [
            "New Moon", "Waxing Crescent", "First Quarter", "Waxing Gibbous",
            "Full Moon", "Waning Gibbous", "Last Quarter", "Waning Crescent",
        ])
    }

    func testEveryPhaseNameRoundTripsThroughCodable() throws {
        for name in MoonPhaseName.allCases {
            XCTAssertEqual(try roundTrip(name), name)
        }
    }

    // MARK: - SolarError

    func testTheErrorDescriptionIsPrintableAsIs() {
        let error = SolarError.invalidCoordinate(latitude: 91, longitude: 0)
        XCTAssertEqual(error.errorDescription?.hasPrefix("not a coordinate: 91.0, 0.0"), true)
    }
}
