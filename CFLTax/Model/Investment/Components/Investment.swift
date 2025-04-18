//
//  Investment.swift
//  CFLTax
//
//  Created by Steven Williams on 8/8/24.
//

import Foundation


@Observable
public class Investment {
    var asset: Asset = simple2Asset
    var leaseTerm: LeaseTerm = simple2LeaseTerm
    var rent: Rent = simple2Rent
    var depreciation: Depreciation = simple2Depreciation
    var taxAssumptions: TaxAssumptions = simple2TaxAssumptions
    var economics: Economics = simple2Economics
    var fee: Fee = simple2Fee
    var earlyBuyout: EarlyBuyout = simple2EBO
    var afterTaxCashflows: Cashflows = Cashflows()
    var beforeTaxCashflows: Cashflows = Cashflows()
    var earlyBuyoutExists: Bool = false
    var feeExists: Bool = false
    var changeState: ChangeType = .none
    
   public init() {
        self.asset = asset
        self.leaseTerm = leaseTerm
        self.rent = rent
        self.depreciation = depreciation
        self.taxAssumptions = taxAssumptions
        self.economics = economics
        self.fee = fee
        self.earlyBuyout = earlyBuyout
        self.setEBOsExistence()
        self.setFeesExistence()
    }
    
    public init(aAsset: Asset, aLeaseTerm: LeaseTerm, aRent: Rent, aDepreciation: Depreciation, aTaxAssumptions: TaxAssumptions, aEconomics: Economics, aFee: Fee, aEarlyBuyout: EarlyBuyout) {
        self.asset = aAsset
        self.leaseTerm = aLeaseTerm
        self.rent = aRent
        self.depreciation = aDepreciation
        self.taxAssumptions = aTaxAssumptions
        self.economics = aEconomics
        self.fee = aFee
        self.earlyBuyout = aEarlyBuyout
        self.setEBOsExistence()
        self.setFeesExistence()
    }
    
    public init(aFile: String) {
        let arrayInvestment: [String] = aFile.components(separatedBy: "*")
        self.asset = readAsset(arrayAsset: arrayInvestment[0].components(separatedBy: ","))
        self.leaseTerm = readLeaseTerm(arrayLeaseTerm: arrayInvestment[1].components(separatedBy: ","))
        self.rent = readRent(arrayGroups: arrayInvestment[2].components(separatedBy: "|"))
        self.depreciation = readDepreciation(arrayDepreciation: arrayInvestment[3].components(separatedBy: ","))
        self.taxAssumptions = readTaxAssumptions(arrayTaxAssumptions: arrayInvestment[4].components(separatedBy: ","))
        self.economics = readEconomics(arrayEconomics: arrayInvestment[5].components(separatedBy: ","))
        self.fee = readFee(arrayFee: arrayInvestment[6].components(separatedBy: ","))
        self.earlyBuyout = readEarlyBuyout(arrayEBO: arrayInvestment[7].components(separatedBy: ","))
        self.setEBOsExistence()
        self.setFeesExistence()
    }
    
    
    public init(aFile: String, resetDates: Bool) {
        let arrayInvestment: [String] = aFile.components(separatedBy: "*")
        self.asset = readAsset(arrayAsset: arrayInvestment[0].components(separatedBy: ","))
        self.leaseTerm = readLeaseTerm(arrayLeaseTerm: arrayInvestment[1].components(separatedBy: ","))
        self.rent = readRent(arrayGroups: arrayInvestment[2].components(separatedBy: "|"))
        self.depreciation = readDepreciation(arrayDepreciation: arrayInvestment[3].components(separatedBy: ","))
        self.taxAssumptions = readTaxAssumptions(arrayTaxAssumptions: arrayInvestment[4].components(separatedBy: ","))
        self.economics = readEconomics(arrayEconomics: arrayInvestment[5].components(separatedBy: ","))
        self.fee = readFee(arrayFee: arrayInvestment[6].components(separatedBy: ","))
        self.earlyBuyout = readEarlyBuyout(arrayEBO: arrayInvestment[7].components(separatedBy: ","))
        self.setEBOsExistence()
        self.setFeesExistence()
        if resetDates {
            self.resetAllDatesToCurrentDate()
        }
    }
    
    public func setEBOsExistence() {
        if self.earlyBuyout.amount.toDecimal() == 0.0 {
            self.earlyBuyoutExists = false
        } else {
            self.earlyBuyoutExists = true
        }
    }
        
    public func removeEBO() {
        self.earlyBuyout.amount = "0.0"
        self.setEBOsExistence()
        self.economics.solveFor = .yield
        self.changeState = .immaterial
    }
    
    public func setFeesExistence() {
        if self.getFeeAmount() == 0.0 {
            self.feeExists = false
        } else {
            self.feeExists = true
        }
    }
    
    public func removeFee() {
        self.fee.amount = "0.0"
        self.setFeesExistence()
        self.economics.solveFor = .yield
        self.changeState = .immaterial
    }
    
    public func getBaseTermInMonths() -> Int {
        var runTotalPeriods: Int = 0
        
        for x in 0..<rent.groups.count {
            if rent.groups[x].isInterim == false {
                let numberOfPeriods = rent.groups[x].noOfPayments
                runTotalPeriods = runTotalPeriods + numberOfPeriods
            }
        }
        
        return runTotalPeriods * 12 / leaseTerm.paymentFrequency.rawValue
    }
    
    public func getLeaseMaturityDate() -> Date {
        return addPeriodsToDate(dateStart: leaseTerm.baseCommenceDate, payPerYear: .monthly, noOfPeriods: getBaseTermInMonths(), referDate: leaseTerm.baseCommenceDate, bolEOMRule: self.leaseTerm.endOfMonthRule)
    }
    
    public func clone() -> Investment {
        let strInvestment = self.writeInvestment()
        let investmentClone: Investment = readInvestment(file: strInvestment)
        
        return investmentClone
    }
    
    public func isSolveForValid() -> Bool {
        switch self.economics.solveFor {
        case .yield:
            if isYieldCalculationValid() == false {
                return false
            }
        case .unLockedRentals:
            if isUnlockedRentalsCalculationValid()  == false {
                return false
            }
        case .fee:
            if isFeeCalculationValid() == false {
                return false
            }
            return true
        case .residualValue:
            if isResidualCalculationValid() == false {
                return false
            }
        case .lessorCost:
            if isLessorCostCalculationValid() == false {
                return false
            }
        }
        return true
    }
    
    private func isUnlockedRentalsCalculationValid() -> Bool {
        let minNoOfPayments = self.rent.getMinTotalNumberPayments(aFrequency: self.leaseTerm.paymentFrequency)
        if self.rent.getTotalNumberOfPayments() < minNoOfPayments {
           return false
        }
        
        if self.rent.allPaymentsAreLocked() == true {
            return false
        }
        
        if self.rent.allPaymentsEqualZero() == true {
            return false
        }
        
        return true
    }
    
    private func isYieldCalculationValid() -> Bool {
        let tempInvestment = self.clone()
        let maxRate: Decimal = 0.15
        let minRate: Decimal = 0.00
        let dayCountMethod = tempInvestment.economics.dayCountMethod

        tempInvestment.setAfterTaxCashflows()

        let npvAtMaxRate = tempInvestment.afterTaxCashflows.ModXNPV(aDiscountRate: maxRate, aDayCountMethod: dayCountMethod)
        let npvAtMinRate = tempInvestment.afterTaxCashflows.ModXNPV(aDiscountRate: minRate, aDayCountMethod: dayCountMethod)

        return !(npvAtMaxRate > 0.0 || npvAtMinRate < 0.0)
    }
    
    private func isFeeCalculationValid() -> Bool {
        let tempInvestment = self.clone()
        let aTargetYield: Decimal = tempInvestment.economics.yieldTarget.toDecimal()
        let aYieldMethod: YieldMethod = tempInvestment.economics.yieldMethod
        let myFeeType: FeeType = tempInvestment.fee.feeType
        tempInvestment.fee.amount = (0.00).toString()
        var currentYield: Decimal = 0.0
        var feeCalculationIsValid: Bool = true
        let tolerance: Decimal = 0.0005

        switch myFeeType {
        case .expense:
            switch aYieldMethod {
            case .MISF_AT:
                tempInvestment.setAfterTaxCashflows()
                currentYield = tempInvestment.getMISF_AT_Yield()
            case .MISF_BT:
                tempInvestment.setAfterTaxCashflows()
                currentYield = tempInvestment.getMISF_BT_Yield()
            case .IRR_PTCF:
                tempInvestment.setBeforeTaxCashflows()
                currentYield = tempInvestment.getIRR_PTCF()
            }
            if aTargetYield >= currentYield || abs(currentYield - aTargetYield) < tolerance {
                feeCalculationIsValid = false
            }
        case .income:
            switch aYieldMethod {
            case .MISF_AT:
                tempInvestment.setAfterTaxCashflows()
                currentYield = tempInvestment.getMISF_AT_Yield()
            case .MISF_BT:
                tempInvestment.setAfterTaxCashflows()
                currentYield = tempInvestment.getMISF_BT_Yield()
            case .IRR_PTCF:
                tempInvestment.setBeforeTaxCashflows()
                currentYield = tempInvestment.getIRR_PTCF()
            }
            if aTargetYield <= currentYield || abs(currentYield - aTargetYield) < tolerance {
                feeCalculationIsValid = false
            }
        }
        return feeCalculationIsValid
    }
    
    private func isLessorCostCalculationValid() -> Bool {
        let tempInvestment = self.clone()
        let minAmount: Decimal = 10_000.00  // Minimum allowable lessor cost
        let maxAmount: Decimal = 10_000_000.00  // Maximum allowable lessor cost
        let aTargetYield: Decimal = tempInvestment.economics.yieldTarget.toDecimal()
        let aYieldMethod: YieldMethod = tempInvestment.economics.yieldMethod

        // Helper function to check if lessor cost is within valid bounds
        func isLessorCostWithinBounds(for lessorCost: Decimal, yieldMethod: YieldMethod) -> Bool {
            tempInvestment.asset.lessorCost = lessorCost.toString(decPlaces: 2)

            switch yieldMethod {
            case .MISF_AT:
                tempInvestment.setAfterTaxCashflows()
                return tempInvestment.afterTaxCashflows.ModXNPV(aDiscountRate: aTargetYield,
                                                                 aDayCountMethod: tempInvestment.economics.dayCountMethod) < 0
            case .MISF_BT:
                tempInvestment.setAfterTaxCashflows()
                return tempInvestment.afterTaxCashflows.ModXNPV(aDiscountRate: aTargetYield,
                                                                 aDayCountMethod: tempInvestment.economics.dayCountMethod) < 0
            case .IRR_PTCF:
                tempInvestment.setBeforeTaxCashflows()
                return tempInvestment.beforeTaxCashflows.ModXNPV(aDiscountRate: aTargetYield,
                                                                  aDayCountMethod: tempInvestment.economics.dayCountMethod) < 0
            }
        }

        // Validate Lessor Cost at minimum and maximum boundaries
        if isLessorCostWithinBounds(for: minAmount, yieldMethod: aYieldMethod) {
            return false
        }
        if !isLessorCostWithinBounds(for: maxAmount, yieldMethod: aYieldMethod) {
            return false
        }

        return true
    }
    
    private func isResidualCalculationValid() -> Bool {
        let tempInvestment = self.clone()
        let minAmount: Decimal = 0.0
        let maxAmount: Decimal = tempInvestment.asset.lessorCost.toDecimal()
        let aTargetYield: Decimal = tempInvestment.economics.yieldTarget.toDecimal()
        let aYieldMethod: YieldMethod = tempInvestment.economics.yieldMethod
        let minimumResidual: Decimal = maxAmount * 0.01  // 1% of Lessor Cost

        // Helper function to check if residual value is within valid bounds
        func isResidualWithinBounds(for residualValue: Decimal, yieldMethod: YieldMethod) -> Bool {
            tempInvestment.asset.residualValue = residualValue.toString(decPlaces: 4)

            switch yieldMethod {
            case .MISF_AT:
                tempInvestment.setAfterTaxCashflows()
                return tempInvestment.afterTaxCashflows.ModXNPV(aDiscountRate: aTargetYield,
                                                                 aDayCountMethod: tempInvestment.economics.dayCountMethod) > minimumResidual
            case .MISF_BT:
                tempInvestment.setAfterTaxCashflows()
                return tempInvestment.afterTaxCashflows.ModXNPV(aDiscountRate: aTargetYield,
                                                                 aDayCountMethod: tempInvestment.economics.dayCountMethod) > minimumResidual
            case .IRR_PTCF:
                tempInvestment.setBeforeTaxCashflows()
                return tempInvestment.beforeTaxCashflows.ModXNPV(aDiscountRate: aTargetYield,
                                                                  aDayCountMethod: tempInvestment.economics.dayCountMethod) > minimumResidual
            }
        }

        // Validate Residual Value at minimum and maximum boundaries
        if isResidualWithinBounds(for: minAmount, yieldMethod: aYieldMethod) {
            return false
        }
        if !isResidualWithinBounds(for: maxAmount, yieldMethod: aYieldMethod) {
            return false
        }

        return true
    }
    
    public func calculate(plannedIncome: String = "0.0", unplannedDate: Date = Date()) {
        let aYieldType: YieldMethod = self.economics.yieldMethod
        let aTargetYield: Decimal = self.economics.yieldTarget.toDecimal()
        
        switch self.economics.solveFor {
        case .fee:
            solveForTarget(aTargetVariable: .fee, aYieldMethod: aYieldType, aTargetYield: aTargetYield)
        case .lessorCost:
            solveForTarget(aTargetVariable: .lessorCost, aYieldMethod: aYieldType, aTargetYield: aTargetYield)
        case .residualValue:
            solveForTarget(aTargetVariable: .residualValue, aYieldMethod: aYieldType, aTargetYield: aTargetYield)
        case .unLockedRentals:
            solveForTarget(aTargetVariable: .unLockedRentals, aYieldMethod: aYieldType, aTargetYield: aTargetYield)
        default:
            break
        }
        
        setAfterTaxCashflows(plannedIncome: plannedIncome, unplannedDate: unplannedDate)
        setBeforeTaxCashflows()
    }
    
    public func setAfterTaxCashflows(plannedIncome: String = "0.0", unplannedDate: Date = Date()) {
        //if setAfterTaxCashflows is not called to the calculate function then items in afterTaxCashflows must e removed
        let myATCollCashflows: NetAfterTaxCashflows = NetAfterTaxCashflows()
        
        let myTempCashflows: Cashflows = myATCollCashflows.createNetAfterTaxCashflows(aInvestment: self, plannedIncome: plannedIncome, unplannedDate: unplannedDate)
        if afterTaxCashflows.count() > 0 {
            afterTaxCashflows.removeAll()
        }
        for x in 0..<myTempCashflows.count() {
            afterTaxCashflows.add(item: myTempCashflows.items[x])
        }
    }
    
    public func setBeforeTaxCashflows() {
        //if setBeforeTaxCashflows is not called to the calculate function then items in beforeTaxCashflows must e removed
        let myBTCollCashflows: PeriodicLeaseCashflows = PeriodicLeaseCashflows()
        let myTempCashflows: Cashflows = myBTCollCashflows.createPeriodicLeaseCashflows(aInvestment: self, lesseePerspective: false)
        if beforeTaxCashflows.count() > 0 {
            beforeTaxCashflows.removeAll()
        }
        for x in 0..<myTempCashflows.count() {
            beforeTaxCashflows.add(item: myTempCashflows.items[x])
        }
    }
    
    
    public func getMISF_AT_Yield () -> Decimal{
        var atYield: Decimal = 0.0
        if afterTaxCashflows.count() > 0 {
            atYield = afterTaxCashflows.XIRR2(guessRate: 0.1, _DayCountMethod: self.economics.dayCountMethod)
        }
        
        return atYield
    }
        
    public func getMISF_BT_Yield () -> Decimal{
        return getMISF_AT_Yield() / (1.0 - self.taxAssumptions.federalTaxRate.toDecimal())
        }
    
    public func getIRR_PTCF() -> Decimal{
        var pretaxIRR: Decimal = 0.0
        if beforeTaxCashflows.count() > 0 {
            pretaxIRR = beforeTaxCashflows.XIRR2(guessRate: 0.1, _DayCountMethod: self.economics.dayCountMethod)
        }
        
        return pretaxIRR
    }
    
    public func getAssetCost(asCashflow: Bool) -> Decimal {
        var factor: Decimal = 1.0
        if asCashflow {
            factor = -1.0
        }
        return self.asset.lessorCost.toDecimal() * factor
    }
    
    public func setFeeToDefault() {
        self.fee.amount = (self.asset.lessorCost.toDecimal() * 0.02).toString(decPlaces: 2)
        self.fee.datePaid = self.asset.fundingDate
        self.fee.feeType = .expense
    }
    
    public func getFeeAmount() -> Decimal {
        if self.fee.amount == "0.0" {
            return 0.0
        }
        var factor: Decimal = 1.0
        if self.fee.feeType == .expense {
            factor = -1.0
        }
        
        return fee.amount.toDecimal() * factor
    }
    
    public func getTotalRent() -> String {
        let tempCashflow = RentalCashflows()
        tempCashflow.createTable(aInvestment: self)
        
        return tempCashflow.getTotal().toString(decPlaces: 10)
    }
    
     public func getAssetResidualValue() -> Decimal {
         return self.asset.residualValue.toDecimal()
    }
    
    public func getAfterTaxCash() -> String {
        return afterTaxCashflows.getTotal().toString(decPlaces: 10)
    }
    
    public func getBeforeTaxCash() -> String {
        return beforeTaxCashflows.getTotal().toString(decPlaces: 10)
    }
    
    public func getSimplePayback() -> Int {
        var runTotal: Decimal = 0.0
        var start: Int = 0
        let startDate: Date = self.afterTaxCashflows.items[0].dueDate
        if afterTaxCashflows.items[0].amount.toDecimal() > 0.0 {
            runTotal = runTotal + afterTaxCashflows.items[0].amount.toDecimal()
            start = 1
        }
        var endDate: Date = Date()
        
        for x in start..<afterTaxCashflows.count() {
            runTotal = runTotal + afterTaxCashflows.items[x].amount.toDecimal()
            if runTotal >= 0.0 {
                endDate = afterTaxCashflows.items[x].dueDate
                break
            }
        }
        return monthsDifference(start: startDate, end: endDate, inclusive: true)
    }
    
    public func getAverageLife() -> Decimal {
        let yieldRate: Decimal = self.getMISF_AT_Yield()
        let myAmortizations: Amortizations = Amortizations()
        myAmortizations.createAmortizations(investCashflows: self.afterTaxCashflows, interestRate: yieldRate, dayCountMethod: self.economics.dayCountMethod)
        let myTotalInterest: Decimal = myAmortizations.totalInterest
        let myAnnualInterest: Decimal = self.getAssetCost(asCashflow: false) * yieldRate
        
        return myTotalInterest / myAnnualInterest
    }
    
    public func getTaxesPaid() -> String {
        let tempCashflow = AnnualTaxableIncomes()
        let taxesPaid = tempCashflow.createPeriodicTaxesPaid_STD(aInvestment: self)
        
        return taxesPaid.getTotal().toString(decPlaces: 10)
    }
    
    public func getImplicitRate() -> Decimal {
        let tempLeaseCashflow = PeriodicLeaseCashflows()
        let myCashflows: Cashflows = tempLeaseCashflow.createPeriodicLeaseCashflows(aInvestment: self, lesseePerspective: true)
        
        return myCashflows.XIRR2(guessRate: 0.10, _DayCountMethod: self.economics.dayCountMethod)
    }
    
    public func getPVOfRents() -> Decimal{
        let tempCashflow = RentalCashflows()
        tempCashflow.createTable(aInvestment: self)
        
        let pvOfRents: Decimal = tempCashflow.XNPV(aDiscountRate: self.economics.discountRateForRent.toDecimal(), aDayCountMethod: self.economics.dayCountMethod)
        
        return pvOfRents
    }
    
    public func getMaxLesseeGuaranty() -> Decimal{
        let myRentalCashflows: RentalCashflows = RentalCashflows()
        myRentalCashflows.createTable(aInvestment: self)
        let presentValueOfRents: Decimal = myRentalCashflows.XNPV(aDiscountRate: self.getImplicitRate(), aDayCountMethod: self.economics.dayCountMethod)
        let ninetyPercentOfAsset: Decimal = self.asset.lessorCost.toDecimal() * 0.899995
        let presentValueDiff: Decimal = ninetyPercentOfAsset - presentValueOfRents
        if presentValueDiff <= 0.0 {
            return 0.0
        }
        let myLeaseCashflows: LeaseTemplateCashflows = LeaseTemplateCashflows()
        myLeaseCashflows.createTemplate(aInvestment: self)
        let futureValueOfDiff: Decimal = myLeaseCashflows.XNFV(aPVAmount: presentValueDiff, aCompoundRate: self.getImplicitRate(), aDayCount: self.economics.dayCountMethod)
        
        return futureValueOfDiff
    }
    
    public func getPVOfObligations(aDiscountRate: Decimal) -> Decimal{
        let tempCashflow = RentalCashflows()
        tempCashflow.createTable(aInvestment: self)
        let leaseEndDate: Date = self.getLeaseMaturityDate()
        let residualGuaranty: Decimal = self.asset.lesseeGuarantyAmount.toDecimal()
        let additionalCF: Cashflow = Cashflow(dueDate: leaseEndDate, amount: residualGuaranty.toString(decPlaces: 4))
        tempCashflow.add(item: additionalCF)
        tempCashflow.consolidateCashflows()
        
        let pvOfObligations: Decimal = tempCashflow.XNPV(aDiscountRate: aDiscountRate, aDayCountMethod: self.economics.dayCountMethod)
        
        return pvOfObligations
    }
    
    public func createLeaseTemplate() -> Cashflows {
        let myCashflows: Cashflows = Cashflows()
        
        let myCashflow: Cashflow = Cashflow(dueDate: self.asset.fundingDate, amount: "0.0")
        myCashflows.add(item: myCashflow)
        
        if self.leaseTerm.baseCommenceDate.isNotEqualTo(date: self.asset.fundingDate) {
            let myCashflow: Cashflow = Cashflow(dueDate: self.leaseTerm.baseCommenceDate, amount: "0.0")
            myCashflows.add(item: myCashflow)
        }
        
        var nextLeaseDate: Date = addOnePeriodToDate(dateStart: self.leaseTerm.baseCommenceDate, payPerYear: self.leaseTerm.paymentFrequency, dateRefer: self.leaseTerm.baseCommenceDate, bolEOMRule: self.leaseTerm.endOfMonthRule)
        while nextLeaseDate.isLessThanOrEqualTo(date: self.getLeaseMaturityDate()) {
            let myCashflow: Cashflow = Cashflow(dueDate: nextLeaseDate, amount: "0.0")
            myCashflows.add(item: myCashflow)
            nextLeaseDate = addOnePeriodToDate(dateStart: nextLeaseDate, payPerYear: self.leaseTerm.paymentFrequency, dateRefer: self.leaseTerm.baseCommenceDate, bolEOMRule: self.leaseTerm.endOfMonthRule)
        }
        
        if nextLeaseDate.isEqualTo(date: self.getLeaseMaturityDate()){
            let myCashflow: Cashflow = Cashflow(dueDate: nextLeaseDate, amount: "0.0")
            myCashflows.add(item: myCashflow)
        }
        
        return myCashflows
    }
    
    
    public func percentToAmount(percent: String) -> String {
        let decAmount: Decimal = percent.toDecimal() * self.asset.lessorCost.toDecimal()
        return decAmount.toString(decPlaces: 4)
    }
    
    public func percentToAmount(percent: String, basis: String) -> String {
        let decAmount: Decimal = percent.toDecimal() * basis.toDecimal()
        return decAmount.toString(decPlaces: 4)
        
    }
    
}

    
   

