//
//  SupportTests.swift
//  Solar
//
//  The pure functions under the API, against the almanac's own numbers.
//

import XCTest
@testable import Solar

final class SupportTests: XCTestCase {

    // MARK: - Julian days

    func testJ2000IsNoonOnTheFirstOfJanuary2000() {
        XCTAssertEqual(JulianDay.julianDay(instant("2000-01-01T12:00:00Z")), 2451545.0, accuracy: 1e-6)
        XCTAssertEqual(JulianDay.century(of: instant("2000-01-01T12:00:00Z")), 0, accuracy: 1e-9)
    }

    func testTheUnixEpochIsHalfADayIntoAJulianDay() {
        XCTAssertEqual(JulianDay.julianDay(Date(timeIntervalSince1970: 0)), 2440587.5)
    }

    func testJulianDaysRoundTrip() {
        let date = instant("2026-09-10T15:30:00Z")
        XCTAssertEqual(JulianDay.date(julianDay: JulianDay.julianDay(date)).timeIntervalSince(date), 0, accuracy: 1e-3)
    }

    // MARK: - Angles

    func testNormalisationBringsAnyAngleInto0To360() {
        XCTAssertEqual(Angles.normalized(-30), 330)
        XCTAssertEqual(Angles.normalized(720), 0)
        XCTAssertEqual(Angles.normalized(359.5), 359.5)
        XCTAssertEqual(Angles.normalized(-720.25), 359.75, accuracy: 1e-9)
    }

    // MARK: - Solar geometry

    func testDeclinationIsTheObliquityAtTheSolsticeAndZeroAtTheEquinox() {
        XCTAssertEqual(SolarGeometry.declination(julianCentury: JulianDay.century(of: instant("2026-06-21T08:24:00Z"))), 23.44, accuracy: 0.02)
        XCTAssertEqual(SolarGeometry.declination(julianCentury: JulianDay.century(of: instant("2026-12-21T20:50:00Z"))), -23.44, accuracy: 0.02)
        XCTAssertEqual(SolarGeometry.declination(julianCentury: JulianDay.century(of: instant("2026-03-20T14:46:00Z"))), 0, accuracy: 0.05)
    }

    func testTheEquationOfTimePeaksInEarlyNovemberAndTroughsInMidFebruary() {
        // The two extremes every sundial's correction plate carries.
        XCTAssertEqual(SolarGeometry.equationOfTime(julianCentury: JulianDay.century(of: instant("2026-11-03T12:00:00Z"))), 16.45, accuracy: 0.3)
        XCTAssertEqual(SolarGeometry.equationOfTime(julianCentury: JulianDay.century(of: instant("2026-02-11T12:00:00Z"))), -14.2, accuracy: 0.3)
    }

    // MARK: - Hour angle

    func testTheSweepIsNinetyDegreesForTheSunOnTheHorizonAtTheEquatorAtEquinox() {
        XCTAssertEqual(HourAngle.sweep(latitude: 0, declination: 0, altitude: 0), .angle(90))
    }

    func testTheSweepReportsWhichWayTheSunFellOutOfReach() {
        XCTAssertEqual(HourAngle.sweep(latitude: 89, declination: 23, altitude: HourAngle.horizon), .alwaysAbove)
        XCTAssertEqual(HourAngle.sweep(latitude: 89, declination: -23, altitude: HourAngle.horizon), .alwaysBelow)
    }

    func testTheHorizonIsTheAlmanacsMinusPointEightThreeThree() {
        XCTAssertEqual(HourAngle.horizon, -0.833)
    }

    // MARK: - Refraction

    func testRefractionIsNothingOverheadAndAboutHalfADegreeAtTheHorizon() {
        XCTAssertEqual(SunAngles.refraction(altitude: 90), 0)
        XCTAssertEqual(SunAngles.refraction(altitude: 0), 0.48, accuracy: 0.03)
        XCTAssertGreaterThan(SunAngles.refraction(altitude: 10), 0)
        XCTAssertLessThan(SunAngles.refraction(altitude: 10), SunAngles.refraction(altitude: 0))
        XCTAssertGreaterThan(SunAngles.refraction(altitude: -1), 0)
    }

    // MARK: - Moon geometry

    func testTheLitFractionFollowsTheElongation() {
        XCTAssertEqual(MoonGeometry.illuminatedFraction(elongation: 0), 0, accuracy: 1e-9)
        XCTAssertEqual(MoonGeometry.illuminatedFraction(elongation: 90), 0.5, accuracy: 1e-9)
        XCTAssertEqual(MoonGeometry.illuminatedFraction(elongation: 180), 1, accuracy: 1e-9)
    }

    func testTheMeanLunationIndexCountsFromJanuary2000() {
        // The new moon of 2026-01-18 is the 322nd after the one k counts from.
        XCTAssertEqual(LunarPhases.meanIndex(of: instant("2026-01-18T19:52:00Z")), 322, accuracy: 0.5)
        XCTAssertEqual(LunarPhases.synodicMonth, 29.530588861)
    }

    // MARK: - Days

    func testADayIsCutInItsZoneAndNoonFallsInsideIt() {
        let day = EventTimes.day(containing: localNoon("2026-06-21", in: sydney), in: sydney, longitude: Place.sydney.longitude)
        XCTAssertEqual(day.start, wall("2026-06-21 00:00", in: sydney))
        XCTAssertEqual(day.end, wall("2026-06-22 00:00", in: sydney))
        XCTAssertGreaterThanOrEqual(day.solarNoon, day.start)
        XCTAssertLessThan(day.solarNoon, day.end)
    }
}
