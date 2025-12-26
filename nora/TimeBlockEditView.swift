//
//  TimeBlockEditView.swift
//  nora
//
//  Created by Akshayraj Sanjai on 12/26/25.
//

import SwiftUI

struct TimeBlockEditView: View {
    let model: TimeBlockFlowModel
    let onDone: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Edit Plan")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Tap an item to edit or swipe to delete")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    VStack(spacing: 12) {
                        ForEach(model.draftItems) { item in
                            TimeBlockEditCard(
                                item: item,
                                onUpdate: { updatedItem in
                                    model.updateDraftItem(updatedItem)
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .padding(.bottom, 100)
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button(action: onDone) {
                Text("Done")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
            .background(
                LinearGradient(
                    colors: [Color(.systemBackground).opacity(0), Color(.systemBackground)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 100)
                .offset(y: 50)
            )
        }
    }
}

struct TimeBlockEditCard: View {
    let item: TimeBlockDraftItem
    let onUpdate: (TimeBlockDraftItem) -> Void
    
    @State private var showingEditSheet = false
    @State private var editedTitle: String
    @State private var editedStartAt: Date
    @State private var editedEndAt: Date?
    
    init(item: TimeBlockDraftItem, onUpdate: @escaping (TimeBlockDraftItem) -> Void) {
        self.item = item
        self.onUpdate = onUpdate
        _editedTitle = State(initialValue: item.title)
        _editedStartAt = State(initialValue: item.startAt)
        _editedEndAt = State(initialValue: item.endAt)
    }
    
    var body: some View {
        Button(action: {
            showingEditSheet = true
        }) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(item.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "pencil")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
                
                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(timeString)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemGray6))
            .cornerRadius(16)
        }
        .sheet(isPresented: $showingEditSheet) {
            NavigationStack {
                Form {
                    Section("Details") {
                        TextField("Title", text: $editedTitle)
                        DatePicker("Start", selection: $editedStartAt)
                        
                        if let endAt = editedEndAt {
                            DatePicker("End", selection: Binding(
                                get: { endAt },
                                set: { editedEndAt = $0 }
                            ))
                        }
                    }
                }
                .navigationTitle("Edit Item")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            showingEditSheet = false
                        }
                    }
                    
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            var updatedItem = TimeBlockDraftItem(
                                title: editedTitle,
                                startAt: editedStartAt,
                                endAt: editedEndAt
                            )
                            updatedItem.id = item.id
                            onUpdate(updatedItem)
                            showingEditSheet = false
                        }
                        .disabled(editedTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }
    
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        if let endAt = item.endAt {
            let startTime = formatter.string(from: item.startAt)
            let endTime = formatter.string(from: endAt)
            return "\(startTime) – \(endTime)"
        } else {
            return formatter.string(from: item.startAt)
        }
    }
}

#Preview {
    let model = TimeBlockFlowModel()
    let draft = TimeBlockService.makeDraft(for: Date())
    model.draftItems = draft.items
    model.currentStep = .edit
    
    return TimeBlockEditView(
        model: model,
        onDone: {}
    )
}
