//
//  AboutView.swift
//  CFLTax
//
//  Created by Steven Williams on 10/29/24.
//

import SwiftUI

struct AboutView: View {
    @Bindable var myInvestment: Investment
    @Binding var isDark: Bool
    @Binding var path: [Int]
    
    @ScaledMetric var scale: CGFloat = 1
    var body: some View {
        VStack (spacing: 0) {
            HeaderView(headerType: .menu, name: "About", viewAsPct: myViewAsPct, goBack: myGoBack, withBackButton: true, withPctButton: false, path: $path, isDark: $isDark)
            Form {
                Section{
                    productNameItem
                    logoItem
                    tagLineItem
                }
               
                Section {
                    thankYouItem
                    productDetailsItem
                    privacyPolicyAndEULA
                }
                
            }
        }
        .environment(\.colorScheme, isDark ? .dark : .light)
        .navigationBarBackButtonHidden(true)
    }
    
    private func myViewAsPct() {
        
    }
    private func myGoBack() {
        self.path.removeLast()
    }

    
    var productNameItem: some View {
        HStack{
            Spacer()
            Text("CalcLPM")
                .font(.headline).fontWeight(.bold)
            Spacer()
        }
    }
    
    var thankYouItem: some View {
        HStack{
            Spacer()
            Text("Thank you for downloading CalcLPM!")
                .font(.subheadline)
            Spacer()
        }
    }
    
    var logoItem: some View {
            VStack{
                HStack {
                    Spacer()
                    Image("CalcLPM Logo")
                        .resizable()
                        .frame(width: scale * 100, height: scale * 100 , alignment: .center)
                        .padding()
                    Spacer()
                }
                HStack{
                    Text(getVersion())
                        .font(.footnote)
                }
            }
    }
    
    var tagLineItem: some View {
        HStack {
            Spacer()
            Text("U.S. tax lease pricing made easy!")
            Spacer()
        }
    }
    
    var productDetailsItem: some View {
        VStack{
            HStack {
                Spacer()
                Link("Visit CalcLPM", destination: URL(string: "https:/www.cfsoftwaresolutions.com")!)
                    .font(myFont)
                Spacer()
            }
          
        }
    }
    
    var privacyPolicyAndEULA: some View {
        HStack {
            Link("Privacy Policy", destination: URL(string: "https://www.calclpm.com/privacy-policy")!)
                .font(myFont)
                .padding(.leading, 15)
            Spacer()
            Text(" | ")
            Spacer()
            Link("Terms of Use", destination: URL(string: "https://www.calclpm.com/terms-of-use")!)
                .font(myFont)
                .padding(.trailing, 15)
        }
    }
    
    private func getVersion() -> String {
        var myVersion: String = "V."
        let myDictionary = Bundle.main.infoDictionary
        let version = myDictionary?["CFBundleShortVersionString"] as? String
        myVersion = myVersion + version!
        
        return myVersion
    }
}

#Preview {
    AboutView(myInvestment: Investment(), isDark: .constant(false), path: .constant([Int]()))
}
