//
//  FeeView.swift
//  CFLTax
//
//  Created by Steven Williams on 8/10/24.
//

import SwiftUI

struct FeeView: View {
    @Bindable var myInvestment: Investment
    @Binding var path: [Int]
    @Binding var isDark: Bool
    @Binding var currentFile: String
    
    @State var myFee: Fee = Fee(amount: "1000.00", feeType: .expense, datePaid: Date())
    @State private var editAmountStarted: Bool = false
    @State private var maximumAmount: Decimal = 1.0
    @FocusState private var amountIsFocused: Bool
    @State private var amountOnEntry: String = ""
    private let pasteBoard = UIPasteboard.general
    
    @State private var alertTitle: String = ""
    @State private var showAlert: Bool = false
    @State private var showPop1: Bool = false
    @State var payHelp1 = feeAmountHelp
    @State private var showPop2: Bool = false
    @State private var payHelp2 = feeDatePaidHelp
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderView(headerType: .menu, name: "Fee", viewAsPct: myViewAsPct, goBack: myGoBack, withBackButton: true, withPctButton: false, path: $path, isDark: $isDark)
            Form{
                Section(header: Text("Details").font(myFont), footer: (Text("File Name: \(currentFile)").font(myFont))) {
                    feeAmountItem
                    datePaidItem
                    feeTypeItem
                }
                Section(header: Text("Submit Form")) {
                    SubmitFormButtonsView(cancelName: "Cancel", doneName: "Done", cancel: myCancel, done: myDone, isFocused: amountIsFocused, isDark: $isDark)
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
        .onAppear {
            self.myFee.makeEqualTo(self.myInvestment.fee)
            self.amountOnEntry = self.myFee.amount
        }
    }
    
    var feeAmountItem: some View {
        HStack{
            leftSideAmountItem
            Spacer()
            rightSideAmountItem
        }
    }
    
    var datePaidItem: some View {
        HStack {
            Text("Date Paid:")
                .font(myFont)
            Image(systemName: "questionmark.circle")
                .font(myFont)
                .foregroundColor(.blue)
                .onTapGesture {
                    self.showPop2 = true
                }
            Spacer()
            Text("\(myFee.datePaid.toStringDateShort())")
                .font(myFont)
        }
        .popover(isPresented: $showPop2) {
            PopoverView(myHelp: $payHelp2, isDark: $isDark)
        }
    }
    
    var feeTypeItem: some View {
        HStack {
            Text("Type:")
                .font(myFont)
            Picker(selection: $myFee.feeType, label: Text("")) {
                ForEach(FeeType.allTypes, id: \.self) { item in
                    Text(item.toString())
                        .font(myFont)
                }
            }
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
        if self.myInvestment.fee.isEqual(to: myFee) == false {
            self.myInvestment.fee = myFee
            self.myInvestment.fee.hasChanged = true
            self.myInvestment.setFeesExistence()
        }
        path.removeLast()
    }
    
}

#Preview {
    FeeView(myInvestment: Investment(), path: .constant([Int]()), isDark: .constant(false), currentFile: .constant("File is New"))
}


//TextField
extension FeeView {
    var leftSideAmountItem: some View {
        HStack {
            Text("Amount: \(Image(systemName: "return"))")
                .font(myFont)
                .foregroundColor(isDark ? .white : .black)
            Image(systemName: "questionmark.circle")
                .font(myFont)
                .foregroundColor(.blue)
                .onTapGesture {
                    self.showPop1 = true
                }
        }
        .popover(isPresented: $showPop1) {
            PopoverView(myHelp: $payHelp1, isDark: $isDark)
        }
    }
    
    var rightSideAmountItem: some View {
        ZStack(alignment: .trailing) {
            TextField("",
                      text: $myFee.amount,
              onEditingChanged: { (editing) in
                if editing == true {
                    self.editAmountStarted = true
            }})
            .onSubmit {
                updateForSubmit()
            }
                .keyboardType(.decimalPad).foregroundColor(.clear)
                .focused($amountIsFocused)
                .textFieldStyle(PlainTextFieldStyle())
                .disableAutocorrection(true)
                .accentColor(.clear)
            Text("\(amountFormatted(editStarted: editAmountStarted))")
                .font(myFont)
                .foregroundColor(isDark ? .white : .black)
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Fee Amount Error"), message: Text(alertFeeAmount), dismissButton: .default(Text("OK")))
        }
    }
    
    func amountFormatted(editStarted: Bool) -> String {
        if editStarted == true {
            return myFee.amount
        } else {
            return amountFormatter(amount: myFee.amount, locale: myLocale)
        }
    }
}

//Decimal Pad Buttons
extension FeeView {
    func updateForCancel() {
        if self.editAmountStarted == true {
            self.myFee.amount = self.amountOnEntry
            self.editAmountStarted = false
        }
        self.amountIsFocused = false
    }
    
    func copyToClipboard() {
        if self.amountIsFocused {
            pasteBoard.string = self.myFee.amount
        }
    }
    
    func paste() {
        if var string = pasteBoard.string {
            string.removeAll(where: { removeCharacters.contains($0) } )
            if string.isDecimal() {
                if self.amountIsFocused {
                    self.myFee.amount = string
                }
            }
        }
    }
    
    func clearAllText() {
        if self.amountIsFocused == true {
            self.myFee.amount = ""
        }
    }
   
    func updateForSubmit() {
        if self.editAmountStarted == true {
            updateForFeeAmount()
        }
        self.amountIsFocused = false
    }
    
    func updateForFeeAmount() {
        if self.myFee.amount.isEmpty {
            self.myFee.amount = "0.00"
        }
        
        let maximumFee: Decimal = myInvestment.asset.lessorCost.toDecimal() * maximumFeePercent.toDecimal()
        if isAmountValid(strAmount: myFee.amount, decLow: 0.0, decHigh: maximumFee, inclusiveLow: true, inclusiveHigh: true) == false {
            self.myFee.amount = self.amountOnEntry
            alertTitle = alertFeeAmount
            showAlert.toggle()
        } else {
            //Amount is Valid
            if self.myFee.amount.toDecimal() > 0.00 && self.myFee.amount.toDecimal() <= 1.0 {
                self.myFee.amount = myInvestment.percentToAmount(percent:  myFee.amount)
            }
        }
            
        self.editAmountStarted = false
    }
    
}
