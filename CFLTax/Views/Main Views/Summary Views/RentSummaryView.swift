//
//  RentSummaryView.swift
//  CFLTax
//
//  Created by Steven Williams on 10/10/24.
//

import SwiftUI

struct RentSummaryView: View {
    @Bindable var myInvestment: Investment
    @Binding var path: [Int]
    @Binding var isDark: Bool
    @Binding var currentFile: String
    
    @State private var viewAsPctOfCost: Bool = false
    @State var implicitRate: String = "0.00"
    @State var presentValue1: String = "0.00"
    @State var presentValue2: String = "0.00"
    @State var discountRate: String = "0.00"
    @State private var amounts: [String] = [String]()
    
    @State private var showPop1: Bool = false
    @State private var payHelp = leaseAmountHelp
    @State var lineHeight: CGFloat = 12
    @State var frameHeight: CGFloat = 12
    
    var body: some View {
        Form {
            Section(header: Text("Statistics")) {
                implicitRateItem
                presentValueItem
                presentValue2Item
            }
            
            Section(header: Text("Lease Rate Factors")) {
                ForEach(Array(amounts.enumerated()), id: \.offset) { index, item in
                    leaseRateFactorRow(amount: item, index: index)
                }
            }
            
        }
        .environment(\.defaultMinListRowHeight, lineHeight)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackButtonView(path: $path, isDark: $isDark)
            }
            ToolbarItem(placement: .topBarTrailing){
                Button(action: {
                    viewAsPctOfCost.toggle()
                }) {
                    Image(systemName: "command.circle")
                        .tint(viewAsPctOfCost ? Color.red : Color.black)
                }
            }
        }
        .environment(\.colorScheme, isDark ? .dark : .light)
        .navigationTitle("Summary")
        .navigationBarBackButtonHidden(true)
        .onAppear {
            self.implicitRate = myInvestment.getImplicitRate().toString(decPlaces: 6)
            self.presentValue1 = myInvestment.getPVOfRents().toString(decPlaces: 6)
            self.presentValue2 = myInvestment.getPVOfObligations().toString(decPlaces: 6)
            self.discountRate = myInvestment.economics.discountRateForRent
            for x in 0..<myInvestment.rent.groups.count {
                let strAmount: String = myInvestment.rent.groups[x].amount
                self.amounts.append(strAmount)
            }
        }
        .popover(isPresented: $showPop1) {
            PopoverView(myHelp: $payHelp, isDark: $isDark)
        }
        
    }
    
    @ViewBuilder func leaseRateFactorRow(amount: String, index: Int) -> some View {
        HStack{
            Text("LRF\(index + 1):")
            Spacer()
            Text("\(getFormattedValue(amount: getAmount(amount: amount, index: index), viewAsPercentOfCost: true, aInvestment: myInvestment, places: 6))")
        }
        .font(myFont)
    }
    
    
    
    func getAmount(amount: String, index: Int) -> String {
        var strAmount = amount
        
        if myInvestment.rent.groups[index].isInterim {
            if myInvestment.rent.groups[index].paymentType == .dailyEquivNext {
                strAmount = getDailyRentForNext(aRent: myInvestment.rent, aFreq: myInvestment.leaseTerm.paymentFrequency).toString(decPlaces: 8)
            } else if myInvestment.rent.groups[index].paymentType == .dailyEquivAll{
                strAmount = getDailyRentForAll(aRent: myInvestment.rent, aFreq: myInvestment.leaseTerm.paymentFrequency).toString(decPlaces: 8)
            }
        }
        
        return strAmount
    }
}

#Preview {
    RentSummaryView(myInvestment: Investment(), path: .constant([Int]()), isDark: .constant(false), currentFile: .constant("File is New"))
}

extension RentSummaryView {
    var implicitRateItem: some View {
        HStack{
            Text("Implicit Rate:")
                .font(myFont)
            Spacer()
            Text("\(percentFormatter(percent: implicitRate, locale: myLocale, places: 3))")
                .font(myFont)
        }.frame(height: frameHeight)
    }
    
    var presentValueItem: some View {
            HStack{
                Text("PV1 @ \(getDiscountRateText()):")
                    .font(myFont)
                Image(systemName: "questionmark.circle")
                    .font(myFont)
                    .onTapGesture {
                        self.showPop1 = true
                    }
                Spacer()
                Text("\(getFormattedValue(amount: presentValue1, viewAsPercentOfCost: viewAsPctOfCost, aInvestment: myInvestment))")
                    .font(myFont)
            }.frame(height: frameHeight)
    }
    
    var presentValue2Item: some View {
        HStack{
            Text("PV2 @ \(getDiscountRateText()):")
                .font(myFont)
            Spacer()
            Text("\(getFormattedValue(amount: presentValue2, viewAsPercentOfCost: viewAsPctOfCost, aInvestment: myInvestment))")
                .font(myFont)
        }.frame(height: frameHeight)
    }
    
    func getDiscountRateText() -> String {
        let strDiscountRate: String = percentFormatter(percent: discountRate, locale: myLocale, places: 3)
        return strDiscountRate
    }
}
