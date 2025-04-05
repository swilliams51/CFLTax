//
//  Rent.swift
//  CFLTax
//
//  Created by Steven Williams on 8/8/24.
//

import Foundation


public struct Rent {
    public var groups: [Group]
    
    init () {
        groups = []
    }
    
    init (groups: [Group]) {
        self.groups = groups
    }
    
    public mutating func addGroup(groupToAdd: Group) {
        self.groups.append(groupToAdd)
    }
    
    public func isEqual(to other: Rent) -> Bool {
        for x in 0..<self.groups.count {
            if !self.groups[x].isEqual(to: other.groups[x]) {
                return false
            }
        }
            
        return true
    }
    
    mutating func makeEqualTo(_ other: Rent) {
            for x in 0..<self.groups.count {
                self.groups[x].makeEqualTo(other.groups[x])
            }
        }
        
    func changeComparedTo(_ other: Rent) -> ChangeType {
        if self.isEqual(to: other) {
            return .none
        }
        
        return .material
    }
    
    public func getNumberOfPaymentsForNewGroup(aGroup: Group, aFrequency: Frequency, eomRule: Bool, referDate: Date) -> Int {
        var numberOfPayments: Int = aGroup.noOfPayments
        let maxRemaining: Int = self.getMaxRemainNumberPayments(maxBaseTerm: maxBaseTerm, freq: aFrequency, eom: eomRule, aRefer: referDate)
        if maxRemaining > 0 {
            if numberOfPayments > maxRemaining {
                numberOfPayments = maxRemaining
            }
        } else {
            numberOfPayments = 0
        }
        
        return numberOfPayments
    }
    
    public func hasAdvanceRentals() -> Bool {
        var bolAdvanceRentals: Bool = false
        
        for x in 0..<groups.count {
            if groups[x].timing == .advance {
                bolAdvanceRentals = true
                break
            }
        }
        
        return bolAdvanceRentals
    }
    
    public func allPaymentsAreLocked() -> Bool {
        var bolAllPaymentsLocked: Bool = true
        
        for x in 0..<groups.count {
            if groups[x].locked == false {
                bolAllPaymentsLocked = false
                break
            }
        }
        
        return bolAllPaymentsLocked
    }
   
    public func allPaymentsEqualZero() -> Bool {
        var nonZeroPaymentExists: Bool = false
        
        for x in 0..<groups.count {
            if groups[x].amount.toDecimal() != 0.00 {
                nonZeroPaymentExists = true
                break
            }
        }
        
        if nonZeroPaymentExists == false {
            return true
        } else {
            return false
        }
    }
    
    public func interimExists() -> Bool {
        if groups.count > 0 {
            if groups[0].isInterim == true {
                return true
            }
        }
        return false
    }
    
    public func getTotalNumberOfPayments() -> Int {
        var runTotalPayments: Int = 0
        
        for x in 0..<groups.count {
            runTotalPayments = runTotalPayments + groups[x].noOfPayments
        }
        
        return runTotalPayments
    }

    public func getTotalAmountOfPayments(aFreq: Frequency, aDayCountMethod: DayCountMethod) -> Decimal {
        var runTotalAmount: Decimal = 0.00
        var amount:Decimal = 0.0
        var counter:Int = 0
        
        if groups[0].isInterim == true {
            if groups[0].amount == "CALCULATED" {
                if groups[0].paymentType == .dailyEquivAll {
                    amount = getDailyRentForAll(aRent: self, aFreq: aFreq, aDayCountMethod: aDayCountMethod)
                } else {
                    amount = getDailyRentForNext(aRent: self, aFreq: aFreq, aDayCountMethod: aDayCountMethod)
                }
            } else {
                amount = groups[0].amount.toDecimal()
            }
            runTotalAmount = runTotalAmount + amount
            counter += 1
        }
        
        for x in counter..<groups.count {
            amount = groups[x].amount.toDecimal() * Decimal(groups[x].noOfPayments)
            runTotalAmount = runTotalAmount + amount
        }
          
        return runTotalAmount
    }
    
    func getIndexOfGroup(aGroup: Group) -> Int {
        var idx: Int = 0

        for x in 0..<groups.count {
            if aGroup.id == groups[x].id {
                idx = x
                break
            }
        }
        return idx
    }
    
    public func getTotalNoOfBasePayments(aFreq: Frequency, eomRule: Bool, interimGroupExists: Bool) -> Int {
        var runTotalNoOfPmts: Int = 0

        for x in 0..<groups.count {
            if x == 0 {
                if interimGroupExists == true && groups[x].noOfPayments == 1{
                    continue
                }
            }
            runTotalNoOfPmts = runTotalNoOfPmts + groups[x].noOfPayments
        }
        
        return runTotalNoOfPmts
    }
    
    func getMinTotalNumberPayments(aFrequency: Frequency) -> Int {
        switch aFrequency {
        case .annual:
            return 1
        case .semiannual:
            return 2
        case .quarterly:
            return 4
        default:
            return 12
        }
    }
    
    func getMaxRemainNumberPayments(maxBaseTerm: Int, freq: Frequency, eom: Bool, aRefer: Date) -> Int {
        let totalPossible = getMaxTotalNumberPayments(maxBaseTerm: maxBaseTerm, aFrequency: freq)
        let totalExisting: Int = getTotalNoOfBasePayments(aFreq: freq, eomRule: eom,  interimGroupExists: self.interimExists())
        
        return totalPossible - totalExisting
    }
    
    
    public func getMaxTotalNumberPayments(maxBaseTerm: Int, aFrequency: Frequency) -> Int {
        switch aFrequency {
        case .annual:
            return maxBaseTerm / 12
        case .semiannual:
            return maxBaseTerm / 6
        case .quarterly:
            return maxBaseTerm / 3
        default:
            return maxBaseTerm
        }
    }
}


public func getDailyRentForNext(aRent: Rent, aFreq: Frequency, aDayCountMethod: DayCountMethod) -> Decimal {
    let nextAmount:Decimal = aRent.groups[1].amount.toDecimal()
    let daysInPeriod: Decimal = 360.0 / Decimal(aFreq.rawValue)
    let daysInInterim = dayCount(aDate1: aRent.groups[0].startDate, aDate2: aRent.groups[0].endDate, aDayCount: aDayCountMethod)
    let dailyRent = nextAmount / daysInPeriod
    let interimRent = dailyRent * daysInInterim.toString().toDecimal()
    
    return interimRent
}

public func getDailyRentForAll (aRent: Rent, aFreq: Frequency, aDayCountMethod: DayCountMethod) -> Decimal {
    var runTotalAmount: Decimal = 0.00
    
    for x in 1..<aRent.groups.count {
        let decAmount = aRent.groups[x].amount.toDecimal()
        let decNumber = Decimal(aRent.groups[x].noOfPayments)
        let totalAmount = decAmount * decNumber
        runTotalAmount = runTotalAmount + totalAmount
    }
    let daysInLease = dayCount(aDate1: aRent.groups[0].startDate, aDate2: aRent.groups[aRent.groups.count - 1].endDate, aDayCount: aDayCountMethod)
    let dailyRent = runTotalAmount / daysInLease.toString().toDecimal()
    let daysInInterim = dayCount(aDate1: aRent.groups[0].startDate, aDate2: aRent.groups[0].endDate, aDayCount: aDayCountMethod)
    let interimRent = dailyRent * daysInInterim.toString().toDecimal()

    return interimRent
}
