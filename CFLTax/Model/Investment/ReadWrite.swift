//
//  ReadWrite.swift
//  CFLTax
//
//  Created by Steven Williams on 8/14/24.
//

import Foundation


public let sampleFile: String = "Mack Trucks,100000,10/01/24,20000,10000,0.00*01/15/25,Monthly,False*4000.50,01/15/25,False,1,10/01/24,Advance,Specified,True,True|1925.60,01/15/30,False,60,01/15/25,Arrears,Rent,False,False*0.00,0.00,Half_Year,5,MACRS,0.0,0.0,0*0.21,December,15*MISF_B/T,0.075,Yield,30/360,0.08,0.00*0.00,Expense,10/01/24*0.00,01/15/29,True"

public let sampleFile2: String = "Mack Trucks,100000,10/01/24,20000,10000,0.00*01/15/25,Monthly,False*4000.50,01/15/25,False,1,10/01/24,Advance,Specified,True,True|1925.60,01/15/30,False,60,01/15/25,Arrears,Rent,False,False*0.00,0.00,Half_Year,5,MACRS,0.0,0.0,0*0.21,December,15*MISF_B/T,0.075,Yield,30/360,0.055,0.00*0.00,Expense,10/01/24*0.00,01/15/29,True"



extension Investment {
    public func writeInvestment() -> String {
        
        let strAsset: String = writeAsset(aAsset: self.asset)
        let strLeaseTerm: String = writeLeaseTerm(aLeaseTerm: self.leaseTerm)
        let strRent: String = writeRent(aRent: self.rent)
        let strDepreciation: String = writeDepreciation(aDepreciation: self.depreciation)
        let strTaxAssumptions: String = writeTaxAssumptions(aTaxAssumptions: self.taxAssumptions)
        let strEconomics: String = writeEconomics(aEconomics: self.economics)
        let strFee: String = writeFee(aFee: self.fee)
        let strEBO: String = writeEBO(aEBO: self.earlyBuyout)
        
        let investmentProperties: Array = [strAsset, strLeaseTerm, strRent, strDepreciation, strTaxAssumptions, strEconomics, strFee, strEBO]
        
        return investmentProperties.joined(separator: "*")
    }

    public func readInvestment(file: String) -> Investment {
        let arrayInvestment: [String] = file.components(separatedBy: "*")
        
        let myAsset: Asset = readAsset(arrayAsset:  arrayInvestment[0].components(separatedBy: ","))
        let myLeaseTerm: LeaseTerm = readLeaseTerm(arrayLeaseTerm: arrayInvestment[1].components(separatedBy: ","))
        let myRent: Rent = readRent(arrayGroups: arrayInvestment[2].components(separatedBy: "|"))
        let myDepreciation: Depreciation = readDepreciation(arrayDepreciation: arrayInvestment[3].components(separatedBy: ","))
        let myTaxAssumptions: TaxAssumptions = readTaxAssumptions(arrayTaxAssumptions: arrayInvestment[4].components(separatedBy: ","))
        let myEconomics: Economics = readEconomics(arrayEconomics: arrayInvestment[5].components(separatedBy: ","))
        let myFee: Fee = readFee(arrayFee: arrayInvestment[6].components(separatedBy: ","))
        let myEBO: EarlyBuyout = readEarlyBuyout(arrayEBO: arrayInvestment[7].components(separatedBy: ","))
        
        let myInvestment: Investment = Investment(aAsset: myAsset, aLeaseTerm: myLeaseTerm, aRent: myRent, aDepreciation: myDepreciation, aTaxAssumptions: myTaxAssumptions, aEconomics: myEconomics, aFee: myFee, aEarlyBuyout: myEBO)
        
        return myInvestment
    }
    
    public func writeAsset(aAsset: Asset) -> String {
        let strName: String = aAsset.name
        let strCost: String = aAsset.lessorCost
        let strFundingDate: String = aAsset.fundingDate.toStringDateShort()
        let strResidualValue: String = aAsset.residualValue
        let strLesseeGuaranty: String = aAsset.lesseeGuarantyAmount
        let strThirdPartyGuaranty: String = aAsset.thirdPartyGuarantyAmount
        
        let assetProperties: Array = [strName, strCost, strFundingDate, strResidualValue, strLesseeGuaranty, strThirdPartyGuaranty]
        let strAsset = assetProperties.joined(separator: ",")
        
        return strAsset
    }
    
    public func writeLeaseTerm(aLeaseTerm: LeaseTerm) -> String {
        let strBaseCommence = aLeaseTerm.baseCommenceDate.toStringDateShort()
        let strPaymentFrequency: String = aLeaseTerm.paymentFrequency.toString()
        let strEOMRule: String = aLeaseTerm.endOfMonthRule.toString()
        
        let leaseTermProperties: Array = [strBaseCommence, strPaymentFrequency, strEOMRule]
        let strLeaseTerm = leaseTermProperties.joined(separator: ",")
        
        return strLeaseTerm
    }
    
    public func writeRent(aRent: Rent) -> String {
        var strGroups: String = ""
        for x in 0..<aRent.groups.count {
            let myGroup: String = writeGroup(aGroup: aRent.groups[x])
            strGroups = strGroups + myGroup
            strGroups = strGroups + "|"
        }
        strGroups = String(strGroups.dropLast())
        
        return strGroups
    }
    
    public func writeGroup(aGroup: Group) -> String {
        let strAmount: String = aGroup.amount
        let strEndDate: String = aGroup.endDate.toStringDateShort()
        let strLocked: String = aGroup.locked.toString()
        let strNoOfPayments: String = aGroup.noOfPayments.toString()
        let strStartDate: String = aGroup.startDate.toStringDateShort()
        let strTiming: String = aGroup.timing.toString()
        let strType: String = aGroup.paymentType.toString()
        let strIsInterim: String = aGroup.isInterim.toString()
        let strUndeletable: String = aGroup.unDeletable.toString()
        
        let groupProperties: Array = [strAmount, strEndDate, strLocked, strNoOfPayments, strStartDate, strTiming, strType, strUndeletable, strIsInterim]
        let strGroupProperties = groupProperties.joined(separator: ",")
        
        return strGroupProperties
    }
    
    public func writeDepreciation(aDepreciation: Depreciation) -> String {
        let strBasisReduction: String = aDepreciation.basisReduction.toString(decPlaces: 4)
        let strBonusDepreciation: String = aDepreciation.bonusDeprecPercent.toString(decPlaces: 4)
        let strConvention: String = aDepreciation.convention.toString()
        let strLife: String = aDepreciation.life.toString()
        let strMethod: String = aDepreciation.method.toString()
        let strInvestTaxCredit: String = aDepreciation.investmentTaxCredit.toString(decPlaces: 4)
        let strSalvageValue: String = aDepreciation.salvageValue
        let strVestingPeriod: String = aDepreciation.vestingPeriod.toString()
        
        let depreciationProperties: Array = [strBasisReduction, strBonusDepreciation, strConvention, strLife, strMethod, strInvestTaxCredit, strSalvageValue, strVestingPeriod]
        let strDepreciationProperties = depreciationProperties.joined(separator: ",")
        
        return strDepreciationProperties
    }
    
    
    public func writeTaxAssumptions(aTaxAssumptions: TaxAssumptions) -> String {
        let strFederalTaxRate: String = aTaxAssumptions.federalTaxRate
        let strFiscalMonthEnd: String = aTaxAssumptions.fiscalMonthEnd.rawValue.toString()
        let strDayOfMonthTaxesPaid: String = aTaxAssumptions.dayOfMonPaid.toString()
        
        let taxAssumptionsProperties: Array = [strFederalTaxRate, strFiscalMonthEnd, strDayOfMonthTaxesPaid]
        let strTaxAssumptionsProperties = taxAssumptionsProperties.joined(separator: ",")
        
        return strTaxAssumptionsProperties
    }
    
    public func writeEconomics(aEconomics: Economics) -> String {
        let strYieldMethod: String = aEconomics.yieldMethod.toString()
        let strYieldTarget: String = aEconomics.yieldTarget
        let strSolveFor: String = aEconomics.solveFor.toString()
        let strDayCountMethod: String = aEconomics.dayCountMethod.toString()
        let strDiscountRateForRent: String = aEconomics.discountRateForRent
        let strSinkingFundRate: String = aEconomics.sinkingFundRate
        
        let economicsProperties: Array = [strYieldMethod, strYieldTarget, strSolveFor, strDayCountMethod, strDiscountRateForRent, strSinkingFundRate]
        let strEconomicsProperties = economicsProperties.joined(separator: ",")
        
        return strEconomicsProperties
    }
    
    public func writeFee(aFee: Fee) -> String {
        let strAmount: String = aFee.amount
        let strFeeType: String = aFee.feeType.toString()
        let strDatePaid: String = aFee.datePaid.toStringDateShort()
        
        let feeProperties: Array = [strAmount, strFeeType, strDatePaid]
        let strFeeProperties = feeProperties.joined(separator: ",")
        
        return strFeeProperties
    }
    
    public func writeEBO(aEBO: EarlyBuyout) -> String {
        let strEboAmount: String = aEBO.amount
        let strExerciseDate: String = aEBO.exerciseDate.toStringDateShort()
        let strRentDueIsPaid: String = aEBO.advanceRentDueIsPaid.toString()
        
        let eboProperties: Array = [strEboAmount, strExerciseDate, strRentDueIsPaid]
        let strEBOProperties = eboProperties.joined(separator: ",")
        
        return strEBOProperties
    }
    
    //Read Investment Components
    public func readAsset(arrayAsset: [String]) -> Asset {
        let name = arrayAsset[0]
        let lessorCost = arrayAsset[1]
        let fundingDate = arrayAsset[2].toDate()
        let residualValue = arrayAsset[3]
        let lesseeGuarantee = arrayAsset[4]
        let thirdPartyGuarantee = arrayAsset[5]
        
        //Asset
        let myAsset = Asset(name: name, fundingDate: fundingDate, lessorCost: lessorCost, residualValue: residualValue, lesseeGuarantyAmount: lesseeGuarantee, thirdPartyGuarantyAmount: thirdPartyGuarantee)
        
        return myAsset
    }
    
    public func readLeaseTerm(arrayLeaseTerm: [String]) -> LeaseTerm {
        let baseCommence = arrayLeaseTerm[0].toDate()
        let payPeriod = arrayLeaseTerm[1].toFrequency
        let eom = arrayLeaseTerm[2].toBool()
        
        let myLeaseTerm = LeaseTerm(baseCommenceDate: baseCommence, paymentFrequency: payPeriod(), eomRule: eom)
        
        return myLeaseTerm
    }
    
    public func readRent(arrayGroups: [String]) -> Rent {
        var myRent: Rent = Rent()
        for x in 0..<arrayGroups.count {
           let newGroup: Group = readGroup(arrayGroup: arrayGroups[x])
            myRent.groups.append(newGroup)
        }
        
        return myRent
    }
    
    
    public func readGroup(arrayGroup: String) -> Group {
        let myGroup = arrayGroup.components(separatedBy: ",")
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
    
    
     public func readDepreciation(arrayDepreciation: [String]) -> Depreciation {
         let basisReduction: Decimal = arrayDepreciation[0].toDecimal()
         let bonusDepreciation: Decimal = arrayDepreciation[1].toDecimal()
         let convention: ConventionType = arrayDepreciation[2].toConventionType()!
         let life: Int = arrayDepreciation[3].toInteger()
         let method: DepreciationType = arrayDepreciation[4].toDepreciationType()
         let investTaxCredit: Decimal = arrayDepreciation[5].toDecimal()
         let salvageValue: String = arrayDepreciation[6]
         let vestingPeriod: Int = arrayDepreciation[7].toInteger()
         
         let myDepreciation: Depreciation = Depreciation(basisReduction: basisReduction, bonusDeprecPercent: bonusDepreciation, convention: convention, life: life, method: method, investmentTaxCredit: investTaxCredit, salvageValue: salvageValue, vestingPeriod: vestingPeriod)
         
         return myDepreciation
    }
    
    public func readTaxAssumptions(arrayTaxAssumptions: [String]) -> TaxAssumptions {
        let myTaxRate = arrayTaxAssumptions[0]
        let myFiscalMonthEnd: TaxYearEnd = arrayTaxAssumptions[1].toTaxYearEnd()!
        let myDayOfMonthTaxesPaid = arrayTaxAssumptions[2].toInteger()
        let myTaxAssumptions = TaxAssumptions(federalTaxRate: myTaxRate, fiscalMonthEnd: myFiscalMonthEnd, dayOfMonPaid: myDayOfMonthTaxesPaid)
        
        return myTaxAssumptions
    }
    
    public func readEarlyBuyout(arrayEBO: [String]) -> EarlyBuyout {
        let myEBOAmount = arrayEBO[0]
        let myOptionsDate = arrayEBO[1].toDate()
        let myRentDueIsPaid: Bool = arrayEBO[2].toBool()
        
        let myEBO = EarlyBuyout(amount: myEBOAmount, exerciseDate: myOptionsDate, rentDueIsPaid: myRentDueIsPaid)
        
        return myEBO
    }
    
    public func readFee(arrayFee: [String]) -> Fee {
        let myFeeAmount = arrayFee[0]
        let myFeeType: FeeType = arrayFee[1].toFeeType()!
        let myFeeDatePaid: Date = arrayFee[2].toDate()
    
        let myFee = Fee(amount: myFeeAmount, feeType: myFeeType, datePaid: myFeeDatePaid)
        
        return myFee
    }
    
    public func readEconomics(arrayEconomics: [String]) -> Economics {
        let myYieldMethod = arrayEconomics[0].toYieldMethod()
        let myYieldTarget: String = arrayEconomics[1]
        let mySolveFor: SolveForOption = arrayEconomics[2].toSolveFor()
        let myDayCountMethod: DayCountMethod = arrayEconomics[3].toDayCountMethod()!
        let myDiscountRate: String = arrayEconomics[4]
        let mySinkingFundRate: String = arrayEconomics[5]
        
        let myEconomics: Economics = Economics(yieldMethod: myYieldMethod, yieldTarget: myYieldTarget, solveFor: mySolveFor, dayCountMethod: myDayCountMethod, discountRateForRent: myDiscountRate, sinkingFundRate: mySinkingFundRate)
        
        return myEconomics
    }
    
    public func writeAsTemplate() -> String {
        self.asset.fundingDate = Date()
        self.resetForFundingDateChange()
        if self.feeExists {
            self.fee.amount = "0.00"
            self.setFeesExistence()
        }
        if self.earlyBuyoutExists {
            self.earlyBuyout.amount = "0.00"
            self.setEBOsExistence()
        }
        
        return self.writeInvestment()
    }
    
}

extension Cashflows {
    public func writeCashflows () -> String {
        var strCashflows: String = ""
        for i in 0..<items.count {
            let strDueDate = items[i].dueDate.toStringDateShort()
            let strAmount = items[i].amount
            let strOneCashflow = strDueDate + "," + strAmount
            strCashflows = strCashflows + strOneCashflow + str_split_Cashflows
        }
        return String(strCashflows.dropLast())
    }

    public func readCashflows (strCFs: String) -> Cashflows {
        let strCashFlows = strCFs.components(separatedBy: str_split_Cashflows)
        let myCashflows = Cashflows()
        
        for strCF in strCashFlows {
            let arryCF = strCF.components(separatedBy: ",")
            
            let dateDue = arryCF[0].toDate()
            let amount = arryCF[1]
            
            let myCF = Cashflow(dueDate: dateDue, amount: amount)
            myCashflows.items.append(myCF)
        }
        
        return myCashflows
    }
}

