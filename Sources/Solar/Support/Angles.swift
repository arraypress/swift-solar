//
//  Angles.swift
//  Solar
//
//  Degrees in, degrees out: the trigonometry here is written in the units the
//  almanacs print, and radians never escape a single expression.
//

import Foundation

/// Degree arithmetic, so no formula in this package carries a stray π.
enum Angles {

    /// Sine of an angle given in degrees.
    static func sin(_ degrees: Double) -> Double {
        Foundation.sin(degrees * .pi / 180)
    }

    /// Cosine of an angle given in degrees.
    static func cos(_ degrees: Double) -> Double {
        Foundation.cos(degrees * .pi / 180)
    }

    /// Tangent of an angle given in degrees.
    static func tan(_ degrees: Double) -> Double {
        Foundation.tan(degrees * .pi / 180)
    }

    /// Arcsine, in degrees.
    static func asin(_ value: Double) -> Double {
        Foundation.asin(value) * 180 / .pi
    }

    /// Arccosine, in degrees.
    static func acos(_ value: Double) -> Double {
        Foundation.acos(value) * 180 / .pi
    }

    /// Arctangent of `y / x`, in degrees.
    static func atan2(_ y: Double, _ x: Double) -> Double {
        Foundation.atan2(y, x) * 180 / .pi
    }

    /// The same direction, expressed in 0 ..< 360.
    ///
    /// The series in ``SolarGeometry`` and ``MoonGeometry`` produce
    /// longitudes of hundreds of thousands of degrees for a date decades
    /// from J2000; the arithmetic is fine with that and the caller is not.
    static func normalized(_ degrees: Double) -> Double {
        let wrapped = degrees.truncatingRemainder(dividingBy: 360)
        return wrapped < 0 ? wrapped + 360 : wrapped
    }
}
