//
//  EconomicsView.swift
//  CFLTax
//
//  Created by Steven Williams on 8/10/24.
//

import SwiftUI

struct EconomicsView: View {
    @Bindable var myInvestment: Investment
    @Binding var path: [Int]
    @Binding var isDark: Bool
    @Binding var currentFile: String
    
    @State var myEconomics: Economics = Economics()
    //Yield Target TextField
    @State private var editYieldTargetStarted: Bool = false
    @State private var maximumYieldTarget: Decimal = maximumYield.toDecimal()
    @State private var yieldTargetOnEntry: String = ""
    @FocusState private var yieldTargetIsFocused: Bool
    //Discount Rate TextField
    @State private var editDiscountRateStarted: Bool = false
    @State private var maximumDiscountRate: Decimal = maximumYield.toDecimal()
    @State private var discountRateOnEntry: String = ""
    @FocusState private var discountRateIsFocused: Bool
    
    //Alerts and Popover
    @State private var showPop1: Bool = false
    @State private var payHelp1 = yieldMethodHelp
    @State private var showPop2: Bool = false
    @State private var payHelp2 = solveForHelp
    @State private var showPop3: Bool = false
    @State private var payHelp3 = dayCountMethodHelp
    @State private var showPop4: Bool = false
    @State private var payHelp4 = discountRateHelp

    private let pasteBoard = UIPasteboard.general
    @State private var alertTitle: String = ""
    @State private var showAlert: Bool = false
   
    
    var body: some View {
        Form{
            Section(header: Text("Parameters").font(myFont), footer: (Text("File Name: \(currentFile)").font(myFont))){
                yieldMethodItem
                yieldTargetItem
                solveForItem
                discountRateItem
                dayCountMethodItem
            }
            Section(header: Text("Submit Form")){
                SubmitFormButtonsView(cancelName: "Cancel", doneName: "Done", cancel: myCancel, done: myDone, isDark: $isDark)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackButtonView(path: $path, isDark: $isDark)
            }
            ToolbarItemGroup(placement: .keyboard){
                DecimalPadButtonsView(cancel: updateForCancel, copy: copyToClipboard, paste: paste, clear: clearAllText, enter: updateForSubmit, isDark: $isDark)
            }
        }
        .environment(\.colorScheme, isDark ? .dark : .light)
        .navigationTitle("Economics")
        .navigationBarBackButtonHidden(true)
        .onAppear {
            self.myEconomics = myInvestment.economics
            self.yieldTargetOnEntry = myEconomics.yieldTarget
            self.discountRateOnEntry = myEconomics.discountRateForRent
        }
    }
}

#Preview {
    EconomicsView(myInvestment: Investment(), path: .constant([Int]()), isDark: .constant(false), currentFile: .constant("File is New"))
}


//Pickers
extension EconomicsView {
    var yieldMethodItem: some View {
        HStack{
            Text("Yield Method:")
                .font(myFont)
            Image(systemName: "questionmark.circle")
                .foregroundColor(.blue)
                .onTapGesture {
                    self.showPop1 = true
                }
            Picker(selection: $myEconomics.yieldMethod, label: Text("")) {
                ForEach(YieldMethod.allTypes, id: \.self) { item in
                    Text(item.toString())
                }
            }
        }
        .popover(isPresented: $showPop1) {
            PopoverView(myHelp: $payHelp1, isDark: $isDark)
        }
    }
    
    var solveForItem: some View {
        HStack{
            Text("Solve For:")
                .font(myFont)
            Image(systemName: "questionmark.circle")
                .foregroundColor(.blue)
                .onTapGesture {
                    self.showPop2 = true
                }
            Picker(selection: $myEconomics.solveFor, label: Text("")) {
                ForEach(SolveForOption.allCases, id: \.self) { item in
                    Text(item.toString())
                }
            }
        }
        .popover(isPresented: $showPop2) {
            PopoverView(myHelp: $payHelp2, isDark: $isDark)
        }
    }
    
    var dayCountMethodItem: some View {
        HStack{
            Text("Day Count:")
                .font(myFont)
            Image(systemName: "questionmark.circle")
                .foregroundColor(.blue)
                .onTapGesture {
                    self.showPop3 = true
                }
            Picker(selection: $myEconomics.dayCountMethod, label: Text("")) {
                ForEach(DayCountMethod.allTypes, id: \.self) { item in
                    Text(item.toString())
                }
            }
        }
        .popover(isPresented: $showPop3) {
            PopoverView(myHelp: $payHelp3, isDark: $isDark)
        }
    }
    
}

//Yield Target TextField
extension EconomicsView {
    var yieldTargetItem: some View {
        HStack{
            leftSideAmountItem
            Spacer()
            rightSideAmountItem
        }
    }
    
    var leftSideAmountItem: some View {
        HStack {
            Text("Target Yield: \(Image(systemName: "return"))")
                .foregroundColor(isDark ? .white : .black)
                .font(myFont)
        }
    }
    
    var rightSideAmountItem: some View {
        ZStack(alignment: .trailing) {
            TextField("",
                      text: $myEconomics.yieldTarget,
              onEditingChanged: { (editing) in
                if editing == true {
                    self.editYieldTargetStarted = true
            }})
            .onSubmit {
                updateForSubmit()
            }
                .keyboardType(.decimalPad).foregroundColor(.clear)
                .focused($yieldTargetIsFocused)
                .textFieldStyle(PlainTextFieldStyle())
                .disableAutocorrection(true)
                .accentColor(.clear)
            Text("\(percentFormatted(editStarted: editYieldTargetStarted))")
                .font(myFont)
                .foregroundColor(isDark ? .white : .black)
        }
    }
    
    func percentFormatted(editStarted: Bool) -> String {
        if editStarted == true {
            return myEconomics.yieldTarget
        } else {
            return percentFormatter(percent: myEconomics.yieldTarget, locale: myLocale, places: 4)
        }
    }
    
}


//Discount Rate For Rent
extension EconomicsView {
    var discountRateItem: some View {
        HStack{
            leftSideDiscountRateItem
            Spacer()
            rightSideDiscountRateItem
        }
    }
    
    var leftSideDiscountRateItem: some View {
        HStack {
            Text("Discount Rate: \(Image(systemName: "return"))")
                .foregroundColor(isDark ? .white : .black)
                .font(myFont)
            Image(systemName: "questionmark.circle")
                .foregroundColor(.blue)
                .onTapGesture {
                    self.showPop4 = true
                }
        }
        .popover(isPresented: $showPop4) {
            PopoverView(myHelp: $payHelp4, isDark: $isDark)
        }
    }
    
    var rightSideDiscountRateItem: some View {
        ZStack(alignment: .trailing) {
            TextField("",
                      text: $myEconomics.discountRateForRent,
              onEditingChanged: { (editing) in
                if editing == true {
                    self.editDiscountRateStarted = true
            }})
            .onSubmit {
                updateForSubmit()
            }
                .keyboardType(.decimalPad).foregroundColor(.clear)
                .focused($discountRateIsFocused)
                .textFieldStyle(PlainTextFieldStyle())
                .disableAutocorrection(true)
                .accentColor(.clear)
            Text("\(discountRateFormatted(editStarted: editDiscountRateStarted))")
                .font(myFont)
                .foregroundColor(isDark ? .white : .black)
        }
    }
    
    func discountRateFormatted(editStarted: Bool) -> String {
        if editStarted == true {
            return myEconomics.discountRateForRent
        } else {
            return percentFormatter(percent: myEconomics.discountRateForRent, locale: myLocale, places: 4)
        }
    }
}

extension EconomicsView {
    func myCancel(){
        path.removeLast()
    }
    func myDone() {
        if self.myInvestment.economics.isEqual(to: myEconomics) == false {
            self.myInvestment.hasChanged = true
            self.myInvestment.economics = myEconomics
        }
        path.removeLast()
    }
}


extension EconomicsView {
    func updateForCancel() {
        if self.editYieldTargetStarted == true {
            self.myEconomics.yieldTarget = self.yieldTargetOnEntry
            self.editYieldTargetStarted = false
        } else {
            self.myEconomics.discountRateForRent = self.discountRateOnEntry
            self.editDiscountRateStarted = false
        }
       
    }
    
    func copyToClipboard() {
        if self.yieldTargetIsFocused {
            pasteBoard.string = self.myEconomics.yieldTarget
        } else {
            pasteBoard.string = self.myEconomics.discountRateForRent
        }
    }
    
    func paste() {
        if var string = pasteBoard.string {
            string.removeAll(where: { removeCharacters.contains($0) } )
            if string.isDecimal() {
                if self.yieldTargetIsFocused {
                    self.myEconomics.yieldTarget = string
                } else {
                    self.myEconomics.discountRateForRent = string
                }
            }
        }
    }
    
    func clearAllText() {
        if self.yieldTargetIsFocused == true {
            self.myEconomics.yieldTarget = ""
        } else {
            self.myEconomics.discountRateForRent = ""
        }
    }
   
    func updateForSubmit() {
        if yieldTargetIsFocused {
            if self.editYieldTargetStarted == true {
               updateForNewYield()
                self.editYieldTargetStarted = false
                self.yieldTargetIsFocused = false
           }
        } else {
            if self.editDiscountRateStarted == true {
                updateForNewDiscountRate()
                editDiscountRateStarted = false
                discountRateIsFocused = false
            }
        }
    }
    
    func updateForNewYield() {
        if isAmountValid(strAmount: myEconomics.yieldTarget, decLow: 0.0, decHigh: maximumYieldTarget, inclusiveLow: true, inclusiveHigh: true) == false {
            self.myEconomics.yieldTarget = self.yieldTargetOnEntry
            alertTitle = alertMaxResidual
            showAlert.toggle()
        }
    }
    
    func updateForNewDiscountRate() {
        if isAmountValid(strAmount: myEconomics.discountRateForRent, decLow: 0.0, decHigh: maximumDiscountRate, inclusiveLow: true, inclusiveHigh: true) == false {
            self.myEconomics.discountRateForRent = self.discountRateOnEntry
            alertTitle = alertMaxResidual
            showAlert.toggle()
        }
    }

}

