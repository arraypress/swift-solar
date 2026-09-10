//
//  MoonTests.swift
//  Solar
//
//  The moon against the US Naval Observatory's 2026 phase table,
//  https://aa.usno.navy.mil/api/moon/phases/year?year=2026 (times in UT),
//  and its illuminated fractions from the rstt/oneday answers.
//

import XCTest
@testable import Solar

final class MoonTests: XCTestCase {

    /// USNO: Full Moon 2026-01-03 10:03.
    func testAFullMoonIsFullyLit() {
        let moon = Moon.phase(at: instant("2026-01-03T10:03:00Z"))
        XCTAssertGreaterThan(moon.illuminatedFraction, 0.99)
        XCTAssertEqual(moon.name, .full)
        XCTAssertEqual(moon.age, 14.3, accuracy: 0.3)
    }

    /// USNO: New Moon 2026-03-19 01:23.
    func testANewMoonIsDark() {
        let moon = Moon.phase(at: instant("2026-03-19T01:23:00Z"))
        XCTAssertLessThan(moon.illuminatedFraction, 0.01)
        XCTAssertEqual(moon.name, .new)
    }

    /// USNO: First Quarter 2026-01-26 04:47, Last Quarter 2026-01-10 15:48.
    func testTheQuartersAreHalfLitAndNamedByDirection() {
        let first = Moon.phase(at: instant("2026-01-26T04:47:00Z"))
        XCTAssertEqual(first.illuminatedFraction, 0.5, accuracy: 0.02)
        XCTAssertEqual(first.name, .firstQuarter)
        XCTAssertTrue(first.isWaxing)

        let last = Moon.phase(at: instant("2026-01-10T15:48:00Z"))
        XCTAssertEqual(last.illuminatedFraction, 0.5, accuracy: 0.02)
        XCTAssertEqual(last.name, .lastQuarter)
        XCTAssertFalse(last.isWaxing)
    }

    func testTheCrescentsAndGibbousPhasesFallInTheirEighths() {
        XCTAssertEqual(Moon.phase(at: instant("2026-03-22T12:00:00Z")).name, .waxingCrescent)
        XCTAssertEqual(Moon.phase(at: instant("2026-12-21T12:00:00Z")).name, .waxingGibbous)
        XCTAssertEqual(Moon.phase(at: instant("2026-01-06T12:00:00Z")).name, .waningGibbous)
        XCTAssertEqual(Moon.phase(at: instant("2026-01-15T12:00:00Z")).name, .waningCrescent)
    }

    /// USNO fracillum: 45% on 2026-06-21, 90% on 2026-12-21, 4% on 2026-03-20.
    func testTheLitFractionMatchesTheAlmanacOnOrdinaryDays() {
        XCTAssertEqual(Moon.phase(at: instant("2026-06-21T12:00:00Z")).illuminatedFraction, 0.45, accuracy: 0.03)
        XCTAssertEqual(Moon.phase(at: instant("2026-12-21T12:00:00Z")).illuminatedFraction, 0.90, accuracy: 0.03)
        XCTAssertEqual(Moon.phase(at: instant("2026-03-20T17:00:00Z")).illuminatedFraction, 0.04, accuracy: 0.03)
    }

    /// USNO: New Moon 2026-06-15 02:54, Full Moon 2026-06-29 23:56,
    /// New Moon 2026-07-14 09:43.
    func testTheNextNewAndFullMoonsMatchTheAlmanacToTheMinute() {
        let moon = Moon.phase(at: instant("2026-06-21T12:00:00Z"))
        assertTime(moon.lastNewMoon, is: "2026-06-15 02:54", in: utc, tolerance: 180)
        assertTime(moon.nextFullMoon, is: "2026-06-29 23:56", in: utc, tolerance: 180)
        assertTime(moon.nextNewMoon, is: "2026-07-14 09:43", in: utc, tolerance: 180)
    }

    /// USNO: New Moon 2026-12-09 00:52, Full Moon 2026-12-24 01:28,
    /// New Moon 2026-08-12 17:37, Full Moon 2026-08-28 04:18.
    func testMorePhasesAcrossTheYearLandWithinThreeMinutes() {
        let december = Moon.phase(at: instant("2026-12-10T00:00:00Z"))
        assertTime(december.lastNewMoon, is: "2026-12-09 00:52", in: utc, tolerance: 180)
        assertTime(december.nextFullMoon, is: "2026-12-24 01:28", in: utc, tolerance: 180)
        let august = Moon.phase(at: instant("2026-08-13T00:00:00Z"))
        assertTime(august.lastNewMoon, is: "2026-08-12 17:37", in: utc, tolerance: 180)
        assertTime(august.nextFullMoon, is: "2026-08-28 04:18", in: utc, tolerance: 180)
    }

    /// USNO: New Moon 2026-03-19 01:23.
    func testTheAgeWrapsFromTwentyNineAndAHalfBackToZeroAtNewMoon() {
        let before = Moon.phase(at: instant("2026-03-19T01:15:00Z"))
        let after = Moon.phase(at: instant("2026-03-19T01:35:00Z"))
        XCTAssertEqual(before.age, 29.5, accuracy: 0.3)
        XCTAssertLessThan(after.age, 0.02)
        XCTAssertEqual(before.nextNewMoon.timeIntervalSince(instant("2026-03-19T01:23:00Z")), 0, accuracy: 180)
        XCTAssertEqual(after.lastNewMoon, before.nextNewMoon)
    }

    func testTheNextMoonsAreAlwaysAfterTheInstantAndTheLastBeforeIt() {
        for iso in ["1900-01-01T00:00:00Z", "2000-01-06T18:14:00Z", "2026-09-10T00:00:00Z", "2100-12-31T23:59:00Z"] {
            let date = instant(iso)
            let moon = Moon.phase(at: date)
            XCTAssertLessThanOrEqual(moon.lastNewMoon, date, iso)
            XCTAssertGreaterThan(moon.nextNewMoon, date, iso)
            XCTAssertGreaterThan(moon.nextFullMoon, date, iso)
            XCTAssertEqual(moon.nextNewMoon.timeIntervalSince(moon.lastNewMoon) / 86_400, 29.53, accuracy: 0.5, iso)
            XCTAssertTrue((0...1).contains(moon.illuminatedFraction), iso)
            XCTAssertTrue((0...30).contains(moon.age), iso)
        }
    }

    func testAMoonPhaseRoundTripsThroughCodable() throws {
        let moon = Moon.phase(at: instant("2026-06-21T12:00:00Z"))
        XCTAssertEqual(try roundTrip(moon), moon)
    }
}
