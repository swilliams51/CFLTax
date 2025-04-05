//
//  TaxAssumptions.swift
//  CFLTax
//
//  Created by Steven Williams on 8/8/24.
//

import Foundation


public struct TaxAssumptions {
    public var federalTaxRate: String
    public var fiscalMonthEnd: TaxYearEnd
    public var dayOfMonPaid: Int
    
    init(federalTaxRate: String, fiscalMonthEnd: TaxYearEnd, dayOfMonPaid: Int) {
        self.federalTaxRate = federalTaxRate
        self.fiscalMonthEnd = fiscalMonthEnd
        self.dayOfMonPaid = dayOfMonPaid
    }
    
    init() {
        self.federalTaxRate = "0.10"
        self.fiscalMonthEnd = .December
        self.dayOfMonPaid = 15
    }
    
    func isEqual(to other: TaxAssumptions) -> Bool {
        var isEqual: Bool = false
        if federalTaxRate == other.federalTaxRate && fiscalMonthEnd == other.fiscalMonthEnd && dayOfMonPaid == other.dayOfMonPaid {
            isEqual = true
        }
        
        return isEqual
    }
    
    func changeComparedTo(_ other: TaxAssumptions) -> ChangeType {
            if isEqual(to: other) {
                return .none
            }
            
            return .material
        }
        
    mutating func makeEqualTo(_ other: TaxAssumptions) {
        self.federalTaxRate = other.federalTaxRate
        self.fiscalMonthEnd = other.fiscalMonthEnd
        self.dayOfMonPaid = other.dayOfMonPaid
    }
}
