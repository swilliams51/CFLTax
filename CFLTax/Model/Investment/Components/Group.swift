//
//  Group.swift
//  CFLTax
//
//  Created by Steven Williams on 8/8/24.
//

import Foundation


public struct Group: Identifiable {
    public let id = UUID()
    public var amount: String
    public var endDate: Date
    public var locked: Bool
    public var noOfPayments: Int
    public var startDate: Date
    public var timing: TimingType
    public var paymentType: PaymentType
    public var isInterim: Bool
    public var unDeletable: Bool
    
    public init(amount: String, endDate: Date, locked: Bool, noOfPayments: Int, startDate: Date, timing: TimingType, paymentType: PaymentType, isInterim: Bool, unDeletable: Bool) {
        self.amount = amount
        self.endDate = endDate
        self.locked = locked
        self.noOfPayments = noOfPayments
        self.startDate = startDate
        self.timing = timing
        self.paymentType = paymentType
        self.isInterim = isInterim
        self.unDeletable = unDeletable
    }
    
    init() {
        amount = "18357.37"
        endDate = addPeriodsToDate(dateStart: Date(), payPerYear: .monthly, noOfPeriods: 60, referDate: Date(), bolEOMRule: true)
        locked = false
        noOfPayments = 60
        startDate = Date()
        timing = .arrears
        paymentType = .baseRental
        isInterim = false
        unDeletable = true
    }
    
    public func isEqual(to other: Group) -> Bool {
        var isEqual: Bool = false
        if amount == other.amount && endDate.isEqualTo(date: other.endDate) && locked == other.locked && noOfPayments == other.noOfPayments && startDate.isEqualTo(date: other.startDate) && timing == other.timing && paymentType == other.paymentType && isInterim == other.isInterim && unDeletable == other.unDeletable {
            isEqual = true
        }
        
        return isEqual
    }
    
    public mutating func makeEqualTo(_ other: Group) {
            self.amount = other.amount
            self.endDate = other.endDate
            self.locked = other.locked
            self.noOfPayments = other.noOfPayments
            self.startDate = other.startDate
            self.timing = other.timing
            self.paymentType = other.paymentType
            self.isInterim = other.isInterim
            self.unDeletable = other.unDeletable
        }
    
    public func isCalculatedPaymentType() -> Bool {
        var bolIsCalcPayment: Bool = false
        
        if self.paymentType == .dailyEquivAll || self.paymentType == .dailyEquivNext {
            bolIsCalcPayment = true
        }
        
        return bolIsCalcPayment
    }
    
    public func getTotalPayments() -> Decimal {
        let myAmount: Decimal = self.amount.toDecimal()
        let numberOfPayments: Decimal = Decimal(self.noOfPayments)
        let totalPayments: Decimal = myAmount * numberOfPayments
        
        return totalPayments
    }
    
    public func copyGroup() -> Group {
        var myGroup = Group()
        myGroup.amount = self.amount
        myGroup.endDate = self.endDate
        myGroup.locked = self.locked
        myGroup.noOfPayments = self.noOfPayments
        myGroup.startDate = self.startDate
        myGroup.timing = self.timing
        myGroup.paymentType = self.paymentType
        myGroup.isInterim = false
        myGroup.unDeletable = false
        
        return myGroup
    }
    
    public func clone() -> Group {
        let strGroup: String = self.writeGroup()
        let groupClone: Group = readGroup(strGroup)
        
        return groupClone
    }
    
    
    public func writeGroup() -> String {
        let strAmount: String = self.amount
        let strEndDate: String = self.endDate.toStringDateShort()
        let strLocked: String = self.locked.toString()
        let strNoOfPayments: String = self.noOfPayments.toString()
        let strStartDate: String = self.startDate.toStringDateShort()
        let strTiming: String = self.timing.toString()
        let strType: String = self.paymentType.toString()
        let strIsInterim: String = self.isInterim.toString()
        let strUndeletable: String = self.unDeletable.toString()
        let groupProperties: Array = [strAmount, strEndDate, strLocked, strNoOfPayments, strStartDate, strTiming, strType, strUndeletable, strIsInterim]
        let strGroupProperties = groupProperties.joined(separator: ",")
        
        return strGroupProperties
    }
    
    public func readGroup(_ strGroup: String) -> Group {
        let myGroup = strGroup.components(separatedBy: ",")
        let myAmount:String = myGroup[0]
        let myEndDate: Date = myGroup[1].toDate()
        let myLocked: Bool = myGroup[2].toBool()
        let myNoOfPayments: Int = myGroup[3].toInteger()
        let myStartDate: Date = myGroup[4].toDate()
        let myTiming: TimingType = myGroup[5].toTimingType()
        let myType: PaymentType = myGroup[6].toPaymentType()
        let myIsInterim: Bool = myGroup[7].toBool()
        let myUndeletable: Bool = myGroup[8].toBool()
        let newGroup: Group = Group(amount: myAmount, endDate: myEndDate, locked: myLocked, noOfPayments: myNoOfPayments, startDate: myStartDate, timing: myTiming, paymentType: myType, isInterim: myIsInterim, unDeletable: myUndeletable)
        
        return newGroup
    }
    
}
