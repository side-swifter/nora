//
//  TimeBlockReviewView.swift
//  nora
//
//  Created by Akshayraj Sanjai on 12/26/25.
//

import SwiftUI
import SwiftData

struct TimeBlockReviewView: View {
    let model: TimeBlockFlowModel
    let onConfirm: () -> Void
    let onCancel: () -> Void
    let onEdit: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Nora's Plan")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text(model.transcript)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(3)
                        
                        HStack {
                            Text("Draft — review before saving")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.orange)
                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    VStack(spacing: 12) {
                        ForEach(model.draftItems) { item in
                            TimeBlockDraftCard(item: item)
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .padding(.bottom, 180)
            }
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 12) {
                Button(action: onConfirm) {
                    Text("Confirm")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                
                HStack(spacing: 12) {
                    Button(action: onCancel) {
                        Text("Cancel")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray5))
                            .cornerRadius(12)
                    }
                    
                    Button(action: onEdit) {
                        Text("Edit")
                            .font(.headline)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                    }
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
                .frame(height: 100)
                .offset(y: 50)
            )
        }
    }
}

struct TimeBlockDraftCard: View {
    let item: TimeBlockDraftItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(item.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text(item.isEvent ? "Event" : "Reminder")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(item.isEvent ? Color.blue : Color.green)
                    .cornerRadius(8)
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
    model.transcript = draft.transcript
    model.draftItems = draft.items
    model.currentStep = .review
    
    return TimeBlockReviewView(
        model: model,
        onConfirm: {},
        onCancel: {},
        onEdit: {}
    )
    .modelContainer(for: NoraItem.self, inMemory: true)
}
