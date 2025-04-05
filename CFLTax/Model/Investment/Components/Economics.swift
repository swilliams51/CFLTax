//
//  Economics.swift
//  CFLTax
//
//  Created by Steven Williams on 8/8/24.
//

import Foundation


public struct Economics {
    public var yieldMethod: YieldMethod
    public var yieldTarget: String
    public var solveFor: SolveForOption
    public var dayCountMethod: DayCountMethod
    public var discountRateForRent: String
    public var sinkingFundRate: String
   
    init(yieldMethod: YieldMethod, yieldTarget: String, solveFor: SolveForOption, dayCountMethod: DayCountMethod, discountRateForRent: String, sinkingFundRate: String = "0.00") {
        self.yieldMethod = yieldMethod
        self.yieldTarget = yieldTarget
        self.solveFor = solveFor
        self.dayCountMethod = dayCountMethod
        self.discountRateForRent = discountRateForRent
        self.sinkingFundRate = sinkingFundRate
    }
    
    init(){
        self.yieldMethod = .MISF_BT
        self.yieldTarget = "0.05"
        self.solveFor = .yield
        self.dayCountMethod = .thirtyThreeSixty
        self.discountRateForRent = "0.075"
        self.sinkingFundRate = "0.00"
    }
    
    func isEqualTo(_ other: Economics) -> Bool {
            var isEqual: Bool = false
               if yieldMethod == other.yieldMethod
                    && yieldTarget == other.yieldTarget
                    && solveFor == other.solveFor
                    && dayCountMethod == other.dayCountMethod
                    && discountRateForRent == other.discountRateForRent
                    && sinkingFundRate == other.sinkingFundRate {
                   isEqual = true
               }
            return isEqual
        }
        
        func changeComparedTo(_ other: Economics) -> ChangeType {
            // If all properties match, return .none
            if self.isEqualTo(other){
                return .none
            }
            
            if self.discountRateForRent == other.discountRateForRent {
                return .immaterial
            }
            
            if other.solveFor == .yield {
                return .immaterial
            }

            // Default to .material if none of the above conditions matched
            return .material
        }
        
        mutating func makeEqualTo(_ other: Economics) {
            self.yieldMethod = other.yieldMethod
            self.yieldTarget = other.yieldTarget
            self.solveFor = other.solveFor
            self.dayCountMethod = other.dayCountMethod
            self.discountRateForRent = other.discountRateForRent
            self.sinkingFundRate = other.sinkingFundRate
            
        }
}
