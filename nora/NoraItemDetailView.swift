//
//  NoraItemDetailView.swift
//  nora
//
//  Created by Akshayraj Sanjai on 12/25/25.
//

import SwiftUI
import SwiftData

struct NoraItemDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    
    let item: NoraItem
    
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(item.title)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        HStack(spacing: 8) {
                            Text(item.isEvent ? "Event" : "Reminder")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(item.isEvent ? Color.blue : Color.green)
                                .cornerRadius(8)
                            
                            if item.isEvent, let mode = item.mode {
                                Text(mode == .inPerson ? "In-person" : "Online")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color(.systemGray5))
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
                }
                
                Section("Time") {
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(.secondary)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(timeRangeString)
                                .font(.body)
                            Text(relativeTimeString)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                if let locationOrLink = item.locationOrLink, !locationOrLink.isEmpty, let mode = item.mode {
                    Section(mode == .inPerson ? "Location" : "Link") {
                        Button(action: {
                            handleLocationTap(locationOrLink: locationOrLink, mode: mode)
                        }) {
                            HStack {
                                Image(systemName: mode == .inPerson ? "location.fill" : "link")
                                    .foregroundColor(.blue)
                                Text(locationOrLink)
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                if let notes = item.notes, !notes.isEmpty {
                    Section("Notes") {
                        Text(notes)
                            .font(.body)
                    }
                }
            }
            .navigationTitle("Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    HStack(spacing: 16) {
                        Button(action: {
                            showingEditSheet = true
                        }) {
                            Image(systemName: "pencil")
                        }
                        
                        Button(role: .destructive, action: {
                            showingDeleteAlert = true
                        }) {
                            Image(systemName: "trash")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingEditSheet) {
                AddItemView(mode: .edit, itemToEdit: item)
            }
            .alert("Delete Item", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteItem()
                }
            } message: {
                Text("Are you sure you want to delete \"\(item.title)\"?")
            }
        }
    }
    
    private var timeRangeString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        if let endAt = item.endAt {
            let timeFormatter = DateFormatter()
            timeFormatter.timeStyle = .short
            let startTime = timeFormatter.string(from: item.startAt)
            let endTime = timeFormatter.string(from: endAt)
            let date = formatter.string(from: item.startAt)
            return "\(date) • \(startTime)–\(endTime)"
        } else {
            return formatter.string(from: item.startAt)
        }
    }
    
    private var relativeTimeString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: item.startAt, relativeTo: Date())
    }
    
    private func handleLocationTap(locationOrLink: String, mode: NoraMode) {
        if mode == .inPerson {
            if let mapsURL = mapsURL(for: locationOrLink) {
                openURL(mapsURL)
            }
        } else if mode == .online {
            if let url = normalizedURL(for: locationOrLink) {
                openURL(url)
            }
        }
    }
    
    private func normalizedURL(for urlString: String) -> URL? {
        var normalized = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !normalized.lowercased().hasPrefix("http://") && !normalized.lowercased().hasPrefix("https://") {
            normalized = "https://" + normalized
        }
        
        return URL(string: normalized)
    }
    
    private func mapsURL(for locationString: String) -> URL? {
        let trimmed = locationString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        
        if let encoded = trimmed.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            return URL(string: "http://maps.apple.com/?q=\(encoded)")
        }
        
        return nil
    }
    
    private func deleteItem() {
        modelContext.delete(item)
        dismiss()
    }
}
