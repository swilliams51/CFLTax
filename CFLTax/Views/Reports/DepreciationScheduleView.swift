//
//  DepreciationScheduleView.swift
//  CFLTax
//
//  Created by Steven Williams on 8/21/24.
//

import SwiftUI

struct DepreciationScheduleView: View {
    @Bindable var myInvestment: Investment
    @Bindable var myDepreciationSchedule: DepreciationIncomes
    @Binding var path: [Int]
    @Binding var isDark: Bool
    @Binding var currentFile: String
    
    var body: some View {
        VStack {
            ReportHeaderView(name: "Depreciation Schedule", viewAsPct: myViewAsPct, path: $path, isDark: $isDark)
            Form {
                Section(header: Text("\(currentFile)")) {
                    ForEach(myDepreciationSchedule.items) { item in
                        HStack {
                            Text("\(item.dueDate.toStringDateShort(yrDigits: 2))")
                            Spacer()
                            Text("\(amountFormatter(amount: item.amount, locale: myLocale))")
                        }
                        .font(myFont)
                    }
                }
                
                Section(header: Text("Totals")) {
                    HStack {
                        Text("\(myDepreciationSchedule.items.count)")
                        Spacer()
                        Text("\(amountFormatter(amount: myDepreciationSchedule.getTotal().toString(decPlaces: 4), locale: myLocale))")
                    }
                    .font(myFont)
                }
            }
        }
        .environment(\.colorScheme, isDark ? .dark : .light)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            if myDepreciationSchedule.items.count > 0 {
                myDepreciationSchedule.items.removeAll()
            }
            myDepreciationSchedule.createTable(aInvestment: myInvestment)
        }
    }
    
    private func myViewAsPct() {
        
    }
}

#Preview {
    DepreciationScheduleView(myInvestment: Investment(), myDepreciationSchedule: DepreciationIncomes(), path: .constant([Int]()), isDark: .constant(false), currentFile: .constant("File is New"))
}
