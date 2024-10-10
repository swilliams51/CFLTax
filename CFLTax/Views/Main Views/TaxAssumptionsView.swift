//
//  TaxAssumptionsView.swift
//  CFLTax
//
//  Created by Steven Williams on 8/9/24.
//

import SwiftUI

struct TaxAssumptionsView: View {
    @Bindable var myInvestment: Investment
    @Binding var path: [Int]
    @Binding var isDark: Bool
    @Binding var currentFile: String
    
    @State private var myTaxAssumptions: TaxAssumptions = TaxAssumptions()
    @State var days: [Int] = [1, 5, 10, 15, 20, 25, 30]

    
    @State private var editTaxRateStarted: Bool = false
    @State private var maximumTaxRate: Decimal = 1.0
    @FocusState private var taxRateIsFocused: Bool
    @State private var showPopover: Bool = false
    private let pasteBoard = UIPasteboard.general
    @State private var taxRateOnEntry: String = ""
    @State var payHelp = leaseAmountHelp
    
    var body: some View {
        Form {
            Section (header: Text("Details").font(myFont), footer: (Text("FileName: \(currentFile)").font(myFont))) {
                federalTaxRateItem
                fiscalMonthEndItem
                dayOfMonthTaxesPaidItem
            }
            Section(header: Text("Submit Form").font(myFont)) {
                SubmitFormButtonsView(cancelName: "Cancel", doneName: "Done", cancel: myCancel, done: myDone, isDark: $isDark)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackButtonView(path: $path, isDark: $isDark)
            }
            ToolbarItemGroup(placement: .keyboard) {
                DecimalPadButtonsView(cancel: updateForCancel, copy: copyToClipboard, paste: paste, clear: clearAllText, enter: updateForSubmit, isDark: $isDark)
            }
        }
        .environment(\.colorScheme, isDark ? .dark : .light)
        .navigationBarTitle("Tax Assumptions")
        .navigationBarBackButtonHidden(true)
        .onAppear() {
            self.myTaxAssumptions = self.myInvestment.taxAssumptions
        }
    }
    
    private func myCancel() {
        path.removeLast()
    }
    
    private func myDone() {
        if self.myInvestment.taxAssumptions.isEqual(to: myTaxAssumptions) == false {
            self.myInvestment.taxAssumptions = myTaxAssumptions
            self.myInvestment.hasChanged = true
        }
        path.removeLast()
    }
}

#Preview {
    TaxAssumptionsView(myInvestment: Investment(), path: .constant([Int]()), isDark: .constant(false), currentFile: .constant("File is New"))
}



extension TaxAssumptionsView {
    var fiscalMonthEndItem: some View {
        HStack {
            Text("Fiscal Month End:")
                .font(myFont)
            Picker(selection: $myTaxAssumptions.fiscalMonthEnd, label: Text("")) {
                ForEach(TaxYearEnd.allCases, id: \.self) { item in
                   Text(item.toString())
                        .font(myFont)
               }
            }
        }
    }
    
    var dayOfMonthTaxesPaidItem: some View {
        HStack {
            Text("Day Taxes Paid:")
                .font(myFont)
            Picker(selection: $myTaxAssumptions.dayOfMonPaid, label: Text("")) {
                ForEach(days, id: \.self) { item in
                   Text(item.toString())
                        .font(myFont)
               }
            }
        }
    }
}

extension TaxAssumptionsView {
    var federalTaxRateItem: some View {
        HStack{
            leftSideAmountItem
            Spacer()
            rightSideAmountItem
        }
    }
    
    var leftSideAmountItem: some View {
        HStack {
            Text("Federal Tax Rate: \(Image(systemName: "return"))")
                .foregroundColor(isDark ? .white : .black)
                .font(myFont)
        }
        .popover(isPresented: $showPopover) {
            PopoverView(myHelp: $payHelp, isDark: $isDark)
        }
    }
    
    var rightSideAmountItem: some View {
        ZStack(alignment: .trailing) {
            TextField("",
                      text: $myTaxAssumptions.federalTaxRate,
              onEditingChanged: { (editing) in
                if editing == true {
                    self.editTaxRateStarted = true
            }})
                .keyboardType(.decimalPad).foregroundColor(.clear)
                .focused($taxRateIsFocused)
                .textFieldStyle(PlainTextFieldStyle())
                .disableAutocorrection(true)
                .accentColor(.clear)
            Text("\(percentFormatted(editStarted: editTaxRateStarted))")
                .font(myFont)
                .foregroundColor(isDark ? .white : .black)
        }
    }
    
    func percentFormatted(editStarted: Bool) -> String {
        if editStarted == true {
            return myTaxAssumptions.federalTaxRate
        } else {
            return percentFormatter(percent: myTaxAssumptions.federalTaxRate, locale: myLocale, places: 2)
        }
    }
}

extension TaxAssumptionsView {
    func updateForCancel() {
        if self.editTaxRateStarted == true {
            self.myTaxAssumptions.federalTaxRate = self.taxRateOnEntry
            self.editTaxRateStarted = false
        }
        self.taxRateIsFocused = false
    }
    
    func copyToClipboard() {
        if self.taxRateIsFocused {
            pasteBoard.string = self.myTaxAssumptions.federalTaxRate
        }
    }
    
    func paste() {
        if var string = pasteBoard.string {
            string.removeAll(where: { removeCharacters.contains($0) } )
            if string.isDecimal() {
                if self.taxRateIsFocused {
                    self.myTaxAssumptions.federalTaxRate = string
                }
            }
        }
    }
    
    func clearAllText() {
        if self.taxRateIsFocused == true {
            self.myTaxAssumptions.federalTaxRate = ""
        }
    }
   
    func updateForSubmit() {
        if self.editTaxRateStarted == true {
            updateForNewTaxRate()
            path.removeLast()
        }
        self.taxRateIsFocused = false
    }
    
    func updateForNewTaxRate() {
        if isAmountValid(strAmount: myTaxAssumptions.federalTaxRate, decLow: 0.0, decHigh: maximumTaxRate, inclusiveLow: true, inclusiveHigh: true) == false {
            self.myTaxAssumptions.federalTaxRate = self.taxRateOnEntry
            //alertTitle = alertMaxResidual
            //showAlert.toggle()
        }
            
        self.editTaxRateStarted = false
    }
}

