//
//  ContentView.swift
//  APIcalls
//
//  Created by Srivastava, Abhisht on 22/11/24.
//

import SwiftUI

struct ContentView: View {
    @State private var user : Githubuser?
    var body: some View {
        VStack(spacing : 20) {
            AsyncImage(url: URL(string: user?.avatar_url ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
                    .frame(width: 100, height: 100)
            } placeholder: {
                Circle()
                    .foregroundColor(.primary)
                    .frame(width: 100, height: 100)
                    .padding(.trailing, 240)
            }
            HStack() {
                Text(user?.login ?? "Login placeholder")
                    .bold()
                    .font(.headline)

                Spacer()

                Text("\(user?.followers ?? 0)")
                    .bold()
                    .font(.headline)
            }

            Text(user?.bio ?? "Bio placeholder")
                .padding()

            if let createdDateString = user?.created_at {
                Text("Created At: \(formattedDate(from: createdDateString))")
            }

                if let updatedDateString = user?.updated_at {
                    Text("Updated at : \(formattedDate(from: updatedDateString))")

            }
            Spacer()

        }
        .padding()
        .task {
            do {
                user = try await getUser()
            } catch GHError.invalidURL {
                print("invalids URL")
            } catch GHError.invalidResponse {
                print ("invalid response")
            } catch GHError.invalidData{
                print ("invalid data")
            } catch {
                print ("Some BKL Data")
            }
        }
    }

///Making API calls to fetch the data and handling the error at every phase

    func getUser() async throws -> Githubuser {
        let endpoint = "https://api.github.com/users/abheesht25"
        guard let url = URL(string: endpoint)
        else {
            throw GHError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let response  = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw GHError.invalidResponse
        }

        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .useDefaultKeys
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(Githubuser.self, from: data)
        } catch {
            throw GHError.invalidData
        }
    }

    ///Function converting the ISO String date to normal date

    func formattedDate(from isoDateString: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium // Example: Nov 13, 2021
        dateFormatter.timeStyle = .none

        if let date = isoFormatter.date(from: isoDateString) {
            return dateFormatter.string(from: date)
        } else {
            return "Invalid date"
        }
    }
}

#Preview {
    ContentView()
}

struct Githubuser : Codable {
    let login: String
    let avatar_url: String
    let created_at : String?
    let updated_at : String?
    let followers : Int?
    let bio : String?
}

enum GHError : Error {
    case invalidURL
    case invalidResponse
    case invalidData
}
