//
//  PhotoView.swift
//  SnacktacularUI
//
//  Created by Roi Jacob on 8/2/25.
//

import SwiftUI
import PhotosUI

struct PhotoView: View {
    @State var spot: Spot // passed in from SpotDetailView
    @State private var photo = Photo()
    @State private var data = Data() // We need to take image & convert it to data to save it
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var pickerIsSelected = true
    @State private var selectedImage = Image(systemName: "photo")
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Spacer()
            
            selectedImage
                .resizable()
                .scaledToFit()
            
            Spacer()
            
            TextField("description", text: $photo.description)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Text("by: \(photo.reviewer), on: \(photo.postedOn.formatted(date: .numeric, time: .omitted))")
                
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Save") {
                            Task {
                                await PhotoViewModel.saveImage(spot: spot, photo: photo, data: data)
                                dismiss()
                            }
                        }
                    }
                }
                .photosPicker(isPresented: $pickerIsSelected, selection: $selectedPhoto)
                .onChange(of: selectedPhoto) {
                    Task {
                        do {
                            if let image = try await selectedPhoto?.loadTransferable(type: Image.self) {
                                selectedImage = image
                            }
                            // Get raw date from image so we can save it to Firebase Storage
                            guard let transferredData = try await selectedPhoto?.loadTransferable(type: Data.self) else {
                                print("😡 ERROR: Could not convert data from selectedPhoto")
                                return
                            }
                            data = transferredData
                        } catch {
                            print("😡 ERROR: Could not create Image from selectPhoto. \(error.localizedDescription)")
                        }
                    }
                }
        }
        .padding()
    }
}

#Preview {
    PhotoView(spot: Spot())
}
