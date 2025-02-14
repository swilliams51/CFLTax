//
//  InvestmentBalancesView.swift
//  CFLTax
//
//  Created by Steven Williams on 9/18/24.
//

import SwiftUI

struct InvestmentBalancesView: View {
    @Bindable var myInvestment: Investment
    @Binding var path: [Int]
    @Binding var isDark: Bool
    @Binding var currentFile: String
    
    @State var myPeriodicInvestmentBalances: PeriodicInvestmentBalances = PeriodicInvestmentBalances()
    @State var viewAsPct: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderView(headerType: .report, name: "Investment Balances", viewAsPct: myViewAsPct, goBack: myGoBack, withBackButton: true, withPctButton: true, path: $path, isDark: $isDark)
            Form {
                Section(header: Text("\(currentFile)")) {
                    ForEach(myPeriodicInvestmentBalances.items) { item in
                        HStack {
                            Text("\(item.dueDate.toStringDateShort())")
                            Spacer()
                            Text("\(getFormattedValue(amount: item.amount, viewAsPercentOfCost: viewAsPct, aInvestment: myInvestment))")
                        }
                        .font(myFont)
                    }
                }
                Section(header: Text("Totals")) {
                    HStack{
                        Text("Count:")
                        Spacer()
                        Text("\(myPeriodicInvestmentBalances.items.count)")
                    }
                    .font(myFont)
                }
               
            }
        }
        .environment(\.colorScheme, isDark ? .dark : .light)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            if myPeriodicInvestmentBalances.items.count > 0 {
                myPeriodicInvestmentBalances.items.removeAll()
            }

            myPeriodicInvestmentBalances.createInvestmentBalances(aInvestment: myInvestment)
        }
    }
    
    private func myViewAsPct() {
        self.viewAsPct.toggle()
    }
    
    private func myGoBack() {
        self.path.removeLast()
    }
    
}

#Preview {
    InvestmentBalancesView(myInvestment: Investment(), path: .constant([Int]()), isDark: .constant(false), currentFile: .constant("File is New"))
}
