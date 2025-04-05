//
//  DepreciationView.swift
//  CFLTax
//
//  Created by Steven Williams on 8/9/24.
//

import SwiftUI

struct DepreciationView: View {
    @Bindable var myInvestment: Investment
    @Binding var path: [Int]
    @Binding var isDark: Bool
    @Binding var currentFile: String
    
    @State var myDepreciation: Depreciation = Depreciation()
    @State var macrsMode: Bool = true
    @State var myLife: Double = 3.0

    @State private var dblLife_MACRS: [Double] = [3, 5, 7, 10, 15, 20]
    @State private var decBonus: [Decimal] = [0.0, 0.5, 1.0]
    var rangeOfYears: ClosedRange<Double> = 3.0...20.0
    
    //Bonus Depreciation TextField Vars
    @State var myBonusPercent: String = ""
    @State private var percentOnEntry: String = ""
    @State private var editPercentStarted: Bool = false
    @State private var maximumPercent: Decimal = 1.0
    @FocusState private var percentIsFocused: Bool
    
    private let pasteBoard = UIPasteboard.general
    
    //Salvage Value Textfield
    @State var mySalvageAmount: String = ""
    @State var salvageOnEntry: String = ""
    @State private var editSalvageStarted: Bool = false
    @State private var maximumSalvage: Decimal = 1.0
    @FocusState private var salvageIsFocused: Bool
   
    @State private var showPop1: Bool = false
    @State private var payHelp1: Help = basisHelp
    @State private var showPop2: Bool = false
    @State private var payHelp2: Help = bonusHelp
    @State private var showPop3: Bool = false
    @State private var payHelp3: Help = salvageValueHelp
    
    @State private var alertTitle: String = ""
    @State private var showAlert1: Bool = false
    @State private var showAlert2: Bool = false
    @State private var showPopoverForSalvage: Bool = false

    var body: some View {
        VStack(spacing: 0){
            HeaderView(headerType: .menu, name: "Depreciation", viewAsPct: myViewAsPct, goBack: myGoBack, withBackButton: true, withPctButton: false, path: $path, isDark: $isDark)
            Form {
                Section(header: Text("Inputs").font(myFont), footer:(Text("File Name: \(currentFile)").font(myFont))) {
                    depreciationParameters
                }
                Section(header: Text("Submit Form")) {
                    SubmitFormButtonsView(cancelName: "Cancel", doneName: "Done", cancel: myCancel, done: myDone, isFocused: keyBoardIsActive(), isDark: $isDark)
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard){
                DecimalPadButtonsView(cancel: updateForCancel, copy: copyToClipboard, paste: paste, clear: clearAllText, enter: updateForSubmit, isDark: $isDark)
            }
        }
        .environment(\.colorScheme, isDark ? .dark : .light)
        .navigationBarBackButtonHidden(true)
        .onAppear{
            myAppear()
        }
    }
    
    var depreciationParameters: some View {
        VStack {
            depreciableBasisItem
            depreciationMethod
            if macrsMode {
                macrsViewItem
            } else {
                straightLineViewItem
            }
        }
    }
    
    var macrsViewItem: some View {
        VStack {
            depreciableLife
            depreciationConvention
            bonusPercentItem
        }
    }
    
    var straightLineViewItem: some View {
        VStack{
            lifeInYearsItem
            depreciationConvention
            salvageValueItem
        }
    }
    
    private func myViewAsPct() {
        
    }
    private func myGoBack() {
        self.path.removeLast()
    }
   
    private func myCancel() {
        self.path.removeLast()
    }
    
    private func myDone() {
        self.myDepreciation.life = myLife.toInteger()
        self.myDepreciation.bonusDeprecPercent = myBonusPercent.toDecimal()
        self.myDepreciation.salvageValue = mySalvageAmount
       
        self.myInvestment.changeState = self.myDepreciation.changeComparedTo(self.myInvestment.depreciation)
       
       if self.myInvestment.changeState == .material {
           self.myInvestment.depreciation = myDepreciation
       }
       
       self.path.removeLast()
    }
    
    private func keyBoardIsActive() -> Bool {
        if percentIsFocused {
            return true
        }
        if salvageIsFocused {
            return true
        }
       
        return false
    }
    
    private func myAppear() {
        self.myDepreciation.makeEqualTo(myInvestment.depreciation)
        self.myLife = myDepreciation.life.toDouble()
        self.myBonusPercent = myDepreciation.bonusDeprecPercent.toString(decPlaces: 4)
        self.mySalvageAmount = myDepreciation.salvageValue

        if self.myDepreciation.method == .MACRS {
            macrsMode = true
        } else {
            macrsMode = false
        }
    }
    
}

#Preview {
    DepreciationView(myInvestment: Investment(), path: .constant([Int]()), isDark: .constant(false), currentFile: .constant("File is New"))
}


//Common Items
extension DepreciationView {
    var depreciableBasisItem: some View {
        HStack {
            Text("Basis:")
            Image(systemName: "questionmark.circle")
                .foregroundColor(.blue)
                .onTapGesture {
                    self.showPop1 = true
                }
            Spacer()
            Text("\(amountFormatter(amount: myInvestment.asset.lessorCost, locale: myLocale))")
        }
        .font(myFont)
        .padding(.top, 10)
        .padding(.bottom, 10)
        .popover(isPresented: $showPop1) {
            PopoverView(myHelp: $payHelp1, isDark: $isDark)
        }
    }
    
    var depreciationMethod: some View {
        HStack {
            Text("Method:")
            Picker(selection: $myDepreciation.method, label: Text("")) {
                ForEach(DepreciationType.twoTypes, id: \.self) { item in
                    Text(item.toString())
                }
                .onChange(of: myDepreciation.method) { oldValue, newValue in
                    if newValue == .MACRS {
                        macrsMode = true
                    } else {
                        macrsMode = false
                    }
                   myDepreciation.method = newValue
                }
            }
        }
        .font(myFont)
        .padding(.bottom, 10)
    }
    
    var depreciationConvention: some View {
        HStack {
            Text("1st Yr Convention:")
            Picker(selection: $myDepreciation.convention, label: Text("")) {
                ForEach(ConventionType.allCases, id: \.self) { item in
                    Text(item.toString())
                }
            }
        }
        .font(myFont)
        .padding(.bottom, 10)
    }
}

//MACRS Items
extension DepreciationView {
    var depreciableLife: some View {
        HStack {
            Text("Life (in years):")
            Picker(selection: $myLife, label: Text("")) {
                ForEach(dblLife_MACRS, id: \.self) { item in
                    Text(item.toString())
                }
            }
        }
        .font(myFont)
        .padding(.bottom, 10)
    }
}

//Straight-Line Items
extension DepreciationView {
    var lifeInYearsItem: some View {
        VStack {
            HStack {
                Text("Life in Years:")
                Spacer()
                Text("\(myDepreciation.life.toString())")
            }
            Slider(value: $myLife, in: 3...20, step: 1) {

            }
            .accentColor(ColorTheme().accent)
            .onChange(of: myLife) { oldValue, newValue in
                myDepreciation.life = newValue.toInteger()
            }
            HStack {
                Spacer()
                Stepper("", value: $myLife, in: rangeOfYears, step: 1, onEditingChanged: { _ in
                   
                }).labelsHidden()
                .transformEffect(.init(scaleX: 1.0, y: 0.9))
            }
        }
        .font(myFont)
        .padding(.bottom, 10)
    }
    
}

//ITC Items
extension DepreciationView {
    var investmentTaxCredit: some View {
        HStack {
            Text("ITC:")
            Spacer()
            Text("\(percentFormatter(percent: myDepreciation.salvageValue, locale: myLocale))")
                .padding(.bottom, 10)
        }
        .font(myFont)
        .padding(.bottom, 10)
    }
    
    var basisReduction: some View {
        HStack {
            Text("Basis Reduction:")
            Spacer()
            Text("\(percentFormatter(percent: myDepreciation.basisReduction.toString(), locale: myLocale))")
        }
        .font(myFont)
        .padding(.top, 10)
    }
}


//Bonus Depreciation TextField
extension DepreciationView {
    var bonusPercentItem: some View {
        HStack{
            leftSideAmountItem
            Spacer()
            rightSideAmountItem
        }
        .padding(.top, 5)
        .padding(.bottom, 5)
    }
    
    var leftSideAmountItem: some View {
        HStack {
            Text("Bonus: \(Image(systemName: "return"))")
                .foregroundColor(isDark ? .white : .black)
            Image(systemName: "questionmark.circle")
                .foregroundColor(.blue)
                .onTapGesture {
                    self.showPop2 = true
                }
        }
        .font(myFont)
        .popover(isPresented: $showPop2) {
            PopoverView(myHelp: $payHelp2, isDark: $isDark)
        }
    }
    
    var rightSideAmountItem: some View {
        ZStack(alignment: .trailing) {
            TextField("",
                      text: $myBonusPercent,
              onEditingChanged: { (editing) in
                if editing == true {
                    self.editPercentStarted = true
            }})
                .keyboardType(.decimalPad).foregroundColor(.clear)
                .focused($percentIsFocused)
                .textFieldStyle(PlainTextFieldStyle())
                .disableAutocorrection(true)
                .accentColor(.clear)
            Text("\(percentFormatted(editStarted: editPercentStarted))")
                .foregroundColor(isDark ? .white : .black)
        }
        .font(myFont)
        .alert(isPresented: $showAlert1) {
            Alert(title: Text("Bonus Depreciation Error"), message: Text(alertBonusDepreciation), dismissButton: .default(Text("OK")))
        }
    }
    
    func percentFormatted(editStarted: Bool) -> String {
        if editStarted == true {
            return myBonusPercent
        } else {
            return percentFormatter(percent: myBonusPercent, locale: myLocale, places: 2)
        }
    }
}

//Salvage Value TextField {
extension DepreciationView {
    var salvageValueItem: some View {
        HStack{
            leftSideSalvageItem
            Spacer()
            rightSideSalvageItem
        }
        .padding(.bottom, 10)
    }
    
    var leftSideSalvageItem: some View {
        HStack {
            Text("amount: \(Image(systemName: "return"))")
                .foregroundColor(isDark ? .white : .black)
            Image(systemName: "questionmark.circle")
                .foregroundColor(.blue)
                .onTapGesture {
                    self.showPop3 = true
                }
        }
        .font(myFont)
        .popover(isPresented: $showPop3) {
            PopoverView(myHelp: $payHelp3, isDark: $isDark)
        }
    }
    
    var rightSideSalvageItem: some View {
        ZStack(alignment: .trailing) {
            TextField("",
                      text: $mySalvageAmount,
              onEditingChanged: { (editing) in
                if editing == true {
                    self.editSalvageStarted = true
            }})
                .keyboardType(.decimalPad).foregroundColor(.clear)
                .focused($salvageIsFocused)
                .textFieldStyle(PlainTextFieldStyle())
                .disableAutocorrection(true)
                .accentColor(.clear)
            Text("\(salvageFormatted(editStarted: editSalvageStarted))")
                .foregroundColor(isDark ? .white : .black)
        }
        .font(myFont)
        .alert(isPresented: $showAlert2) {
            Alert(title: Text("Salvage Value Error"), message: Text(alertSalvageValue), dismissButton: .default(Text("OK")))
        }
    }
    
    func salvageFormatted(editStarted: Bool) -> String {
        if editStarted == true {
            return mySalvageAmount
        } else {
            return amountFormatter(amount: mySalvageAmount, locale: myLocale)
        }
    }
}


//Decimal Pad Buttons
extension DepreciationView {
    func updateForCancel() {
        if percentIsFocused == true {
            if self.editPercentStarted == true {
                self.myBonusPercent = self.percentOnEntry
                self.editPercentStarted = false
            }
            self.percentIsFocused = false
        } else {
            if salvageIsFocused == true {
                if editSalvageStarted == true {
                    self.mySalvageAmount = self.salvageOnEntry
                    editSalvageStarted = false
                }
            }
        }
    }
    
    func copyToClipboard() {
        if self.percentIsFocused {
            pasteBoard.string = self.myBonusPercent
        } else {
            pasteBoard.string = self.mySalvageAmount
        }
    }
    
    func paste() {
        if var string = pasteBoard.string {
            string.removeAll(where: { removeCharacters.contains($0) } )
            if string.isDecimal() {
                if self.percentIsFocused {
                    self.myBonusPercent = string
                } else {
                    self.mySalvageAmount = string
                }
            }
        }
    }
    
    func clearAllText() {
        if self.percentIsFocused == true {
            self.myBonusPercent = ""
        } else {
            self.mySalvageAmount = ""
        }
    }
   
    func updateForSubmit() {
        if self.editPercentStarted == true {
            updateForNewBonusPercent()
        } else {
            updateForNewSalvageValue()
        }
    }
    
    func updateForNewBonusPercent() {
        if isAmountValid(strAmount: myBonusPercent, decLow: 0.0, decHigh: maximumPercent, inclusiveLow: true, inclusiveHigh: true) == false {
            self.myBonusPercent = self.percentOnEntry
            showAlert1.toggle()
        }
        self.editPercentStarted = false
        self.percentIsFocused = false
    }
    
    func updateForNewSalvageValue() {
        if mySalvageAmount.isEmpty {
            self.mySalvageAmount = "0.00"
        }
        if isAmountValid(strAmount: mySalvageAmount, decLow: 0.0, decHigh: maximumLessorCost.toDecimal(), inclusiveLow: true, inclusiveHigh: true) == false {
            self.mySalvageAmount = self.salvageOnEntry
            showAlert2.toggle()
        } else {
            //Amount is Valid
            if self.mySalvageAmount.toDecimal() > 0.00 && self.mySalvageAmount.toDecimal() <= 1.0 {
                self.mySalvageAmount = myInvestment.percentToAmount(percent: mySalvageAmount)
            }
        }
        self.editSalvageStarted = false
        self.salvageIsFocused = false
    }
    
  
    
    
}
