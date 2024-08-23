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
    
}