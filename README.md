# Swift Solar

Sunrise, sunset, twilight and the phase of the moon, computed on the device for any place and date — as typed values, on any Apple platform.

```swift
import Solar

let reykjavik = try Coordinate(latitude: 64.1466, longitude: -21.9426)
let zone = TimeZone(identifier: "Atlantic/Reykjavik")!
let day = Solar.day(Date(), at: reykjavik, in: zone)

day.sunrise            // .at(2026-06-21 02:55)
day.sunset             // .at(2026-06-22 00:04) — after midnight, and honestly so
day.civilDusk          // .polarDay — it sets, but it never gets dark
day.dayLength          // 76_133 seconds

Solar.isDaylight(at: Date(), coordinate: reykjavik)
Moon.phase(at: Date()).name           // .waxingGibbous
Moon.phase(at: Date()).nextFullMoon   // 2026-06-29 23:56 UTC
```

## Why

Every app that shows a sunrise either calls a weather API for it or compares the clock to 6 am. The first needs a key, a network and a location permission for a number that has been computable by hand since the 1800s; the second is wrong by hours for most of the planet for most of the year. The questions people get wrong when they guess:

| Question | The wrong answer, and why it is tempting |
|---|---|
| Is it daytime? | "It is after 6 am." In Tromsø in June it is daytime at 2 am; in December it is not daytime at noon. |
| When does the sun set today in Reykjavik on the solstice? | "Yesterday's, at 00:04." That is the set that *ended yesterday*; today's is 00:04 tomorrow. A list of events inside the date pairs this morning's rise with last night's set. |
| Is sunset as long after noon as sunrise is before it? | Almost, and not quite — the sun's declination moves nearly half a degree a day near the equinoxes, so the two half-days differ by up to a minute. NOAA evaluates the sun at the event, not at noon, and so does this. |
| What is 6 am here? | Solar noon is not 12:00. The sun runs 16 minutes ahead of or behind the clock through the year, plus four minutes for every degree of longitude from the zone's meridian. |
| When does the moon rise? | Not answered here. Moonrise depends on the place, moves by almost an hour a day, and needs the moon's parallax and distance — a different and larger piece of work than a phase, and saying so beats a wrong number. |

## Installation

```swift
.package(url: "https://github.com/arraypress/swift-solar.git", from: "0.1.0")
```

Foundation only. No dependencies, every Apple platform, macOS 14+.

## A place

```swift
let sydney = try Coordinate(latitude: -33.8688, longitude: 151.2093)
try Coordinate(latitude: 151.2093, longitude: -33.8688)   // throws: latitude first
```

Latitude first, north and east positive, validated once so nothing downstream checks again. A coordinate the wrong way round is refused when it is out of range and cannot be otherwise — `-0.1, 51.5` is a real place in the Gulf of Guinea.

## A day

```swift
let day = Solar.day(date, at: sydney, in: TimeZone(identifier: "Australia/Sydney")!)

day.sunrise        // SolarEvent
day.sunset
day.solarNoon      // Date — the transit, not 12:00
day.dayLength      // TimeInterval

day.civilDawn      // -6°: light to read by
day.nauticalDusk   // -12°: the last of the horizon
day.astronomicalDawn   // -18°: the end of full darkness
day.dawn(.nautical)    // the same, by name
```

The day is a calendar day in the zone you name — from `start` to `end`, which is 23 or 25 hours on the two days a year the clocks change — and every event is the one that belongs to that day's solar noon. The zone defaults to UTC rather than to the machine's, so the same call gives the same answer on every machine; pass the place's zone to get its calendar day.

Rise and set are the sun's centre at -0.833° below the horizon: half a degree of atmospheric refraction plus a quarter of a degree for the top edge of the disc. That is the definition NOAA, the US Naval Observatory and every printed almanac share, so the times here agree with the newspaper.

## An event that did not happen

```swift
switch day.sunset {
case .at(let date):  …
case .polarDay:      // the sun never set
case .polarNight:    // the sun never rose
}

day.sunset.date        // Date? — for callers happy to print nothing
day.sunset.occurred
```

Three cases rather than an optional, because the two ways of having no time mean opposite things, and nothing here ever invents a time. For a twilight the same two cases read one level down: `.polarDay` on a civil dusk means the sun never dropped below -6° — Reykjavik in June, where the sun sets and the sky never gets darker than civil twilight.

## Right now

```swift
Solar.isDaylight(at: Date(), coordinate: sydney)     // by the same -0.833° as sunrise

let sun = Solar.position(at: Date(), coordinate: sydney)
sun.altitude           // degrees above the horizon, as geometry has it
sun.apparentAltitude   // as seen — refraction lifts the sun half a degree at the horizon
sun.azimuth            // degrees clockwise from true north
```

`isDaylight` is asked of the instant, not of the day's events, so it needs no zone and cannot disagree with the sunrise and sunset it sits between.

## Golden hour and blue hour

```swift
let golden = Solar.goldenHour(on: date, at: sydney, in: zone)   // -4° to +6°
let blue = Solar.blueHour(on: date, at: sydney, in: zone)       // -6° to -4°

golden.morning   // DateInterval?
golden.evening
```

Golden hour exists on any day the sun crosses -4°. When it never climbs to 6° — Tromsø in December, where it peaks at -3° and never rises at all — the morning window runs to solar noon and the evening one starts there, because the light is golden all day and "none" would be the wrong answer to a photographer. Blue hour needs both crossings: at 61° north in June the sun dips to -5° and comes back, one continuous blue hour across midnight with no edges to report, and that reads as `nil` rather than as a window that ends at 23:59.

## The moon

```swift
let moon = Moon.phase(at: Date())
moon.illuminatedFraction   // 0 at new, 1 at full
moon.age                   // days since the last new moon, counted from the real one
moon.isWaxing
moon.name                  // .waxingGibbous — one of eight, each owning 45° of the cycle
moon.name.label            // "Waxing Gibbous"
moon.lastNewMoon
moon.nextNewMoon
moon.nextFullMoon
```

The phase is the same from everywhere on Earth, so this needs no coordinate. The instants of new and full moon are Meeus's series with every correction term he lists, which lands them within a minute of the USNO's tables; the lit fraction is from the moon's longitude to thirty terms, which puts it within a hundredth. Moonrise and moonset are not here, for the reason in the table above.

## Accuracy

Measured, not assumed, against the US Naval Observatory's rise/set API for seven places on fixed dates — Greenwich at both solstices, Sydney, Quito at the equinox, Reykjavik and Tromsø in June and December, Kiritimati across the date line — plus Greenwich in 1900, 2100 and on a leap day. Every rise, set, transit and civil twilight lands within **one minute** of the USNO's, which prints to the minute; the tests assert two. Polar day and night are reported exactly where the USNO reports "continuously above" or "below". New and full moons across 2026 land within **one minute**; the lit fraction within **0.01** of the USNO's percentage.

What that rests on: NOAA's solar position algorithm (Meeus, *Astronomical Algorithms*, chapter 25) with the declination and the equation of time refined at the event itself; Meeus chapter 49 for the phases, with ΔT taken as 69 seconds, which is right to a minute across the 2020s and drifts by under a second a year.

## Tested

87 tests, every one a fixed place, a fixed date and one right answer quoted from the almanac in the test that checks it. Both poles, both sides of the date line, latitude exactly ±90 and longitude exactly ±180 and one step past each, the equator at the equinox and its symmetry, a leap day, the 23- and 25-hour days when London's clocks change, one minute either side of midnight, 1900 and 2100, a sunset that lands after midnight, every polar case, new, full and both quarters, the age wrapping from 29.5 back to 0, every error, and every enum through JSON and back. No test says "today".

## Licence

MIT.
