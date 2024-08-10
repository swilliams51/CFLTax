//
//  Cashflow.swift
//  CFLTax
//
//  Created by Steven Williams on 8/8/24.
//

import Foundation

public struct Cashflow: Identifiable {
    public let id = UUID()
    
    public var dueDate: Date
    public var amount: String
   
    public init(dueDate: Date, amount: String) {
        self.dueDate = dueDate
        self.amount = amount
    }
}

@Observable
public class Cashflows {
    public var items: [Cashflow]
    
    public init() {
        items = [Cashflow]()
    }
    
    public func count() -> Int {
        return items.count
    }
    
    public func add(item: Cashflow) {
        items.append(item)
    }
    
    public func addAll(aCFs: Cashflows) {
        for x in 0..<aCFs.count() {
            add(item: aCFs.items[x])
        }
    }
    
    public func removeAll() {
        items.removeAll()
    }
    
    public func sortByDueDate() {
        items.sort { $0.dueDate < $1.dueDate }
    }
    
    public func getTotal() -> Decimal {
        var runTotal: Decimal = 0.0
        
        for x in 0..<items.count {
            runTotal = runTotal + items[x].amount.toDecimal()
        }
        
        return  runTotal
    }
    
    public func getIndex(dateAsk: Date, returnNextOnMatch: Bool) -> Int {
        var idx:Int = 0
        
        for i in 0..<items.count {
            if dateAsk == items[i].dueDate {
                idx = i
                break
            } else if dateAsk < items[i].dueDate {
                if returnNextOnMatch == true {
                    idx = i - 1
                    break
                } else {
                    idx = i
                    break
                }
            }
        }
        
        return idx
    }
    
    public func consolidateCashflows() {
        while checkConsolidation() == false {
            if items.count > 1 {
                for x in 0..<items.count {
                    for y in 1..<items.count {
                        if x + y > items.count - 1 {
                            break
                        }
                        if items[x].dueDate == items[x + y].dueDate {
                            let newAmount: Decimal = items[x].amount.toDecimal() + items[x + y].amount.toDecimal()
                            items[x].amount = newAmount.toString(decPlaces: 4)
                            items.remove(at: x + y)
                        }
                    }
                }
            }
        }
    }
    
    public func checkConsolidation() -> Bool {
        var consolidationIsValid: Bool = true
        
        for x in 0..<items.count - 1 {
            if items[x].dueDate == items[x + 1].dueDate {
                consolidationIsValid = false
                break
            }
        }
        
        return consolidationIsValid
    }
    
    public func deepClone () -> Cashflows {
        let strCashflows: String = writeCashflows(aCFs: self)
        return readCashflows(strCFs: strCashflows)
    }
    
    func XIRR2(guessRate: Decimal, _DayCountMethod: DayCountMethod) -> Decimal {
        var irr: Decimal = guessRate
        var y: Decimal = XNPV(aDiscountRate: irr, aDayCountMethod: _DayCountMethod)
        var iCount: Int = 1
        
        while abs(y) > toleranceAmounts {
            if y > 0.0 {
                irr = incrementRate(x1: irr, y1: y, iCounter: iCount, _DayCountMethod: _DayCountMethod)
            } else {
                irr = decrementRate(x1: irr, y1: y, iCounter: iCount, _DayCountMethod: _DayCountMethod)
            }
            y =  XNPV(aDiscountRate: irr, aDayCountMethod: _DayCountMethod)
            iCount += 1
        }
        
       return irr
    }
    
    func incrementRate(x1: Decimal, y1: Decimal, iCounter: Int, _DayCountMethod: DayCountMethod) -> Decimal {
        //when NPV > 0.0
        var newX: Decimal = x1
        var newY: Decimal = y1
        let factor: Decimal = power(base: 10.0, exp: iCounter)
        
        while newY > 0.0 {
            newX = newX + newX / factor
            newY = XNPV(aDiscountRate: newX, aDayCountMethod: _DayCountMethod)
        }
        return mxbFactor(factor1: x1, value1: y1, factor2: newX, value2: newY)
    }
    
    func decrementRate(x1: Decimal, y1: Decimal, iCounter: Int, _DayCountMethod: DayCountMethod) -> Decimal {
        //when NPV < 0.0
        var newX: Decimal = x1
        var newY: Decimal = y1
        let factor: Decimal = power(base: 10.0, exp: iCounter)
        
        while newY < 0.0 {
            newX = newX - newX / factor
            newY = XNPV(aDiscountRate: newX, aDayCountMethod: _DayCountMethod)
        }
        return mxbFactor(factor1: x1, value1: y1, factor2: newX, value2: newY)
    }
    
    
    func XNPV (aDiscountRate: Decimal, aDayCountMethod: DayCountMethod) -> Decimal {
        var tempSum = items[0].amount.toDecimal()
        if items.count > 1 {
            var prevPVFactor: Decimal = 1.0
            var x = 1
            while x < items.count {
                let dateStart = items[x - 1].dueDate
                let dateEnd = items[x].dueDate
                let aDailyRate: Decimal = dailyRate(iRate: aDiscountRate, aDate1: dateStart, aDate2: dateEnd, aDayCountMethod: aDayCountMethod)
                let aDayCount = dayCount(aDate1: dateStart, aDate2: dateEnd, aDayCount: aDayCountMethod)
                let currPVFactor: Decimal = prevPVFactor / ( 1.0 + aDailyRate * Decimal(aDayCount))
                let pvAmount: Decimal = currPVFactor * items[x].amount.toDecimal()
                tempSum = tempSum + pvAmount
                prevPVFactor = currPVFactor
                x = x + 1
            }
        }
        return tempSum
    }
    
    func XNFV (aPVAmount: Decimal, aCompoundRate: Decimal, aDayCount: DayCountMethod) -> Decimal {
        var prevFVFactor: Decimal = 1.0
        
        for i in 1..<items.count {
            let dateStart = items[i - 1].dueDate
            let dateEnd = items[i].dueDate
            let dailyCompound = dailyRate(iRate: aCompoundRate, aDate1: dateStart, aDate2: dateEnd, aDayCountMethod: aDayCount)
            let noOfDays = Decimal(dayCount(aDate1: dateStart, aDate2: dateEnd, aDayCount: aDayCount))
            let compoundRate = 1.0 + dailyCompound * noOfDays
            let currFVFactor = prevFVFactor * compoundRate
            prevFVFactor = currFVFactor
        }
       return aPVAmount * prevFVFactor
    }
    
    
    
    
}


//Cashflows
public func writeCashflows (aCFs: Cashflows) -> String {
    var strCashflows: String = ""
    for i in 0..<aCFs.items.count {
        let strDueDate = aCFs.items[i].dueDate.toStringDateShort(yrDigits: 4)
        let strAmount = aCFs.items[i].amount
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
