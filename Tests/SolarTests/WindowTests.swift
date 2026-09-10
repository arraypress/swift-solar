//
//  WindowTests.swift
//  Solar
//
//  Golden hour and blue hour: present, absent, and running to noon.
//

import XCTest
@testable import Solar

final class WindowTests: XCTestCase {

    func testGoldenHourBracketsSunriseAndSunsetOnAnOrdinaryDay() throws {
        let day = Solar.day(localNoon("2026-06-21", in: london), at: Place.greenwich, in: london)
        let windows = Solar.goldenHour(on: localNoon("2026-06-21", in: london), at: Place.greenwich, in: london)
        let morning = try XCTUnwrap(windows.morning), evening = try XCTUnwrap(windows.evening)
        let sunrise = try XCTUnwrap(day.sunrise.date), sunset = try XCTUnwrap(day.sunset.date)
        XCTAssertLessThan(morning.start, sunrise)
        XCTAssertGreaterThan(morning.end, sunrise)
        XCTAssertLessThan(evening.start, sunset)
        XCTAssertGreaterThan(evening.end, sunset)
        // From -4° to +6° takes 82 minutes at 51° north in June: the sun
        // rises at a shallow angle there, not straight up as at the equator,
        // where the same ten degrees take forty minutes.
        XCTAssertEqual(morning.duration, 82 * 60, accuracy: 5 * 60)
        let equator = Solar.goldenHour(on: localNoon("2026-03-20", in: utc), at: Place.equator, in: utc)
        XCTAssertEqual(try XCTUnwrap(equator.morning).duration, 40 * 60, accuracy: 5 * 60)
    }

    func testBlueHourStartsAtCivilDawnAndEndsBeforeSunrise() throws {
        let day = Solar.day(localNoon("2026-12-21", in: london), at: Place.greenwich, in: london)
        let windows = Solar.blueHour(on: localNoon("2026-12-21", in: london), at: Place.greenwich, in: london)
        let morning = try XCTUnwrap(windows.morning), evening = try XCTUnwrap(windows.evening)
        XCTAssertEqual(morning.start.timeIntervalSince(try XCTUnwrap(day.civilDawn.date)), 0, accuracy: 1)
        XCTAssertLessThan(morning.end, try XCTUnwrap(day.sunrise.date))
        XCTAssertGreaterThan(evening.start, try XCTUnwrap(day.sunset.date))
        XCTAssertEqual(evening.end.timeIntervalSince(try XCTUnwrap(day.civilDusk.date)), 0, accuracy: 1)
    }

    func testWhereTheSunNeverGetsLowThereIsNoGoldenOrBlueHour() {
        let date = localNoon("2026-06-21", in: oslo)
        let golden = Solar.goldenHour(on: date, at: Place.tromso, in: oslo)
        let blue = Solar.blueHour(on: date, at: Place.tromso, in: oslo)
        XCTAssertNil(golden.morning)
        XCTAssertNil(golden.evening)
        XCTAssertNil(blue.morning)
        XCTAssertNil(blue.evening)
    }

    func testWhereTheSunNeverGetsHighGoldenHourRunsToNoon() throws {
        let date = localNoon("2026-12-21", in: oslo)
        let day = Solar.day(date, at: Place.tromso, in: oslo)
        let golden = Solar.goldenHour(on: date, at: Place.tromso, in: oslo)
        let morning = try XCTUnwrap(golden.morning), evening = try XCTUnwrap(golden.evening)
        XCTAssertEqual(morning.end, day.solarNoon)
        XCTAssertEqual(evening.start, day.solarNoon)
        XCTAssertLessThan(morning.start, morning.end)
    }

    func testABlueHourWithOnlyOneEdgeIsReportedAsNone() throws {
        // At 61° north in June the sun dips to about -5.5°: it crosses -4°
        // but never -6°, so the blue light runs across midnight with no edges.
        let date = localNoon("2026-06-21", in: utc)
        let blue = Solar.blueHour(on: date, at: Place.sixtyOneNorth, in: utc)
        XCTAssertNil(blue.morning)
        XCTAssertNil(blue.evening)
        let golden = Solar.goldenHour(on: date, at: Place.sixtyOneNorth, in: utc)
        XCTAssertNotNil(golden.morning)
        XCTAssertNotNil(golden.evening)
    }

    func testTheWindowsDefaultToUTC() {
        let date = instant("2026-06-21T12:00:00Z")
        XCTAssertEqual(Solar.goldenHour(on: date, at: Place.greenwich), Solar.goldenHour(on: date, at: Place.greenwich, in: .gmt))
        XCTAssertEqual(Solar.blueHour(on: date, at: Place.greenwich), Solar.blueHour(on: date, at: Place.greenwich, in: .gmt))
    }

    func testWindowsRoundTripThroughCodable() throws {
        let windows = Solar.goldenHour(on: localNoon("2026-06-21", in: london), at: Place.greenwich, in: london)
        XCTAssertEqual(try roundTrip(windows), windows)
        let none = SolarWindows(morning: nil, evening: nil)
        XCTAssertEqual(try roundTrip(none), none)
    }
}
