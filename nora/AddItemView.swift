//
//  AddItemView.swift
//  nora
//
//  Created by Akshayraj Sanjai on 12/24/25.
//

import SwiftUI
import SwiftData

enum DurationOption: String, CaseIterable {
    case none = "None"
    case fifteenMin = "15m"
    case thirtyMin = "30m"
    case fortyFiveMin = "45m"
    case oneHour = "1h"
    case twoHours = "2h"
    case custom = "Custom"
    
    var minutes: Int? {
        switch self {
        case .none: return nil
        case .fifteenMin: return 15
        case .thirtyMin: return 30
        case .fortyFiveMin: return 45
        case .oneHour: return 60
        case .twoHours: return 120
        case .custom: return nil
        }
    }
}

enum AddItemMode {
    case create
    case edit
}

struct AddItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let mode: AddItemMode
    let itemToEdit: NoraItem?
    
    @State private var title: String = ""
    @State private var startAt: Date = Date()
    @State private var notes: String = ""
    @State private var selectedDuration: DurationOption = .none
    @State private var customHours: Int = 1
    @State private var customMinutes: Int = 0
    @State private var selectedMode: NoraMode = .inPerson
    @State private var locationOrLink: String = ""
    @State private var showingDeleteAlert = false
    
    init(mode: AddItemMode = .create, itemToEdit: NoraItem? = nil) {
        self.mode = mode
        self.itemToEdit = itemToEdit
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: $title)
                    DatePicker("Start", selection: $startAt)
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("How long?")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 70))], spacing: 8) {
                            ForEach(DurationOption.allCases, id: \.self) { option in
                                Button(action: {
                                    selectedDuration = option
                                }) {
                                    Text(option.rawValue)
                                        .font(.subheadline)
                                        .fontWeight(selectedDuration == option ? .semibold : .regular)
                                        .foregroundColor(selectedDuration == option ? .white : .primary)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .background(selectedDuration == option ? Color.blue : Color(.systemGray5))
                                        .cornerRadius(8)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        
                        if selectedDuration == .custom {
                            HStack(spacing: 16) {
                                Picker("Hours", selection: $customHours) {
                                    ForEach(0..<24) { hour in
                                        Text("\(hour)h").tag(hour)
                                    }
                                }
                                .pickerStyle(.wheel)
                                .frame(maxWidth: .infinity)
                                
                                Picker("Minutes", selection: $customMinutes) {
                                    ForEach([0, 15, 30, 45], id: \.self) { minute in
                                        Text("\(minute)m").tag(minute)
                                    }
                                }
                                .pickerStyle(.wheel)
                                .frame(maxWidth: .infinity)
                            }
                            .frame(height: 120)
                        }
                    }
                }
                
                if hasDuration {
                    Section {
                        Picker("Mode", selection: $selectedMode) {
                            Text("In-person").tag(NoraMode.inPerson)
                            Text("Online").tag(NoraMode.online)
                        }
                        .pickerStyle(.segmented)
                        
                        if selectedMode == .inPerson {
                            TextField("Location", text: $locationOrLink)
                        } else {
                            TextField("Link", text: $locationOrLink)
                        }
                    }
                }
                
                Section {
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                if mode == .edit, itemToEdit != nil {
                    Section {
                        Button(role: .destructive, action: {
                            showingDeleteAlert = true
                        }) {
                            HStack {
                                Spacer()
                                Text("Delete Item")
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle(mode == .edit ? "Edit Item" : "Tell Nora")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if mode == .edit, let item = itemToEdit {
                    loadItemData(item)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveItem()
                    }
                    .disabled(!isValid)
                }
            }
            .alert("Delete Item?", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteItem()
                }
            } message: {
                Text("This can't be undone.")
            }
        }
    }
    
    private var isValid: Bool {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmedTitle.isEmpty
    }
    
    private var hasDuration: Bool {
        if selectedDuration == .custom {
            return customHours > 0 || customMinutes > 0
        }
        return selectedDuration != .none
    }
    
    private func saveItem() {
        guard isValid else { return }
        
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedLocationOrLink = locationOrLink.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let endAt = calculateEndAt()
        let itemMode = endAt != nil ? selectedMode : nil
        
        if mode == .edit, let item = itemToEdit {
            // Update existing item
            item.title = trimmedTitle
            item.startAt = startAt
            item.endAt = endAt
            item.mode = itemMode
            item.locationOrLink = endAt != nil && !trimmedLocationOrLink.isEmpty ? trimmedLocationOrLink : nil
            item.notes = !trimmedNotes.isEmpty ? trimmedNotes : nil
        } else {
            // Create new item
            let item = NoraItem(
                title: trimmedTitle,
                startAt: startAt,
                endAt: endAt,
                mode: itemMode,
                locationOrLink: endAt != nil && !trimmedLocationOrLink.isEmpty ? trimmedLocationOrLink : nil,
                notes: !trimmedNotes.isEmpty ? trimmedNotes : nil
            )
            modelContext.insert(item)
        }
        
        dismiss()
    }
    
    private func loadItemData(_ item: NoraItem) {
        title = item.title
        startAt = item.startAt
        notes = item.notes ?? ""
        
        if let mode = item.mode {
            selectedMode = mode
        }
        
        locationOrLink = item.locationOrLink ?? ""
        
        // Calculate duration from endAt
        if let endAt = item.endAt {
            let duration = Calendar.current.dateComponents([.hour, .minute], from: item.startAt, to: endAt)
            let totalMinutes = (duration.hour ?? 0) * 60 + (duration.minute ?? 0)
            
            // Try to match preset durations
            switch totalMinutes {
            case 15:
                selectedDuration = .fifteenMin
            case 30:
                selectedDuration = .thirtyMin
            case 45:
                selectedDuration = .fortyFiveMin
            case 60:
                selectedDuration = .oneHour
            case 120:
                selectedDuration = .twoHours
            default:
                selectedDuration = .custom
                customHours = duration.hour ?? 0
                customMinutes = duration.minute ?? 0
            }
        } else {
            selectedDuration = .none
        }
    }
    
    private func calculateEndAt() -> Date? {
        if selectedDuration == .custom {
            let totalMinutes = customHours * 60 + customMinutes
            if totalMinutes > 0 {
                return Calendar.current.date(byAdding: .minute, value: totalMinutes, to: startAt)
            }
            return nil
        }
        
        if let minutes = selectedDuration.minutes {
            return Calendar.current.date(byAdding: .minute, value: minutes, to: startAt)
        }
        
        return nil
    }
    
    private func deleteItem() {
        guard let item = itemToEdit else { return }
        modelContext.delete(item)
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    AddItemView()
        .modelContainer(for: NoraItem.self, inMemory: true)
}
