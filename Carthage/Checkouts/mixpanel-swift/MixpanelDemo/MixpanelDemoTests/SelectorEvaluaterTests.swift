//
//  SelectorTests.swift
//  MixpanelDemoTests
//
//  Created by Madhu Palani on 3/4/19.
//  Copyright © 2019 Mixpanel. All rights reserved.
//

import Foundation
import XCTest
@testable import Mixpanel
@testable import MixpanelDemo

class SelectorEvaluatorTests: XCTestCase {
    var logger: TestLogging!
    override func setUp() {
        super.setUp()
        logger = TestLogging()
        Logger.addLogging(logger)
    }
    
    func testToNumber() {
        XCTAssertNil(SelectorEvaluator.toNumber(value: nil))
        XCTAssertNil(SelectorEvaluator.toNumber(value: Date(timeIntervalSince1970: 0)))
        XCTAssertEqual(SelectorEvaluator.toNumber(value: true), 1)
        XCTAssertEqual(SelectorEvaluator.toNumber(value: false), 0)
        XCTAssertEqual(SelectorEvaluator.toNumber(value: Double(100.1)), 100.1)
        XCTAssertEqual(SelectorEvaluator.toNumber(value: Int(101)), 101)
        XCTAssertEqual(SelectorEvaluator.toNumber(value: NSNumber(value: 101.1)), 101.1)
        XCTAssertEqual(SelectorEvaluator.toNumber(value: "100"), 100)
        XCTAssertEqual(SelectorEvaluator.toNumber(value: "101.1"), 101.1)
        XCTAssertEqual(SelectorEvaluator.toNumber(value: "abc"), 0)
    }
    
    func testToBoolean() {
        XCTAssertFalse(SelectorEvaluator.toBoolean(value: nil))
        XCTAssertTrue(SelectorEvaluator.toBoolean(value: true))
        XCTAssertFalse(SelectorEvaluator.toBoolean(value: false))
        XCTAssertTrue(SelectorEvaluator.toBoolean(value: 100))
        XCTAssertTrue(SelectorEvaluator.toBoolean(value: 0.1))
        XCTAssertTrue(SelectorEvaluator.toBoolean(value: -1))
        XCTAssertFalse(SelectorEvaluator.toBoolean(value: 0))
        XCTAssertFalse(SelectorEvaluator.toBoolean(value: 0.0))
        XCTAssertTrue(SelectorEvaluator.toBoolean(value: "abc"))
        XCTAssertFalse(SelectorEvaluator.toBoolean(value: ""))
        XCTAssertTrue(SelectorEvaluator.toBoolean(value: [1,2]))
        XCTAssertFalse(SelectorEvaluator.toBoolean(value: []))
        XCTAssertTrue(SelectorEvaluator.toBoolean(value: ["abc": 1]))
        XCTAssertFalse(SelectorEvaluator.toBoolean(value: [:]))
        XCTAssertTrue(SelectorEvaluator.toBoolean(value: Date(timeIntervalSince1970: 1)))
        XCTAssertFalse(SelectorEvaluator.toBoolean(value: Date(timeIntervalSince1970: 0)))
        XCTAssertFalse(SelectorEvaluator.toBoolean(value: TakeoverNotification(JSONObject: nil)))
    }
    
    func testEvaluateNumber() {
        XCTAssertNil(SelectorEvaluator.evaluateNumber(node: [:], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid operator: number")
        XCTAssertNil(SelectorEvaluator.evaluateNumber(node: ["operator": "or"], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid operator: number")
        XCTAssertNil(SelectorEvaluator.evaluateNumber(node: ["operator": "number"], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid operator: number")
        XCTAssertNil(SelectorEvaluator.evaluateNumber(node: ["operator": "number", "children": []], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid operator: number")
        XCTAssertNil(SelectorEvaluator.evaluateNumber(node: ["operator": "number", "children": [[], []]], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid operator: number")
        
        XCTAssertEqual(SelectorEvaluator.evaluateNumber(node: ["operator": "number", "children": [["property": "event", "value": "prop"]]], properties: ["prop": Date(timeIntervalSince1970: 1)]), 1)
        XCTAssertNil(SelectorEvaluator.evaluateNumber(node: ["operator": "number", "children": [["property": "event", "value": "prop"]]], properties: ["prop": [:]]))
        XCTAssertNil(SelectorEvaluator.evaluateNumber(node: ["operator": "number", "children": [["property": "event", "value": "prop"]]], properties: ["prop": []]))
        XCTAssertEqual(SelectorEvaluator.evaluateNumber(node: ["operator": "number", "children": [["property": "event", "value": "prop"]]], properties: ["prop": true]), 1)
        XCTAssertEqual(SelectorEvaluator.evaluateNumber(node: ["operator": "number", "children": [["property": "event", "value": "prop"]]], properties: ["prop": false]), 0)
        XCTAssertEqual(SelectorEvaluator.evaluateNumber(node: ["operator": "number", "children": [["property": "event", "value": "prop"]]], properties: ["prop": Double(100)]), 100)
        XCTAssertEqual(SelectorEvaluator.evaluateNumber(node: ["operator": "number", "children": [["property": "event", "value": "prop"]]], properties: ["prop": Double(100.1)]), 100.1)
        XCTAssertEqual(SelectorEvaluator.evaluateNumber(node: ["operator": "number", "children": [["property": "event", "value": "prop"]]], properties: ["prop": Int(101)]), 101)
        XCTAssertEqual(SelectorEvaluator.evaluateNumber(node: ["operator": "number", "children": [["property": "event", "value": "prop"]]], properties: ["prop": "101"]), 101)
        XCTAssertEqual(SelectorEvaluator.evaluateNumber(node: ["operator": "number", "children": [["property": "event", "value": "prop"]]], properties: ["prop": "10.1"]), 10.1)
        XCTAssertEqual(SelectorEvaluator.evaluateNumber(node: ["operator": "number", "children": [["property": "event", "value": "prop"]]], properties: ["prop": "abc"]), 0)
        XCTAssertEqual(SelectorEvaluator.evaluateNumber(node: ["operator": "number", "children": [["property": "event", "value": "prop"]]], properties: ["prop": ""]), 0)
    }
    
    func testEvaluateBoolean() {
        XCTAssertNil(SelectorEvaluator.evaluateBoolean(node: [:], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid operator: boolean")
        XCTAssertNil(SelectorEvaluator.evaluateBoolean(node: ["operator": "or"], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid operator: boolean")
        XCTAssertNil(SelectorEvaluator.evaluateBoolean(node: ["operator": "boolean"], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid operator: boolean")
        XCTAssertNil(SelectorEvaluator.evaluateBoolean(node: ["operator": "boolean", "children": []], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid operator: boolean")
        XCTAssertNil(SelectorEvaluator.evaluateBoolean(node: ["operator": "boolean", "children": [[], []]], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid operator: boolean")
        
        XCTAssertFalse(SelectorEvaluator.evaluateBoolean(node: ["operator": "boolean", "children": [["property": "event", "value": "prop"]]], properties: [:])!)
        XCTAssertTrue(SelectorEvaluator.evaluateBoolean(node: ["operator": "boolean", "children": [["property": "event", "value": "prop"]]], properties: ["prop": true])!)
        XCTAssertFalse(SelectorEvaluator.evaluateBoolean(node: ["operator": "boolean", "children": [["property": "event", "value": "prop"]]], properties: ["prop": false])!)
        XCTAssertTrue(SelectorEvaluator.evaluateBoolean(node: ["operator": "boolean", "children": [["property": "event", "value": "prop"]]], properties: ["prop": 100])!)
        XCTAssertFalse(SelectorEvaluator.evaluateBoolean(node: ["operator": "boolean", "children": [["property": "event", "value": "prop"]]], properties: ["prop": 0])!)
        XCTAssertTrue(SelectorEvaluator.evaluateBoolean(node: ["operator": "boolean", "children": [["property": "event", "value": "prop"]]], properties: ["prop": "100"])!)
        XCTAssertFalse(SelectorEvaluator.evaluateBoolean(node: ["operator": "boolean", "children": [["property": "event", "value": "prop"]]], properties: ["prop": ""])!)
        XCTAssertTrue(SelectorEvaluator.evaluateBoolean(node: ["operator": "boolean", "children": [["property": "event", "value": "prop"]]], properties: ["prop": [1,2,3]])!)
        XCTAssertFalse(SelectorEvaluator.evaluateBoolean(node: ["operator": "boolean", "children": [["property": "event", "value": "prop"]]], properties: ["prop": []])!)
        XCTAssertTrue(SelectorEvaluator.evaluateBoolean(node: ["operator": "boolean", "children": [["property": "event", "value": "prop"]]], properties: ["prop": ["a":1]])!)
        XCTAssertFalse(SelectorEvaluator.evaluateBoolean(node: ["operator": "boolean", "children": [["property": "event", "value": "prop"]]], properties: ["prop": [:]])!)
        XCTAssertTrue(SelectorEvaluator.evaluateBoolean(node: ["operator": "boolean", "children": [["property": "event", "value": "prop"]]], properties: ["prop": Date(timeIntervalSince1970: 1)])!)
        XCTAssertFalse(SelectorEvaluator.evaluateBoolean(node: ["operator": "boolean", "children": [["property": "event", "value": "prop"]]], properties: ["prop": Date(timeIntervalSince1970: 0)])!)
    }
    
    func testEvaluateDatetime() {
        XCTAssertNil(SelectorEvaluator.evaluateDateTime(node: [:], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid operator: datetime")
        XCTAssertNil(SelectorEvaluator.evaluateDateTime(node: ["operator": "or"], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid operator: datetime")
        XCTAssertNil(SelectorEvaluator.evaluateDateTime(node: ["operator": "datetime"], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid operator: datetime")
        XCTAssertNil(SelectorEvaluator.evaluateDateTime(node: ["operator": "datetime", "children": []], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid operator: datetime")
        XCTAssertNil(SelectorEvaluator.evaluateDateTime(node: ["operator": "datetime", "children": [[], []]], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid operator: datetime")
        
        XCTAssertNil(SelectorEvaluator.evaluateDateTime(node: ["operator": "datetime", "children": [["property": "event", "value": "prop"]]], properties: [:]))
        XCTAssertNil(SelectorEvaluator.evaluateDateTime(node: ["operator": "datetime", "children": [["property": "event", "value": "prop"]]], properties: ["prop": true]))
        XCTAssertEqual(SelectorEvaluator.evaluateDateTime(node: ["operator": "datetime", "children": [["property": "event", "value": "prop"]]], properties: ["prop": 10]), Date(timeIntervalSince1970: 10))
        let df = DateFormatter.formatterForJSONDate();
        let dt = df.date(from: "2019-02-01T12:01:01")
        XCTAssertNotNil(dt)
        XCTAssertEqual(SelectorEvaluator.evaluateDateTime(node: ["operator": "datetime", "children": [["property": "event", "value": "prop"]]], properties: ["prop": "2019-02-01T12:01:01"]), dt)
        XCTAssertEqual(SelectorEvaluator.evaluateDateTime(node: ["operator": "datetime", "children": [["property": "event", "value": "prop"]]], properties: ["prop": dt!]), dt)
        XCTAssertNil(SelectorEvaluator.evaluateDateTime(node: ["operator": "datetime", "children": [["property": "event", "value": "prop"]]], properties: ["prop": "2019-02-01T32:01:01"]))
    }
    
    func testEvaluateList() {
        XCTAssertNil(SelectorEvaluator.evaluateList(node: [:], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid operator: list")
        XCTAssertNil(SelectorEvaluator.evaluateList(node: ["operator": "or"], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid operator: list")
        XCTAssertNil(SelectorEvaluator.evaluateList(node: ["operator": "list"], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid operator: list")
        XCTAssertNil(SelectorEvaluator.evaluateList(node: ["operator": "list", "children": []], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid operator: list")
        XCTAssertNil(SelectorEvaluator.evaluateList(node: ["operator": "list", "children": [[], []]], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid operator: list")
        
        XCTAssertNil(SelectorEvaluator.evaluateList(node: ["operator": "list", "children": [["property": "event", "value": "prop"]]], properties: [:]))
        XCTAssertNil(SelectorEvaluator.evaluateList(node: ["operator": "list", "children": [["property": "event", "value": "prop"]]], properties: ["prop": 1]))
        XCTAssertNil(SelectorEvaluator.evaluateList(node: ["operator": "list", "children": [["property": "event", "value": "prop"]]], properties: ["prop": ""]))
        XCTAssertNil(SelectorEvaluator.evaluateList(node: ["operator": "list", "children": [["property": "event", "value": "prop"]]], properties: ["prop": [:]]))
        
        XCTAssertEqual(NSSet(array: SelectorEvaluator.evaluateList(node: ["operator": "list", "children": [["property": "event", "value": "prop"]]], properties: ["prop": []])!), NSSet(array: []))
        XCTAssertEqual(NSSet(array: SelectorEvaluator.evaluateList(node: ["operator": "list", "children": [["property": "event", "value": "prop"]]], properties: ["prop": [1,2,3]])!), NSSet(array: [1,2,3]))
    }
    
    func testEvaluateString() {
        XCTAssertNil(SelectorEvaluator.evaluateString(node: [:], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid operator: string")
        XCTAssertNil(SelectorEvaluator.evaluateString(node: ["operator": "or"], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid operator: string")
        XCTAssertNil(SelectorEvaluator.evaluateString(node: ["operator": "string"], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid operator: string")
        XCTAssertNil(SelectorEvaluator.evaluateString(node: ["operator": "string", "children": []], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid operator: string")
        XCTAssertNil(SelectorEvaluator.evaluateString(node: ["operator": "string", "children": [[], []]], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid operator: string")
        
        let df = DateFormatter.formatterForJSONDate()
        let dt = df.date(from: "2019-01-01T00:00:00")
        XCTAssertNotNil(dt)
        XCTAssertEqual(SelectorEvaluator.evaluateString(node: ["operator": "string", "children": [["property": "event", "value": "prop"]]], properties: ["prop": dt!]), "2019-01-01T00:00:00")
        XCTAssertEqual(SelectorEvaluator.evaluateString(node: ["operator": "string", "children": [["property": "event", "value": "prop"]]], properties: ["prop": 100]), "100")
        XCTAssertEqual(SelectorEvaluator.evaluateString(node: ["operator": "string", "children": [["property": "event", "value": "prop"]]], properties: ["prop": []]), "[]")
        XCTAssertEqual(SelectorEvaluator.evaluateString(node: ["operator": "string", "children": [["property": "event", "value": "prop"]]], properties: ["prop": [1,2,3]]), "[1,2,3]")
        XCTAssertEqual(SelectorEvaluator.evaluateString(node: ["operator": "string", "children": [["property": "event", "value": "prop"]]], properties: ["prop": [:]]), "{}")
        XCTAssertEqual(SelectorEvaluator.evaluateString(node: ["operator": "string", "children": [["property": "event", "value": "prop"]]], properties: ["prop": ["a":"b"]]), "{\"a\":\"b\"}")
        XCTAssertEqual(SelectorEvaluator.evaluateString(node: ["operator": "string", "children": [["property": "event", "value": "prop"]]], properties: ["prop": true]), "true")
        XCTAssertEqual(SelectorEvaluator.evaluateString(node: ["operator": "string", "children": [["property": "event", "value": "prop"]]], properties: ["prop": "blah"]), "blah")
    }
    
    func testEvaluateAnd() {
        XCTAssertNil(SelectorEvaluator.evaluateAnd(node: [:], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid operator: and")
        XCTAssertNil(SelectorEvaluator.evaluateAnd(node: ["operator": "or"], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid operator: and")
        XCTAssertNil(SelectorEvaluator.evaluateAnd(node: ["operator": "and"], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid operator: and")
        XCTAssertNil(SelectorEvaluator.evaluateAnd(node: ["operator": "and", "children": []], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid operator: and")
        XCTAssertNil(SelectorEvaluator.evaluateAnd(node: ["operator": "and", "children": [[]]], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid operator: and")
        
        XCTAssertTrue(SelectorEvaluator.evaluateAnd(node: ["operator": "and", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": true, "prop2": true])!)
        XCTAssertFalse(SelectorEvaluator.evaluateAnd(node: ["operator": "and", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": true, "prop2": false])!)
        XCTAssertFalse(SelectorEvaluator.evaluateAnd(node: ["operator": "and", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": false, "prop2": true])!)
        XCTAssertFalse(SelectorEvaluator.evaluateAnd(node: ["operator": "and", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": false, "prop2": false])!)
    }
    
    func testEvaluateOr() {
        XCTAssertNil(SelectorEvaluator.evaluateOr(node: [:], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid operator: or")
        XCTAssertNil(SelectorEvaluator.evaluateOr(node: ["operator": "and"], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid operator: or")
        XCTAssertNil(SelectorEvaluator.evaluateOr(node: ["operator": "or"], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid operator: or")
        XCTAssertNil(SelectorEvaluator.evaluateOr(node: ["operator": "or", "children": []], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid operator: or")
        XCTAssertNil(SelectorEvaluator.evaluateOr(node: ["operator": "or", "children": [[]]], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid operator: or")
        
        XCTAssertTrue(SelectorEvaluator.evaluateOr(node: ["operator": "or", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": true, "prop2": true])!)
        XCTAssertTrue(SelectorEvaluator.evaluateOr(node: ["operator": "or", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": true, "prop2": false])!)
        XCTAssertTrue(SelectorEvaluator.evaluateOr(node: ["operator": "or", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": false, "prop2": true])!)
        XCTAssertFalse(SelectorEvaluator.evaluateOr(node: ["operator": "or", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": false, "prop2": false])!)
    }
    
    func testEvaluateIn() {
        XCTAssertNil(SelectorEvaluator.evaluateIn(node: [:], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid operator: in")
        XCTAssertNil(SelectorEvaluator.evaluateIn(node: ["operator": "and"], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid operator: in")
        XCTAssertNil(SelectorEvaluator.evaluateIn(node: ["operator": "in"], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid operator: in")
        XCTAssertNil(SelectorEvaluator.evaluateIn(node: ["operator": "in", "children": []], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid operator: in")
        XCTAssertNil(SelectorEvaluator.evaluateIn(node: ["operator": "in", "children": [[]]], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid operator: in")
        
        XCTAssertTrue(SelectorEvaluator.evaluateIn(node: ["operator": "in", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": 1, "prop2": [1,2]])!)
        XCTAssertTrue(SelectorEvaluator.evaluateIn(node: ["operator": "in", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": "ab", "prop2": "abc"])!)
        XCTAssertFalse(SelectorEvaluator.evaluateIn(node: ["operator": "in", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": 1, "prop2": [11]])!)
        XCTAssertFalse(SelectorEvaluator.evaluateIn(node: ["operator": "in", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": "ab", "prop2": "bac"])!)
        
        XCTAssertFalse(SelectorEvaluator.evaluateIn(node: ["operator": "not in", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": 1, "prop2": [1,2]])!)
        XCTAssertFalse(SelectorEvaluator.evaluateIn(node: ["operator": "not in", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": "ab", "prop2": "abc"])!)
        XCTAssertTrue(SelectorEvaluator.evaluateIn(node: ["operator": "not in", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": 1, "prop2": [11]])!)
        XCTAssertTrue(SelectorEvaluator.evaluateIn(node: ["operator": "not in", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": "ab", "prop2": "bac"])!)
    }
    
    func testEvaluatePlus() {
        XCTAssertNil(SelectorEvaluator.evaluatePlus(node: [:], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid operator: +")
        XCTAssertNil(SelectorEvaluator.evaluatePlus(node: ["operator": "and"], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid operator: +")
        XCTAssertNil(SelectorEvaluator.evaluatePlus(node: ["operator": "+"], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid operator: +")
        XCTAssertNil(SelectorEvaluator.evaluatePlus(node: ["operator": "+", "children": []], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid operator: +")
        XCTAssertNil(SelectorEvaluator.evaluatePlus(node: ["operator": "+", "children": [[]]], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid operator: +")
        
        XCTAssertNil(SelectorEvaluator.evaluatePlus(node: ["operator": "+", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": 1, "prop2": [1,2]]))
        XCTAssertEqual(SelectorEvaluator.evaluatePlus(node: ["operator": "+", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": 1, "prop2": 2]) as? Double, 3)
        XCTAssertEqual(SelectorEvaluator.evaluatePlus(node: ["operator": "+", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": "1", "prop2": "2"]) as? String, "12")
    }
    
    func testEvaluateArithmetic() {
        XCTAssertNil(SelectorEvaluator.evaluateArithmetic(node: [:], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid arithmetic operator")
        XCTAssertNil(SelectorEvaluator.evaluateArithmetic(node: ["operator": "and"], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid arithmetic operator")
        XCTAssertNil(SelectorEvaluator.evaluateArithmetic(node: ["operator": "-"], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid arithmetic operator")
        XCTAssertNil(SelectorEvaluator.evaluateArithmetic(node: ["operator": "-", "children": []], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid arithmetic operator")
        XCTAssertNil(SelectorEvaluator.evaluateArithmetic(node: ["operator": "-", "children": [[]]], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid arithmetic operator")
        
        XCTAssertEqual(SelectorEvaluator.evaluateArithmetic(node: ["operator": "-", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": 1, "prop2": 2]), -1)
        XCTAssertEqual(SelectorEvaluator.evaluateArithmetic(node: ["operator": "*", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": 1, "prop2": 2]), 2)
        XCTAssertEqual(SelectorEvaluator.evaluateArithmetic(node: ["operator": "/", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": 1, "prop2": 2]), 0.5)
        XCTAssertNil(SelectorEvaluator.evaluateArithmetic(node: ["operator": "/", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": 1, "prop2": 0]))
        XCTAssertNil(SelectorEvaluator.evaluateArithmetic(node: ["operator": "%", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": 1, "prop2": 0]))
        XCTAssertEqual(SelectorEvaluator.evaluateArithmetic(node: ["operator": "%", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": 0, "prop2": 1]), 0)
        XCTAssertEqual(SelectorEvaluator.evaluateArithmetic(node: ["operator": "%", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": -1, "prop2": 2]), 1)
        XCTAssertEqual(SelectorEvaluator.evaluateArithmetic(node: ["operator": "%", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": -1, "prop2": -2]), -1)
        XCTAssertEqual(SelectorEvaluator.evaluateArithmetic(node: ["operator": "%", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": 1, "prop2": -2]), -1)
    }
    
    func testEvaluateEquality() {
        XCTAssertNil(SelectorEvaluator.evaluateEquality(node: [:], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid (not) equality operator")
        XCTAssertNil(SelectorEvaluator.evaluateEquality(node: ["operator": "and"], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid (not) equality operator")
        XCTAssertNil(SelectorEvaluator.evaluateEquality(node: ["operator": "=="], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid (not) equality operator")
        XCTAssertNil(SelectorEvaluator.evaluateEquality(node: ["operator": "==", "children": []], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid (not) equality operator")
        XCTAssertNil(SelectorEvaluator.evaluateEquality(node: ["operator": "==", "children": [[]]], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid (not) equality operator")
        
        XCTAssertTrue(SelectorEvaluator.evaluateEquality(node: ["operator": "==", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: [:])!)
        
        XCTAssertFalse(SelectorEvaluator.evaluateEquality(node: ["operator": "==", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": 1, "prop2": "1"])!)
        
        XCTAssertTrue(SelectorEvaluator.evaluateEquality(node: ["operator": "==", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": 1, "prop2": 1])!)
        XCTAssertFalse(SelectorEvaluator.evaluateEquality(node: ["operator": "==", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": 1, "prop2": 2])!)
        
        XCTAssertTrue(SelectorEvaluator.evaluateEquality(node: ["operator": "==", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": true, "prop2": true])!)
        XCTAssertTrue(SelectorEvaluator.evaluateEquality(node: ["operator": "==", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": false, "prop2": false])!)
        XCTAssertFalse(SelectorEvaluator.evaluateEquality(node: ["operator": "==", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": true, "prop2": false])!)
        XCTAssertFalse(SelectorEvaluator.evaluateEquality(node: ["operator": "==", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": false, "prop2": true])!)
        
        XCTAssertTrue(SelectorEvaluator.evaluateEquality(node: ["operator": "==", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": "abc", "prop2": "abc"])!)
        XCTAssertFalse(SelectorEvaluator.evaluateEquality(node: ["operator": "==", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": "abc", "prop2": "acb"])!)
        
        XCTAssertTrue(SelectorEvaluator.evaluateEquality(node: ["operator": "==", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": Date(timeIntervalSince1970: 100), "prop2": Date(timeIntervalSince1970: 100)])!)
        XCTAssertFalse(SelectorEvaluator.evaluateEquality(node: ["operator": "==", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": Date(timeIntervalSince1970: 100), "prop2": Date(timeIntervalSince1970: 101)])!)
        
        XCTAssertTrue(SelectorEvaluator.evaluateEquality(node: ["operator": "==", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": ["a": 1, "b": 2], "prop2": ["b": 2, "a": 1]])!)
        XCTAssertFalse(SelectorEvaluator.evaluateEquality(node: ["operator": "==", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": ["a": 1, "b": 2], "prop2": ["b": 1, "a": 2]])!)
        
        XCTAssertFalse(SelectorEvaluator.evaluateEquality(node: ["operator": "!=", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: [:])!)
        
        XCTAssertTrue(SelectorEvaluator.evaluateEquality(node: ["operator": "!=", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": 1, "prop2": "1"])!)
        
        XCTAssertFalse(SelectorEvaluator.evaluateEquality(node: ["operator": "!=", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": 1, "prop2": 1])!)
        XCTAssertTrue(SelectorEvaluator.evaluateEquality(node: ["operator": "!=", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": 1, "prop2": 2])!)
        
        XCTAssertFalse(SelectorEvaluator.evaluateEquality(node: ["operator": "!=", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": true, "prop2": true])!)
        XCTAssertFalse(SelectorEvaluator.evaluateEquality(node: ["operator": "!=", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": false, "prop2": false])!)
        XCTAssertTrue(SelectorEvaluator.evaluateEquality(node: ["operator": "!=", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": true, "prop2": false])!)
        XCTAssertTrue(SelectorEvaluator.evaluateEquality(node: ["operator": "!=", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": false, "prop2": true])!)
        
        XCTAssertFalse(SelectorEvaluator.evaluateEquality(node: ["operator": "!=", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": "abc", "prop2": "abc"])!)
        XCTAssertTrue(SelectorEvaluator.evaluateEquality(node: ["operator": "!=", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": "abc", "prop2": "acb"])!)
        
        XCTAssertFalse(SelectorEvaluator.evaluateEquality(node: ["operator": "!=", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": Date(timeIntervalSince1970: 100), "prop2": Date(timeIntervalSince1970: 100)])!)
        XCTAssertTrue(SelectorEvaluator.evaluateEquality(node: ["operator": "!=", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": Date(timeIntervalSince1970: 100), "prop2": Date(timeIntervalSince1970: 101)])!)
        
        XCTAssertFalse(SelectorEvaluator.evaluateEquality(node: ["operator": "!=", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": ["a": 1, "b": 2], "prop2": ["b": 2, "a": 1]])!)
        XCTAssertTrue(SelectorEvaluator.evaluateEquality(node: ["operator": "!=", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": ["a": 1, "b": 2], "prop2": ["b": 1, "a": 2]])!)
    }
    
    func testEvaluateComparison() {
        XCTAssertNil(SelectorEvaluator.evaluateComparison(node: [:], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid comparison operator")
        XCTAssertNil(SelectorEvaluator.evaluateComparison(node: ["operator": "and"], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid comparison operator")
        XCTAssertNil(SelectorEvaluator.evaluateComparison(node: ["operator": "<"], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid comparison operator")
        XCTAssertNil(SelectorEvaluator.evaluateComparison(node: ["operator": "<", "children": []], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid comparison operator")
        XCTAssertNil(SelectorEvaluator.evaluateComparison(node: ["operator": "<", "children": [[]]], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid comparison operator")
        
        XCTAssertFalse(SelectorEvaluator.evaluateComparison(node: ["operator": ">", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": 1, "prop2": 1])!)
        XCTAssertFalse(SelectorEvaluator.evaluateComparison(node: ["operator": ">", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": Date(timeIntervalSince1970: 1), "prop2": Date(timeIntervalSince1970: 1)])!)
        XCTAssertFalse(SelectorEvaluator.evaluateComparison(node: ["operator": ">", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": 1, "prop2": 2])!)
        XCTAssertFalse(SelectorEvaluator.evaluateComparison(node: ["operator": ">", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": Date(timeIntervalSince1970: 1), "prop2": Date(timeIntervalSince1970: 2)])!)
        XCTAssertTrue(SelectorEvaluator.evaluateComparison(node: ["operator": ">", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": 2, "prop2": 1])!)
        XCTAssertTrue(SelectorEvaluator.evaluateComparison(node: ["operator": ">", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": Date(timeIntervalSince1970: 2), "prop2": Date(timeIntervalSince1970: 1)])!)

        XCTAssertTrue(SelectorEvaluator.evaluateComparison(node: ["operator": ">=", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": 1, "prop2": 1])!)
        XCTAssertTrue(SelectorEvaluator.evaluateComparison(node: ["operator": ">=", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": Date(timeIntervalSince1970: 1), "prop2": Date(timeIntervalSince1970: 1)])!)
        XCTAssertFalse(SelectorEvaluator.evaluateComparison(node: ["operator": ">=", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": 1, "prop2": 2])!)
        XCTAssertFalse(SelectorEvaluator.evaluateComparison(node: ["operator": ">=", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": Date(timeIntervalSince1970: 1), "prop2": Date(timeIntervalSince1970: 2)])!)
        XCTAssertTrue(SelectorEvaluator.evaluateComparison(node: ["operator": ">=", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": 2, "prop2": 1])!)
        XCTAssertTrue(SelectorEvaluator.evaluateComparison(node: ["operator": ">=", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": Date(timeIntervalSince1970: 2), "prop2": Date(timeIntervalSince1970: 1)])!)
        
        XCTAssertFalse(SelectorEvaluator.evaluateComparison(node: ["operator": "<", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": 1, "prop2": 1])!)
        XCTAssertFalse(SelectorEvaluator.evaluateComparison(node: ["operator": "<", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": Date(timeIntervalSince1970: 1), "prop2": Date(timeIntervalSince1970: 1)])!)
        XCTAssertTrue(SelectorEvaluator.evaluateComparison(node: ["operator": "<", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": 1, "prop2": 2])!)
        XCTAssertTrue(SelectorEvaluator.evaluateComparison(node: ["operator": "<", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": Date(timeIntervalSince1970: 1), "prop2": Date(timeIntervalSince1970: 2)])!)
        XCTAssertFalse(SelectorEvaluator.evaluateComparison(node: ["operator": "<", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": 2, "prop2": 1])!)
        XCTAssertFalse(SelectorEvaluator.evaluateComparison(node: ["operator": "<", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": Date(timeIntervalSince1970: 2), "prop2": Date(timeIntervalSince1970: 1)])!)

        XCTAssertTrue(SelectorEvaluator.evaluateComparison(node: ["operator": "<=", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": 1, "prop2": 1])!)
        XCTAssertTrue(SelectorEvaluator.evaluateComparison(node: ["operator": "<=", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": Date(timeIntervalSince1970: 1), "prop2": Date(timeIntervalSince1970: 1)])!)
        XCTAssertTrue(SelectorEvaluator.evaluateComparison(node: ["operator": "<=", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": 1, "prop2": 2])!)
        XCTAssertTrue(SelectorEvaluator.evaluateComparison(node: ["operator": "<=", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": Date(timeIntervalSince1970: 1), "prop2": Date(timeIntervalSince1970: 2)])!)
        XCTAssertFalse(SelectorEvaluator.evaluateComparison(node: ["operator": "<=", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": 2, "prop2": 1])!)
        XCTAssertFalse(SelectorEvaluator.evaluateComparison(node: ["operator": "<=", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": Date(timeIntervalSince1970: 2), "prop2": Date(timeIntervalSince1970: 1)])!)
        
        XCTAssertTrue(SelectorEvaluator.evaluateComparison(node: ["operator": "<=", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": "abc", "prop2": "abc"])!)
        XCTAssertTrue(SelectorEvaluator.evaluateComparison(node: ["operator": ">=", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": "abc", "prop2": "abc"])!)
        XCTAssertTrue(SelectorEvaluator.evaluateComparison(node: ["operator": ">", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": "abc", "prop2": "ab"])!)
        XCTAssertTrue(SelectorEvaluator.evaluateComparison(node: ["operator": "<", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": "ab", "prop2": "abc"])!)
        
        XCTAssertNil(SelectorEvaluator.evaluateComparison(node: ["operator": "<=", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": [1,2,3], "prop2": 1]))
    }
    
    func testEvaluateDefined() {
        XCTAssertNil(SelectorEvaluator.evaluateDefined(node: [:], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid operator: (not) defined")
        XCTAssertNil(SelectorEvaluator.evaluateDefined(node: ["operator": "or"], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid operator: (not) defined")
        XCTAssertNil(SelectorEvaluator.evaluateDefined(node: ["operator": "defined"], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid operator: (not) defined")
        XCTAssertNil(SelectorEvaluator.evaluateDefined(node: ["operator": "defined", "children": []], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid operator: (not) defined")
        XCTAssertNil(SelectorEvaluator.evaluateDefined(node: ["operator": "defined", "children": [[], []]], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid operator: (not) defined")
        
        XCTAssertFalse(SelectorEvaluator.evaluateDefined(node: ["operator": "defined", "children": [["property": "event", "value": "prop"]]], properties: [:])!)
        XCTAssertTrue(SelectorEvaluator.evaluateDefined(node: ["operator": "defined", "children": [["property": "event", "value": "prop"]]], properties: ["prop": []])!)
        
        XCTAssertTrue(SelectorEvaluator.evaluateDefined(node: ["operator": "not defined", "children": [["property": "event", "value": "prop"]]], properties: [:])!)
        XCTAssertFalse(SelectorEvaluator.evaluateDefined(node: ["operator": "not defined", "children": [["property": "event", "value": "prop"]]], properties: ["prop": []])!)
    }
    
    func testEvaluateNot() {
        XCTAssertNil(SelectorEvaluator.evaluateNot(node: [:], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid operator: not")
        XCTAssertNil(SelectorEvaluator.evaluateNot(node: ["operator": "or"], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid operator: not")
        XCTAssertNil(SelectorEvaluator.evaluateNot(node: ["operator": "not"], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid operator: not")
        XCTAssertNil(SelectorEvaluator.evaluateNot(node: ["operator": "not", "children": []], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid operator: not")
        XCTAssertNil(SelectorEvaluator.evaluateNot(node: ["operator": "not", "children": [[], []]], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid operator: not")
        
        XCTAssertTrue(SelectorEvaluator.evaluateNot(node: ["operator": "not", "children": [["property": "event", "value": "prop"]]], properties: [:])!)
        XCTAssertTrue(SelectorEvaluator.evaluateNot(node: ["operator": "not", "children": [["property": "event", "value": "prop"]]], properties: ["prop": false])!)
        XCTAssertFalse(SelectorEvaluator.evaluateNot(node: ["operator": "not", "children": [["property": "event", "value": "prop"]]], properties: ["prop": true])!)
        XCTAssertNil(SelectorEvaluator.evaluateNot(node: ["operator": "not", "children": [["property": "event", "value": "prop"]]], properties: ["prop": []]))
        XCTAssertNil(SelectorEvaluator.evaluateNot(node: ["operator": "not", "children": [["property": "event", "value": "prop"]]], properties: ["prop": 1]))
        XCTAssertNil(SelectorEvaluator.evaluateNot(node: ["operator": "not", "children": [["property": "event", "value": "prop"]]], properties: ["prop": "1"]))
        XCTAssertNil(SelectorEvaluator.evaluateNot(node: ["operator": "not", "children": [["property": "event", "value": "prop"]]], properties: ["prop": [:]]))
    }
    
    func testEvaluateWindow() {
        XCTAssertNil(TestSelectorEvaluator.evaluateWindow(value: [:]))
        XCTAssertEqual(logger.logMessage?.text, "missing window")
        XCTAssertNil(TestSelectorEvaluator.evaluateWindow(value: ["window":[:]]))
        XCTAssertEqual(logger.logMessage?.text, "missing value")
        XCTAssertNil(TestSelectorEvaluator.evaluateWindow(value: ["window":["value":[]]]))
        XCTAssertEqual(logger.logMessage?.text, "missing value")
        XCTAssertNil(TestSelectorEvaluator.evaluateWindow(value: ["window":["value":1]]))
        XCTAssertEqual(logger.logMessage?.text, "missing unit")
        XCTAssertNil(TestSelectorEvaluator.evaluateWindow(value: ["window":["value":1, "unit": "blah"]]))
        XCTAssertEqual(logger.logMessage?.text, "Invalid unit for window")
        
        XCTAssertEqual(TestSelectorEvaluator.evaluateWindow(value: ["window": ["value": -2, "unit": "hour"]]), Date(timeIntervalSince1970: 10000+(2*60*60)))
        XCTAssertEqual(TestSelectorEvaluator.evaluateWindow(value: ["window": ["value": -2, "unit": "day"]]), Date(timeIntervalSince1970: 10000+(2*24*60*60)))
        XCTAssertEqual(TestSelectorEvaluator.evaluateWindow(value: ["window": ["value": -2, "unit": "week"]]), Date(timeIntervalSince1970: 10000+(2*7*24*60*60)))
        XCTAssertEqual(TestSelectorEvaluator.evaluateWindow(value: ["window": ["value": -2, "unit": "month"]]), Date(timeIntervalSince1970: 10000+(2*30*24*60*60)))
        XCTAssertEqual(TestSelectorEvaluator.evaluateWindow(value: ["window": ["value": 2, "unit": "hour"]]), Date(timeIntervalSince1970: 10000+(-2*60*60)))
    }
    
    func testEvaluateOperand() {
        XCTAssertNil(SelectorEvaluator.evaluateOperand(node: [:], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "missing key property")
        XCTAssertNil(SelectorEvaluator.evaluateOperand(node: ["property": 1], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "missing key property")
        XCTAssertNil(SelectorEvaluator.evaluateOperand(node: ["property": "event"], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "missing key value")
        XCTAssertNil(SelectorEvaluator.evaluateOperand(node: ["property": "event", "value": 1], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "unexpected type for event property")
        
        XCTAssertEqual(SelectorEvaluator.evaluateOperand(node: ["property": "event", "value": "prop"], properties: ["prop": Double(100)]) as? Double, 100)
        XCTAssertEqual(SelectorEvaluator.evaluateOperand(node: ["property": "literal", "value": "prop"], properties: ["prop": Double(100)]) as? String, "prop")
        XCTAssertEqual(TestSelectorEvaluator.evaluateOperand(node: ["property": "literal", "value": "now"], properties: ["prop": Double(100)]) as? Date, Date(timeIntervalSince1970: 10000))
        XCTAssertEqual(TestSelectorEvaluator.evaluateOperand(node: ["property": "literal", "value": ["window": ["value": -1, "unit": "hour"]]], properties: ["prop": Double(100)]) as? Date, Date(timeIntervalSince1970: 10000+(60*60)))
    }
    
    func testEvaluateOperator() {
        XCTAssertNil(SelectorEvaluator.evaluateOperator(node: [:], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid operator key")
        XCTAssertNil(SelectorEvaluator.evaluateOperator(node: ["operator": 1], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "invalid operator key")
        XCTAssertNil(SelectorEvaluator.evaluateOperator(node: ["operator": "blah"], properties: InternalProperties()))
        XCTAssertEqual(logger.logMessage?.text, "Unknown operator blah")
        
        XCTAssertTrue(SelectorEvaluator.evaluateOperator(node: ["operator": "and", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": true, "prop2": true]) as! Bool)
        XCTAssertTrue(SelectorEvaluator.evaluateOperator(node: ["operator": "or", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": true, "prop2": false]) as! Bool)
        XCTAssertTrue(SelectorEvaluator.evaluateOperator(node: ["operator": "in", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": 1, "prop2": [1,2]]) as! Bool)
        XCTAssertTrue(SelectorEvaluator.evaluateOperator(node: ["operator": "not in", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": 12, "prop2": [1,2]]) as! Bool)
        XCTAssertEqual(SelectorEvaluator.evaluateOperator(node: ["operator": "+", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": 1, "prop2": 2]) as! Double, 3)
        XCTAssertEqual(SelectorEvaluator.evaluateOperator(node: ["operator": "-", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": 1, "prop2": 2]) as! Double, -1)
        XCTAssertEqual(SelectorEvaluator.evaluateOperator(node: ["operator": "*", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": 1, "prop2": 2]) as! Double, 2)
        XCTAssertEqual(SelectorEvaluator.evaluateOperator(node: ["operator": "/", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": 1, "prop2": 2]) as! Double, 0.5)
        XCTAssertEqual(SelectorEvaluator.evaluateOperator(node: ["operator": "%", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": 1, "prop2": 2]) as! Double, 1)
        XCTAssertTrue(SelectorEvaluator.evaluateOperator(node: ["operator": "==", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": false, "prop2": false]) as! Bool)
        XCTAssertTrue(SelectorEvaluator.evaluateOperator(node: ["operator": "!=", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": true, "prop2": false]) as! Bool)
        XCTAssertTrue(SelectorEvaluator.evaluateOperator(node: ["operator": ">", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": 2, "prop2": 1]) as! Bool)
        XCTAssertTrue(SelectorEvaluator.evaluateOperator(node: ["operator": ">=", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": 2, "prop2": 2]) as! Bool)
        XCTAssertTrue(SelectorEvaluator.evaluateOperator(node: ["operator": "<", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": 0, "prop2": 1]) as! Bool)
        XCTAssertTrue(SelectorEvaluator.evaluateOperator(node: ["operator": "<=", "children": [["property": "event", "value": "prop1"], ["property": "event", "value": "prop2"]]], properties: ["prop1": 1, "prop2": 1]) as! Bool)
        XCTAssertTrue(SelectorEvaluator.evaluateOperator(node: ["operator": "boolean", "children": [["property": "event", "value": "prop"]]], properties: ["prop": true]) as! Bool)
        XCTAssertEqual(SelectorEvaluator.evaluateOperator(node: ["operator": "string", "children": [["property": "event", "value": "prop"]]], properties: ["prop": 100]) as! String, "100")
        XCTAssertEqual(NSSet(array: SelectorEvaluator.evaluateOperator(node: ["operator": "list", "children": [["property": "event", "value": "prop"]]], properties: ["prop": [1,2,3]]) as! Array), NSSet(array: [1,2,3]))
        XCTAssertEqual(SelectorEvaluator.evaluateOperator(node: ["operator": "number", "children": [["property": "event", "value": "prop"]]], properties: ["prop": "101"]) as! Double, 101)
        let df = DateFormatter.formatterForJSONDate();
        let dt = df.date(from: "2019-02-01T12:01:01")
        XCTAssertNotNil(dt)
        XCTAssertEqual(SelectorEvaluator.evaluateOperator(node: ["operator": "datetime", "children": [["property": "event", "value": "prop"]]], properties: ["prop": "2019-02-01T12:01:01"]) as? Date, dt)
        XCTAssertTrue(SelectorEvaluator.evaluateOperator(node: ["operator": "defined", "children": [["property": "event", "value": "prop"]]], properties: ["prop": []]) as! Bool)
        XCTAssertTrue(SelectorEvaluator.evaluateOperator(node: ["operator": "not defined", "children": [["property": "event", "value": "prop"]]], properties: [:]) as! Bool)
        XCTAssertTrue(SelectorEvaluator.evaluateOperator(node: ["operator": "not", "children": [["property": "event", "value": "prop"]]], properties: ["prop": false]) as! Bool)
    }
    
    func testEvaluate() {
        XCTAssertNil(SelectorEvaluator.evaluate(selector: [:], properties: InternalProperties()))
        XCTAssertNil(SelectorEvaluator.evaluate(selector: ["operator": "unknown"], properties: ["prop": 1]))
        let value = SelectorEvaluator.evaluate(selector: ["operator": ">", "children": [["property": "event", "value": "prop1"], ["property": "literal", "value": ["window": ["value": 1, "unit": "hour"]]]]], properties: ["prop1": Date()])
        XCTAssertNotNil(value)
        XCTAssertTrue(value!)
    }
}

class TestSelectorEvaluator: SelectorEvaluator {
    override class func getCurrentDate() -> Date {
        return Date(timeIntervalSince1970: 10000)
    }
}

class TestLogging: Logging {
    var logMessage: LogMessage?
    
    init?() {
        logMessage = nil
    }
    
    func addMessage(message: LogMessage) {
        logMessage = message
    }
}
