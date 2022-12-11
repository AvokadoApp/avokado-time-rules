import XCTest
@testable import AvokadoTimeRules

final class TimeRange_Utils_Tests: XCTestCase {
    
    func test_IsFullWeek() {
        let timeRanges = WeekDay.allCases.map {
            TimeRange(
                weekday: $0,
                start: Time(00, 00),
                end: Time(00, 00)
            )
        }
        
        XCTAssertTrue(timeRanges.isFullWeek())
    }
    
    func test_IsNotFullWeek() {
        var timeRanges = WeekDay.allCases.map {
            TimeRange(
                weekday: $0,
                start: Time(00, 00),
                end: Time(00, 00)
            )
        }
        timeRanges[6] = TimeRange(
            weekday: .saturday,
            start: Time(00, 00),
            end: Time(23, 59)
        )
        
        XCTAssertFalse(timeRanges.isFullWeek())
    }
    
    func test_SimpleNormalization() {
        let timeRange = TimeRange(
            weekday: .monday,
            start: Time(13, 00),
            end: Time(15, 00)
        )
        
        let normalized = timeRange.normalized()
        
        printTimeLine()
        normalized.printDebugTimeLine()
        
        XCTAssertEqual(normalized.count, 1)
        XCTAssertEqual(normalized[0].lowerBound, (1440 * 1) + (13 * 60))
        XCTAssertEqual(normalized[0].upperBound, (1440 * 1) + (15 * 60))
    }
    
    func test_SaturdayOverlapNormalization() {
        let timeRange = TimeRange(
            weekday: .saturday,
            start: Time(20, 00),
            end: Time(02, 00)
        )
        
        let normalized = timeRange.normalized()
        printTimeLine()
        normalized.printDebugTimeLine()
        
        XCTAssertEqual(normalized.count, 2)
        XCTAssertEqual(normalized[0].lowerBound, (1440 * 6) + (20 * 60))
        XCTAssertEqual(normalized[0].upperBound, 1440 * 7)
        
        XCTAssertEqual(normalized[1].lowerBound, 0)
        XCTAssertEqual(normalized[1].upperBound, (1440 * 0) + (02 * 60))
    }
    
    
    func test_WeekNormalization() {
        let timeRange = TimeRange(
            weekday: nil,
            start: Time(13, 00),
            end: Time(21, 00)
        )
        
        let normalized = timeRange.normalized()
        printTimeLine()
        normalized.printDebugTimeLine()
        
        XCTAssertEqual(normalized.count, 7)
    }
    
    func test_WeekOverlapNormalization() {
        let timeRange = TimeRange(
            weekday: nil,
            start: Time(20, 00),
            end: Time(02, 00)
        )
        
        let normalized = timeRange.normalized()
        printTimeLine()
        normalized.printDebugTimeLine()
        
        XCTAssertEqual(normalized.count, 8)
    }
    
    func test_CombinedNormalizations() {
        let timeRanges = [
            TimeRange(
                weekday: .monday,
                start: Time(20, 00),
                end: Time(02, 00)
            ),
            TimeRange(
                weekday: .tuesday,
                start: Time(01, 00),
                end: Time(03, 00)
            )
        ]
        
        let normalized = timeRanges.normalized()
        printTimeLine()
        timeRanges[0].normalized().printDebugTimeLine()
        timeRanges[1].normalized().printDebugTimeLine()
        normalized.printDebugTimeLine()
        XCTAssertEqual(normalized.count, 1)
        XCTAssertEqual(normalized[0].lowerBound, (1440 * 1) + (20 * 60))
        XCTAssertEqual(normalized[0].upperBound, (1440 * 2) + (03 * 60))
        
    }
    
    func test_basicSubstraction1() {
        let base = [
            TimeRange(
                weekday: .sunday,
                start: Time(10, 00),
                end: Time(04, 00)
            )
        ]
        
        let other = [
            TimeRange(
                weekday: .sunday,
                start: Time(14, 00),
                end: Time(18, 00)
            )
        ]
        
        let diff: [ClosedRange<UInt>] = base.subtracting(other)
        printTimeLine()
        base.normalized().printDebugTimeLine()
        other.normalized().printDebugTimeLine()
        diff.printDebugTimeLine()
        XCTAssertEqual(diff.count, 2)
        XCTAssertEqual(diff[0].lowerBound, (10 * 60))
        XCTAssertEqual(diff[0].upperBound, (14 * 60))
        XCTAssertEqual(diff[1].lowerBound, (18 * 60))
        XCTAssertEqual(diff[1].upperBound, (28 * 60))
        
    }
    
    func test_basicSubstraction2() {
        let base = [
            TimeRange(
                weekday: .sunday,
                start: Time(15, 00),
                end: Time(16, 00)
            )
        ]
        
        let other = [
            TimeRange(
                weekday: .sunday,
                start: Time(14, 00),
                end: Time(18, 00)
            )
        ]
        
        let diff: [ClosedRange<UInt>] = base.subtracting(other)
        printTimeLine()
        diff.printDebugTimeLine()
        XCTAssertEqual(diff.count, 0)
    }
    
    func test_basicSubstraction3() {
        let base = [
            TimeRange(
                weekday: .sunday,
                start: Time(4, 00),
                end: Time(20, 00)
            )
        ]
        
        let other = [
            TimeRange(
                weekday: .sunday,
                start: Time(14, 00),
                end: Time(23, 00)
            )
        ]
        
        let diff: [ClosedRange<UInt>] = base.subtracting(other)
        printTimeLine()
        base.normalized().printDebugTimeLine()
        other.normalized().printDebugTimeLine()
        diff.printDebugTimeLine()
        XCTAssertEqual(diff.count, 1)
        XCTAssertEqual(diff[0].lowerBound, (04 * 60))
        XCTAssertEqual(diff[0].upperBound, (14 * 60))
    }
    
    func test_basicSubstraction4() {
        let base = [
            TimeRange(
                weekday: .wednesday,
                start: Time(4, 00),
                end: Time(20, 00)
            )
        ]
        
        let other = [
            TimeRange(
                weekday: .tuesday,
                start: Time(14, 00),
                end: Time(08, 00)
            )
        ]
        
        let diff: [ClosedRange<UInt>] = base.subtracting(other)
        printTimeLine()
        base.normalized().printDebugTimeLine()
        other.normalized().printDebugTimeLine()
        diff.printDebugTimeLine()
        XCTAssertEqual(diff.count, 1)
        XCTAssertEqual(diff[0].lowerBound, (08 * 60 + (1440 * 3)))
        XCTAssertEqual(diff[0].upperBound, (20 * 60 + (1440 * 3)))
    }
    
    func test_basicSubstraction5() {
        let base = [
            TimeRange(
                weekday: .sunday,
                start: Time(4, 00),
                end: Time(20, 00)
            )
        ]
        
        let other = [
            TimeRange(
                weekday: .saturday,
                start: Time(14, 00),
                end: Time(08, 00)
            )
        ]
        
        let diff: [ClosedRange<UInt>] = base.subtracting(other)
        printTimeLine()
        base.normalized().printDebugTimeLine()
        other.normalized().printDebugTimeLine()
        diff.printDebugTimeLine()
        XCTAssertEqual(diff.count, 1)
        XCTAssertEqual(diff[0].lowerBound, (08 * 60 + (1440 * 0)))
        XCTAssertEqual(diff[0].upperBound, (20 * 60 + (1440 * 0)))
    }
    
    func test_basicSubstraction6() {
        let base = [
            TimeRange(
                weekday: .saturday,
                start: Time(20, 00),
                end: Time(12, 00)
            )
        ]
        
        let other = [
            TimeRange(
                weekday: .saturday,
                start: Time(14, 00),
                end: Time(08, 00)
            )
        ]
        
        let diff: [ClosedRange<UInt>] = base.subtracting(other)
        printTimeLine()
        base.normalized().printDebugTimeLine()
        other.normalized().printDebugTimeLine()
        diff.printDebugTimeLine()
        XCTAssertEqual(diff.count, 1)
        XCTAssertEqual(diff[0].lowerBound, (08 * 60 + (1440 * 0)))
        XCTAssertEqual(diff[0].upperBound, (12 * 60 + (1440 * 0)))
    }
    
    func test_basicSubstraction7() {
        let base = [
            TimeRange(
                weekday: nil,
                start: Time(14, 00),
                end: Time(17, 00)
            ),
            TimeRange(
                weekday: .friday,
                start: Time(19, 00),
                end: Time(22, 00)
            ),
            TimeRange(
                weekday: .saturday,
                start: Time(22, 00),
                end: Time(04, 00)
            )
        ]
        let other = [
            TimeRange(
                weekday: .friday,
                start: Time(15, 00),
                end: Time(15, 00)
            )
        ]
        
        let diff: [ClosedRange<UInt>] = base.subtracting(other)
        printTimeLine()
        base.normalized().printDebugTimeLine()
        other.normalized().printDebugTimeLine()
        diff.printDebugTimeLine()
    }
    
    func test_Optimized() {
        let base = TimeRange(weekday: nil, start: Time(20, 00), end: Time(04, 00))
        printTimeLine()
        XCTAssertEqual(base.expanded().count, 7)
        base.normalized().printDebugTimeLine()
        base.expanded().normalized().printDebugTimeLine()
        XCTAssertEqual(base.expanded().optimized().count, 1)
        base.expanded().optimized().normalized().printDebugTimeLine()
    }
}

func printTimeLine() {
    var result = ""
    var madeChange = false
    for i in stride(from: UInt(), to: 7 * 24, by: 2) {
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
    print(result)
}
