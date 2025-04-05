//
//  ContentView.swift
//  CFLTax
//
//  Created by Steven Williams on 8/8/24.
//

import SwiftUI
import FirebaseAnalytics
import RevenueCat
import RevenueCatUI

struct HomeView: View {
    @State public var myInvestment: Investment = Investment(aFile: sampleFile, resetDates: true)
    @State public var path: [Int] = [Int]()
    @State public var isDark: Bool = false
    @State var selectedGroup: Group = Group()
    @State var index: Int = 0
    @State var myDepreciationSchedule: DepreciationIncomes = DepreciationIncomes()
    @State var myRentalSchedule: RentalCashflows = RentalCashflows()
    @State var myTaxableIncomes: AnnualTaxableIncomes = AnnualTaxableIncomes()
    @State var myAnnualizedRent: AnnualizedRentalCashflows = AnnualizedRentalCashflows()
    
    @State var isLoading: Bool = false
    @State private var fileMenuIsDisabled : Bool = false
    @State private var myFeeAmortization: FeeIncomes = FeeIncomes()
    @State private var isShowingCalculationErrorAlert: Bool = false
    @State private var currentFile: String = "File is New"
    @State private var maximumEBOAmount: Decimal = 0.0
    @State private var minimumEBOAmount: Decimal = 0.0
    @State private var showPop1: Bool = false
    @State private var showPop2: Bool = false
    @State private var showPop3: Bool = false
    @State private var feeHelp = feeHomeHelp
    @State private var eboHelp = eboHomeHelp
    @State private var calculationHelp = calculateHomeHelp
    @AppStorage("darkMode") var darkMode: Bool = false

    var body: some View {
        NavigationStack (path: $path){
            ZStack {
                VStack (spacing: 0) {
                    HeaderView(headerType: .home, name: "Home", viewAsPct: myViewAsPct, goBack: myGoBack, withBackButton: false, withPctButton: false, path: $path, isDark: $isDark)
                    Form {
                        Section(header: Text("Parameters"), footer: (Text("File Name: \(currentFile)"))) {
                            assetItem
                            LeaseTermItem
                            rentItem
                            depreciationItem
                            taxAssumptionsItem
                            if self.myInvestment.feeExists {
                                feeItem
                            }
                            if self.myInvestment.earlyBuyoutExists {
                                eboItem
                            }
                            economicsItem
                        }
                        Section(header: Text("Results")) {
                            calculatedItem
                            subMenuItem
                        }
                    }
                }
                if isLoading {
                    ProgressView()
                        .scaleEffect(3)
                }
            }
            .presentPaywallIfNeeded(requiredEntitlementIdentifier: "All Access")
            .analyticsScreen(name: "Home")
            .toolbar{
                ToolbarItem(placement: .bottomBar) {
                    Menu(content: {
                        removeItemsMenu
                    }, label: {
                        Image(systemName: "minus.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundColor(ColorTheme().accent)
                            .opacity(fileMenuIsDisabled ? 0.5 : 1.0)
                    })
                }
               
                ToolbarItem(placement: .bottomBar) {
                    Menu(content: {
                        addItemsMenu
                    }, label: {
                        Image(systemName: "plus.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundColor(ColorTheme().accent)
                            .opacity(fileMenuIsDisabled ? 0.5 : 1.0)
                    })
                    .disabled(fileMenuIsDisabled)
                }
            }
            .environment(\.colorScheme, isDark ? .dark : .light)
            .navigationDestination(for: Int.self) { selectedView in
                ViewsManager(myInvestment: myInvestment, myDepreciationSchedule: myDepreciationSchedule, myRentalSchedule: myRentalSchedule, myTaxableIncomes: myTaxableIncomes, myFeeAmortization: myFeeAmortization, myAnnualizedRent: myAnnualizedRent, path: $path, isDark: $isDark, selectedGroup: $selectedGroup, currentFile: $currentFile, minimumEBOAmount: $minimumEBOAmount, maximumEBOAmount: $maximumEBOAmount, selectedView: selectedView)
            }
            .onAppear{
                self.isLoading = false
                if self.myInvestment.changeState == .material {
                    if self.myInvestment.earlyBuyoutExists {
                        self.myInvestment.removeEBO()
                    }
                    fileMenuIsDisabled = true
                } else if self.myInvestment.changeState == .immaterial{
                    fileMenuIsDisabled = true
                } else {
                    fileMenuIsDisabled = false
                }
                if self.darkMode == true {
                    isDark = true
                }
            }
            .popover(isPresented: $showPop1) {
                PopoverView(myHelp: $feeHelp, isDark: $isDark)
            }
            .popover(isPresented: $showPop2) {
                PopoverView(myHelp: $eboHelp, isDark: $isDark)
            }
            
            .popover(isPresented: $showPop3){
                PopoverView(myHelp: $calculationHelp, isDark: $isDark)
            }
            .alert(isPresented: $isShowingCalculationErrorAlert) {
                Alert(title: Text("Calculation Error"), message: Text(alertCalculationError), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func myViewAsPct() {
        
    }
    private func myGoBack() {
       
    }
    
    var assetItem: some View {
        HStack {
            Text("Asset")
                .font(myFont)
            Spacer()
            Image(systemName: "chevron.right")
        }
        .contentShape(Rectangle())
        .onTapGesture {
            path.append(1)
        }
    }
    
    var LeaseTermItem: some View {
        HStack {
            Text("Lease Term")
                .font(myFont)
            Spacer()
            Image(systemName: "chevron.right")
        }
        .contentShape(Rectangle())
        .onTapGesture {
            path.append(2)
        }
    }
    
    var rentItem: some View {
        HStack {
            Text("Rent")
                .font(myFont)

            Spacer()
            Image(systemName: "chevron.right")
        }
        .contentShape(Rectangle())
        .onTapGesture {
            path.append(3)
        }
    }
    
    var depreciationItem: some View {
        HStack {
            Text("Depreciation")
                .font(myFont)
            Spacer()
            Image(systemName: "chevron.right")
        }
        .contentShape(Rectangle())
        .onTapGesture {
            path.append(4)
        }
    }
    
    var taxAssumptionsItem: some View {
        HStack{
            Text("Tax Assumptions")
                .font(myFont)
            Spacer()
            Image(systemName: "chevron.right")
        }
        .contentShape(Rectangle())
        .onTapGesture {
            path.append(5)
        }
    }
    
    var feeItem: some View {
        HStack{
            Text("Fee")
                .font(myFont)
            Image(systemName: "questionmark.circle")
                .font(myFont)
                .foregroundColor(.blue)
                .onTapGesture {
                    self.showPop1 = true
                }
            Spacer()
            Image(systemName: "chevron.right")
        }
        .contentShape(Rectangle())
        .onTapGesture {
            path.append(6)
        }
    }
    
    var eboItem: some View {
        HStack{
            Text("Early Buyout")
                .font(myFont)
            Image(systemName: "questionmark.circle")
                .font(myFont)
                .foregroundColor(.blue)
                .onTapGesture {
                    self.showPop2 = true
                }
            Spacer()
            Image(systemName: "chevron.right")
        }
        .contentShape(Rectangle())
        .onTapGesture {
            self.isLoading = true
            Task {
                await goToEBOView()
            }
        }
    }
    
    var economicsItem: some View {
        HStack{
            Text("Economics")
                .font(myFont)
            Spacer()
            Image(systemName: "chevron.right")
        }
        .contentShape(Rectangle())
        .onTapGesture {
            path.append(7)
        }
    }
    
    var calculatedItem: some View {
        HStack{
            Text("Calculate:")
                .font(myFont)
            Image(systemName: "questionmark.circle")
                .font(myFont)
                .foregroundColor(.blue)
                .onTapGesture {
                    self.showPop3 = true
                }
            Text("\(myInvestment.economics.solveFor.toString())")
                .font(myFont)
            Spacer()
            Image(systemName: "return")
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if myInvestment.isSolveForValid() {
                self.isLoading = true
                self.myInvestment.changeState = .none
                self.fileMenuIsDisabled = false
                Task {
                    await goToResultsView()
                }
            } else {
                self.isShowingCalculationErrorAlert = true
                self.isLoading = false
            }
           
        }
    }
    
    var subMenuItem: some View {
        HStack{
            Text("File Menu")
                .font(myFont)
                .foregroundColor(fileMenuIsDisabled ? Color("InvestChangedTrue") : Color("InvestChangedFalse"))
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(fileMenuIsDisabled ? Color("InvestChangedTrue") : Color("InvestChangedFalse"))
        }
        .contentShape(Rectangle())
        .onTapGesture {
            path.append(26)
        }
        .disabled(fileMenuIsDisabled ? true : false)
    }
    
    
    private func goToEBOView() async {
        try? await Task.sleep(nanoseconds: 500_000_000)
        self.path.append(8)
    }
    
    private func goToResultsView() async {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        self.path.append(25)
    }
    
//    private func resetInvestment() {
//        myInvestment.hasChanged = false
//        if myInvestment.feeExists {
//            myInvestment.fee.hasChanged = false
//        }
//        if myInvestment.earlyBuyoutExists {
//            myInvestment.earlyBuyout.hasChanged = false
//        }
//    }
    
//    private func calculate() {
//        if myInvestment.isSolveForValid() {
//           
//            myInvestment.hasChanged = false
//            if myInvestment.feeExists {
//                myInvestment.fee.hasChanged = false
//            }
//            if myInvestment.earlyBuyoutExists {
//                myInvestment.earlyBuyout.hasChanged = false
//            }
//            
//            Task {
//                await goToResultsView()
//            }
//            self.isLoading = false
//        } else {
//            self.isShowingCalculationErrorAlert = true
//            self.isLoading = false
//        }
//    }
//    
//    private func calculate2() async {
//        if myInvestment.isSolveForValid() {
//            myInvestment.hasChanged = false
//            if myInvestment.feeExists {
//                myInvestment.fee.hasChanged = false
//            }
//            if myInvestment.earlyBuyoutExists {
//                myInvestment.earlyBuyout.hasChanged = false
//            }
//            
//           // await goToResultsView()
//            self.path.append(25)
//            self.isLoading = false
//        } else {
//            self.isShowingCalculationErrorAlert = true
//            self.isLoading = false
//        }
//    }
    
//    private func investmentHasChanged() -> Bool {
//        if myInvestment.hasChanged {
//            return true
//        }
//        if myInvestment.fee.hasChanged {
//            return true
//        }
//        if myInvestment.earlyBuyout.hasChanged {
//            return true
//        }
//        
//        return false
//    }
    
}




#Preview {
    HomeView(myInvestment: Investment())
}




extension HomeView {
    var removeItemsMenu: some View {
        VStack {
            if myInvestment.feeExists {
                removeFeeItem
            }
            
            if myInvestment.earlyBuyoutExists {
                removeEBOItem
            }
        }
    }
    
    var removeFeeItem: some View {
        Button(action: {
            self.myInvestment.fee.amount = "0.00"
            self.myInvestment.setFeesExistence()
            self.myInvestment.changeState = .material
        }) {
            Label("Remove Fee", systemImage: "folder.badge.minus")
                .font(myFont)
        }
    }
    
    var removeEBOItem: some View {
        Button(action: {
            self.myInvestment.earlyBuyout.amount = "0.00"
            self.myInvestment.setEBOsExistence()
            self.myInvestment.changeState = .material
        }) {
            Label("Remove Early Buyout", systemImage: "folder.badge.minus")
                .font(myFont)
        }
    }
    
    var addItemsMenu: some View {
        VStack{
            if myInvestment.feeExists == false {
                addFeeItem
            }
            if myInvestment.earlyBuyoutExists == false {
                addEBOItem
            }
        }
    }
    
    var addFeeItem: some View {
        Button(action: {
            self.myInvestment.setFeeToDefault()
            self.myInvestment.setFeesExistence()
            self.myInvestment.changeState = .immaterial
        }) {
            Label("Add Fee", systemImage: "folder.badge.plus")
                .font(myFont)
        }
    }
    
    var addEBOItem: some View {
        Button(action: {
            self.myInvestment.setEBOToDefault()
            self.myInvestment.setEBOsExistence()
            self.myInvestment.changeState = .immaterial
        }) {
            Label("Add EBO", systemImage: "folder.badge.plus")
        }
        
    }
    
    
}
