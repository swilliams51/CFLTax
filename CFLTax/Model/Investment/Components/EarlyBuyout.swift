//
//  EarlyBuyout.swift
//  CFLTax
//
//  Created by Steven Williams on 8/8/24.
//

import Foundation


public struct EarlyBuyout {
    public var amount: String
    public var exerciseDate: Date
    public var advanceRentDueIsPaid: Bool = false
    public var hasChanged: Bool = false
    
    init(amount: String, exerciseDate: Date, rentDueIsPaid: Bool) {
        self.amount = amount
        self.exerciseDate = exerciseDate
    }
    
    init() {
        self.amount = "0.00"
        self.exerciseDate = Date()
        self.advanceRentDueIsPaid = false
    }
    
    public func getEBOTermInMonths(aInvestment: Investment) -> Int {
        let tempInvestment = aInvestment.clone()
        let noOfPaymentPeriods: Int = aInvestment.payPeriodsInEBOTerm(aInvestment: tempInvestment, dateAsk: self.exerciseDate)
        
        return noOfPaymentPeriods * 12 / tempInvestment.leaseTerm.paymentFrequency.rawValue
    }
    
    func isEqual(to other: EarlyBuyout) -> Bool {
        var isEqual: Bool = false
        if self.amount == other.amount &&
            self.exerciseDate.isEqualTo(date: other.exerciseDate) &&
            self.advanceRentDueIsPaid == other.advanceRentDueIsPaid {
            isEqual = true
        }
        
        return isEqual
    }
    
    mutating func makeEqualTo(_ other: EarlyBuyout) {
            self.amount = other.amount
            self.exerciseDate = other.exerciseDate
            self.advanceRentDueIsPaid = other.advanceRentDueIsPaid
        }
    
}

extension Investment {
    public func setEBOToDefault() {
        let leaseExpiry: Date = self.getLeaseMaturityDate()
        let frequency: Frequency = self.leaseTerm.paymentFrequency
        let noOfPeriods: Int = self.leaseTerm.paymentFrequency.rawValue
        let endDate: Date = subtractPeriodsFromDate(dateStart: leaseExpiry, payPerYear: frequency, noOfPeriods: noOfPeriods, referDate: self.leaseTerm.baseCommenceDate, bolEOMRule: self.leaseTerm.endOfMonthRule)
        self.earlyBuyout.exerciseDate = endDate
        
        let myTerminationValues: TerminationValues = TerminationValues()
        myTerminationValues.createTable(aInvestment: self)
        let myCFTValues: Cashflows = myTerminationValues.createTerminationValues()
        self.earlyBuyout.amount = myCFTValues.vLookup(dateAsk: endDate).toString(decPlaces: 2)
    }
    
    public func getParValue(askDate: Date) -> Decimal {
        let myTVs: TerminationValues = TerminationValues()
        myTVs.createTable(aInvestment: self)
        let myCFTValues: Cashflows = myTVs.createTerminationValues()
        let tvOnChopDate: Decimal = myCFTValues.vLookup(dateAsk: askDate)
        
        return tvOnChopDate
    }
    
    public func getExerciseDate(eboTermInMonths: Int) -> Date {
        let noOfPaymentPeriods: Int = eboTermInMonths / (12 / self.leaseTerm.paymentFrequency.rawValue)
        let startDate: Date = self.leaseTerm.baseCommenceDate
        let exerciseDate = addPeriodsToDate(dateStart: startDate, payPerYear: self.leaseTerm.paymentFrequency, noOfPeriods: noOfPaymentPeriods, referDate: startDate, bolEOMRule: self.leaseTerm.endOfMonthRule)
        
        return exerciseDate
    }
    
    public func getExerciseDate(eboTermInMonths: Int, stepInterval: Frequency) -> Date {
        let noOfPaymentPeriods: Int = eboTermInMonths / (12 / stepInterval.rawValue)
        let startDate: Date = self.leaseTerm.baseCommenceDate
        let exerciseDate = addPeriodsToDate(dateStart: startDate, payPerYear: stepInterval, noOfPeriods: noOfPaymentPeriods, referDate: startDate, bolEOMRule: self.leaseTerm.endOfMonthRule)
        
        return exerciseDate
    }
    
    public func getEBOPremium_bps(aEBO: EarlyBuyout, aBaseYield: Decimal) -> Double {
        let eboYield: Decimal = solveForEBOYield(aEBO: aEBO)
        let eboPremium: Decimal = eboYield - aBaseYield
        let eboPremiumBps: Decimal = (eboPremium * 10000.00)
        let bps:Double = eboPremiumBps.truncate()
        
        return bps
    }
    
    public func solveForEBOAmount(aEBO: EarlyBuyout, aBaseYield: Decimal, bpsSpread: Double) -> Decimal {
        let adder: Decimal = Decimal(bpsSpread) / 10000.00
        let targetYield: Decimal = aBaseYield + adder
        
        return solveForEBOAmount(aEBO: aEBO, aTargetYield: targetYield)
    }
    
    public func solveForEBOAmount(aEBO: EarlyBuyout, aTargetYield: Decimal) -> Decimal {
        let myEBOInvestment: Investment = self.clone()
        let dateOfUnplanned: Date = aEBO.exerciseDate
        let myPlannedIncome: Decimal = plannedIncome(aInvestment: self, dateAsk: dateOfUnplanned)
        
        myEBOInvestment.rent = eboRent(aInvestment: self, chopDate: dateOfUnplanned)
        let myEBOAmount: Decimal = solveForEarlyBuyoutAmount(aEBOInvestment: myEBOInvestment, aTargetYield: aTargetYield, aPlannedIncome: myPlannedIncome, aUnplannedDate: dateOfUnplanned)
        
        return myEBOAmount
    }
    
    public func solveForEBOYield(aEBO: EarlyBuyout) -> Decimal {
        let myEBOInvestment: Investment = self.clone()
        myEBOInvestment.earlyBuyout = aEBO
        let dateOfUnplanned: Date = myEBOInvestment.earlyBuyout.exerciseDate
        let myPlannedIncome: Decimal = plannedIncome(aInvestment: self, dateAsk: dateOfUnplanned)
       
        myEBOInvestment.rent = eboRent(aInvestment: self, chopDate: dateOfUnplanned)
        
        myEBOInvestment.asset.residualValue = aEBO.amount
        myEBOInvestment.economics.solveFor = .yield
        myEBOInvestment.economics.yieldMethod = .MISF_AT
        myEBOInvestment.calculate(plannedIncome: myPlannedIncome.toString(decPlaces: 5), unplannedDate: dateOfUnplanned)
        
        let yieldToReturn: Decimal = myEBOInvestment.getMISF_AT_Yield()

        return yieldToReturn
    }
    
    public func getEBOAllInRate(aEBO: EarlyBuyout) -> Decimal {
        let myEBOInvestment: Investment = self.clone()
        if myEBOInvestment.feeExists {
            myEBOInvestment.fee.amount = "0.0"
            myEBOInvestment.setFeesExistence()
        }
        myEBOInvestment.rent = eboRent(aInvestment: myEBOInvestment, chopDate: aEBO.exerciseDate)
        myEBOInvestment.asset.residualValue = aEBO.amount
        myEBOInvestment.economics.solveFor = .yield
        myEBOInvestment.economics.yieldMethod = .IRR_PTCF
        myEBOInvestment.calculate()
        
        return myEBOInvestment.getIRR_PTCF()
    }
    
    public func solveEBOIRR_Of_PTCF(aEBO: EarlyBuyout) -> Decimal {
        let myEBOInvestment: Investment = self.clone()
        myEBOInvestment.rent = eboRent(aInvestment: myEBOInvestment, chopDate: aEBO.exerciseDate)
        myEBOInvestment.asset.residualValue = aEBO.amount
        myEBOInvestment.economics.solveFor = .yield
        myEBOInvestment.economics.yieldMethod = .IRR_PTCF
        myEBOInvestment.calculate()
        
        return myEBOInvestment.getIRR_PTCF()
    }
    
    public func eboResidual(aInvestment: Investment) -> Decimal {
        let tempInvestment: Investment = aInvestment.clone()
        let myTVs: TerminationValues = TerminationValues()
        myTVs.createTable(aInvestment: tempInvestment)
        let myTValues: Cashflows = myTVs.createTerminationValues()
        let tvOnChopDate: Decimal = myTValues.vLookup(dateAsk: tempInvestment.earlyBuyout.exerciseDate)
        return tvOnChopDate
    }
    
    public func eboRent(aInvestment: Investment, chopDate: Date) -> Rent {
        let tempInvestment: Investment = aInvestment.clone()
        let noOfPeriodsInEBOTerm: Int = payPeriodsInEBOTerm(aInvestment: tempInvestment, dateAsk: chopDate)
        var myRent: Rent = Rent()
        var start: Int = 0
        var startDate = tempInvestment.leaseTerm.baseCommenceDate
        if tempInvestment.rent.groups[0].isInterim {
            myRent.groups.append(tempInvestment.rent.groups[0])
            start = 1
        }
        
        var totalNoOfPaymentsAdded: Int = 0
        while totalNoOfPaymentsAdded < noOfPeriodsInEBOTerm { // 0 < 48
            var group: Group = Group()
            group.makeEqualTo(tempInvestment.rent.groups[start])
            let groupNoOfPayments: Int = group.noOfPayments // 60
            let noToAdd: Int = min(groupNoOfPayments, noOfPeriodsInEBOTerm - totalNoOfPaymentsAdded)
            group.noOfPayments = noToAdd
            group.endDate = addPeriodsToDate(dateStart: startDate, payPerYear: tempInvestment.leaseTerm.paymentFrequency, noOfPeriods: noToAdd, referDate: tempInvestment.leaseTerm.baseCommenceDate, bolEOMRule: tempInvestment.leaseTerm.endOfMonthRule)
            startDate = group.endDate
            myRent.groups.append(group)
            totalNoOfPaymentsAdded += noToAdd
            start += 1
        }
        
        return myRent
    }
    
    public func payPeriodsInEBOTerm(aInvestment: Investment, dateAsk: Date) -> Int {
        let tempInvestment: Investment = aInvestment.clone()
        var dateStart = tempInvestment.rent.groups[0].startDate
        if tempInvestment.rent.groups[0].isInterim {
            dateStart = tempInvestment.rent.groups[0].endDate
        }
        
        let noOfMonthsInEBOTerm = monthsDifference(start: dateStart, end: dateAsk, inclusive: false)
        let noOfPaymentsInEBOTerm = noOfMonthsInEBOTerm / (12 / tempInvestment.leaseTerm.paymentFrequency.rawValue)
        
        return noOfPaymentsInEBOTerm
    }
    
   public func plannedIncome(aInvestment: Investment, dateAsk: Date) -> Decimal {
       let tempInvestment: Investment = aInvestment.clone()
       let fiscalYearEnd: Date = getFiscalYearEnd(askDate: dateAsk, fiscalMonthEnd: tempInvestment.taxAssumptions.fiscalMonthEnd.rawValue)
       let myAnnualTaxableIncomes: AnnualTaxableIncomes = AnnualTaxableIncomes()
       let myNetTaxableIncomes: Cashflows = myAnnualTaxableIncomes.createNetTaxableIncomes(aInvestment: tempInvestment)
       let decPlannedIncome: Decimal = myNetTaxableIncomes.vLookup(dateAsk: fiscalYearEnd)
       
       return decPlannedIncome
    }
    
    public func getArrearsRent(dateAsk: Date) -> Decimal {
        let tempInvestment: Investment = self.clone()
        let myArrearsRents: PeriodicArrearsRents = PeriodicArrearsRents()
        myArrearsRents.createTable(aInvestment: tempInvestment)
        let decArrearsRent: Decimal = myArrearsRents.vLookup(dateAsk: dateAsk)
        
        return decArrearsRent
    }
    
    public func getEBO_ATCashflows(aEBO: EarlyBuyout) -> Cashflows {
        let myEBOInvestment: Investment = self.clone()
        let dateOfUnplanned: Date = myEBOInvestment.earlyBuyout.exerciseDate
        let myPlannedIncome: Decimal = plannedIncome(aInvestment: self, dateAsk: dateOfUnplanned)
        
        myEBOInvestment.rent = eboRent(aInvestment: self, chopDate: dateOfUnplanned)
        myEBOInvestment.asset.residualValue = aEBO.amount
        myEBOInvestment.setAfterTaxCashflows(plannedIncome: myPlannedIncome.toString(decPlaces: 5), unplannedDate: dateOfUnplanned)
        let myEBO_ATCF: Cashflows = myEBOInvestment.afterTaxCashflows
        
        return myEBO_ATCF
    }
    
    public func getEBO_BTCashflows(aEBO: EarlyBuyout) -> Cashflows {
        let myEBOInvestment: Investment = self.clone()
        myEBOInvestment.rent = eboRent(aInvestment: myEBOInvestment, chopDate: aEBO.exerciseDate)
        myEBOInvestment.asset.residualValue = aEBO.amount
        myEBOInvestment.setBeforeTaxCashflows()
        let myEBO_BTCF: Cashflows = myEBOInvestment.beforeTaxCashflows
        
        return myEBO_BTCF
    }
    
}
