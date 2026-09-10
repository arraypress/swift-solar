//
//  SunAngles.swift
//  Solar
//
//  Altitude and azimuth at an instant, plus the refraction the air adds.
//

import Foundation

/// The sun's altitude and azimuth for an observer, at one instant.
enum SunAngles {

    /// Altitude of the sun's centre above the horizon, degrees, as geometry
    /// has it — no refraction. Negative is below.
    static func altitude(at date: Date, latitude: Double, longitude: Double) -> Double {
        let (declination, hourAngle) = declinationAndHourAngle(at: date, longitude: longitude)
        let cosZenith = Angles.sin(latitude) * Angles.sin(declination)
            + Angles.cos(latitude) * Angles.cos(declination) * Angles.cos(hourAngle)
        return 90 - Angles.acos(min(1, max(-1, cosZenith)))
    }

    /// Azimuth of the sun, degrees clockwise from true north.
    static func azimuth(at date: Date, latitude: Double, longitude: Double) -> Double {
        let (declination, hourAngle) = declinationAndHourAngle(at: date, longitude: longitude)
        let zenith = 90 - altitude(at: date, latitude: latitude, longitude: longitude)
        let denominator = Angles.cos(latitude) * Angles.sin(zenith)
        guard abs(denominator) > 1e-9 else {
            /// Straight overhead, or at a pole: azimuth is undefined, and
            /// north is as good an answer as any.
            return 0
        }
        let cosine = min(1, max(-1, (Angles.sin(latitude) * Angles.cos(zenith) - Angles.sin(declination)) / denominator))
        let angle = Angles.acos(cosine)
        return hourAngle > 0 ? Angles.normalized(angle + 180) : Angles.normalized(540 - angle)
    }

    /// How much the atmosphere lifts the sun at a given true altitude,
    /// degrees. NOAA's fit, in arcseconds converted.
    ///
    /// About 0.57° on the horizon, a few arcminutes at 10°, nothing above
    /// 85°. What the eye sees is ``altitude`` plus this.
    static func refraction(altitude: Double) -> Double {
        if altitude > 85 { return 0 }
        let tangent = Angles.tan(altitude)
        let seconds: Double
        if altitude > 5 {
            seconds = 58.1 / tangent - 0.07 / pow(tangent, 3) + 0.000086 / pow(tangent, 5)
        } else if altitude > -0.575 {
            seconds = 1735 + altitude * (-518.2 + altitude * (103.4 + altitude * (-12.79 + altitude * 0.711)))
        } else {
            seconds = -20.774 / tangent
        }
        return seconds / 3600
    }

    /// Declination of the sun and the observer's local hour angle at an
    /// instant, both in degrees. The hour angle is negative before solar noon.
    private static func declinationAndHourAngle(at date: Date, longitude: Double) -> (Double, Double) {
        let t = JulianDay.century(of: date)
        let minutesPastUTCMidnight = (date.timeIntervalSince1970.truncatingRemainder(dividingBy: 86_400) + 86_400)
            .truncatingRemainder(dividingBy: 86_400) / 60
        let trueSolarMinutes = (minutesPastUTCMidnight + SolarGeometry.equationOfTime(julianCentury: t) + 4 * longitude + 1440)
            .truncatingRemainder(dividingBy: 1440)
        var hourAngle = trueSolarMinutes / 4 - 180
        if hourAngle < -180 { hourAngle += 360 }
        return (SolarGeometry.declination(julianCentury: t), hourAngle)
    }
}
