//
//  RentScheduleView.swift
//  CFLTax
//
//  Created by Steven Williams on 8/23/24.
//

import SwiftUI

struct RentScheduleView: View {
    @Bindable var myInvestment: Investment
    @Bindable var myRentalSchedule: RentalCashflows
    @Binding var path: [Int]
    @Binding var isDark: Bool
    @Binding var currentFile: String
    
    @State var viewAsPct: Bool = false
    
    var body: some View {
        VStack (spacing: 0){
            HeaderView(headerType: .report, name: "Rent Schedule", viewAsPct: myViewAsPct, goBack: myGoBack, withBackButton: true, withPctButton: true, path: $path, isDark: $isDark)
            Form {
                Section(header: Text("\(currentFile)")) {
                    ForEach(myRentalSchedule.items) { item in
                        HStack {
                            Text("\(item.dueDate.toStringDateShort())")
                            Spacer()
                            Text("\(getFormattedValue(amount: item.amount, viewAsPercentOfCost: viewAsPct, aInvestment: myInvestment))")
                        }
                        .font(myFont)
                    }
                }
                
                Section(header: Text("Totals")) {
                    HStack {
                        Text("\(myRentalSchedule.items.count)")
                        Spacer()
                        Text("\(getFormattedValue(amount: myRentalSchedule.getTotal().toString(decPlaces: 4), viewAsPercentOfCost: viewAsPct, aInvestment: myInvestment))")
                    }
                    .font(myFont)
                }
               
            }
        }
        .environment(\.colorScheme, isDark ? .dark : .light)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            if myRentalSchedule.items.count > 0 {
                myRentalSchedule.items.removeAll()
            }
            myRentalSchedule.createTable(aInvestment: myInvestment)
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
    RentScheduleView(myInvestment: Investment(), myRentalSchedule: RentalCashflows(), path: .constant([Int]()), isDark: .constant(false), currentFile: .constant("File is New"))
}
