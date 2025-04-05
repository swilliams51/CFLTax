//
//  Enums.swift
//  CFLTax
//
//  Created by Steven Williams on 8/8/24.
//

import Foundation


public enum SolveForOption {
    case fee
    case lessorCost
    case residualValue
    case unLockedRentals
    case yield
    
    static let allCases: [SolveForOption] = [.fee, .lessorCost, .residualValue, .unLockedRentals, .yield]
    static let baseCases: [SolveForOption] = [.lessorCost, .residualValue, .unLockedRentals, .yield]
    
    public func toString() -> String {
        switch self {
        case .fee:
            return "Fee"
        case .lessorCost:
            return "Lessor Cost"
        case .residualValue:
            return "Residual Value"
        case .unLockedRentals:
            return "Unlocked Rentals"
        default:
            return "Yield"
        }
    }
}

extension String {
    func toSolveFor() -> SolveForOption {
        switch self {
        case "Fee":
            return .fee
        case "Lessor Cost":
            return .lessorCost
        case "Residual Value":
            return .residualValue
        case "Unlocked Rentals":
            return .unLockedRentals
        default:
            return .yield
        }
    }
}

public enum YieldMethod {
    case MISF_AT
    case MISF_BT
    case IRR_PTCF

    
    public func toString() -> String {
        switch self {
        case .IRR_PTCF:
            return "Pre_Tax IRR"
        case .MISF_AT:
            return "MISF A/T"
        case .MISF_BT:
            return "MISF B/T"
        }
    }
    
    static let allTypes: [YieldMethod] = [.IRR_PTCF,.MISF_AT,.MISF_BT]
}

extension String {
    func toYieldMethod() -> YieldMethod {
        switch self {
        case "Pre_Tax IRR":
            return .IRR_PTCF
        case "MISF A/T":
            return .MISF_AT
        case "MISF B/T":
            return .MISF_BT
        default:
            return .MISF_AT
        }
    }
}

public enum TaxYearEnd: Int {
    case January = 1
    case February = 2
    case March = 3
    case April = 4
    case May = 5
    case June = 6
    case July = 7
    case August = 8
    case September = 9
    case October = 10
    case November = 11
    case December = 12
    
    func toString() -> String {
        switch self {
        case .January:
            return "January"
        case .February:
            return "February"
        case .March:
            return "March"
        case .April:
            return "April"
        case .May:
            return "May"
        case .June:
            return "June"
        case .July:
            return "July"
        case .August:
            return "August"
        case .September:
            return "September"
        case .October:
            return "October"
        case .November:
            return "November"
        case .December:
            return "December"
        }
    }

    
    static let allCases: [TaxYearEnd] = [.January, .February, .March, .April, .May, .June, .July, .August, .September, .October, .November, .December]
}

extension String {
    func toTaxYearEnd() -> TaxYearEnd? {
        switch self {
        case "1":
            return .January
        case "2":
            return .February
        case "3":
            return .March
        case "4":
            return .April
        case "5":
            return .May
        case "6":
            return .June
        case "7":
            return .July
        case "8":
            return .August
        case "9":
            return .September
        case "10":
            return .October
        case "11":
            return .November
        default :
            return .December
            
        }
    }
}

public enum ChangeType: String {
    case none
    case immaterial
    case material
}

public enum ConventionType {
    case halfYear
    case midMonth
    case midQuarter
    
    public func toString() -> String {
        switch self {
        case .halfYear:
            return "Half_Year"
        case .midMonth:
            return "Mid_Month"
        default:
            return "Mid_Quarter"
        }
    }
    
    static let allCases: [ConventionType] = [.halfYear, .midMonth, .midQuarter]
}

extension String {
    func toConventionType() -> ConventionType? {
        switch self {
        case "Half_Year":
            return .halfYear
        case "Mid_Month":
            return .midMonth
        case "Mid_Quarter":
            return .midQuarter
        default:
            return .halfYear
        }
    }
}

public enum DayCountMethod: Int {
    case thirtyThreeSixty
    case actualThreeSixtyFive
    case actualActual
    case actualThreeSixty
    
    func toString() -> String {
        switch self {
        case .thirtyThreeSixty:
            return "30/360"
        case .actualThreeSixtyFive:
            return "Actual/365"
        case .actualActual:
            return "Actual/Actual"
        case .actualThreeSixty:
            return "Actual/360"
        }
    }
    
    func toInt() -> Int {
        return self.rawValue
    }
    
    static let allTypes: [DayCountMethod] = [.thirtyThreeSixty, .actualThreeSixtyFive, .actualActual, .actualThreeSixty]
}

extension String {
    func toDayCountMethod() -> DayCountMethod? {
        switch self {
        case "30/360":
            return .thirtyThreeSixty
        case "Actual/365":
            return .actualThreeSixtyFive
        case "Actual/Actual":
            return .actualActual
        case "Actual/360":
            return .actualThreeSixty
        default:
            return .thirtyThreeSixty
        }
    }
}


public enum DepreciationType {
    case MACRS
    case One_Fifty_DB
    case One_Seventy_Five_DB
    case StraightLine
    
    public func toString() -> String {
        switch self{
        case .MACRS:
            return "MACRS"
        case .One_Fifty_DB:
            return "One Fifty DB"
        case .One_Seventy_Five_DB:
            return "One SeventyFive DB"
        case .StraightLine:
            return "Straightline"
        }
    }
    
    static let twoTypes: [DepreciationType] = [.MACRS, .StraightLine]
    static let allTypes: [DepreciationType] = [.MACRS, .One_Fifty_DB, .One_Seventy_Five_DB, .StraightLine]
    static let macrs: [DepreciationType] = [.MACRS]
}

extension String {
    func toDepreciationType () -> DepreciationType? {
        switch self {
        case "MACRS":
            return .MACRS
        case "One Fifty DB":
            return .One_Fifty_DB
        case "One SeventyFive DB":
            return .One_Seventy_Five_DB
        default:
            return .StraightLine
        }
    }
}

public enum FeeType{
    case expense
    case income
    
    public func toString() -> String {
        switch self{
        case .expense:
            return "Expense"
        case .income:
            return "Income"
        }
    }
    
    static let allTypes: [FeeType] = [.expense, .income]
}

extension String {
    func toFeeType () -> FeeType? {
        switch self {
        case "Income":
            return .income
        default :
            return .expense
        }
    }
}
public enum FeeAmortizationMethod {
    case daily
    case monthly
    
}

public enum Frequency: Int, CaseIterable {
    case monthly = 12
    case quarterly = 4
    case semiannual = 2
    case annual = 1
    
    func toString () -> String {
        switch self {
        case .monthly:
            return "Monthly"
        case .quarterly:
            return "Quarterly"
        case .semiannual:
            return "Semiannual"
        case .annual:
            return "Annual"
        }
        
    }
    
    public static let allCases: [Frequency] = [.monthly, .quarterly, .semiannual, .annual]
    static let three: [Frequency] = [.monthly, .quarterly, .semiannual]
    static let two: [Frequency] = [.monthly, .quarterly]
    static let one: [Frequency] = [.monthly]
}

extension String {
    func toFrequency() -> Frequency {
        switch self {
        case "Monthly":
            return .monthly
        case "Quarterly":
            return .quarterly
        case "Semiannual":
            return .semiannual
        case "Annual":
            return .annual
        default:
            return .monthly
        }
    }
}



public enum InterimRentType {
    case dailyEquivAll
    case dailyEquivNext
    case specified
    
    func toString() -> String {
        switch self {
        case .dailyEquivAll:
            return "DeAll"
        case .dailyEquivNext:
            return "DeNext"
        default:
            return "Specified"
        }
    }
    
    static let allTypes: [InterimRentType] = [.dailyEquivAll, .dailyEquivNext, .specified]
}

public enum PaymentType {
    case dailyEquivAll
    case dailyEquivNext
    case baseRental
    case specified
    
    func toString() -> String {
        switch self {
        case .dailyEquivAll:
            return "DeAll"
        case .dailyEquivNext:
            return "DeNext"
        case .baseRental:
            return "Rent"
        default:
            return "Specified"
        }
    }
    
    static let allTypes: [PaymentType] = [.dailyEquivAll, .dailyEquivNext, .baseRental, .specified]
    static let interimTypes: [PaymentType] = [.dailyEquivAll, .dailyEquivNext, .specified]
    static let baseTermTypes: [PaymentType] = [.baseRental]
}

extension String {
    func toPaymentType() -> PaymentType {
        switch self {
        case "DeAll":
            return .dailyEquivAll
        case "DeNext":
            return .dailyEquivNext
        case "Rent":
            return .baseRental
        default :
            return .specified
        }
    }
}

public enum TimingType {
    case advance
    case arrears
    case equals
    
    func toString () -> String {
        switch self {
        case .advance:
            return "Advance"
        case .arrears:
            return "Arrears"
        default:
            return "Equals"
        }
    }
    
    static let nonResidualPayments: [TimingType] = [.advance, .arrears]
}


public enum AssetTextFieldType {
    case assetName
    case lessorCost
    case residualValue
    case lesseeGuaranty
    
    func toString() -> String {
        switch self {
            case .assetName:
                return "Asset Name"
            case .lessorCost:
                return "Lessor Cost"
            case .residualValue:
                return "Residual Value"
            case .lesseeGuaranty:
                return "Lessee Guaranty"
            }
    }
}

public enum HeaderViewType {
    case home
    case menu
    case report
}


