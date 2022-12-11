import Foundation

public enum WeekDay: Int, Codable, Equatable, CustomDebugStringConvertible, CaseIterable, Hashable {
    case sunday = 1
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    
    public var next: WeekDay {
        switch self {
        case .saturday: return .sunday
        default: return WeekDay(rawValue: self.rawValue + 1)!
        }
    }
    
    public var debugDescription: String {
        switch self {
        case .sunday:
            return "sunday"
        case .monday:
            return "monday"
        case .tuesday:
            return "tuesday"
        case .wednesday:
            return "wednesday"
        case .thursday:
            return "thursday"
        case .friday:
            return "friday"
        case .saturday:
            return "saturday"
        }
    }
    
    public var name: String {
        debugDescription
    }
    
    public static func fromName(_ name: String) -> WeekDay? {
        switch name {
        case "sunday":
            return .sunday
        case "monday":
            return .monday
        case "tuesday":
            return .tuesday
        case "wednesday":
            return .wednesday
        case "thursday":
            return .thursday
        case "friday":
            return .friday
        case "saturday":
            return .saturday
        default:
            return nil
        }
    }
}

public struct Time: Comparable, Codable, Equatable, CustomDebugStringConvertible, Hashable {
    public let minute: UInt
    
    public init(_ hour: UInt, _ minute: UInt) {
        self.init(absoluteMinutes: hour * 60 + minute)
    }
    
    public init(absoluteMinutes: UInt) {
        precondition(absoluteMinutes < 60 * 24)
        self.minute = absoluteMinutes
    }
    
    private var minuteOfTheDay: UInt {
        minute
    }
    
    public static func < (lhs: Time, rhs: Time) -> Bool {
        lhs.minuteOfTheDay < rhs.minuteOfTheDay
    }
    
    enum CodingKeys: String, CodingKey {
        case minute = "m"
    }
    
    public var debugDescription: String {
        return "\(minute / 60) : \(minute % 60)"
    }
    
    public func encode(to encoder: Encoder) throws {
        try minute.encode(to: encoder)
    }
    
    public init(from decoder: Decoder) throws {
        self.minute = try UInt(from: decoder)
    }
}

public struct TimeRange: Codable, Equatable, Hashable {
    public let weekday: WeekDay?
    public let start: Time
    public let end: Time
    
    enum CodingKeys: String, CodingKey {
        case weekday = "w"
        case start = "s"
        case end = "e"
    }
    
    public init(weekday: WeekDay?, start: Time, end: Time) {
        self.weekday = weekday
        self.start = start
        self.end = end
    }
    
    public func contains(weekday requestedWeekday: WeekDay, _ time: Time) -> Bool {
        if let referenceWeekDay = weekday {
            return simpleOverlapCheck(referenceWeekDay: referenceWeekDay, requestedWeekDay: requestedWeekday, time: time)
        } else {
            return simpleOverlapCheck(time: time)
        }
    }
    
    private func simpleOverlapCheck(referenceWeekDay: WeekDay, requestedWeekDay: WeekDay, time: Time) -> Bool {
        if start == end {
            // time interval is 00:00 - 00:00
            return referenceWeekDay == requestedWeekDay
        } else if start < end {
            // time interval is 15:00 - 23:00
            return start <= time && time < end && referenceWeekDay == requestedWeekDay
        } else {
            // time interval is 21:00 - 01:00
            if referenceWeekDay == requestedWeekDay {
                return start <= time
            } else if requestedWeekDay == referenceWeekDay.next {
                return time < end
            }
            return false
        }
    }
    
    private func simpleOverlapCheck(time: Time) -> Bool {
        if start == end {
            // time interval is 00:00 - 00:00
            return true
        } else if start < end {
            // time interval is 15:00 - 23:00
            return start <= time && time < end
        } else {
            // time interval is 21:00 - 01:00
            return start <= time || time < end
        }
    }
}

public indirect enum TimeRule: Equatable {
    case dateInterval(DateInterval)
    case timeRange(TimeRange)
    case and([TimeRule])
    case or([TimeRule])
    case not(TimeRule)
    case closed
    
    /// The `timeZone` parameter will be used to extract the weekday, hour and minute
    /// in the local time range. ``TimeRange`` is expresses as the number of minutes
    /// passed since midnight for a given `TimeZone`, therefor we need to know
    /// which `TimeZone` we must refer to
    public func contains(_ date: Date, for timeZone: TimeZone) -> Bool {
        switch self {
        case let .dateInterval(dateInterval):
            return dateInterval.contains(date)
        case let .timeRange(timeRange):
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = TimeZone(identifier: "UTC")!
            let dateComponents = calendar.dateComponents(
                [.weekday, .hour, .minute],
                from: date
            )
            let requestedTimeOfDay = Time(
                UInt(dateComponents.hour!),
                UInt(dateComponents.minute!)
            )
            return timeRange.contains(weekday: WeekDay(rawValue: dateComponents.weekday!)!, requestedTimeOfDay)
        case let .and(timeRules):
            return timeRules.allSatisfy { $0.contains(date, for: timeZone) }
        case let .or(timeRules):
            return timeRules.first(where: { $0.contains(date, for: timeZone) }) != nil
        case let .not(timeRule):
            return !timeRule.contains(date, for: timeZone)
        case .closed:
            return false
        }
    }
    
    public enum Types: String, RawRepresentable, Codable {
        case dateInterval = "d"
        case timeRange = "t"
        case and = "a"
        case or = "o"
        case not = "n"
        case closed = "c"
    }
}

extension TimeRule: Encodable {
    
    enum CodingKeys: String, CodingKey {
        case type = "t"
        case rule = "r"
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .dateInterval(let dateInterval):
            try container.encode(Types.dateInterval, forKey: .type)
            let superEncoder = container.superEncoder(forKey: .rule)
            var ruleContainer = superEncoder.singleValueContainer()
            try ruleContainer.encode(dateInterval)
            
        case .timeRange(let timeRange):
            try container.encode(Types.timeRange, forKey: .type)
            let superEncoder = container.superEncoder(forKey: .rule)
            var ruleContainer = superEncoder.singleValueContainer()
            try ruleContainer.encode(timeRange)

        case .and(let array):
            try container.encode(Types.and, forKey: .type)
            let superEncoder = container.superEncoder(forKey: .rule)
            var ruleContainer = superEncoder.singleValueContainer()
            try ruleContainer.encode(array)

        case .or(let array):
            try container.encode(Types.or, forKey: .type)
            let superEncoder = container.superEncoder(forKey: .rule)
            var ruleContainer = superEncoder.singleValueContainer()
            try ruleContainer.encode(array)
            
        case .not(let timeRule):
            try container.encode(Types.not, forKey: .type)
            let superEncoder = container.superEncoder(forKey: .rule)
            var ruleContainer = superEncoder.singleValueContainer()
            try ruleContainer.encode(timeRule)
            
        case .closed:
            try container.encode(Types.closed, forKey: .type)
        }
    }
}

extension TimeRule: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(Types.self, forKey: .type)
        
        switch type {
        case .dateInterval:
            let rule = try container.decode(DateInterval.self, forKey: .rule)
            self = .dateInterval(rule)
        case .timeRange:
            let rule = try container.decode(TimeRange.self, forKey: .rule)
            self = .timeRange(rule)
        case .and:
            let rule = try container.decode(Array<TimeRule>.self, forKey: .rule)
            self = .and(rule)
        case .or:
            let rule = try container.decode(Array<TimeRule>.self, forKey: .rule)
            self = .or(rule)
        case .not:
            let rule = try container.decode(TimeRule.self, forKey: .rule)
            self = .not(rule)
        case .closed:
            self = .closed
        }
    }
}

extension TimeRule: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .dateInterval(let dateInterval):
            return "from \(dateInterval.start.debugDescription) to \(dateInterval.end.debugDescription)"
            
        case .timeRange(let timeRange):
            return "\(timeRange.weekday == nil ? "any day" : "every \(timeRange.weekday!.debugDescription)") from \(timeRange.start.debugDescription) to \(timeRange.end.debugDescription)"

        case .and(let array):
            return "(\(array.map(\.debugDescription).joined(separator: " AND ")))"

        case .or(let array):
            return "(\(array.map(\.debugDescription).joined(separator: " OR ")))"
            
        case .not(let timeRule):
            return "NOT \(timeRule.debugDescription)"
            
        case .closed:
            return "closed"
        }
    }
}
