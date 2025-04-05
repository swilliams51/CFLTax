//
//  LeaseTermView.swift
//  CFLTax
//
//  Created by Steven Williams on 8/9/24.
//

import SwiftUI

struct LeaseTermView: View {
    @Bindable var myInvestment: Investment
    @Binding var path: [Int]
    @Binding var isDark: Bool
    @Binding var currentFile: String
    
    @State var myLeaseTerm = LeaseTerm()
    @State var baseCommenceDate: Date = Date()
    @State var myPaymentFrequency: Frequency = .monthly
    @State var paymentFrequencyOnEntry: Frequency = .monthly
    @State var endOfMonthRule: Bool = false
    @State var baseTermInMonths: Int = 12
    @State var rangeOfDates: ClosedRange<Date> = Date()...Date()
    
    //Alerts and Popovers
    @State private var showPop1: Bool = false
    @State private var showPop2: Bool = false
    @State private var showPop3: Bool = false
    @State private var baseHelp: Help = baseTermHelp
    @State private var eomRuleHelp = leaseTermEOMRuleHelp
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderView(headerType: .menu, name: "Lease Term", viewAsPct: myViewAsPct, goBack: myGoBack, withBackButton: true, withPctButton: false, path: $path, isDark: $isDark)
            Form {
                Section (header: Text("Details").font(myFont), footer: (Text("File Name: \(currentFile)").font(myFont))) {
                    paymentFrequencyItem
                        .padding(.bottom, 5)
                    baseCommenceDateItem
                        .padding(.top, 5)
                        .padding(.bottom, 5)
                    eomRuleItem
                        .padding(.bottom, 5)
                    baseTermInMonthsItem
                        .padding(.bottom, 5)
                }
                Section(header: Text("Submit Form")) {
                    SubmitFormButtonsView(cancelName: "Cancel", doneName: "Done", cancel: myCancel, done: myDone, isFocused: false, isDark: $isDark)
                }
            }
        }
        .environment(\.colorScheme, isDark ? .dark : .light)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            self.myLeaseTerm.makeEqualTo(myInvestment.leaseTerm)
            self.baseCommenceDate = myInvestment.leaseTerm.baseCommenceDate
            self.paymentFrequencyOnEntry = myInvestment.leaseTerm.paymentFrequency
            self.rangeOfDates = getRangeOfBaseTermCommenceDates()
        }
    }
    
    var baseCommenceDateItem: some View {
        HStack{
            Text("Base Start:")
                .font(myFont)
            Image(systemName: "questionmark.circle")
                .foregroundColor(.blue)
                .onTapGesture {
                    self.showPop1.toggle()
                }
            Spacer()
            DatePicker("", selection: $baseCommenceDate, in: rangeOfDates, displayedComponents:[.date])
                .transformEffect(.init(scaleX: 1.0, y: 0.90))
                .environment(\.locale, myLocale)
                .font(myFont)
        }
        .disabled(false)
        .popover(isPresented: $showPop1) {
            PopoverView(myHelp: $baseHelp, isDark: $isDark)
        }
    }
    
    var paymentFrequencyItem: some View {
        HStack {
            Text("Frequency:")
                .font(myFont)
            Picker(selection: $myPaymentFrequency, label: Text("")) {
                ForEach(Frequency.allCases, id: \.self) { item in
                   Text(item.toString())
                        .font(myFont)

               }
            }
            .onChange(of: myPaymentFrequency) { oldValue, newValue in
                rangeOfDates = getRangeOfBaseTermCommenceDates()
            }
        }
    }
    
    var eomRuleItem: some View {
        HStack{
            Toggle(isOn: $endOfMonthRule) {
                HStack {
                    Text("EOM Rule:")
                        .font(myFont)
                    Image(systemName: "questionmark.circle")
                        .foregroundColor(.blue)
                        .onTapGesture {
                            self.showPop2.toggle()
                        }
                }
            }
        }
        .popover(isPresented: $showPop2) {
            PopoverView(myHelp: $eomRuleHelp, isDark: $isDark)
        }
    }
    
    var baseTermInMonthsItem: some View {
        HStack{
            Text("Base Term:")
                .font(myFont)
            Image(systemName: "questionmark.circle")
                .foregroundColor(.blue)
                .onTapGesture {
                    self.showPop3.toggle()
                }
            Spacer()
            Text("\(myInvestment.getBaseTermInMonths())")
                .font(myFont)
            
        }
        .popover(isPresented: $showPop3) {
            PopoverView(myHelp: $baseHelp, isDark: $isDark)
        }
    }
    
    private func myViewAsPct() {
        
    }
    private func myGoBack() {
        self.path.removeLast()
    }
    
    func myCancel() {
        path.removeLast()
    }
    
    func myDone() {
        self.myLeaseTerm.baseCommenceDate = baseCommenceDate
        self.myLeaseTerm.endOfMonthRule = endOfMonthRule
        self.myLeaseTerm.paymentFrequency = myPaymentFrequency
        
        self.myInvestment.changeState = myLeaseTerm.changeComparedTo(myInvestment.leaseTerm)
        
        if myInvestment.changeState != .none {
            myInvestment.leaseTerm.makeEqualTo(myLeaseTerm)
        }
        
        if baseCommenceDate.isNotEqualTo(date: myInvestment.asset.fundingDate) {
            myInvestment.resetForBaseTermCommenceDateChange()
        }
        path.removeLast()
    }
    
    func getRangeOfBaseTermCommenceDates() -> ClosedRange<Date> {
        let start: Date = baseCommenceDate
        var maxInterim: Int

        switch myPaymentFrequency {
        case .quarterly:
            maxInterim = 3
        case .semiannual:
            maxInterim = 6
        case .annual:
            maxInterim = 12
        default:
            maxInterim = 3
        }

        let end: Date = addPeriodsToDate(dateStart: start, payPerYear: .monthly, noOfPeriods: maxInterim, referDate: start, bolEOMRule: myInvestment.leaseTerm.endOfMonthRule)

        return start...end
    }
    
}

#Preview {
    LeaseTermView(myInvestment: Investment(), path: .constant([Int]()), isDark: .constant(false), currentFile: .constant("File is New"))
}


