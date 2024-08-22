//Async Await with SwiftUI

import SwiftUI
import Foundation

// MARK: - Model Definitions

struct Hotel: Codable, Identifiable {
    let id: Int
    let name: String
    let cuisine: String
}

struct AdditionalInfo: Codable {
    let title: String
}

// MARK: - Network Service

class NetworkService {
    static let shared = NetworkService()

    private init() {}

    // Asynchronously fetch hotels from a JSON endpoint
    func fetchHotels() async throws -> [Hotel] {
        let url = URL(string: "https://raw.githubusercontent.com/janeshsutharios/REST_GET_API/main/HotelsList.json")!
        let (data, _) = try await URLSession.shared.data(from: url)
        do  {
            let results = try JSONDecoder().decode([Hotel].self, from: data)
            return results
        } catch {
            print("Error in fetching hotels:", error)
            return []
        }
    }

    // Asynchronously fetch additional information from another JSON endpoint
    func fetchAdditionalInfo() async throws -> [AdditionalInfo] {
        let url = URL(string: "https://raw.githubusercontent.com/janeshsutharios/REST_GET_API/main/get.json")!
        let (data, _) = try await URLSession.shared.data(from: url)
        do {
            return try JSONDecoder().decode([AdditionalInfo].self, from: data)
        } catch {
            print("Error in fetching additional info:", error)
            return []
        }
    }
}

// MARK: - View Model

@MainActor
class HotelViewModel: ObservableObject {
    @Published var hotels: [Hotel] = []
    @Published var additionalInfo: [AdditionalInfo] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private var tasks: [Task<Void, Never>] = []

    // Fetch data from NetworkService
    func fetchData() {
        guard #available(iOS 15.0, *) else { return }

        isLoading = true
        cancelTasks() // Cancel any existing tasks

        // Task to fetch hotels
        let fetchHotelsTask = Task {
            do {
                let hotels = try await NetworkService.shared.fetchHotels()
                self.hotels = hotels
            } catch {
                if !Task.isCancelled {
                    self.errorMessage = "Failed to fetch hotels: \(error.localizedDescription)"
                }
            }
        }

        // Task to fetch additional info
        let fetchAdditionalInfoTask = Task {
            do {
                let additionalInfo = try await NetworkService.shared.fetchAdditionalInfo()
                self.additionalInfo = additionalInfo
            } catch {
                if !Task.isCancelled {
                    self.errorMessage = "Failed to fetch additional info: \(error.localizedDescription)"
                }
            }
        }

        // Store tasks for cancellation and completion handling
        tasks = [fetchHotelsTask, fetchAdditionalInfoTask]

        // Wait for both tasks to complete before setting isLoading to false
        Task {
            await fetchHotelsTask.value
            await fetchAdditionalInfoTask.value
            self.isLoading = false
        }
    }

    // Cancel all ongoing tasks
    func cancelTasks() {
        tasks.forEach { $0.cancel() }
        tasks.removeAll()
    }
}

// MARK: - Content View

struct ContentView: View {
    @StateObject private var viewModel = HotelViewModel()

    var body: some View {
        NavigationView {
            VStack {
                // Show loading indicator while fetching data
                if viewModel.isLoading {
                    ProgressView("Loading...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .onDisappear {
                            viewModel.cancelTasks() // Cancel the tasks if the view disappears
                        }
                }
                // Show error message if data fetching fails
                else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
                // Display fetched additional info and hotels list
                else {
                    Text(viewModel.additionalInfo.first?.title ?? "No additional info")
                        .font(.headline)
                        .padding()
                    
                    List(viewModel.hotels) { hotel in
                        VStack(alignment: .leading) {
                            Text(hotel.name)
                                .font(.headline)
                            Text(hotel.cuisine)
                                .font(.subheadline)
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
            .navigationTitle("Hotels")
            .onAppear {
                viewModel.fetchData() // Fetch data when view appears
            }
            .onDisappear {
                viewModel.cancelTasks() // Cancel tasks when view disappears
            }
        }
    }
}

// MARK: - App Entry Point

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
