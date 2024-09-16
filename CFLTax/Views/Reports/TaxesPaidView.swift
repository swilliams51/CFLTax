//
//  TaxesPaidView.swift
//  CFLTax
//
//  Created by Steven Williams on 9/1/24.
//

import SwiftUI

struct TaxesPaidView: View {
    @Bindable var myInvestment: Investment
    @Bindable var myTaxableIncomes: AnnualTaxableIncomes
    @Binding var path: [Int]
    @Binding var isDark: Bool
    @State var myPeriodicTaxesPaid: Cashflows = Cashflows()
    
    var body: some View {
        Form {
            Section(header: Text("Taxes Paid Schedule")) {
                ForEach(myPeriodicTaxesPaid.items) { item in
                    HStack {
                        Text("\(item.dueDate.toStringDateShort(yrDigits: 2))")
                        Spacer()
                        Text("\(amountFormatter(amount: item.amount, locale: myLocale))")
                    }
                }
            }
            Section(header: Text("Totals")) {
                HStack {
                    Text("\(myPeriodicTaxesPaid.items.count)")
                    Spacer()
                    Text("\(amountFormatter(amount: myPeriodicTaxesPaid.getTotal().toString(decPlaces: 4), locale: myLocale))")
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackButtonView(path: $path, isDark: $isDark)
            }
        }
        .environment(\.colorScheme, isDark ? .dark : .light)
        .navigationTitle("Taxes Paid")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            myPeriodicTaxesPaid =   myTaxableIncomes.createPeriodicTaxesPaid_STD(aInvestment: myInvestment)
        }
    }
}

#Preview {
    TaxesPaidView(myInvestment: Investment(), myTaxableIncomes: AnnualTaxableIncomes(), path: .constant([Int]()), isDark: .constant(false))
}