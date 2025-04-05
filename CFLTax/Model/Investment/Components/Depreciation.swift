//
//  Depreciation.swift
//  CFLTax
//
//  Created by Steven Williams on 8/8/24.
//

import Foundation


public struct Depreciation {
    public var basisReduction: Decimal
    public var bonusDeprecPercent: Decimal
    public var convention: ConventionType
    public var life: Int
    public var method: DepreciationType
    public var investmentTaxCredit: Decimal
    public var salvageValue: String
    public var vestingPeriod: Int
    
    
    init(basisReduction: Decimal, bonusDeprecPercent: Decimal, convention: ConventionType, life: Int, method: DepreciationType, investmentTaxCredit: Decimal, salvageValue: String, vestingPeriod: Int) {
        self.basisReduction = basisReduction
        self.bonusDeprecPercent = bonusDeprecPercent
        self.convention = convention
        self.life = life
        self.method = method
        self.investmentTaxCredit = investmentTaxCredit
        self.salvageValue = salvageValue
        self.vestingPeriod = vestingPeriod
    }
    
    init() {
        self.basisReduction = 0.0
        self.bonusDeprecPercent = 0.0
        self.convention = .halfYear
        self.life = 5
        self.method = .MACRS
        self.investmentTaxCredit = 0.0
        self.salvageValue = "0.0"
        self.vestingPeriod = 0
    }
    
    func changeComparedTo(_ other: Depreciation) -> ChangeType {
            if self.isEqual(to: other) {
                return .none
            }
            
            return .material
        }
        
    func isEqual(to other: Depreciation) -> Bool {
        var isEqual: Bool = false
        if basisReduction == other.basisReduction &&
            bonusDeprecPercent == other.bonusDeprecPercent &&
            convention == other.convention &&
            life == other.life &&
            method == other.method &&
            investmentTaxCredit == other.investmentTaxCredit &&
            salvageValue == other.salvageValue &&
            vestingPeriod == other.vestingPeriod {
            isEqual = true
        }
        
        return isEqual
    }
    
    mutating func makeEqualTo(_ other: Depreciation) {
        self.basisReduction = other.basisReduction
        self.bonusDeprecPercent = other.bonusDeprecPercent
        self.convention = other.convention
        self.life = other.life
        self.method = other.method
        self.investmentTaxCredit = other.investmentTaxCredit
        self.salvageValue = other.salvageValue
        self.vestingPeriod = other.vestingPeriod
    }
    
}
