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
    @State var days: [Int] = [1, 5, 10, 15, 20, 25]

    @State private var editTaxRateStarted: Bool = false
    @State private var maximumTaxRate: Decimal = 1.0
    @State private var taxRateOnEntry: String = ""
    @FocusState private var taxRateIsFocused: Bool
    private let pasteBoard = UIPasteboard.general
    
    @State private var alertTitle: String = ""
    @State private var showAlert: Bool = false
    @State private var showPop1: Bool = false
    @State var payHelp = dayOfMonthHelp
    
    var body: some View {
        VStack(spacing: 0){
            HeaderView(headerType: .menu, name: "Tax Assumptions", viewAsPct: myViewAsPct, goBack: myGoBack, withBackButton: true, withPctButton: false, path: $path, isDark: $isDark)
            Form {
                Section (header: Text("Federal Income Tax").font(myFont), footer: (Text("File Name: \(currentFile)").font(myFont))) {
                    federalTaxRateItem
                    fiscalMonthEndItem
                    dayOfMonthTaxesPaidItem
                }
                Section(header: Text("Submit Form").font(myFont)) {
                    SubmitFormButtonsView(cancelName: "Cancel", doneName: "Done", cancel: myCancel, done: myDone, isFocused: taxRateIsFocused, isDark: $isDark)
                }
            }
            
        }
        .environment(\.colorScheme, isDark ? .dark : .light)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                DecimalPadButtonsView(cancel: updateForCancel, copy: copyToClipboard, paste: paste, clear: clearAllText, enter: updateForSubmit, isDark: $isDark)
            }
        }
        .onAppear() {
            self.myTaxAssumptions = self.myInvestment.taxAssumptions
        }
    }
    
    private func myViewAsPct() {
        
    }
    private func myGoBack() {
        self.path.removeLast()
    }
    
    private func myCancel() {
        path.removeLast()
    }
    
    private func myDone() {
        self.myInvestment.changeState = myTaxAssumptions.changeComparedTo(self.myInvestment.taxAssumptions)
                
            if self.myInvestment.changeState == .material {
                self.myInvestment.taxAssumptions = myTaxAssumptions
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
            Image(systemName: "questionmark.circle")
                .font(myFont)
                .foregroundColor(.blue)
                .onTapGesture {
                    showPop1.toggle()
                }
            
            Picker(selection: $myTaxAssumptions.dayOfMonPaid, label: Text("")) {
                ForEach(days, id: \.self) { item in
                    Text(item.toString())
                        .font(myFont)
                }
            }
        }
        .popover(isPresented: $showPop1) {
            PopoverView(myHelp: $payHelp, isDark: $isDark)
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
            Text("Tax Rate: \(Image(systemName: "return"))")
                .foregroundColor(isDark ? .white : .black)
                .font(myFont)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
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
            .onSubmit {
                updateForSubmit()
            }
                .keyboardType(.decimalPad).foregroundColor(.clear)
                .focused($taxRateIsFocused)
                .textFieldStyle(PlainTextFieldStyle())
                .disableAutocorrection(true)
                .accentColor(.clear)
            Text("\(percentFormatted(editStarted: editTaxRateStarted))")
                .font(myFont)
                .foregroundColor(isDark ? .white : .black)
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Federal Tax Rate Error"), message: Text(alertFederalTaxRate), dismissButton: .default(Text("OK")))
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
        }
        self.taxRateIsFocused = false
    }
    
    func updateForNewTaxRate() {
        if isAmountValid(strAmount: myTaxAssumptions.federalTaxRate, decLow: 0.0, decHigh: maximumTaxRate, inclusiveLow: true, inclusiveHigh: false) == false {
            self.myTaxAssumptions.federalTaxRate = self.taxRateOnEntry
            showAlert = true
        }
            
        self.editTaxRateStarted = false
    }
}

