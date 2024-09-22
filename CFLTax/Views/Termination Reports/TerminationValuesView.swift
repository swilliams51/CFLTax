//
//  TerminationValuesView.swift
//  CFLTax
//
//  Created by Steven Williams on 9/20/24.
//

import SwiftUI

struct TerminationValuesView: View {
    @Bindable var myInvestment: Investment
    @Binding var path: [Int]
    @Binding var isDark: Bool
    
    @State var myTValues: TerminationValues = TerminationValues()
    @State var viewAsPercentOfCost: Bool = false
    
    var body: some View {
        Form {
            Section(header: Text("Par Value TVs")) {
                ForEach(myTValues.items) { item in
                    HStack {
                        Text("\(item.dueDate.toStringDateShort(yrDigits: 2))")
                        Spacer()
                        Text("\(getFormattedValue(amount: item.amount))")
                    }
                }
            }
           
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackButtonView(path: $path, isDark: $isDark)
            }
            ToolbarItem(placement: .topBarTrailing){
                Button(action: {
                    viewAsPercentOfCost.toggle()
                }) {
                    Image(systemName: "command.circle")
                        .tint(viewAsPercentOfCost ? Color.red : Color.black)
                }
            }
        }
        .environment(\.colorScheme, isDark ? .dark : .light)
        .navigationTitle("Termination Values")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            if myTValues.items.count > 0 {
                myTValues.items.removeAll()
            }
            myTValues.createTerminationValues(aInvestment: myInvestment)
        }
    }
    
    func getFormattedValue (amount: String) -> String {
        if viewAsPercentOfCost {
            let decAmount = amount.toDecimal()
            let decCost = myInvestment.getAssetCost(asCashflow: false)
            let decPercent = decAmount / decCost
            let strPercent: String = decPercent.toString(decPlaces: 5)
            
            return percentFormatter(percent: strPercent, locale: myLocale, places: 3)
        } else {
             return amountFormatter(amount: amount, locale: myLocale)
        }
    }
}

#Preview {
    TerminationValuesView(myInvestment: Investment(), path: .constant([Int]()), isDark: .constant(false))
}