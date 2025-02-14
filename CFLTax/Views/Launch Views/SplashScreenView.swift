//
//  SplashScreenView.swift
//  CFLTax
//
//  Created by Steven Williams on 10/29/24.
//

import SwiftUI

struct SplashScreenView: View {
    private let phrase: String = "U.S. Tax Lease Pricing Made Easy!!"
    private let timer = Timer.publish(every: 0.075, on: .main, in: .common).autoconnect()
    @State private var counter: Int = 0
    @State private var banner: String = ""
    //@State private var hasTimeElapsed: Bool = false
    @Binding var showLaunchView: Bool

    var body: some View {
        ZStack {
            Color.launch.background
                .ignoresSafeArea()
            HStack {
                Text("CalcLPM")
                    .font(.largeTitle).fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .offset(y: -80)
            
            Image("CalcLPM Logo")
                .resizable()
                .frame(width: 100, height: 100).fontWeight(.heavy)
            
            HStack {
                Text(banner)
                    .font(.headline).fontWeight(.bold)
                    .foregroundColor(.white)
                    .onReceive(timer) { _ in
                        if counter <= phrase.count + 1 {
                            banner = String(phrase.prefix(counter))
                        } else if counter == phrase.count + 10 {
                            timer.upstream.connect().cancel()
                            self.showLaunchView = false
                        } else {
                            
                        }
                        counter += 1
                    }
            }
            .offset(y: 80)
        }
        .transition(AnyTransition.scale.animation(.easeIn))
    }
}

#Preview {
    SplashScreenView(showLaunchView: .constant(false))
}
