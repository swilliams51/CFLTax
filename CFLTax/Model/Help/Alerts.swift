//
//  Alerts.swift
//  CFLTax
//
//  Created by Steven Williams on 10/9/24.
//

import Foundation

//Asset
public let alertAssetName: String = "A valid equipment name must be a string no longer than 25 characters including spaces.  The string must be comprised of only letters, numbers and/or spaces. Special characters are not allowed!"
public let alertLessorCost: String = "A valid Lessor Cost is a decimal that is greater than 999.99 but is less than 10,000,000.00!"
public let alertResidualValue: String = "The Residual Value cannot exceed the Lessor Cost!"
public let alertLesseeGty: String = "The Lessee Guaranty cannot exceed the Residual Value!"
public let alertPaymentAmount: String = "The payment amount cannot exceed the Lessor Cost. To enter such an amount first return to the Asset screen and enter a temporary amount for the Lessor Cost that is greater than the payment amount that was rejected.  Then return the Payment Group screen and enter the desired payment amount."
public let alertBonusDepreciation: String = "The Bonus Depreciation cannot exceed 100% of Lessor Cost!"
public let alertSalvageValue: String = "The Salvage Value cannot exceed the Lessor Cost!"
public let alertFederalTaxRate: String = "The Federal Tax Rate must be less than 100%!"
public let alertFeeAmount: String = "The Fee Amount cannot exceed the 15% of Lessor Cost!"
public let alertInterimGroup: String = "To delete an Interim Payment Group go to the Lease Term screen and reset the Base Term Commencement Date to the Funding Date!!"
public let alertFirstPaymentGroup: String = "The first Payment Group following a Interim Payment Group cannot be deleted. If an interim payment group does not exist then the Rent must include one payment group in which the number of payments is greater than 1!!"
public let alertMaxTargetYield: String = "The Target Yield cannot exceed \(percentFormatter(percent:maximumYield, locale: myLocale, places: 2))!"
public let alertMaxDiscountRate: String = "The Discount Rate for calculating the present value of Rents cannot exceed \(percentFormatter(percent:maximumYield, locale: myLocale, places: 2))!"
public let alertCalculationError = "There is one or more issues with the input parameters that will cause the calculation to produce either a negative value or a value greater than the maximum amount allowable. Please review your inputs. The current calculation has been terminated."
public let alertMaxBaseTerm: String = "The Base Term cannot exceed \(maxBaseTerm) months!"
public let alertForStructureWarning: String = "A structure cannot be applied if 1- an Interim Payment Group exists, 2- more than one Base Payment Group exists, or 3- a strucrture has already been applied."
