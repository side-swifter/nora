//
//  ContentView.swift
//  nora
//
//  Created by Akshayraj Sanjai on 12/24/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \NoraItem.startAt, order: .forward) private var items: [NoraItem]
    
    @State private var showingAddItem = false
    @State private var selectedItem: NoraItem?
    @State private var editingItem: NoraItem?
    @State private var showingTimeBlockSheet = false
    
    #if DEBUG
    @State private var aiPingStatus: String?
    @State private var showingAIPingAlert = false
    private let aiService = AIService()
    #endif
    
    var body: some View {
        NavigationStack {
            #if DEBUG
            Text("")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Ping AI") {
                            Task {
                                do {
                                    let reply = try await aiService.ping()
                                    aiPingStatus = "✅ SUCCESS: \(reply)"
                                } catch {
                                    aiPingStatus = "❌ FAILED: \(error.localizedDescription)"
                                }
                                showingAIPingAlert = true
                            }
                        }
                    }
                }
                .alert("AI Ping Result", isPresented: $showingAIPingAlert) {
                    Button("OK") { aiPingStatus = nil }
                } message: {
                    Text(aiPingStatus ?? "")
                }
            #endif
            GeometryReader { geo in
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(greeting)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            Text(todayDateString)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Up Next")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .padding(.horizontal)
                            
                            if let nextItem = nextItem {
                                NoraItemCard(
                                    item: nextItem,
                                    style: .hero,
                                    onTap: {
                                        selectedItem = nextItem
                                    },
                                    onEdit: {
                                        editingItem = nextItem
                                    }
                                )
                                .padding(.horizontal)
                            } else {
                                Text("Nothing upcoming")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, minHeight: 110, alignment: .leading)
                                    .padding(.horizontal, 20)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(24)
                                    .padding(.horizontal)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Upcoming")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .padding(.horizontal)
                            
                            if todayItems.isEmpty {
                                Text("No items scheduled")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, minHeight: 60, alignment: .leading)
                                    .padding(.horizontal, 16)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                                    .padding(.horizontal)
                            } else {
                                VStack(spacing: 12) {
                                    ForEach(todayItems) { item in
                                        NoraItemCard(
                                            item: item,
                                            style: .compact,
                                            onTap: {
                                                selectedItem = item
                                            },
                                            onEdit: {
                                                editingItem = item
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .frame(minHeight: geo.size.height, alignment: .topLeading)
                    .padding(.bottom, 120)
                }
                .frame(maxWidth: .infinity)
            }
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 12) {
                    Button(action: {
                        showingTimeBlockSheet = true
                    }) {
                        Text("Time-block with Nora")
                            .font(.headline)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue, lineWidth: 2)
                            )
                            .cornerRadius(12)
                    }
                    
                    Button(action: { showingAddItem = true }) {
                        Text("Tell Nora")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
                .background(
                    LinearGradient(
                        colors: [Color(.systemBackground).opacity(0), Color(.systemBackground)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 120)
                    .offset(y: 60)
                )
            }
            .sheet(isPresented: $showingAddItem) {
                AddItemView()
            }
            .sheet(item: $selectedItem) { item in
                NoraItemDetailView(item: item)
            }
            .sheet(item: $editingItem) { item in
                NavigationStack {
                    AddItemView(mode: .edit, itemToEdit: item)
                }
            }
            .fullScreenCover(isPresented: $showingTimeBlockSheet) {
                TimeBlockFlowView()
            }
        }
    }
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12:
            return "Good Morning"
        case 12..<17:
            return "Good Afternoon"
        default:
            return "Good Evening"
        }
    }
    
    private var todayDateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: Date())
    }
    
    private var nextItem: NoraItem? {
        let now = Date()
        let upcoming = items.filter { $0.startAt >= now }.sorted(by: { $0.startAt < $1.startAt })
        return upcoming.first
    }
    
    private var todayItems: [NoraItem] {
        let calendar = Calendar.current
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)
        let endOfToday = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: now) ?? now
        
        return items.filter { item in
            item.startAt >= startOfToday && item.startAt <= endOfToday
        }.sorted(by: { $0.startAt < $1.startAt })
    }
}

#Preview {
    ContentView()
        .modelContainer(for: NoraItem.self, inMemory: true)
}
