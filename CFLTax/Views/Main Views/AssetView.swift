//
//  AssetView.swift
//  CFLTax
//
//  Created by Steven Williams on 8/9/24.
//

import SwiftUI

struct AssetView: View {
    @Bindable var myInvestment: Investment
    @Binding var path: [Int]
    @Binding var isDark: Bool
    @Binding var currentFile: String
    
    @State var myAsset: Asset = Asset()
    // Asset Name Textfield
    @State private var editNameStarted: Bool = false
    @State private var fundingDateHasChanged: Bool = false
    @State private var nameOnEntry: String = ""
    @FocusState private var nameIsFocused: Bool
    //Lessor Cost TextField
    @State private var editLessorStarted: Bool = false
    @State private var lessorCostOnEntry: String = ""
    @FocusState private var lessorCostIsFocused: Bool
    //Residual value TextField
    @State private var editResidualValueStarted: Bool = false
    @State private var residualValueOnEntry: String = ""
    @State private var residualPercentOnEntry: Decimal = 0.0
    @FocusState private var residualValueIsFocused: Bool
    //Lessee Guaranty TextField
    @State private var editLesseeGuarantyStarted: Bool = false
    @FocusState private var lesseeGuarantyIsFocused: Bool
    @State private var lesseeGuarantyOnEntry: String = ""
    @State private var lesseeGuarantyPercentOnEntry: Decimal = 0.0
   
    private let pasteBoard = UIPasteboard.general
   
    @State private var showPop1: Bool = false
    @State private var showPop2: Bool = false
    @State private var showPop3: Bool = false
    @State private var alertTitle: String = ""
    
    @State private var showAlert1: Bool = false
    @State private var showAlert2: Bool = false
    @State private var showAlert3: Bool = false
    @State private var showAlert4: Bool = false
  
    @State var assetHelp1 = assetResidualValueHelp
    @State var assetHelp2 = assetLesseeGuarantyHelp
    @State var assetHelp3 = assetFundingDateHelp
    
    @State private var padding: CGFloat = 7
 
    var body: some View {
        VStack(spacing: 0) {
            HeaderView(headerType: .menu, name: "Asset", viewAsPct: myViewAsPct, goBack: myGoBack, withBackButton: true, withPctButton: false, path: $path, isDark: $isDark)
            Form {
                Section(header: Text("Details").font(myFont), footer: (Text("File Name: \(currentFile)").font(myFont))) {
                    assetNameItem
                    lessorCostItem
                    residualAmountItem
                    lesseeGuarantyItem
                    fundingDateItem
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
        .onAppear {
            self.myAsset.makeEqualTo(myInvestment.asset)
            self.nameOnEntry = myAsset.name
            self.lessorCostOnEntry = myAsset.lessorCost
            self.residualValueOnEntry = myAsset.residualValue
            self.lesseeGuarantyOnEntry = myAsset.lesseeGuarantyAmount
            self.residualPercentOnEntry = residualValueOnEntry.toDecimal() / lessorCostOnEntry.toDecimal()
            self.lesseeGuarantyPercentOnEntry = lesseeGuarantyOnEntry.toDecimal() / lessorCostOnEntry.toDecimal()
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
        let tempDate: Date = myInvestment.asset.fundingDate
        
        switch myInvestment.asset.changeComparedTo(myAsset) {
            case .none:
                myInvestment.changeState = .none
            case .immaterial:
                myInvestment.changeState = .immaterial
            case .material:
                myInvestment.changeState = .material
        }
        
        myInvestment.asset = myAsset
        if tempDate.isNotEqualTo(date: myAsset.fundingDate) {
            myInvestment.resetForFundingDateChange()
        }

        path.removeLast()
    }
    
    private func keyBoardIsActive() -> Bool {
        if nameIsFocused {
            return true
        }
        if lessorCostIsFocused {
            return true
        }
        if residualValueIsFocused {
            return true
        }
        if lesseeGuarantyIsFocused {
            return true
        }
        return false
    }
    
}

#Preview {
    AssetView(myInvestment: Investment(), path: .constant([Int]()), isDark: .constant(false), currentFile: .constant("File is New"))
}

extension AssetView {
    var fundingDateItem: some View {
        HStack{
            Text("Funding Date:")
            Image(systemName: "questionmark.circle")
                .foregroundColor(.blue)
                .onTapGesture {
                    self.showPop3 = true
                }
            Spacer()
            DatePicker("", selection: $myAsset.fundingDate,  displayedComponents:[.date])
                //.transformEffect(.init(scaleX: 1.0, y: 0.90))
                .environment(\.locale, myLocale)
                .onChange(of: myAsset.fundingDate) { oldValue, newValue in
                  
                }
        }
        .font(myFont)
        .padding(.top, padding)
        .padding(.bottom, padding)
        .popover(isPresented: $showPop3) {
            PopoverView(myHelp: $assetHelp3, isDark: $isDark)
        }
    }
}

//Asset Name TextField
extension AssetView {
    var assetNameItem: some View {
        HStack{
            leftSideAssetNameItem
            Spacer()
            rightSideAssetNameItem
        }
        .padding(.top, padding)
        .padding(.bottom, padding)
    }
    
    var leftSideAssetNameItem: some View {
        HStack {
            Text("Name: \(Image(systemName: "return"))")
                .foregroundColor(isDark ? .white : .black)
                .font(myFont)
        }
    }
    
    var rightSideAssetNameItem: some View {
        ZStack(alignment: .trailing) {
            TextField("",
                      text: $myAsset.name,
              onEditingChanged: { (editing) in
                if editing == true {
                    self.editNameStarted = true
            }})
            .onSubmit {
                updateForSubmit()
            }
                .keyboardType(.default).foregroundColor(.clear)
                .focused($nameIsFocused)
                .textFieldStyle(PlainTextFieldStyle())
                .disableAutocorrection(true)
                .accentColor(.clear)
            Text("\(myAsset.name)")
                .font(myFont)
                .foregroundColor(isDark ? .white : .black)
        }
        .alert(isPresented: $showAlert1) {
            Alert(title: Text("Asset Name Error"), message: Text(alertAssetName), dismissButton: .default(Text("OK")))
        }
    }
}

// Lessor Cost TextField
extension AssetView {
    var lessorCostItem: some View {
        HStack{
            leftSideLessorCostItem
            Spacer()
            rightSideLessorCostItem
        }
        .padding(.top, padding)
        .padding(.bottom, padding)
    }
    
    var leftSideLessorCostItem: some View {
        HStack {
            Text("Lessor Cost: \(Image(systemName: "return"))")
                .font(myFont)
                .foregroundColor(isDark ? .white : .black)
        }
    }
    
    var rightSideLessorCostItem: some View {
        ZStack(alignment: .trailing) {
            TextField("",
                      text: $myAsset.lessorCost,
              onEditingChanged: { (editing) in
                if editing == true {
                    self.editLessorStarted = true
            }})
            .onSubmit {
                updateForSubmit()
            }
                .keyboardType(.decimalPad).foregroundColor(.clear)
                .focused($lessorCostIsFocused)
                .textFieldStyle(PlainTextFieldStyle())
                .disableAutocorrection(true)
                .accentColor(.clear)
            Text("\(amountFormatted(editStarted: editLessorStarted))")
                .font(myFont)
                .foregroundColor(isDark ? .white : .black)
        }
        .alert(isPresented: $showAlert2) {
            Alert(title: Text("Lessor Cost Error"), message: Text(alertLessorCost), dismissButton: .default(Text("OK")))
        }
    }
    
    func amountFormatted(editStarted: Bool) -> String {
        if editStarted == true {
            return myAsset.lessorCost
        } else {
            return amountFormatter(amount: myAsset.lessorCost, locale: myLocale)
        }
    }
}

//Residual Value TextField
extension AssetView {
    var residualAmountItem: some View {
        HStack{
            leftSideResidualValueItem
            Spacer()
            rightSideResidualValueItem
        }
        .padding(.top, padding)
        .padding(.bottom, padding)
    }
    
    var leftSideResidualValueItem: some View {
        HStack {
            Text("Residual: \(Image(systemName: "return"))")
                .foregroundColor(isDark ? .white : .black)
                .font(myFont)
            Image(systemName: "questionmark.circle")
                .foregroundColor(.blue)
                .onTapGesture {
                    self.showPop1 = true
                }
        }
        .popover(isPresented: $showPop1) {
            PopoverView(myHelp: $assetHelp1, isDark: $isDark)
        }
    }
    
    var rightSideResidualValueItem: some View {
        ZStack(alignment: .trailing) {
            TextField("",
                      text: $myAsset.residualValue,
              onEditingChanged: { (editing) in
                if editing == true {
                    self.editResidualValueStarted = true
            }})
                .onSubmit {
                    updateForSubmit()
                }
                .keyboardType(.decimalPad).foregroundColor(.clear)
                .focused($residualValueIsFocused)
                .textFieldStyle(PlainTextFieldStyle())
                .disableAutocorrection(true)
                .accentColor(.clear)
            Text("\(residualValueFormatted(editStarted: editResidualValueStarted))")
                .foregroundColor(isDark ? .white : .black)
        }
        .alert(isPresented: $showAlert3) {
            Alert(title: Text("Residual Value Error"), message: Text(alertResidualValue), dismissButton: .default(Text("OK")))
        }
        .font(myFont)
    }
    
    func residualValueFormatted(editStarted: Bool) -> String {
        if editStarted == true {
            return myAsset.residualValue
        } else {
            return amountFormatter(amount: myAsset.residualValue, locale: myLocale)
        }
    }
}

//Lessee Guaranty
extension AssetView {
    var lesseeGuarantyItem: some View {
        HStack{
            leftSideLesseeGuarantyItem
            Spacer()
            rightSideLesseeGuarantyItem
        }
        .padding(.top, padding)
        .padding(.bottom, padding)
    }
    
    var leftSideLesseeGuarantyItem: some View {
        HStack {
            Text("Lessee GTY: \(Image(systemName: "return"))")
                .foregroundColor(isDark ? .white : .black)
                .font(myFont)
            Image(systemName: "questionmark.circle")
                .foregroundColor(.blue)
                .onTapGesture {
                    self.showPop2 = true
                }
        }
        .popover(isPresented: $showPop2) {
            PopoverView(myHelp: $assetHelp2, isDark: $isDark)
        }
    }
    
    var rightSideLesseeGuarantyItem: some View {
        ZStack(alignment: .trailing) {
            TextField("",
                      text: $myAsset.lesseeGuarantyAmount,
              onEditingChanged: { (editing) in
                if editing == true {
                    self.editLesseeGuarantyStarted = true
            }})
                .onSubmit {
                    updateForSubmit()
                }
                .keyboardType(.decimalPad).foregroundColor(.clear)
                .focused($lesseeGuarantyIsFocused)
                .textFieldStyle(PlainTextFieldStyle())
                .disableAutocorrection(true)
                .accentColor(.clear)
            Text("\(lesseeGuarantyFormatted(editStarted: editLesseeGuarantyStarted))")
                .foregroundColor(isDark ? .white : .black)
        }
        .alert(isPresented: $showAlert4) {
            Alert(title: Text("Lessee Guaranty Error"), message: Text(alertLesseeGty), dismissButton: .default(Text("OK")))
        }
        .font(myFont)
    }
    
    func lesseeGuarantyFormatted(editStarted: Bool) -> String {
        if editStarted == true {
            return myAsset.lesseeGuarantyAmount
        } else {
            return amountFormatter(amount: myAsset.lesseeGuarantyAmount, locale: myLocale)
        }
    }
}

extension AssetView {
    func updateForCancel() {
        switch getFocusedTextField() {
        case .assetName:
            if self.editNameStarted == true {
                self.myAsset.name = self.nameOnEntry
                self.editNameStarted = false
            }
            self.nameIsFocused = false
        case .lessorCost:
            if self.editLessorStarted == true {
                self.myAsset.lessorCost = self.lessorCostOnEntry
                self.editLessorStarted = false
            }
            self.lessorCostIsFocused = false
        case .residualValue:
            if self.editResidualValueStarted == true {
                self.myAsset.residualValue = self.residualValueOnEntry
                editResidualValueStarted = false
            }
            self.residualValueIsFocused = false
        case .lesseeGuaranty:
            if self.editLesseeGuarantyStarted == true {
                self.myAsset.lesseeGuarantyAmount = self.lesseeGuarantyOnEntry
                editResidualValueStarted = false
            }
            self.lesseeGuarantyIsFocused = false
        default :
            self.nameIsFocused = false
        }
    }
    
    func copyToClipboard() {
        switch getFocusedTextField() {
        case .assetName:
            pasteBoard.string = self.myAsset.name
        case .lessorCost:
            pasteBoard.string = self.myAsset.lessorCost
        case .residualValue:
            pasteBoard.string = self.myAsset.residualValue
        case .lesseeGuaranty:
            pasteBoard.string = self.myAsset.lesseeGuarantyAmount
        default :
            pasteBoard.string = ""
        }
    }
    
    func paste() {
        if var string = pasteBoard.string {
            string.removeAll(where: { removeCharacters.contains($0) } )
            if string.isDecimal() {
                switch getFocusedTextField() {
                case .assetName:
                    self.myAsset.name = string
                case .lessorCost:
                    self.myAsset.lessorCost = string
                case .residualValue:
                    self.myAsset.residualValue = string
                case .lesseeGuaranty:
                    self.myAsset.lesseeGuarantyAmount = string
                default:
                    string = ""
                }
            }
        }
    }
    
    func clearAllText() {
        switch getFocusedTextField() {
        case .assetName:
            self.myAsset.name = ""
        case .lessorCost:
            self.myAsset.lessorCost = ""
        case .residualValue:
            self.myAsset.residualValue = ""
        case .lesseeGuaranty:
            self.myAsset.lesseeGuarantyAmount = ""
        default:
            self.myAsset.name = ""
        }
    }
    
    func updateForSubmit() {
        switch getFocusedTextField() {
        case .assetName:
            updateForAssetName()
            self.nameIsFocused = false
        case .lessorCost:
            updateForLessorCost()
            self.lessorCostIsFocused = false
        case .residualValue:
            updateForResidualAmount()
            self.residualValueIsFocused = false
        case .lesseeGuaranty:
            updateForLesseeGuaranty()
            self.lesseeGuarantyIsFocused = false
        default:
            break
        }
    }
    
    func updateForAssetName() {
        if isNameValid(strIn: myAsset.name) == false {
            self.myAsset.name = self.nameOnEntry
            showAlert1 = true
        }
        
        self.editNameStarted = false
    }
    
    func updateForLessorCost() {
        if isAmountValid(strAmount: myAsset.lessorCost, decLow: minimumLessorCost.toDecimal(), decHigh: maximumLessorCost.toDecimal(), inclusiveLow: true, inclusiveHigh: true) == false {
            self.myAsset.lessorCost = self.lessorCostOnEntry
            showAlert2 = true
        }
        self.myAsset.residualValue = (myAsset.lessorCost.toDecimal() * residualPercentOnEntry).toString()
        self.myAsset.lesseeGuarantyAmount = (myAsset.lessorCost.toDecimal() * lesseeGuarantyPercentOnEntry).toString()
            
        self.editLessorStarted = false
    }
    
    func updateForResidualAmount() {
        if myAsset.residualValue.isEmpty {
            self.myAsset.residualValue = "0.00"
        }
        
        if isAmountValid(strAmount: myAsset.residualValue, decLow: 0.0, decHigh: maximumLessorCost.toDecimal(), inclusiveLow: true, inclusiveHigh: true) == false {
            self.myAsset.residualValue = self.residualValueOnEntry
            showAlert3 = true
        } else {
            if self.myAsset.residualValue.toDecimal() > 0.00 && self.myAsset.residualValue.toDecimal() <= 1.0 {
                self.myAsset.residualValue = myInvestment.percentToAmount(percent: myAsset.residualValue, basis: myAsset.lessorCost)
            }
            self.myAsset.lesseeGuarantyAmount = (0.00).toString()
        }
            
        self.editResidualValueStarted = false
    }
    
    func updateForLesseeGuaranty() {
        if self.myAsset.lesseeGuarantyAmount.isEmpty {
            self.myAsset.lesseeGuarantyAmount = "0.00"
        }
        if isAmountValid(strAmount: myAsset.lesseeGuarantyAmount, decLow: 0.0, decHigh: myAsset.residualValue.toDecimal(), inclusiveLow: true, inclusiveHigh: true) == false {
            self.myAsset.lesseeGuarantyAmount = self.lesseeGuarantyOnEntry
            showAlert4 = true
        } else {
            if self.myAsset.lesseeGuarantyAmount.toDecimal() > 0.00 && self.myAsset.lesseeGuarantyAmount.toDecimal() <= 1.0 {
                self.myAsset.lesseeGuarantyAmount = myInvestment.percentToAmount(percent: myAsset.lesseeGuarantyAmount, basis: myAsset.lessorCost)
            }
        }
            
        self.editLesseeGuarantyStarted = false
    }
}

extension AssetView {
    func getFocusedTextField() -> AssetTextFieldType? {
        var focusedTextField: AssetTextFieldType? = nil
        
        if nameIsFocused {
           focusedTextField = .assetName
        } else if lessorCostIsFocused {
            focusedTextField = .lessorCost
        } else if residualValueIsFocused {
           focusedTextField = .residualValue
        } else if lesseeGuarantyIsFocused {
            focusedTextField = .lesseeGuaranty
        }
        
        return focusedTextField
    }
    
}
    



