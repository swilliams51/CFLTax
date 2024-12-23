//
//  ReportHeaderView.swift
//  CFLTax
//
//  Created by Steven Williams on 11/19/24.
//

import SwiftUI

struct ReportHeaderView: View {
    let name: String
    let viewAsPct:() -> Void
    @Binding var path: [Int]
    @Binding var isDark: Bool
    
    @State var viewAsPctOfCost: Bool = false
    @State var buttonName: String = "Back"
    @State private var isHome: Bool = false
    
    @Environment(\.verticalSizeClass) var verticalSizeClass
    var isLandscape: Bool { verticalSizeClass == .compact }
    
    var body: some View {
        ZStack {
            Color.black.opacity(isDark ? 1.0 : 0.05)
                .ignoresSafeArea()
            VStack {
                buttonItems
                headerItem
            }

        }
        .environment(\.colorScheme, isDark ? .dark : .light)
        .frame(width: getWidth(), height: getHeight())
        .onAppear {
            if self.path.count == 1 {
                buttonName = "Home"
            }
        }
    }
    
    private func getWidth() -> CGFloat {
        if isLandscape {
            return UIScreen.main.bounds.height * 2.0
        } else {
            return UIScreen.main.bounds.width
        }
    }
    
    func getHeight() -> CGFloat {
        if isLandscape {
            return UIScreen.main.bounds.width * 0.10
        } else {
            //return 75
           return UIScreen.main.bounds.height * 0.08
        }
    }
    
    var buttonItems: some View {
        HStack{
            backButtonItem
            Spacer()
            commandButtonItem
        }
        .padding(.top, 20)
        .padding(.bottom, 20)
    }
    
    var backButtonItem: some View {
        HStack {
            Button {
                self.path.removeLast()
            } label: {
                Image(systemName: "chevron.left")
                Text(buttonName)
            }
            .tint(Color("BackButtonColor"))
            .padding(.leading, 20)
            Spacer()
        }
    }
    
    var commandButtonItem: some View {
        Button(action: {
            viewAsPct()
            viewAsPctOfCost.toggle()
        }) {
            Image(systemName: "command.circle")
                .tint(viewAsPctOfCost ? Color("PercentOff") : Color("PercentOn"))
                .scaleEffect(1.2)
        }
        .padding(.trailing, 20)
    }
    
    var headerItem: some View {
        HStack {
            Text(name)
                .font(.headline)
                .fontWeight(.bold)
                .padding(.bottom, 20)
                .foregroundColor(isDark ? .white : .black)
        }
    }
    
}

#Preview {
    ReportHeaderView(name: "Header", viewAsPct: {}, path: .constant([Int]()), isDark: .constant(false))
}
