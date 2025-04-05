//
//  FileOpenView.swift
//  CFLTax
//
//  Created by Steven Williams on 9/4/24.
//

import SwiftUI

struct FileOpenView: View {
    @Bindable var myInvestment: Investment
    @Binding var currentFile: String
    @Binding var path:[Int]
    @Binding var isDark: Bool
   
    @State private var files: [String] = [String]()
    @State private var fm = LocalFileManager()
    @State private var folderIsEmpty: Bool = false
    @State private var noOfSavedFiles: Int = 0
    @State private var investmentDoc: InvestmentDocument = InvestmentDocument(investmentData: "")
    @State private var selectedFileIndex: Int = 0
    @State private var selectedFile: String = ""
    @State private var showDeleteAlert: Bool = false
    @State private var textFileLabel: String = "Files:"
    @State private var templateMode: Bool = false
    
    var body: some View {
        VStack(spacing: 0){
            HeaderView(headerType: .menu, name: "File Open", viewAsPct: myViewAsPct, goBack: myGoBack, withBackButton: true, withPctButton: false, path: $path, isDark: $isDark)
            Form {
                Section(header: Text(textFileLabel)) {
                    numberOfSavedFilesRow
                    pickerOfSavedFiles
                }
                Section(header: Text("Submit Form")){
                    deleteAndOpenTextButtonsRow
                }
            }
        }
        .environment(\.colorScheme, isDark ? .dark : .light)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            self.files = fm.listFiles(templateMode: templateMode)
            self.noOfSavedFiles = self.files.count
            if self.noOfSavedFiles == 0 {
                self.folderIsEmpty = true
            } else {
                self.selectedFile = self.files[0]
            }
        }
    }
    
    private func myViewAsPct() {
        
    }
    private func myGoBack() {
        self.path.removeLast()
    }
    
    var numberOfSavedFilesRow: some View {
        HStack {
            Text("Number Saved:")
            Spacer()
            Text("\(self.noOfSavedFiles)")
        }
        .font(myFont)
    }
    
    var pickerOfSavedFiles: some View {
        Picker(selection: $selectedFileIndex, label:
            Text(textFileLabel)
                .font(myFont)
            ){
            ForEach(0..<files.count, id: \.self) { i in
                Text(self.files[i])
                    .font(myFont)
            }
        }
        .font(myFont)
        .disabled(folderIsEmpty)
        .onChange(of: selectedFileIndex) { oldValue, newValue in
            self.selectedFile = String(self.files[selectedFileIndex])
        }
    }
    
    var deleteAndOpenTextButtonsRow: some View {
        HStack {
            Text("Delete")
                .alert(isPresented: $showDeleteAlert) {
                Alert (
                    title: Text("Are you sure you want to delete this file?"),
                    message: Text("There is no undo"),
                    primaryButton: .destructive(Text("Delete")) {
                        deleteFile()
                },
                       secondaryButton: .cancel()
                )}
            .disabled(folderIsEmpty)
            .foregroundColor(folderIsEmpty ? .gray : .accentColor)
            .onTapGesture {
                if self.folderIsEmpty == false{
                    self.showDeleteAlert.toggle()
                }
            }
            Spacer()
            Text("Open")
                .disabled(folderIsEmpty)
                .foregroundColor(folderIsEmpty ? .gray : .accentColor)
                .onTapGesture {
                    if folderIsEmpty == false {
                        openFile()
                    }
                }
        }
        .font(myFont)
    }
    
}

#Preview {
    FileOpenView(myInvestment: Investment(), currentFile: .constant("File is New"), path: .constant([Int]()), isDark: .constant(false))
}


extension FileOpenView {
    func deleteFile() {
        fm.deleteFile(fileName: self.selectedFile)
        self.myInvestment.resetToDefault()
        self.currentFile = "File is New"
        self.path.removeLast()
    }

    
    func openFile() {
        self.selectedFile = files[selectedFileIndex]
        let strFileText: String = fm.fileOpen(fileName: selectedFile)
        
        if self.selectedFile.contains("_tmp") {
            //self.myLease.openAsTemplate(strFile: strFileText)
        } else {
            self.myInvestment.resetToFileData(strFile: strFileText)
            self.myInvestment.setFeesExistence()
            self.myInvestment.setEBOsExistence()
        }
        self.currentFile = self.selectedFile
        self.path.removeAll()
    }
}
