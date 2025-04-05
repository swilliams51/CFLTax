//
//  Asset.swift
//  CFLTax
//
//  Created by Steven Williams on 8/8/24.
//

import Foundation


public struct Asset {
    public var name: String
    public var fundingDate: Date
    public var lessorCost: String
    public var residualValue: String
    public var lesseeGuarantyAmount: String
    public var thirdPartyGuarantyAmount: String
    
    init(name: String, fundingDate: Date, lessorCost: String, residualValue: String, lesseeGuarantyAmount: String = "0.00", thirdPartyGuarantyAmount: String = "0.00") {
        self.name = name
        self.fundingDate = fundingDate
        self.lessorCost = lessorCost
        self.residualValue = residualValue
        self.lesseeGuarantyAmount = lesseeGuarantyAmount
        self.thirdPartyGuarantyAmount = thirdPartyGuarantyAmount
    }
    
    init() {
        self.name = "Sample asset name"
        self.fundingDate = Date()
        self.lessorCost = "100000.00"
        self.residualValue = "20000.00"
        self.lesseeGuarantyAmount = "0.0"
        self.thirdPartyGuarantyAmount = "0.0"
    }
    
    func changeComparedTo(_ other: Asset) -> ChangeType {
            if self.isEqual(to: other) {
                return .none
            }
            
            if self.fundingDate.isEqualTo(date: other.fundingDate) == false {
                return .material
            }
            
            if self.lessorCost != other.lessorCost {
                return .material
            }
            
            if self.residualValue != other.residualValue {
                return .material
            }
            

            let immaterialMatches = [
                self.name == other.name,
                self.lesseeGuarantyAmount == other.lesseeGuarantyAmount,
                self.thirdPartyGuarantyAmount == other.thirdPartyGuarantyAmount
            ].filter { $0 }.count

            if immaterialMatches > 0 {
                return .immaterial
            }

            return .material
        }

        func isEqual(to other: Asset) -> Bool {
            var isEqual: Bool = false
            if name == other.name &&
                fundingDate.isEqualTo(date: other.fundingDate) &&
                lessorCost == other.lessorCost &&
                residualValue == other.residualValue &&
                lesseeGuarantyAmount == other.lesseeGuarantyAmount &&
                thirdPartyGuarantyAmount == other.thirdPartyGuarantyAmount {
                 isEqual = true
             }
            return isEqual
        }
        
        mutating func makeEqualTo(_ other: Asset) {
            name = other.name
            fundingDate = other.fundingDate
            lessorCost = other.lessorCost
            residualValue = other.residualValue
            lesseeGuarantyAmount = other.lesseeGuarantyAmount
            thirdPartyGuarantyAmount = other.thirdPartyGuarantyAmount
        }

    
    
}
