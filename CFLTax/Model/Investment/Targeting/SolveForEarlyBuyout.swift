//
//  SolveForEarlyBuyout.swift
//  CFLTax
//
//  Created by Steven Williams on 4/5/25.
//

import Foundation
extension Investment {
    public func solveForEarlyBuyout(aEBOInvestment: Investment, aTargetYield: Decimal, aPlannedIncome: Decimal, aUnplannedDate: Date) -> Decimal {
        let tempInvestment = aEBOInvestment.clone()
        let startingEBO: Decimal = tempInvestment.asset.lessorCost.toDecimal() * 0.30
        tempInvestment.asset.residualValue = startingEBO.toString(decPlaces: 4)
        
        var x1: Decimal = 1.0
        var y1: Decimal = getNPVAfterNewFactor(aInvestment: tempInvestment, aFactor: x1, discountRate: aTargetYield, aPlannedIncome: aPlannedIncome, aUnplannedDate: aUnplannedDate)
        var step: Decimal = 5.0
        var myDirection: Int = (y1 < 0) ? 1 : -1
        var (x2, y2) = adjustFactorToCrossXAxis(aInvestment: tempInvestment, discountRate: aTargetYield, x1: x1, y1: y1, step: step, direction: myDirection, aPlannedIncome: aPlannedIncome, aUnplannedDate: aUnplannedDate)
        var newFactor: Decimal = findCrossingPoint(x1: x1, y1: y1, x2: x2, y2: y2)
        var newY = getNPVAfterNewFactor(aInvestment: tempInvestment, aFactor: newFactor, discountRate: aTargetYield, aPlannedIncome: aPlannedIncome, aUnplannedDate: aUnplannedDate)
        x1 = x2 ; y1 = y2
        x2 = newFactor ; y2 = newY
        
        if abs(newY) > 0.005 {
            step = 10.0
            var iteration = 1
            
            while iteration < 4 {
                let stepFactor = min(power(base: 10.0, exp: iteration), 10000.0)
                newFactor = findCrossingPoint(x1: x1, y1: y1, x2: x2, y2: y2)
                newY = getNPVAfterNewFactor(aInvestment: tempInvestment, aFactor: newFactor, discountRate: aTargetYield, aPlannedIncome: aPlannedIncome, aUnplannedDate: aUnplannedDate)
                
                if abs(newY) < 0.005 {
                    break
                }
                x1 = newFactor ; y1 = newY
                myDirection = (y1 < 0) ? 1 : -1
                (x2, y2) = adjustFactorToCrossXAxis(aInvestment: tempInvestment, discountRate: aTargetYield, x1: x1, y1: y1, step: stepFactor, direction: myDirection, aPlannedIncome: aPlannedIncome, aUnplannedDate: aUnplannedDate)
                iteration += 1
            }
        }
        
        return tempInvestment.asset.residualValue.toDecimal() * newFactor
    }
    
    
    private func getNPVAfterNewFactor(aInvestment: Investment, aFactor: Decimal, discountRate: Decimal, aPlannedIncome: Decimal, aUnplannedDate: Date) -> Decimal {
        let eboInvestment = aInvestment.clone()
        var tempResidual: Decimal = eboInvestment.asset.residualValue.toDecimal()
        tempResidual = tempResidual * aFactor
        eboInvestment.asset.residualValue = tempResidual.toString(decPlaces: 4)
        eboInvestment.setAfterTaxCashflows(plannedIncome: aPlannedIncome.toString(decPlaces: 4), unplannedDate: aUnplannedDate)
        let newNPV: Decimal = eboInvestment.afterTaxCashflows.ModXNPV(aDiscountRate: discountRate, aDayCountMethod: self.economics.dayCountMethod)
        
        return newNPV
    }
    
    private func adjustFactorToCrossXAxis(aInvestment: Investment, discountRate: Decimal, x1: Decimal, y1: Decimal, step: Decimal, direction: Int, aPlannedIncome: Decimal, aUnplannedDate: Date) -> (Decimal, Decimal) {
        let tempInvestment = aInvestment.clone()
       var newX = x1
       var newY = y1
       let stepFactor: Decimal = step // Initial step scaling

       while newY.sign == y1.sign {
           newX += Decimal(direction) * (newX / stepFactor)
           newY = getNPVAfterNewFactor(aInvestment: tempInvestment, aFactor: newX, discountRate: discountRate, aPlannedIncome: aPlannedIncome, aUnplannedDate: aUnplannedDate)
       }
       
       return (newX, newY)
    }
    
    private func findCrossingPoint(x1: Decimal, y1: Decimal, x2: Decimal, y2: Decimal) -> Decimal {
        let slope = (y2 - y1) / (x2 - x1)
        let intercept = y2 - (slope * x2)
        return -intercept / slope
    }
    
    
}
