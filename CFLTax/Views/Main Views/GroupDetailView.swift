//
//  GroupDetailView.swift
//  CFLTax
//
//  Created by Steven Williams on 8/12/24.
//

import SwiftUI

struct GroupDetailView: View {
    @Bindable var myInvestment: Investment
    @Binding var selectedGroup: Group
    @Binding var isDark: Bool
    @Binding var path: [Int]
    @Binding var currentFile: String

    @State private var alertTitle: String = ""
    @State private var count = 0
    @State private var index: Int = 0
    @State private var isInterimGroup: Bool = false
    @State private var isResidualGroup: Bool = false
    @State private var isCalculatedPayment: Bool = false
    @State private var noOfPayments: Double = 1.0
    @State private var rangeOfPayments: ClosedRange<Double> = 1.0...120.0
    @State private var sliderIsLocked: Bool = false
    @State private var startingNoOfPayments: Double = 120.0
    @State private var startingTotalPayments: Double = 120.0
    @State private var timingIsLocked: Bool = false
    
    @State private var showAlert: Bool = false
    @State private var showPop1: Bool = false
    @State private var showPop2: Bool = false
    @State private var showPop3: Bool = false
    @State private var payHelp1 = numberOfPaymentsHelp
    @State private var payHelp2 = paymentAmountHelp
    @State private var payHelp3 = lockedPaymentHelp
   
    //Payment textfield variables
    private let pasteBoard = UIPasteboard.general
    @State private var editPaymentAmountStarted: Bool = false
    @State private var maximumPaymentAmount: Decimal = 1.0
    @State private var paymentAmountOnEntry: String = ""
    @FocusState private var paymentAmountIsFocused: Bool
    
    var body: some View {
        VStack(spacing: 0){
            HeaderView(headerType: .menu, name: "Group Detail", viewAsPct: myViewAsPct, goBack: myGoBack, withBackButton: true, withPctButton: false, path: $path, isDark: $isDark)
            Form {
                Section(header: Text(isInterimGroup ? "Interim Rent Details" : "Base Rent Details").font(myFont), footer: (Text("File Name: \(currentFile)").font(myFont))) {
                    VStack {
                        paymentTypeItem
                        noOfPaymentsItem
                        paymentTimingItem
                        paymentAmountItem
                        paymentLockedItem
                    }
                }
                Section(header: Text("Submit Form").font(.footnote)){
                    SubmitFormButtonsView(cancelName: "Delete", doneName: "Done", cancel: deleteGroup, done: submitForm, isFocused: paymentAmountIsFocused, isDark: $isDark)
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard){
                DecimalPadButtonsView(cancel: updateForCancel, copy: copyToClipboard, paste: paste, clear: clearAllText, enter: updateForSubmit, isDark: $isDark)
            }
        }
        .environment(\.colorScheme, isDark ? .dark : .light)
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .onAppear{
            viewOnAppear()
        }
    }
    
    private func myViewAsPct() {
        
    }
    private func myGoBack() {
        self.path.removeLast()
    }
}

#Preview {
    GroupDetailView(myInvestment: Investment(), selectedGroup: .constant(Group()), isDark: .constant(false), path: .constant([Int]()), currentFile: .constant("File is New"))
}

//View on Appear
//Group Details Section
//Delete and Done Buttons
extension GroupDetailView {
    func viewOnAppear() {
        self.index = self.myInvestment.rent.getIndexOfGroup(aGroup: selectedGroup)
        self.count = self.myInvestment.rent.groups.count - 1
        
        if self.selectedGroup.isInterim == true {
            self.isInterimGroup = true
            self.sliderIsLocked = true
        }
        
        if self.isInterimGroup == false {
            self.rangeOfPayments = rangeNumberOfPayments()
        }
        if self.selectedGroup.isCalculatedPaymentType() {
            self.resetForPaymentTypeChange()
        }
        self.maximumPaymentAmount = myInvestment.getAssetCost(asCashflow: true) * -1.0
        self.noOfPayments = self.selectedGroup.noOfPayments.toDouble()
        self.startingNoOfPayments = self.noOfPayments
        self.startingTotalPayments = Double(self.myInvestment.rent.getTotalNumberOfPayments())
        self.paymentAmountOnEntry = self.selectedGroup.amount
    }
}

extension GroupDetailView {
    var paymentTypeItem: some View {
        Picker(selection: $selectedGroup.paymentType, label: Text("Type:").font(myFont)) {
            ForEach(getPaymentTypes(), id: \.self) { paymentType in
                Text(paymentType.toString())
                    .font(myFont)
            }
            .onChange(of: selectedGroup.paymentType) { oldValue, newValue in
                self.resetForPaymentTypeChange()
            }
            .font(myFont)
            
        }
        .padding(.bottom, 10)
    }
    
    var noOfPaymentsItem: some View {
        VStack {
            noOfPaymentsSubItem
            sliderSubItem
            stepperSubItem
        }
        .popover(isPresented: $showPop1) {
            PopoverView(myHelp: $payHelp1, isDark: $isDark)
        }
    }
    
    var noOfPaymentsSubItem: some View {
        HStack {
            Text("No. of payments:")
                .font(myFont)
            Image(systemName: "questionmark.circle")
                .foregroundColor(.blue)
                .onTapGesture {
                    self.showPop1 = true
                }
            Spacer()
            Text("\(selectedGroup.noOfPayments.toString())")
                .font(myFont)
        } .padding(.bottom, 10)
    }
    
    var sliderSubItem: some View {
        Slider(value: $noOfPayments, in: rangeOfPayments, step: 1) {
            
        }
        .accentColor(ColorTheme().accent)
        .disabled(sliderIsLocked)
        .onChange(of: noOfPayments) { oldValue, newValue in
            self.selectedGroup.noOfPayments = newValue.toInteger()
        }
        .padding(.bottom, 10)
    }
    
    var stepperSubItem: some View {
        HStack {
            Spacer()
            Stepper("", value: $noOfPayments, in: rangeOfPayments, step: 1,
                    onEditingChanged: { _ in
                
            }).labelsHidden()
                .transformEffect(.init(scaleX: 1.0, y: 0.9))
                .disabled(sliderIsLocked)
        }
        .padding(.bottom, 10)
    }
    
    
    var paymentTimingItem: some View {
        Picker(selection: $selectedGroup.timing, label: Text("Timing:").font(myFont)) {
            ForEach(TimingType.nonResidualPayments, id: \.self) { PaymentTiming in
                Text(PaymentTiming.toString())
                    .font(myFont)
            }
        }
        .disabled(timingIsLocked)
    }
    
    var paymentLockedItem: some View {
        HStack {
            Text(selectedGroup.locked ? "Locked" : "Unlocked")
            Image(systemName: "questionmark.circle")
                .foregroundColor(.blue)
                .onTapGesture {
                    self.showPop3 = true
                }
            Spacer()
            Toggle(isOn: $selectedGroup.locked) {
            }
        }
        .disabled(self.selectedGroup.isCalculatedPaymentType() ? true : false)
        .font(myFont)
        .popover(isPresented: $showPop3) {
            PopoverView(myHelp: $payHelp3, isDark: $isDark)
        }
    }
    
}

//Payment Amount TextField
extension GroupDetailView {
    var paymentAmountItem: some View {
        HStack{
            leftSideAmountItem
            Spacer()
            rightSideAmountItem
        }
        .padding(.bottom, 10)
    }
    
    var leftSideAmountItem: some View {
        HStack {
            Text(isCalculatedPayment ? "Amount:" : "Amount: \(Image(systemName: "return"))")
                .font(myFont)
                .foregroundColor(isDark ? .white : .black)
            Image(systemName: "questionmark.circle")
                .foregroundColor(.blue)
                .onTapGesture {
                    self.showPop2 = true
                }
        }
        .popover(isPresented: $showPop2) {
            PopoverView(myHelp: $payHelp2, isDark: $isDark)
        }
    }
    
    var rightSideAmountItem: some View {
        ZStack(alignment: .trailing) {
            TextField("",
              text: $selectedGroup.amount,
              onEditingChanged: { (editing) in
                if editing == true {
                    self.editPaymentAmountStarted = true
            }})
            .onSubmit {
                updateForSubmit()
            }
                .disabled(paymentTextFieldIsLocked())
                .keyboardType(.decimalPad).foregroundColor(.clear)
                .focused($paymentAmountIsFocused)
                .textFieldStyle(PlainTextFieldStyle())
                .disableAutocorrection(true)
                .accentColor(.clear)
                .frame(width: 100, height: 30, alignment: .trailing)
                .border(Color.clear, width: 0)
               
            Text("\(paymentFormatted(editStarted: editPaymentAmountStarted))")
                .font(myFont)
                .frame(width: 100, height: 30, alignment: .trailing)
                .foregroundColor(isDark ? .white : .black)
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Payment Amount Error"), message: Text(alertPaymentAmount), dismissButton: .default(Text("OK")))
        }
        
    }
    
    func paymentFormatted(editStarted: Bool) -> String {
        if isCalculatedPayment == true {
            return selectedGroup.amount
        } else {
            if editStarted == true {
                return selectedGroup.amount
            }
            return amountFormatter(amount: selectedGroup.amount, locale: myLocale)
        }
    }
    
    func paymentTextFieldIsLocked() -> Bool {
        if selectedGroup.isCalculatedPaymentType() == true {
            return true
        } else {
            return false
        }
    }
    // Functions
    func updateForCancel() {
        if self.editPaymentAmountStarted == true {
            self.selectedGroup.amount = self.paymentAmountOnEntry
            self.editPaymentAmountStarted = false
        }
        self.paymentAmountIsFocused = false
    }
    
    func copyToClipboard() {
        if self.paymentAmountIsFocused {
            pasteBoard.string = self.selectedGroup.amount
        }
    }
    
    func paste() {
        if var string = pasteBoard.string {
            string.removeAll(where: { removeCharacters.contains($0) } )
            if string.isDecimal() {
                if self.paymentAmountIsFocused {
                    self.selectedGroup.amount = string
                }
            }
        }
    }
    
    func clearAllText() {
        if self.paymentAmountIsFocused == true {
            self.selectedGroup.amount = ""
        }
    }
   
    func updateForSubmit() {
        if self.editPaymentAmountStarted == true {
            updateForPaymentAmount()
        }
        self.paymentAmountIsFocused = false
    }
    
    func updateForPaymentAmount() {
        if selectedGroup.amount == "" {
            self.selectedGroup.amount = "0.00"
        }
       
        if isAmountValid(strAmount: selectedGroup.amount, decLow: 0.0, decHigh: maximumPaymentAmount, inclusiveLow: true, inclusiveHigh: true) == false {
            self.selectedGroup.amount = self.paymentAmountOnEntry
            showAlert.toggle()
        } else {
            if self.selectedGroup.amount.toDecimal() > 0.00 && self.selectedGroup.amount.toDecimal() <= 1.0 {
                self.selectedGroup.amount = myInvestment.percentToAmount(percent:  selectedGroup.amount)
            }
            if selectedGroup.amount.toDecimal() == 0.00 {
                selectedGroup.locked = true
            }
        }
        self.editPaymentAmountStarted = false
    }
    
}
//Cancel and Submit Buttons{today()
extension GroupDetailView {
    var textButtonsForCancelAndDoneRow: some View {
        HStack {
            Text("Delete")
                .disabled(paymentAmountIsFocused)
                .font(myFont)
                .foregroundColor(ColorTheme().accent)
                .onTapGesture {
                    deleteGroup()
                }
            Spacer()
            Text("Done")
                .disabled(paymentAmountIsFocused)
                .font(myFont)
                .foregroundColor(ColorTheme().accent)
                .onTapGesture {
                    submitForm()
                }
        }
    }
    
    func deleteGroup () {
        let result = isGroupDeletable()
        
        if result.condition == false {
            if result.message == 0 {
                self.alertTitle = alertInterimGroup
                self.showAlert.toggle()
            } else {
                self.alertTitle = alertFirstPaymentGroup
                self.showAlert.toggle()
            }
        } else {
            self.myInvestment.rent.groups.remove(at: index)
            self.myInvestment.resetFirstGroup(isInterim: self.myInvestment.rent.interimExists())
            self.path.removeLast()
            }
        }
    
    func submitForm() {
        if myInvestment.rent.groups[index].isEqual(to: selectedGroup) == false {
               myInvestment.rent.groups[index].makeEqualTo(selectedGroup)
               myInvestment.changeState = .material
       }
       self.myInvestment.resetFirstGroup(isInterim: self.myInvestment.rent.interimExists())
       self.path.removeLast()
    }
    
    func isGroupDeletable() -> (condition:Bool, message: Int) {
        if self.selectedGroup.isInterim == true {
            return (false, 0)
        }
        if myInvestment.rent.interimExists() == true {
            if self.index == 1 {
                return (false, 0)
            }
        }
        if myInvestment.rent.interimExists() == false {
            if self.index == 0 {
                return (false, 1)
            }
        }
         
        return (true, -1)
    }
    
}

//Local Functions
extension GroupDetailView {
    func getAlert() -> Alert{
        return Alert(title: Text(alertTitle))
    }

    func getPaymentTypes() -> [PaymentType] {
        if self.isInterimGroup {
            return PaymentType.interimTypes
        } else {
            return PaymentType.baseTermTypes
        }
    }
    
    func getTimingTypes() -> [TimingType] {
        return TimingType.nonResidualPayments
    }
    
    func getDefaultPaymentAmount() -> String {
        var defaultAmount: String =  (self.myInvestment.getAssetCost(asCashflow: true)  * 0.015).toString(decPlaces: 4)
        
        if self.myInvestment.rent.groups.count > 1 {
            for x in 0..<self.myInvestment.rent.groups.count {
                if self.myInvestment.rent.groups[x].amount != "CALCULATED" {
                    defaultAmount = self.myInvestment.rent.groups[x].amount.toDecimal().toString(decPlaces: 3)
                    break
                }
            }
        }
        return defaultAmount
    }
    
    func rangeNumberOfPayments () -> ClosedRange<Double> {
        let starting: Double = 1.0
        let maxNumber: Double = myInvestment.rent.getMaxRemainNumberPayments(maxBaseTerm: maxBaseTerm, freq: myInvestment.leaseTerm.paymentFrequency, eom: myInvestment.leaseTerm.endOfMonthRule, aRefer: myInvestment.leaseTerm.baseCommenceDate).toDouble()
        let currentNumber:Double = selectedGroup.noOfPayments.toDouble()
        let ending: Double = maxNumber + currentNumber
        
        return starting...ending
    }
    
    func resetForPaymentTypeChange() {
        if selectedGroup.isCalculatedPaymentType() == true {
            isCalculatedPayment = true
            selectedGroup.locked = true
            selectedGroup.amount = "CALCULATED"
            self.sliderIsLocked = true
        } else {
            isCalculatedPayment = false
            selectedGroup.amount = getDefaultPaymentAmount()
            selectedGroup.locked = false
            self.sliderIsLocked = false
        }
        
    }
    
}


