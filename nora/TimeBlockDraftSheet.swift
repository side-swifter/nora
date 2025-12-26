//
//  TimeBlockDraftSheet.swift
//  nora
//
//  Created by Akshayraj Sanjai on 12/25/25.
//

import SwiftUI
import SwiftData

struct TimeBlockDraftSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let transcript: String
    let draftBlocks: [DraftBlock]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Nora's Plan")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text(transcript)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                            
                            Text("Draft – review before saving")
                                .font(.caption)
                                .foregroundColor(.orange)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.orange.opacity(0.1))
                                .cornerRadius(8)
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                        VStack(spacing: 12) {
                            ForEach(draftBlocks) { block in
                                DraftBlockRow(block: block)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .padding(.bottom, 120)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 12) {
                    Button(action: confirmPlan) {
                        Text("Confirm")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    
                    HStack(spacing: 12) {
                        Button(action: { dismiss() }) {
                            Text("Cancel")
                                .font(.headline)
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(.systemGray5))
                                .cornerRadius(12)
                        }
                        
                        Button(action: {}) {
                            Text("Edit")
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                        }
                        .disabled(true)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
                .background(Color(.systemBackground))
            }
        }
    }
    
    private func confirmPlan() {
        for block in draftBlocks {
            let item = NoraItem(
                title: block.title,
                startAt: block.startAt,
                endAt: block.endAt,
                mode: nil,
                locationOrLink: nil,
                notes: nil
            )
            modelContext.insert(item)
        }
        
        try? modelContext.save()
        dismiss()
    }
}

struct DraftBlockRow: View {
    let block: DraftBlock
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(block.title)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(timeString)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(block.isEvent ? "Event" : "Reminder")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(block.isEvent ? Color.blue : Color.green)
                .cornerRadius(8)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        if let endAt = block.endAt {
            let startTime = formatter.string(from: block.startAt)
            let endTime = formatter.string(from: endAt)
            return "\(startTime) – \(endTime)"
        } else {
            return formatter.string(from: block.startAt)
        }
    }
}

#Preview {
    let transcript = "Tomorrow: Gym 7-8, Breakfast 8-8:30, CAD 9-11, Lunch 12:30-1, Meeting 5:30-6, Homework 6-8"
    let blocks = generateDraftPlan(from: transcript, referenceDate: Date())
    
    return TimeBlockDraftSheet(transcript: transcript, draftBlocks: blocks)
        .modelContainer(for: NoraItem.self, inMemory: true)
}
