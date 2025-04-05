//
//  SolveForTargetVariable.swift
//  CFLTax
//
//  Created by Steven Williams on 4/5/25.
//

import Foundation

extension Investment {
    
    public func solveForTarget(aTargetVariable: SolveForOption, aYieldMethod: YieldMethod, aTargetYield: Decimal) {
        // Clone the original investment
        let tempInvestment: Investment = self.clone()
        var yield: Decimal = aTargetYield
        var isAfterTax: Bool = false
        if aYieldMethod == .MISF_AT {
            isAfterTax = true
        }
        if aYieldMethod != .IRR_PTCF {
            if !isAfterTax {
                yield *= (1.0 - self.taxAssumptions.federalTaxRate.toDecimal())
            }
        }
        //**Establish first point and rapidly locate 2nd point on opposite side of x-axis
        var x1: Decimal = 1.0
        var y1 = getNPVAfterNewFactor(aInvestment: tempInvestment, aFactor: x1, aTargetVariable: aTargetVariable, aYieldMethod: aYieldMethod, discountRate: yield)
        // **Adjust step in large linear amounts to rapidly obtain second point on opposite side of x-axis**
        var step: Decimal = 5.0
        var myDirection = getDirection(aInvestment: tempInvestment, y1: y1, aTargetVariable: aTargetVariable)
        var (x2, y2) = adjustFactorToCrossXAxis(aInvestment: tempInvestment, aTargetVariable: aTargetVariable, aYieldMethod: aYieldMethod, discountRate: yield, x1: x1, y1: y1, step: step, direction: myDirection)
        // **Calculate x-intercept**
        var newFactor: Decimal = findCrossingPoint(x1: x1, y1: y1, x2: x2, y2: y2)
        var newY: Decimal = getNPVAfterNewFactor(aInvestment: tempInvestment, aFactor: newFactor, aTargetVariable: aTargetVariable, aYieldMethod: aYieldMethod, discountRate: yield)
        // **Swap points**
        x1 = x2 ; y1 = y2
        x2 = newFactor ; y2 = newY

        if abs(newY) > 0.005 {
            step = 10.0
            var iteration = 1
            // **Step 2: Adjust step geometrically and use Secant Method via findCrossingPoint for faster convergence**
            while iteration < 4 {
                let stepFactor = min(power(base: 10.0, exp: iteration), 10000.0)
                newFactor = findCrossingPoint(x1: x1, y1: y1, x2: x2, y2: y2)
                newY = getNPVAfterNewFactor(aInvestment: tempInvestment, aFactor: newFactor, aTargetVariable: aTargetVariable, aYieldMethod: aYieldMethod, discountRate: yield)
                if abs(newY) < 0.005 {
                    break
                }

                // Swap points and refine using adjustFactorToCrossXAxis if needed
                x1 = newFactor ; y1 = newY
                myDirection = getDirection(aInvestment: tempInvestment, y1: y1, aTargetVariable: aTargetVariable)
                (x2, y2) = adjustFactorToCrossXAxis(aInvestment: tempInvestment, aTargetVariable: aTargetVariable, aYieldMethod: aYieldMethod, discountRate: yield, x1: x1, y1: y1, step: stepFactor, direction: myDirection)
                iteration += 1
            }
        }
        // **Step 3: Apply final scaling factor to actual investment**
        applyFinalScalingFactor(targetVariable: aTargetVariable, factor: newFactor)
    }
    
    private func getDirection(aInvestment: Investment, y1: Decimal, aTargetVariable: SolveForOption) -> Int {
        switch aTargetVariable {
        case .fee where aInvestment.fee.feeType == .expense,
             .lessorCost:
            return (y1 > 0) ? 1 : -1
        default:
            return (y1 < 0) ? 1 : -1
        }
    }

    // **Refined adjustFactorToCrossXAxis with dynamic step adjustment**
    private func adjustFactorToCrossXAxis(aInvestment: Investment, aTargetVariable: SolveForOption, aYieldMethod: YieldMethod, discountRate: Decimal, x1: Decimal, y1: Decimal, step: Decimal, direction: Int) -> (Decimal, Decimal) {
        let tempInvestment = aInvestment.clone()
       var newX = x1
       var newY = y1
       let stepFactor: Decimal = step // Initial step scaling

       while newY.sign == y1.sign {
           newX += Decimal(direction) * (newX / stepFactor)
           newY = getNPVAfterNewFactor(aInvestment: tempInvestment, aFactor: newX, aTargetVariable: aTargetVariable, aYieldMethod: aYieldMethod, discountRate: discountRate)
       }
       
       return (newX, newY)
    }

    // **Find crossing point using secant method**
    private func findCrossingPoint(x1: Decimal, y1: Decimal, x2: Decimal, y2: Decimal) -> Decimal {
        let slope = (y2 - y1) / (x2 - x1)
        let intercept = y2 - (slope * x2)
        return -intercept / slope
    }

    // **Calculate NPV after applying scaling factor**
    private func getNPVAfterNewFactor(aInvestment: Investment, aFactor: Decimal, aTargetVariable: SolveForOption, aYieldMethod: YieldMethod, discountRate: Decimal) -> Decimal {
        let tempInvestment = aInvestment.clone()
        
        switch aTargetVariable {
        case .unLockedRentals:
            for x in 0..<tempInvestment.rent.groups.count where !tempInvestment.rent.groups[x].locked {
                tempInvestment.rent.groups[x].amount = (tempInvestment.rent.groups[x].amount.toDecimal() * aFactor).toString()
            }
        case .lessorCost:
            var tempCost: Decimal = tempInvestment.asset.lessorCost.toDecimal()
            tempCost = tempCost * aFactor
            tempInvestment.asset.lessorCost = tempCost.toString()
        case .residualValue:
            var tempResidualValue: Decimal = tempInvestment.asset.residualValue.toDecimal()
            tempResidualValue = tempResidualValue * aFactor
            tempInvestment.asset.residualValue = tempResidualValue.toString()
        case .fee:
            var tempFee: Decimal = tempInvestment.fee.amount.toDecimal()
            tempFee = tempFee * aFactor
            tempInvestment.fee.amount = tempFee.toString()
        default :
            break
        }
        
        if aYieldMethod == .IRR_PTCF {
            tempInvestment.setBeforeTaxCashflows()
            return tempInvestment.beforeTaxCashflows.ModXNPV(aDiscountRate: discountRate, aDayCountMethod: self.economics.dayCountMethod)
        } else {
            tempInvestment.setAfterTaxCashflows()
            return tempInvestment.afterTaxCashflows.ModXNPV(aDiscountRate: discountRate, aDayCountMethod: self.economics.dayCountMethod)
        }
    }
    
    
    private func applyFinalScalingFactor(targetVariable: SolveForOption, factor: Decimal) {
        switch targetVariable {
        case .unLockedRentals:
            for x in 0..<self.rent.groups.count where !self.rent.groups[x].locked {
                self.rent.groups[x].amount = (self.rent.groups[x].amount.toDecimal() * factor).toString()
            }
        case .lessorCost:
            var tempLessorCost: Decimal = self.getAssetCost(asCashflow: false)
            tempLessorCost = tempLessorCost * factor
            self.asset.lessorCost = tempLessorCost.toString()
        case .residualValue:
            var tempResidualValue: Decimal = self.asset.residualValue.toDecimal()
            tempResidualValue = tempResidualValue * factor
            self.asset.residualValue = tempResidualValue.toString()
        case .fee:
            var tempFee: Decimal = self.fee.amount.toDecimal()
            tempFee = tempFee * factor
            self.fee.amount = tempFee.toString()
        case .yield:
            break
        }
    }

}
