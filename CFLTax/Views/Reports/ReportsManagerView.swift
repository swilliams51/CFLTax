//
//  ReportsManagerView.swift
//  CFLTax
//
//  Created by Steven Williams on 8/20/24.
//

import SwiftUI

struct ReportsManagerView: View {
    @Bindable var myInvestment: Investment
    @Bindable var myDepreciationSchedule: DepreciationIncomes
    @Binding var path: [Int]
    @Binding var isDark: Bool
    @Binding var currentFile: String
    
    var body: some View {
        Form{
            Section(header: Text("Reports"), footer: (Text("FileName: \(currentFile)"))) {
                leaseRentalsItem
                depreciationScheduleItem
                feeAmortizationItem
                taxableIncomeItem
                taxesPaidItem
                beforeTaxLeaseCashflowsItem
                afterTaxLeaseCashflowsItem
                investmentAmortizationItem
            }
            
        }
        .toolbar{
            ToolbarItem(placement: .topBarLeading) {
                BackButtonView(path: $path, isDark: $isDark)
            }
        }
        .environment(\.colorScheme, isDark ? .dark : .light)
        .navigationBarTitle("Reports")
        .navigationBarBackButtonHidden(true)
    }
    
    var leaseRentalsItem: some View {
        HStack {
            Text("Schedule of Rents")
                .font(myFont2)
            Spacer()
            Image(systemName: "chevron.right")
        }
        .contentShape(Rectangle())
        .onTapGesture {
            path.append(21)
        }
    }
    
    var depreciationScheduleItem: some View {
        HStack {
            Text("Depreciation Schedule")
                .font(myFont2)
            Spacer()
            Image(systemName: "chevron.right")
        }
        .contentShape(Rectangle())
        .onTapGesture {
            path.append(22)
        }
    }
    
    var feeAmortizationItem: some View {
        HStack {
            Text("Fee Amortization")
                .font(myFont2)
            Spacer()
            Image(systemName: "chevron.right")
        }
        .contentShape(Rectangle())
        .onTapGesture {
            path.append(28)
        }
    }
    
    var taxableIncomeItem: some View {
        HStack {
            Text("Taxable Income")
                .font(myFont2)
            Spacer()
            Image(systemName: "chevron.right")
                
        }
        .contentShape(Rectangle())
        .onTapGesture {
            path.append(33)
        }
    }
    
    var taxesPaidItem: some View {
        HStack{
        Text("Taxes Paid")
                .font(myFont2)
            Spacer()
            Image(systemName: "chevron.right")
        }
        .contentShape(Rectangle())
        .onTapGesture {
            path.append(34)
        }
    }
    
    var beforeTaxLeaseCashflowsItem: some View {
        HStack {
            Text("Before-Tax Lease Cashflows")
                .font(myFont2)
            Spacer()
            Image(systemName: "chevron.right")
        }
        .contentShape(Rectangle())
        .onTapGesture {
            path.append(23)
        }
    }
    
    var afterTaxLeaseCashflowsItem: some View {
        HStack {
            Text("After-Tax Lease Cashflows")
                .font(myFont2)
            Spacer()
            Image(systemName: "chevron.right")
        }
        .contentShape(Rectangle())
        .onTapGesture {
            path.append(24)
        }
    }
    
    var investmentAmortizationItem: some View {
        HStack {
            Text("Investment Amortization")
                .font(myFont2)
            Spacer()
            Image(systemName: "chevron.right")
        }
        .contentShape(Rectangle())
        .onTapGesture {
            path.append(35)
        }
    }

}

#Preview {
    ReportsManagerView(myInvestment: Investment(), myDepreciationSchedule: DepreciationIncomes(), path: .constant([Int]()), isDark: .constant(false), currentFile: .constant("File is New"))
}