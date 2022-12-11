//import XCTest
//@testable import AvokadoTimeRules
//
//final class AvokadoTimeRulesTests: XCTestCase {
//    
//    let formatter: DateFormatter = {
//        let _formatter = DateFormatter()
//        _formatter.timeZone = TimeZone(identifier: "UTC")
//        _formatter.dateFormat = "yyyy/MM/dd'T'HH:mm:ss"
//        return _formatter
//    }()
//    
//    func testCostumizedTime() throws {
//        let beginSummerHoliday = formatter.date(from: "2023/06/01T00:00:00")!
//        let endSummerHoliday = formatter.date(from: "2023/07/10T00:00:00")!
//        
//        let timeRule: TimeRule =
//            .and([
//                .not(.dateInterval(DateInterval(start: beginSummerHoliday, end: endSummerHoliday))),
//                .or([
//                    .timeRange(TimeRange(weekday: .tuesday, start: Time(11, 00), end: Time(14, 30))),
//                    .timeRange(TimeRange(weekday: .wednesday, start: Time(22, 00), end: Time(05, 00))),
//                    .timeRange(TimeRange(weekday: .thursday, start: Time(11, 00), end: Time(14, 30))),
//                    .timeRange(TimeRange(weekday: .friday, start: Time(11, 00), end: Time(14, 30))),
//                    .timeRange(TimeRange(weekday: .friday,  start: Time(18, 00), end: Time(00, 00))),
//                    .timeRange(TimeRange(weekday: .saturday, start: Time(00, 00), end: Time(00, 00))),
//                    .timeRange(TimeRange(weekday: .sunday, start: Time(11, 00), end: Time(14, 30)))
//                ]),
//            ])
//        
//        let mondayThreeOctober = formatter.date(from: "2022/10/03T13:00:00")!
//        XCTAssertFalse(timeRule.contains(mondayThreeOctober))
//
//        let tuesday11AM = formatter.date(from: "2022/10/04T11:01:00")!
//        XCTAssertTrue(timeRule.contains(tuesday11AM))
//
//        let wednesday11PM = formatter.date(from: "2022/10/05T23:00:00")!
//        XCTAssertTrue(timeRule.contains(wednesday11PM))
//        
//        let thursday12AM = formatter.date(from: "2022/10/06T00:00:00")!
//        XCTAssertTrue(timeRule.contains(thursday12AM))
//        
//        let thursday03AM = formatter.date(from: "2022/10/06T03:00:00")!
//        XCTAssertTrue(timeRule.contains(thursday03AM))
//        
//        let saturdayNextJune = formatter.date(from: "2023/06/10T11:01:00")!
//        XCTAssertFalse(timeRule.contains(saturdayNextJune))
//    }
//    
//    func testSimpleWeekTime() throws {
//        let timeRule: TimeRule = .timeRange(TimeRange(weekday: nil, start: Time(12, 00), end: Time(01, 00)))
//        
//        let day1 = formatter.date(from: "2022/10/03T13:00:00")!
//        XCTAssertTrue(timeRule.contains(day1))
//        
//        let day2 = formatter.date(from: "2022/10/04T13:00:00")!
//        XCTAssertTrue(timeRule.contains(day2))
//        
//        let day3 = formatter.date(from: "2022/10/05T13:00:00")!
//        XCTAssertTrue(timeRule.contains(day3))
//        
//        let day4 = formatter.date(from: "2022/10/06T13:00:00")!
//        XCTAssertTrue(timeRule.contains(day4))
//        
//        let day5 = formatter.date(from: "2022/10/07T13:00:00")!
//        XCTAssertTrue(timeRule.contains(day5))
//        
//        let day6 = formatter.date(from: "2022/10/08T13:00:00")!
//        XCTAssertTrue(timeRule.contains(day6))
//        
//        let day7 = formatter.date(from: "2022/10/09T13:00:00")!
//        XCTAssertTrue(timeRule.contains(day7))
//        
//        let day8 = formatter.date(from: "2022/10/10T13:00:00")!
//        XCTAssertTrue(timeRule.contains(day8))
//        
//        let day9 = formatter.date(from: "2022/10/11T13:00:00")!
//        XCTAssertTrue(timeRule.contains(day9))
//        
//        let day10 = formatter.date(from: "2022/10/12T13:00:00")!
//        XCTAssertTrue(timeRule.contains(day10))
//        
//    }
//    
//    func testSimpleWeekTimeMidnight() throws {
//        let timeRule: TimeRule = .timeRange(TimeRange(weekday: nil, start: Time(12, 00), end: Time(01, 00)))
//        
//        let day1 = formatter.date(from: "2022/10/03T00:00:00")!
//        XCTAssertTrue(timeRule.contains(day1))
//        
//        let day2 = formatter.date(from: "2022/10/04T00:00:00")!
//        XCTAssertTrue(timeRule.contains(day2))
//        
//        let day3 = formatter.date(from: "2022/10/05T00:00:00")!
//        XCTAssertTrue(timeRule.contains(day3))
//        
//        let day4 = formatter.date(from: "2022/10/06T00:00:00")!
//        XCTAssertTrue(timeRule.contains(day4))
//        
//        let day5 = formatter.date(from: "2022/10/07T00:00:00")!
//        XCTAssertTrue(timeRule.contains(day5))
//        
//        let day6 = formatter.date(from: "2022/10/08T00:00:00")!
//        XCTAssertTrue(timeRule.contains(day6))
//        
//        let day7 = formatter.date(from: "2022/10/09T00:00:00")!
//        XCTAssertTrue(timeRule.contains(day7))
//        
//        let day8 = formatter.date(from: "2022/10/10T00:00:00")!
//        XCTAssertTrue(timeRule.contains(day8))
//        
//        let day9 = formatter.date(from: "2022/10/11T00:00:00")!
//        XCTAssertTrue(timeRule.contains(day9))
//        
//        let day10 = formatter.date(from: "2022/10/12T00:00:00")!
//        XCTAssertTrue(timeRule.contains(day10))
//    }
//    
//    func testSimpleWeekTime1AM() throws {
//        let timeRule: TimeRule = .timeRange(TimeRange(weekday: nil, start: Time(12, 00), end: Time(01, 00)))
//        
//        let day1 = formatter.date(from: "2022/10/03T00:00:40")!
//        XCTAssertTrue(timeRule.contains(day1))
//        
//        let day2 = formatter.date(from: "2022/10/04T00:00:40")!
//        XCTAssertTrue(timeRule.contains(day2))
//        
//        let day3 = formatter.date(from: "2022/10/05T00:00:40")!
//        XCTAssertTrue(timeRule.contains(day3))
//        
//        let day4 = formatter.date(from: "2022/10/06T00:00:40")!
//        XCTAssertTrue(timeRule.contains(day4))
//        
//        let day5 = formatter.date(from: "2022/10/07T00:00:40")!
//        XCTAssertTrue(timeRule.contains(day5))
//        
//        let day6 = formatter.date(from: "2022/10/08T00:00:40")!
//        XCTAssertTrue(timeRule.contains(day6))
//        
//        let day7 = formatter.date(from: "2022/10/09T00:00:40")!
//        XCTAssertTrue(timeRule.contains(day7))
//        
//        let day8 = formatter.date(from: "2022/10/10T00:00:40")!
//        XCTAssertTrue(timeRule.contains(day8))
//        
//        let day9 = formatter.date(from: "2022/10/11T00:00:40")!
//        XCTAssertTrue(timeRule.contains(day9))
//        
//        let day10 = formatter.date(from: "2022/10/12T00:00:40")!
//        XCTAssertTrue(timeRule.contains(day10))
//        
//    }
//    
//    func testSimpleWeekTime7AM() throws {
//        let timeRule: TimeRule = .timeRange(TimeRange(weekday: nil, start: Time(12, 00), end: Time(01, 00)))
//        
//        let day1 = formatter.date(from: "2022/10/03T07:00:40")!
//        XCTAssertFalse(timeRule.contains(day1))
//        
//        let day2 = formatter.date(from: "2022/10/04T07:00:40")!
//        XCTAssertFalse(timeRule.contains(day2))
//        
//        let day3 = formatter.date(from: "2022/10/05T07:00:40")!
//        XCTAssertFalse(timeRule.contains(day3))
//        
//        let day4 = formatter.date(from: "2022/10/06T07:00:40")!
//        XCTAssertFalse(timeRule.contains(day4))
//        
//        let day5 = formatter.date(from: "2022/10/07T07:00:40")!
//        XCTAssertFalse(timeRule.contains(day5))
//        
//        let day6 = formatter.date(from: "2022/10/08T07:00:40")!
//        XCTAssertFalse(timeRule.contains(day6))
//        
//        let day7 = formatter.date(from: "2022/10/09T07:00:40")!
//        XCTAssertFalse(timeRule.contains(day7))
//        
//        let day8 = formatter.date(from: "2022/10/10T07:00:40")!
//        XCTAssertFalse(timeRule.contains(day8))
//        
//        let day9 = formatter.date(from: "2022/10/11T07:00:40")!
//        XCTAssertFalse(timeRule.contains(day9))
//        
//        let day10 = formatter.date(from: "2022/10/12T07:00:40")!
//        XCTAssertFalse(timeRule.contains(day10))
//        
//    }
//    
//    func testSimpleWeek24_7() throws {
//        let timeRule: TimeRule = .timeRange(TimeRange(weekday: nil, start: Time(00, 00), end: Time(00, 00)))
//        
//        let day1 = formatter.date(from: "2022/10/03T00:00:00")!
//        XCTAssertTrue(timeRule.contains(day1))
//        
//        let day2 = formatter.date(from: "2022/10/04T00:00:00")!
//        XCTAssertTrue(timeRule.contains(day2))
//        
//        let day3 = formatter.date(from: "2022/10/05T00:00:00")!
//        XCTAssertTrue(timeRule.contains(day3))
//        
//        let day4 = formatter.date(from: "2022/10/03T00:30:00")!
//        XCTAssertTrue(timeRule.contains(day4))
//        
//        let day5 = formatter.date(from: "2022/10/04T00:30:00")!
//        XCTAssertTrue(timeRule.contains(day5))
//        
//        let day6 = formatter.date(from: "2022/10/05T00:30:00")!
//        XCTAssertTrue(timeRule.contains(day6))
//        
//        let day7 = formatter.date(from: "2022/10/03T23:00:00")!
//        XCTAssertTrue(timeRule.contains(day7))
//        
//        let day8 = formatter.date(from: "2022/10/04T23:00:00")!
//        XCTAssertTrue(timeRule.contains(day8))
//        
//        let day9 = formatter.date(from: "2022/10/05T23:00:00")!
//        XCTAssertTrue(timeRule.contains(day9))
//    }
//    
//    func testSimpleWeekStandardTime() throws {
//        let timeRule: TimeRule = .timeRange(TimeRange(weekday: nil, start: Time(13, 00), end: Time(22, 00)))
//        
//        let day1 = formatter.date(from: "2022/10/03T21:59:59")!
//        XCTAssertTrue(timeRule.contains(day1))
//        
//        let day2 = formatter.date(from: "2022/10/04T14:00:00")!
//        XCTAssertTrue(timeRule.contains(day2))
//        
//        let day3 = formatter.date(from: "2022/10/04T13:00:00")!
//        XCTAssertTrue(timeRule.contains(day3))
//        
//        let day1_ = formatter.date(from: "2022/10/03T23:00:00")!
//        XCTAssertFalse(timeRule.contains(day1_))
//        
//        let day2_ = formatter.date(from: "2022/10/04T10:00:00")!
//        XCTAssertFalse(timeRule.contains(day2_))
//        
//        let day3_ = formatter.date(from: "2022/10/04T22:00:00")!
//        XCTAssertFalse(timeRule.contains(day3_))
//        
//    }
//    
//    func testDisco() throws {
//        let timeRule: TimeRule = .timeRange(TimeRange(weekday: .saturday, start: Time(22, 00), end: Time(06, 00)))
//        
//        let day1 = formatter.date(from: "2022/10/08T21:59:59")!
//        XCTAssertFalse(timeRule.contains(day1))
//        
//        let day2 = formatter.date(from: "2022/10/08T22:00:00")!
//        XCTAssertTrue(timeRule.contains(day2))
//        
//        let day3 = formatter.date(from: "2022/10/09T00:00:00")!
//        XCTAssertTrue(timeRule.contains(day3))
//        
//        let day4 = formatter.date(from: "2022/10/08T00:00:00")!
//        XCTAssertFalse(timeRule.contains(day4))
//        
//        let day5 = formatter.date(from: "2022/10/09T01:00:00")!
//        XCTAssertTrue(timeRule.contains(day5))
//        
//        let day6 = formatter.date(from: "2022/10/09T05:59:59")!
//        XCTAssertTrue(timeRule.contains(day6))
//        
//        let day7 = formatter.date(from: "2022/10/09T06:00:00")!
//        XCTAssertFalse(timeRule.contains(day7))
//        
//        let day8 = formatter.date(from: "2022/10/09T07:00:00")!
//        XCTAssertFalse(timeRule.contains(day8))
//    }
//    
//    func testCodable() throws {
//        let beginSummerHoliday = formatter.date(from: "2023/06/01T00:00:00")!
//        let endSummerHoliday = formatter.date(from: "2023/07/10T00:00:00")!
//        
//        let timeRule: TimeRule =
//            .and([
//                .not(.dateInterval(DateInterval(start: beginSummerHoliday, end: endSummerHoliday))),
//                .or([
//                    .timeRange(TimeRange(weekday: .tuesday, start: Time(11, 00), end: Time(14, 30))),
//                    .timeRange(TimeRange(weekday: .wednesday, start: Time(22, 00), end: Time(05, 00))),
//                    .timeRange(TimeRange(weekday: .thursday, start: Time(11, 00), end: Time(14, 30))),
//                    .timeRange(TimeRange(weekday: .friday, start: Time(11, 00), end: Time(14, 30))),
//                    .timeRange(TimeRange(weekday: .friday,  start: Time(18, 00), end: Time(00, 00))),
//                    .timeRange(TimeRange(weekday: .saturday, start: Time(00, 00), end: Time(00, 00))),
//                    .timeRange(TimeRange(weekday: .sunday, start: Time(11, 00), end: Time(14, 30)))
//                ]),
//            ])
//        
//        let encoder = JSONEncoder()
//        let decoder = JSONDecoder()
//        let encodedData = try encoder.encode(timeRule)
//        let decoded = try decoder.decode(TimeRule.self, from: encodedData)
//        
//        XCTAssertEqual(timeRule, decoded)
//    }
//}
