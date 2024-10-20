//
//  YTDTaxesPaidView.swift
//  CFLTax
//
//  Created by Steven Williams on 9/18/24.
//

import SwiftUI

struct YTDTaxesPaidView: View {
    @Bindable var myInvestment: Investment
    @Binding var path: [Int]
    @Binding var isDark: Bool
    @Binding var currentFile: String
    
    @State var myPeriodicTaxesPaid: PeriodicYTDTaxesPaid = PeriodicYTDTaxesPaid()
  
    var body: some View {
        Form {
            Section(header: Text("\(currentFile)")) {
                ForEach(myPeriodicTaxesPaid.items) { item in
                    HStack {
                        Text("\(item.dueDate.toStringDateShort(yrDigits: 2))")
                        Spacer()
                        Text("\(amountFormatter(amount: item.amount, locale: myLocale))")
                    }
                    .font(myFont)
                }
            }
            Section(header: Text("Count")) {
                HStack{
                    Text("Count:")
                    Spacer()
                    Text("\(myPeriodicTaxesPaid.items.count)")
                }
                .font(myFont)
            }
           
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackButtonView(path: $path, isDark: $isDark)
            }
        }
        .environment(\.colorScheme, isDark ? .dark : .light)
        .navigationTitle("YTD Taxes Paid")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            if myPeriodicTaxesPaid.items.count > 0 {
                myPeriodicTaxesPaid.items.removeAll()
            }

            myPeriodicTaxesPaid.createTable(aInvestment: myInvestment)
        }
    }
}

#Preview {
    YTDTaxesPaidView(myInvestment: Investment(), path: .constant([Int]()), isDark: .constant(false), currentFile: .constant("Fiel is New"))
}
