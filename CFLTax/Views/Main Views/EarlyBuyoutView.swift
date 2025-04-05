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
    
    @State private var myEBO: EarlyBuyout = EarlyBuyout()
    
    @State private var amountColor: Int = 1
    @State private var parValuePremium: Decimal = 0.0
    @State private var basisPoints: Double = 0.00
    @State private var baseYield: Decimal = 0.05
    @State private var sliderOneMoved: Bool = false
    @State private var sliderTwoMoved: Bool = false
    @State private var eboTerm: Double = 12.0
    @State private var parValue: String = "0.00"

    //Alerts and Popovers
    @State private var myEBOHelp = eboHelp
    @State private var myEBOHelp2 = eboHelp2
    @State private var showAlert1: Bool = false
    @State private var showPop1: Bool = false
    @State private var showPop2: Bool = false
    @State private var isLoading: Bool = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HeaderView(headerType: .menu, name: "Early Buyout", viewAsPct: myViewAsPct, goBack: myGoBack, withBackButton: true, withPctButton: false, path: $path, isDark: $isDark)
                Form {
                    Section (header: Text("Exercise Date").font(.footnote), footer: Text("Full Term MISF A/T Yield: \(percentFormatter(percent: baseYield.toString(decPlaces: 5), locale: myLocale, places: 3))")) {
                        eboTermInMonthsRow
                        eboTermStepperRow
                        calculateEBOExerciseDateRow
                    }
                    
                    Section (header: Text("EBO Amount").font(.footnote), footer: Text("Par Value on Date: \(amountFormatter(amount: parValue, locale: myLocale, places: 2))")) {
                        //eboAmountRow
                        interestRateAdderRow
                        basisPointsStepperRow2
                        calculatedButtonItemRow
                    }
                    
                    Section(header: Text("Submit Form")) {
                        SubmitFormButtonsView(cancelName: "Cancel", doneName: "Done", cancel: myCancel, done: myDone, isFocused: getFocus(), isDark: $isDark)
                    }
                }
            }
            if self.isLoading {
                ProgressView()
                    .scaleEffect(3)
            }
            
        }
      
        .environment(\.colorScheme, isDark ? .dark : .light)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            self.myInvestment.economics.solveFor = .yield
            self.myInvestment.calculate()
            self.baseYield = myInvestment.getMISF_AT_Yield()
            self.myEBO = self.myInvestment.earlyBuyout
            self.eboTerm = myEBO.getEBOTermInMonths(aInvestment: myInvestment).toDouble()
            self.parValue = myInvestment.getParValue(askDate: myEBO.exerciseDate).toString(decPlaces: 4)
            self.basisPoints = myInvestment.getEBOPremium_bps(aEBO: myEBO, aBaseYield: self.baseYield)
        }
        .popover(isPresented: $showPop1) {
            PopoverView(myHelp: $myEBOHelp, isDark: $isDark)
        }
        .popover(isPresented: $showPop2) {
            PopoverView(myHelp: $myEBOHelp2, isDark: $isDark)
        }
    }
    
    
    var parValueOnDateRow: some View {
        HStack {
            Text("Par Value on Date:")
                .font(myFont)
            Spacer()
            Text(amountFormatter(amount: parValue, locale: myLocale))
                .font(myFont)
        }
    }
    
    private func myViewAsPct() {
        
    }
    
    private func myGoBack() {
        self.isLoading = true
        Task {
            await goBack()
        }
    }
    
    private func goBack() async{
        self.path.removeLast()
    }
    
    private func myCancel() {
        path.removeLast()
    }
    
    private func myDone() {
        submitForm()
        path.removeLast()
    }
    
    private func calculateEBO() async {
        self.myEBO.amount = self.myInvestment.solveForEBOAmount(aEBO: myEBO, aBaseYield: baseYield, bpsSpread: basisPoints).toString(decPlaces: 6)
        self.sliderTwoMoved = false
        self.isLoading = false
    }
    
    private func getFocus() -> Bool {
        var isFocused: Bool = false
        if sliderOneMoved || sliderTwoMoved {
            isFocused = true
        }
        
        return isFocused
    }
    
    
}

#Preview {
    EarlyBuyoutView(myInvestment: Investment(), path: .constant([Int]()), isDark: .constant(false), currentFile: .constant("File is New"), minimumEBOAmount: .constant(0.0), maximumEBOAmount: .constant(0.0))
}


//EBO Exercise Date
extension EarlyBuyoutView {
    var eboTermInMonthsRow: some View {
        VStack {
            HStack {
                Text("EBO Term In Months:")
                    .font(myFont)
                Spacer()
                Text("\(eboTerm.toString(decPlaces: 0))")
                    .font(myFont)
            }
            
            Slider(value: $eboTerm, in: rangeBaseTermMonths, step: getStepValue()) { editing in
                self.amountColor = 1
                self.sliderOneMoved = true
            }
            .accentColor(basisPoints < 0 ? .red : .green)
        }
    }
    
    var eboTermStepperRow: some View {
        HStack {
            Spacer()
            Stepper("", value: $eboTerm, in: rangeBaseTermMonths, step: 1, onEditingChanged: { _ in
                self.sliderOneMoved = true
                
            }).labelsHidden()
                .transformEffect(.init(scaleX: 1.0, y: 0.9))
        }
    }
    
    var calculateEBOExerciseDateRow: some View {
        HStack{
            Button(action: {
                self.myEBO.exerciseDate = self.myInvestment.getExerciseDate(eboTermInMonths: eboTerm.toInteger())
                self.parValue = self.myInvestment.getParValue(askDate: myEBO.exerciseDate).toString(decPlaces: 4)
                self.myEBO.amount = self.parValue
                self.basisPoints = myInvestment.getEBOPremium_bps(aEBO: myEBO, aBaseYield: self.baseYield)
                self.sliderOneMoved = false
            }) {
                Text(sliderOneMoved ? "Calculate" : "Exercise Date:")
                    .font(myFont)
                    .foregroundColor(sliderOneMoved ? .blue : .gray)
            }
            Image(systemName: "questionmark.circle")
                .foregroundColor(Color.blue)
                .onTapGesture {
                    self.showPop2 = true
                }
            Spacer()
            Text("\(myEBO.exerciseDate.toStringDateShort())")
                .font(myFont)
        }
    }
    
    private func getStepValue() -> Double {
        switch myInvestment.leaseTerm.paymentFrequency {
            case .monthly: return 1
        case .quarterly: return 4
        case .semiannual: return 2
        case .annual: return 12
        }
    }
}


//EBO Amount
extension EarlyBuyoutView {
    var interestRateAdderRow: some View {
        VStack {
            HStack {
                Text("MISF A/T Yield Adder:")
                    .font(myFont)
                Spacer()
                Text("\(basisPointsFormatter(basisPoints: basisPoints, locale: myLocale)) bps")
                    .font(myFont)
            }
            
            Slider(value: $basisPoints, in: -50...maxEBOSpread.toDouble(), step: 1) { editing in
                self.amountColor = 1
                self.sliderTwoMoved = true
            }
            .accentColor(basisPoints < 0 ? .red : .green)
        }
    }
    
    var basisPointsStepperRow2: some View {
        HStack {
            Spacer()
            Stepper("", value: $basisPoints, in: 0...maxEBOSpread.toDouble(), step: 1, onEditingChanged: { _ in
                self.sliderTwoMoved = true
                
            }).labelsHidden()
            .transformEffect(.init(scaleX: 1.0, y: 0.9))
        }
    }
    
    var calculatedButtonItemRow: some View {
        HStack{
            Button(action: {
                if sliderTwoMoved {
                    self.isLoading = true
                    Task {
                        await calculateEBO()
                    }
                }
            }) {
                Text(sliderTwoMoved ? "Calculate" : "EBO Amount:")
                    .font(myFont)
                    .foregroundColor(sliderTwoMoved ? .blue : .gray)
            }
            Image(systemName: "questionmark.circle")
                .foregroundColor(Color.blue)
                .onTapGesture {
                    self.showPop2 = true
                }
            Spacer()
            Text("\(amountFormatter(amount: self.myEBO.amount, locale: myLocale))")
                .font(myFont)
        }
    }

    func submitForm() {
        if self.myInvestment.earlyBuyout.isEqual(to: self.myEBO) == false {
               self.myInvestment.earlyBuyout = self.myEBO
               self.myInvestment.changeState = .immaterial
           } else {
               self.myInvestment.changeState = .none
           }
    }

    var rangeBaseTermMonths: ClosedRange<Double> {
        let starting: Int = 12
        let ending: Int = myInvestment.getBaseTermInMonths() - 12
        let start:Double = Double(starting)
        let end:Double = Double(ending)
        
        
        return start...end
    }
    
    
}
