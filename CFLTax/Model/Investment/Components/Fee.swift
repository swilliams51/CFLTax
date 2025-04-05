//
//  Fee.swift
//  CFLTax
//
//  Created by Steven Williams on 8/8/24.
//

import Foundation


public struct Fee {
    public var amount: String
    public var feeType: FeeType
    public var datePaid: Date
    public var hasChanged: Bool = false
    
    init(amount: String, feeType: FeeType = .expense, datePaid: Date = Date()) {
        self.amount = amount
        self.datePaid = datePaid
        self.feeType = feeType
    }
    
    func changeComparedTo(_ other: Fee) -> ChangeType {
            if isEqual(to: other) {
                return .none
            }
            
            return .material
        }
        
        mutating func makeEqualTo(_ other: Fee) {
            self.amount = other.amount
            self.datePaid = other.datePaid
            self.feeType = other.feeType
        }
    
    
    func isEqual(to other: Fee) -> Bool {
        var isEqual: Bool = false
        if amount == other.amount && feeType == other.feeType && datePaid == other.datePaid {
            isEqual = true
        }
        return isEqual
    }

}
