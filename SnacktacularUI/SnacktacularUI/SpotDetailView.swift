//
//  SpotDetailView.swift
//  SnacktacularUI
//
//  Created by Roi Jacob on 7/27/25.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct SpotDetailView: View {
    @FirestoreQuery(collectionPath: "spots") var photos: [Photo]
    @State var spot: Spot // pass in value from ListView
    @State private var photoSheetIsPresented = false
    @State private var showingAlert = false // Alert user if they need to save Spot before adding a Photo
    @State private var alertMessage = "Cannot add a Photo until you save the Spot."
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Group {
                TextField("name", text: $spot.name)
                    .font(.title)
                    .autocorrectionDisabled()
                
                TextField("address", text: $spot.address)
                    .font(.title2)
                    .autocorrectionDisabled()
            }
            .textFieldStyle(.roundedBorder)
            .overlay {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(.gray.opacity(0.5), lineWidth: 2)
            }
            .padding(.horizontal)
            
            Button { // Photo Button
                if spot.id == nil { // Ask if you want to save
                    showingAlert.toggle()
                } else { // Go right to PhotoView
                    photoSheetIsPresented.toggle()
                }
            } label: {
                Image(systemName: "camera.fill")
                Text("Photo")
            }
            .bold()
            .buttonStyle(.borderedProminent)
            .tint(.snack)
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(photos) { photo in
                        let url = URL(string: photo.imageURLString)
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipped()
                        } placeholder: {
                            ProgressView()
                        }
                    }
                }
            }
            .frame(height: 80)
            
            Spacer()
        }
        .navigationBarBackButtonHidden()
        .task {
            $photos.path = "spots/\(spot.id ?? "")/photos"
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    saveSpot()
                    dismiss()
                }
            }
        }
        .alert(alertMessage, isPresented: $showingAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Save") {
                // We want to return spot.id after saving a new Spot. Right now it's nil
                Task {
                    guard let id = await SpotViewModel.saveSpot(spot: spot) else {
                        print("😡 ERROR: Saving spot in alert returned nil")
                        return
                    }
                    spot.id = id
                    print("spot.id: \(id)")
                    photoSheetIsPresented.toggle() // Now open sheet & move to PhotoView
                }
            }
        }
        .fullScreenCover(isPresented: $photoSheetIsPresented) {
            PhotoView(spot: spot)
        }
    }
    
    func saveSpot() {
        Task {
            guard let id = await SpotViewModel.saveSpot(spot: spot) else {
                print("😡 ERROR: Saving spot from Save button")
                return
            }
            print("spot.id: \(id)")
            print("😎 Nice spot save!")
        }
    }
}

#Preview {
    NavigationStack {
        SpotDetailView(spot: Spot(id: "1", name: "Boston Public Market", address: "Boston, MA"))
    }
}
