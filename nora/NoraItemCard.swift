//
//  NoraItemCard.swift
//  nora
//
//  Created by Akshayraj Sanjai on 12/25/25.
//

import SwiftUI
import SwiftData

enum CardStyle {
    case hero
    case compact
}

struct NoraItemCard: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openURL) private var openURL
    
    let item: NoraItem
    let style: CardStyle
    let onTap: () -> Void
    let onEdit: () -> Void
    
    @State private var showingDeleteAlert = false
    
    var body: some View {
        Button(action: onTap) {
            if style == .hero {
                heroCardContent
            } else {
                compactCardContent
            }
        }
        .buttonStyle(.plain)
        .alert("Delete Item", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteItem()
            }
        } message: {
            Text("Are you sure you want to delete \"\(item.title)\"?")
        }
    }
    
    private var heroCardContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Text(item.isEvent ? "Event" : "Reminder")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(item.isEvent ? Color.blue : Color.green)
                    .cornerRadius(12)
                
                if item.isEvent, let mode = item.mode {
                    Text(mode == .inPerson ? "In-person" : "Online")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(.systemGray5))
                        .cornerRadius(12)
                }
                
                Spacer()
                
                Menu {
                    Button(action: onEdit) {
                        Label("Edit", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive, action: {
                        showingDeleteAlert = true
                    }) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .padding(8)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            
            Text(item.title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(timeRangeString)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(relativeTimeString)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if let locationOrLink = item.locationOrLink, !locationOrLink.isEmpty, let mode = item.mode {
                    HStack(spacing: 6) {
                        Text(mode == .inPerson ? "📍" : "🔗")
                            .font(.subheadline)
                        Text(locationOrLink)
                            .font(.subheadline)
                            .foregroundColor(.blue)
                            .underline()
                    }
                    .padding(.top, 4)
                    .onTapGesture {
                        handleLocationTap(locationOrLink: locationOrLink, mode: mode)
                    }
                }
            }
            
            if let notes = item.notes, !notes.isEmpty {
                Text(notes)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color(.systemGray6))
        .cornerRadius(24)
    }
    
    private var compactCardContent: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(timeRangeString)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Menu {
                Button(action: onEdit) {
                    Label("Edit", systemImage: "pencil")
                }
                
                Button(role: .destructive, action: {
                    showingDeleteAlert = true
                }) {
                    Label("Delete", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding(8)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var timeRangeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        if let endAt = item.endAt {
            let startTime = formatter.string(from: item.startAt)
            let endTime = formatter.string(from: endAt)
            return "\(startTime)–\(endTime)"
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
    }
}
