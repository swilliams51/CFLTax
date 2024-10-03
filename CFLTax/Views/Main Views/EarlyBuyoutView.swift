//
//  EarlyBuyoutView.swift
//  CFLTax
//
//  Created by Steven Williams on 9/26/24.
//

import SwiftUI

struct EarlyBuyoutView: View {
    @Bindable var myInvestment: Investment
    @Binding var path: [Int]
    @Binding var isDark: Bool
    @Binding var currentFile: String
    @Binding var minimumEBOAmount: Decimal
    @Binding var maximumEBOAmount: Decimal
   
    @State private var alertTitle: String = ""
    @State private var amountColor: Int = 1
    @State private var parValuePremium: Decimal = 0.0
    @State private var basisPoints: Double = 0.00
    @State private var baseYield: Decimal = 0.05
    @State private var calculatedButtonPressed: Bool = true
    @State private var eboTerm: Int = 42
    @State private var editAmountStarted: Bool = false
    @State private var myEBO: EarlyBuyout = EarlyBuyout()
    @State private var myEBOHelp = eboHelp
    @State private var myEBOHelp2 = eboHelp2
    @State private var parValue: String = "0.00"
    @State private var premiumIsSpecified = false
    @State private var rentDueIsPaid = true
    @State private var showAlert: Bool = false
    @State private var showPopover: Bool = false
    @State private var showPopover2: Bool = false
    @State private var stepBps: Double = 1.0
    @State private var stepValue: Int = 1
   
    @FocusState private var amountIsFocused: Bool
    private let pasteBoard = UIPasteboard.general
    
    var defaultInactive: Color = Color.theme.inActive
    var defaultCalculated: Color = Color.theme.calculated
    var activeButton: Color = Color.theme.accent
    var standard: Color = Color.theme.active
    
    var body: some View {
        Form {
            Section (header: Text("Exercise Date").font(.footnote)) {
                eboTermInMonsRow
                exerciseDateRow
                parValueOnDateRow
                fullTermYieldRow
            }
            
            Section (header: Text("EBO Amount").font(.footnote)) {
                eboAmountRow
                interestRateAdderRow
                basisPointsStepperRow2
                if premiumIsSpecified == false {
                    if self.calculatedButtonPressed == true {
                        self.calculatedResultItemRow
                    } else {
                        calculatedButtonItemRow
                    }
                    
                } else {
                    specifiedItemRow
                }
            }
            
            
            Section(header: Text("Submit Form")) {
                SubmitFormButtonsView(cancelName: "Cancel", doneName: "Done", cancel: myCancel, done: myDone, isDark: $isDark)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BackButtonView(path: $path, isDark: $isDark)
            }
        }
        .environment(\.colorScheme, isDark ? .dark : .light)
        .navigationBarTitle("Asset")
        .navigationBarBackButtonHidden(true)
        .onAppear {
            
            self.myEBO = self.myInvestment.earlyBuyout
            self.baseYield = self.myInvestment.getMISF_AT_Yield()
            self.eboTerm = myEBO.getEBOTermInMonths(aInvestment: myInvestment)
            self.parValue = myInvestment.getParValue(askDate: myEBO.exerciseDate).toString(decPlaces: 4)
            setMaxAndMinEBOAmount()
           
        }
    }
    
    private func setMaxAndMinEBOAmount() {
        self.minimumEBOAmount = self.parValue.toDecimal()
        self.maximumEBOAmount = self.myInvestment.solveForEBOAmount(aEBO: myEBO, aBaseYield: baseYield, bpsSpread: 500.0)
    }
    
    private func myCancel() {
        path.removeLast()
    }
    
    private func myDone() {
        submitForm()
        path.removeLast()
    }
}

#Preview {
    EarlyBuyoutView(myInvestment: Investment(), path: .constant([Int]()), isDark: .constant(false), currentFile: .constant("File is New"), minimumEBOAmount: .constant(0.0), maximumEBOAmount: .constant(0.0))
}

//Section Exercise Date
extension EarlyBuyoutView {
    var eboTermInMonsRow: some View {
        HStack {
            Text("term in mons: \(eboTerm)")
                .font(.subheadline)
            Stepper(value: $eboTerm, in: rangeBaseTermMonths, step: getStep()) {
    
            }.onChange(of: eboTerm) { oldTerm, newTerm in
                let noOfPeriods: Int = newTerm / (12 / self.myInvestment.leaseTerm.paymentFrequency.rawValue)
                self.myEBO.exerciseDate = self.myInvestment.getExerciseDate(eboTermInMonths: noOfPeriods)
                self.basisPoints = 0.0
            }
        }
        .font(.subheadline)
    }
    
    var exerciseDateRow: some View {
        HStack {
            Text("exercise date:")
                .font(.subheadline)
            Image(systemName: "questionmark.circle")
                .foregroundColor(Color.black)
                .onTapGesture {
                    self.showPopover = true
                }
            Spacer()
            Text(myEBO.exerciseDate.toStringDateShort(yrDigits: 4))
                .font(.subheadline)
                
                .onChange(of: myEBO.exerciseDate) { oldDate, newDate in
                    self.parValue = self.myInvestment.getParValue(askDate: newDate).toString()
                    self.myEBO.amount = self.parValue
                    setMaxAndMinEBOAmount()
                }
        }
    }
    
    var parValueOnDateRow: some View {
        HStack {
            Text("par value on date:")
                .font(.subheadline)
            Spacer()
            Text(amountFormatter(amount: parValue, locale: myLocale))
                .font(.subheadline)
        }
    }
    
    var fullTermYieldRow: some View {
        HStack {
            Text("full term yield:")
                .font(.subheadline)
            Spacer()
            Text("\(percentFormatter(percent: baseYield.toString(decPlaces: 5), locale: myLocale, places: 2))")
        }
    }
}

extension EarlyBuyoutView {
    var eboAmountRow: some View {
        HStack {
            Text(premiumIsSpecified ? "adder to par value:" : "adder to full term yield:")
                .font(.subheadline)
            Image(systemName: "questionmark.circle")
                .foregroundColor(Color.theme.accent)
                .onTapGesture {
                    self.showPopover2 = true
                }
            Spacer()
            Toggle("is calculated", isOn: $premiumIsSpecified)
                .labelsHidden()
                .onChange(of: premiumIsSpecified) { oldValue, newValue in
                    if newValue == true {
                        self.basisPoints = (myInvestment.getEBOPremium(aEBO: myEBO)).toDouble()
                        self.amountColor = 0
                    } else {
                        self.basisPoints = 0.00
                        self.myEBO.amount = self.parValue
                        self.amountColor = 1
                    }
                }
        }
    }
    
    //Row 2
    var interestRateAdderRow: some View {
        VStack {
            HStack {
                Text("adder to MISF AT Yield:")
                    .font(.subheadline)
                    .foregroundColor(premiumIsSpecified ? defaultInactive : defaultCalculated)
                Spacer()
                Text("\(basisPoints, specifier: "%.0f") bps")
                    .font(.subheadline)
                    .foregroundColor(premiumIsSpecified ? defaultInactive : defaultCalculated)
            }
            
            Slider(value: $basisPoints, in: 0...maxEBOSpread.toDouble(), step: stepBps) { editing in
                self.amountColor = 1
                self.calculatedButtonPressed = false
            }

            .disabled(premiumIsSpecified ? true : false)
        }
    }
    
    var parValueAdderRow: some View {
        VStack {
            HStack{
                Text("adder to par value:")
                Spacer()
                Text("\(parValuePremium) $1.00")
                    .font(.subheadline)
                    .foregroundColor(premiumIsSpecified ? defaultInactive : defaultCalculated)
                    
            }
            
        }
    }
    
    var basisPointsStepperRow2: some View {
        HStack {
            Spacer()
            Stepper("", value: $basisPoints, in: 0...maxEBOSpread.toDouble(), step: 1, onEditingChanged: { _ in
                self.calculatedButtonPressed = false
            }).labelsHidden()
            .transformEffect(.init(scaleX: 1.0, y: 0.9))
        }
    }
    
    //Row 3a
    var calculatedButtonItemRow: some View {
        HStack{
            Button(action: {
                self.myEBO.amount = self.myInvestment.solveForEBOAmount(aEBO: myEBO, aBaseYield: baseYield, bpsSpread: basisPoints).toString(decPlaces: 6)
                self.calculatedButtonPressed = true
                self.editAmountStarted = false
            }) {
                Text("calculate")
                    .font(.subheadline)
            }
            Spacer()
            
            Text("\(eboFormatted(editStarted:editAmountStarted))")
                .font(.subheadline)
        }
    }
    
    var calculatedResultItemRow: some View {
        HStack {
            Text(basisPoints == 0 ? "par value:" : "calculated ebo:")
                .font(.subheadline)
            Spacer()
            Text("\(eboFormatted(editStarted:editAmountStarted))")
                .font(.subheadline)
        }
    }
    
    //Row 3b
    var specifiedItemRow: some View {
        HStack {
            Text("Specified Amount:")
                .font(myFont2)
            Spacer()
            Text("\(amountFormatter(amount: myEBO.amount, locale: myLocale))")
                .font(myFont2)
                .onTapGesture {
                    path.append(44)
                }
        }
    }
    
    func eboFormatted(editStarted: Bool) -> String {
        if editStarted == true {
            return self.myEBO.amount
        } else {
            return amountFormatter(amount: self.myEBO.amount, locale: myLocale)
        }
    }
    
    func getAlert() -> Alert{
        return Alert(title: Text(alertTitle))
    }
    
    func getStep() -> Int {
        switch self.myInvestment.leaseTerm.paymentFrequency {
        case .monthly:
            return 1
        case .quarterly:
            return 3
        case .semiannual:
            return 6
        default:
            return 12
        }
    }
    
    func submitForm (){
        self.myInvestment.earlyBuyout = self.myEBO
    }

    
    var rangeBaseTermMonths: ClosedRange<Int> {
        let starting: Int = 12
        let ending: Int = myInvestment.getBaseTermInMonths() - 12
        
        return starting...ending
    }
    
    
}
