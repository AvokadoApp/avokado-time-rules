import Algorithms

public extension TimeRange {
    var endsAfterMidnight: Bool {
        self.end <= self.start
    }
    
    func expanded() -> [TimeRange] {
        if weekday == nil {
            return WeekDay.allCases.map { TimeRange(weekday: $0, start: self.start, end: self.end) }
        } else {
            return [self]
        }
    }
    
    func normalized() -> [ClosedRange<UInt>] {
        if let weekday {
            let ordinal = UInt(weekday.rawValue - 1)
            let start = ordinal * 1440 + self.start.minute
            let end = (self.endsAfterMidnight ? ordinal + 1 : ordinal ) * 1440 + self.end.minute
            if end >= 1440 * 7 {
                return [start ... 1440 * 7, 0 ... (end - 1440 * 7)]
            }
            return [start ... end]
        } else {
            return WeekDay.allCases.flatMap { TimeRange(weekday: $0, start: self.start, end: self.end).normalized() }
        }
    }
    
    func isSuperSet(of other: Self) -> Bool {
        let normalizedSelf = self.normalized()
        return other.normalized().allSatisfy { other in
            normalizedSelf.contains(where: { range in
                range.contains(other.lowerBound) && range.contains(other.upperBound)
            })
        }
    }
}

fileprivate struct TimeRangeWithoutDay: Hashable {
    let start: Time
    let end: Time
}

public extension Collection<TimeRange> {
    
    func optimized() -> [TimeRange] {
        let removingDuplicates = Set(self)
        let grouppedByTime = Dictionary(grouping: removingDuplicates, by: { TimeRangeWithoutDay(start: $0.start, end: $0.end) })
        return grouppedByTime.map(\.value).flatMap { group in
            if group.count == 7 {
                return [TimeRange(weekday: nil, start: group.first!.start, end: group.first!.end)]
            } else {
                return group
            }
        }
    }
    
    func expanded() -> [TimeRange] {
        self.flatMap { $0.expanded() }
    }
    
    func containsOverlaps() -> Bool {
        guard self.count > 1 else {
            return false
        }
        
        for pair in self.expanded().combinations(ofCount: 2) {
            let weekday1Start = pair[0].weekday!
            let weekday2Start = pair[1].weekday!
            
            let weekday1End = pair[0].end < pair[0].start ? weekday1Start.next : weekday1Start
            let weekday2End = pair[1].end < pair[1].start ? weekday2Start.next : weekday2Start
            
            if pair[0].contains(weekday: weekday2Start, pair[1].start) ||
                pair[0].contains(weekday: weekday2End, pair[1].end) ||
                pair[1].contains(weekday: weekday1Start, pair[0].start) ||
                pair[1].contains(weekday: weekday1End, pair[0].end)
            {
                return true
            }
        }
        
        return false
    }
    
    func normalized() -> [ClosedRange<UInt>] {
        combinedIntervals(
            intervals: self.flatMap { $0.normalized() }
        )
    }
    
    func isSuperSet(of other: Element) -> Bool {
        let normalizedSelf = self.normalized()
        return other.normalized().allSatisfy { other in
            normalizedSelf.contains(where: { range in
                range.contains(other.lowerBound) && range.contains(other.upperBound)
            })
        }
    }
    
    func isSuperSet(of others: some Collection<TimeRange>) -> Bool {
        let normalizedSelf = self.normalized()
        return others.normalized().allSatisfy { other in
            normalizedSelf.contains(where: { range in
                range.contains(other.lowerBound) && range.contains(other.upperBound)
            })
        }
    }
    
    func subtracting(_ others: some Collection<TimeRange>) -> [ClosedRange<UInt>] {
        var copy = self.normalized()
        for other in others.normalized() {
            for index in copy.indices {
                if copy[index].lowerBound > other.upperBound {
                    break
                }
                if copy[index].contains(other.lowerBound) && copy[index].contains(other.upperBound) {
                    copy.insert(other.upperBound ... copy[index].upperBound, at: index + 1)
                    copy[index] = copy[index].lowerBound ... other.lowerBound
                    break
                }
                if other.contains(copy[index].lowerBound) && other.contains(copy[index].upperBound) {
                    copy[index] = 0 ... 0
                }
                if copy[index].contains(other.lowerBound) {
                    copy[index] = copy[index].lowerBound ... other.lowerBound
                }
                if copy[index].contains(other.upperBound) {
                    copy[index] = other.upperBound ... copy[index].upperBound
                }
            }
        }
        return copy.filter { $0.lowerBound < $0.upperBound }
    }
    
    func subtracting(_ others: some Collection<TimeRange>) throws -> Array<TimeRange> {
        try Array(denormalizing: self.subtracting(others))
    }
    
    func getDebugTimeLine(hourInterval: Int = 1, addingHeader: Bool = false) -> String {
        self.normalized().getDebugTimeLine(hourInterval: hourInterval, addingHeader: addingHeader)
    }
    
    func isFullWeek() -> Bool {
        self.isSuperSet(of: TimeRange(weekday: nil, start: Time(absoluteMinutes: 0), end: Time(absoluteMinutes: 0)))
    }
}

public extension Array<TimeRange> {
    init(denormalizing normalized: some Collection<ClosedRange<UInt>>) throws {
        let result = try normalized.map { singleRange in
            let startDayRawValue = singleRange.lowerBound / (60 * 24) + 1
            guard let startDay = WeekDay(rawValue: Int(startDayRawValue)) else {
                throw TimeRuleInitializationError.higherThanWeekNumberOfMinutes
            }
            
            return TimeRange(
                weekday: startDay,
                start: Time(absoluteMinutes: singleRange.lowerBound % (60 * 24)),
                end: Time(absoluteMinutes: singleRange.upperBound % (60 * 24))
            )   
        }
        self.init(result)
    }
}

public enum TimeRuleInitializationError: Error {
    case higherThanWeekNumberOfMinutes
    
}

public extension Array<ClosedRange<UInt>> {
    func getDebugTimeLine(hourInterval: Int = 1, addingHeader: Bool = false) -> String {
        var result = String()
        let baseCapacity = 7 * 24 * 60 / ( 60 * hourInterval)
        result.reserveCapacity(baseCapacity * (addingHeader ? 2 : 1) + 1)
        if addingHeader {
            var madeChange = false
            for i in stride(from: UInt(), to: 7 * 24, by: hourInterval) {
                if madeChange {
                    madeChange = false
                    continue
                }
                if i % 6 == 0 {
                    let day = i / 24
                    let i = i - day * 24
                    if i < 10 {
                        result.append("0\(i)")
                    } else {
                        result.append("\(i)")
                    }
                    madeChange = true
                } else {
                    result.append(" ")
                }
            }
            result.append("\n")
        }
        
        for i in stride(from: UInt(), to: 7 * 24 * 60, by: 60 * hourInterval) {
            if self.contains(where: {
                $0.contains(i) && i != $0.upperBound
            }) {
                result.append("•")
            } else {
                result.append(" ")
            }
        }
        return result
    }
    func printDebugTimeLine() {
        print(getDebugTimeLine(hourInterval: 2))
    }
}

fileprivate func combinedIntervals(intervals: [ClosedRange<UInt>]) -> [ClosedRange<UInt>] {
    
    var combined = [ClosedRange<UInt>]()
    var accumulator: ClosedRange<UInt> = (0...0) // empty range
    
    for interval in intervals.sorted(by: { $0.lowerBound  < $1.lowerBound  } ) {
        
        if accumulator == (0...0) {
            accumulator = interval
        }
        
        if accumulator.upperBound >= interval.upperBound {
            // interval is already inside accumulator
        }
            
        else if accumulator.upperBound >= interval.lowerBound  {
            // interval hangs off the back end of accumulator
            accumulator = (accumulator.lowerBound...interval.upperBound)
        }
            
        else if accumulator.upperBound <= interval.lowerBound  {
            // interval does not overlap
            combined.append(accumulator)
            accumulator = interval
        }
    }
    
    if accumulator != (0...0) {
        combined.append(accumulator)
    }
    
    return combined
}
