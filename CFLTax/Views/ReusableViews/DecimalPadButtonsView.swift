//
//  DecimalPadButtonsView.swift
//  CFLTax
//
//  Created by Steven Williams on 8/9/24.
//

import SwiftUI


struct DecimalPadButtonsView: View {
    let cancel: () -> Void
    let copy: () -> Void
    let paste: () -> Void
    let clear: () -> Void
    let enter: () -> Void
    @Binding var isDark: Bool
    
    var body: some View {
        HStack {
            cancelDecimalPadButton(cancel: cancel, isDark: $isDark)
            Spacer()
            helpDecimalPadItem(isDark: $isDark)
            copyDecimalPadButton(copy: copy, isDark: $isDark)
            pasteDecimalPadButton(paste: paste, isDark: $isDark)
            clearDecimalPadButton(clear: clear, isDark: $isDark)
            Spacer()
            enterDecimalPadButton(enter: enter, isDark: $isDark)
        }
        .padding(.leading, 20)
        .padding(.trailing, 20)
    }
    
}



#Preview {
    DecimalPadButtonsView(cancel: {}, copy: {}, paste: {}, clear: {}, enter: {}, isDark: .constant(false))
}


struct cancelDecimalPadButton: View {
    let cancel: () -> Void
    @Binding var isDark: Bool
    
    var body: some View {
        Button {
            cancel()
        } label: {
            Label ("", systemImage: "escape")
        }
        .tint(isDark ? .white : .red)
    }
}

struct helpDecimalPadItem: View {
    @State var showPopover: Bool = false
    @Binding var isDark: Bool
    
    var body: some View {
        Image(systemName: "questionmark.circle")
            .foregroundColor(isDark ? .white : .green)
            .onTapGesture {
                showPopover.toggle()
            }
            .padding()
            .popover(isPresented: $showPopover) {
                PopoverDecimalPadView(isDark: $isDark)
            }
    }
}

struct copyDecimalPadButton: View {
    let copy: () -> Void
    @Binding var isDark: Bool
    
    var body: some View {
        Button {
           copy()
        } label: {
            Label("", systemImage: "clipboard")
        }
        .tint(isDark ? .white : .orange)
    }
}

struct pasteDecimalPadButton: View {
    let paste: () -> Void
    @Binding var isDark: Bool
    
    var body: some View {
        Button {
            paste()
        } label: {
            Label("", systemImage: "paintbrush")
        }.tint(isDark ? .white : .purple)
    }
}

struct clearDecimalPadButton: View {
    let clear: () -> Void
    @Binding var isDark: Bool
    
    var body: some View {
        Button {
            clear()
        } label: {
            Label("", systemImage: "clear")
        }.tint(isDark ? .white : .black)
    }
}

struct enterDecimalPadButton: View {
    let enter: () -> Void
    @Binding var isDark: Bool
    
    var body: some View {
        Button {
            enter()
        } label: {
            Label("", systemImage: "return")
        }.tint(isDark ? .white : .black)
    }
    
}
