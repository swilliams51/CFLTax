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
    
    var body: some View {
        Form{
            leaseRentalsItem
            depreciationScheduleItem
            beforeTaxLeaseCashflowsItem
            afterTaxLeaseCashflowsItem
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
                .onTapGesture {
                    path.append(21)
                }
            Spacer()
            Image(systemName: "chevron.right")
                .onTapGesture {
                    path.append(21)
                }
        }
    }
    
    var depreciationScheduleItem: some View {
        HStack {
            Text("Depreciation Schedule")
                .font(myFont2)
                .onTapGesture {
                    path.append(22)
                }
            Spacer()
            Image(systemName: "chevron.right")
                .onTapGesture {
                    path.append(22)
                }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            path.append(22)
        }
    }
    
    var beforeTaxLeaseCashflowsItem: some View {
        HStack {
            Text("Before-Tax Lease Cashflows")
                .font(myFont2)
                .onTapGesture {
                    path.append(23)
                }
            Spacer()
            Image(systemName: "chevron.right")
                .onTapGesture {
                    path.append(23)
                }
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
                .onTapGesture {
                    path.append(24)
                }
            Spacer()
            Image(systemName: "chevron.right")
                .onTapGesture {
                    path.append(24)
                }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            path.append(24)
        }
    }

}

#Preview {
    ReportsManagerView(myInvestment: Investment(), myDepreciationSchedule: DepreciationIncomes(), path: .constant([Int]()), isDark: .constant(false))
}