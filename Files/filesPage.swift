//
//  filesPage.swift
//  Readable
//
//  Created by Maysam alhuthail on 09/06/1447 AH.
//
import SwiftUI

struct filesPage: View {

    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @State private var searchText = ""
    @State private var showAddPopup = false

    var body: some View {
        ZStack {
            Color(.background)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 20) {

                // Top Bar
                HStack {
                    Text("Files")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(Color(hex: "17374F"))


                    Spacer()

                    // Add Button
                    Button(action: {
                        showAddPopup = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color(hex: "17374F"))
                            .clipShape(Circle())
                    }
                    .padding(.trailing, 20)
                }
                .padding(.top, 20)
                .padding(.horizontal)

                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)

                    TextField("Search File", text: $searchText)
                        .foregroundColor(.primary)

                    Image(systemName: "mic.fill")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color(.systemGray5))
                .cornerRadius(15)
                .padding(.horizontal)

                Spacer()
            }
        }
        // Pop-up
        .sheet(isPresented: $showAddPopup) {
            VStack(spacing: 20) {
                Text("Add New File")
                    .font(.title)
                    .bold()
         

                Text("Add your options or UI here…")

                Button("scan text") {
                    showAddPopup = false
                }
                .padding()
            }
            .padding()
            .presentationDetents([.medium, .large])
        }
    }
}


struct filesPage_Previews: PreviewProvider {
    static var previews: some View {
        filesPage()
            .environmentObject(SettingsViewModel())
    }
}
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")

        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)

        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255

        self.init(red: r, green: g, blue: b)
    }
}
