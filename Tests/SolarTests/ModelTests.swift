//
//  ModelTests.swift
//  Solar
//
//  The public initialisers store what they are given, so a caller can build
//  a value by hand — for a fixture, or a preview — and get it back unchanged.
//

import XCTest
@testable import Solar

final class ModelTests: XCTestCase {

    func testASolarDayBuiltByHandKeepsEveryField() throws {
        let start = wall("2026-06-21 00:00", in: london), end = wall("2026-06-22 00:00", in: london)
        let noon = wall("2026-06-21 13:02", in: london)
        let day = SolarDay(
            start: start, end: end, timeZone: london, coordinate: Place.greenwich,
            sunrise: .at(wall("2026-06-21 04:43", in: london)), sunset: .polarDay, solarNoon: noon, dayLength: 86_400,
            civilDawn: .polarDay, civilDusk: .polarNight,
            nauticalDawn: .at(noon), nauticalDusk: .polarDay,
            astronomicalDawn: .polarNight, astronomicalDusk: .at(noon)
        )
        XCTAssertEqual(day.start, start)
        XCTAssertEqual(day.end, end)
        XCTAssertEqual(day.timeZone, london)
        XCTAssertEqual(day.coordinate, Place.greenwich)
        XCTAssertEqual(day.sunrise, .at(wall("2026-06-21 04:43", in: london)))
        XCTAssertEqual(day.sunset, .polarDay)
        XCTAssertEqual(day.solarNoon, noon)
        XCTAssertEqual(day.dayLength, 86_400)
        XCTAssertEqual(day.civilDawn, .polarDay)
        XCTAssertEqual(day.civilDusk, .polarNight)
        XCTAssertEqual(day.nauticalDawn, .at(noon))
        XCTAssertEqual(day.nauticalDusk, .polarDay)
        XCTAssertEqual(day.astronomicalDawn, .polarNight)
        XCTAssertEqual(day.astronomicalDusk, .at(noon))
        XCTAssertEqual(try roundTrip(day), day)
    }

    func testAMoonPhaseBuiltByHandKeepsEveryField() throws {
        let new = instant("2026-06-15T02:54:00Z"), full = instant("2026-06-29T23:56:00Z"), next = instant("2026-07-14T09:43:00Z")
        let moon = MoonPhase(
            illuminatedFraction: 0.45, age: 6.4, isWaxing: true, name: .firstQuarter,
            lastNewMoon: new, nextNewMoon: next, nextFullMoon: full
        )
        XCTAssertEqual(moon.illuminatedFraction, 0.45)
        XCTAssertEqual(moon.age, 6.4)
        XCTAssertTrue(moon.isWaxing)
        XCTAssertEqual(moon.name, .firstQuarter)
        XCTAssertEqual(moon.lastNewMoon, new)
        XCTAssertEqual(moon.nextNewMoon, next)
        XCTAssertEqual(moon.nextFullMoon, full)
        XCTAssertEqual(try roundTrip(moon), moon)
    }
}
