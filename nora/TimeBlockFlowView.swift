//
//  TimeBlockFlowView.swift
//  nora
//
//  Created by Akshayraj Sanjai on 12/26/25.
//

import SwiftUI
import SwiftData

struct TimeBlockFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var model = TimeBlockFlowModel()
    
    var body: some View {
        NavigationStack {
            Group {
                switch model.currentStep {
                case .mic:
                    TimeBlockMicView(model: model)
                    
                case .review:
                    TimeBlockReviewView(
                        model: model,
                        onConfirm: handleConfirm,
                        onCancel: { dismiss() },
                        onEdit: { model.goToEdit() }
                    )
                    
                case .edit:
                    TimeBlockEditView(
                        model: model,
                        onDone: { model.goToReview() }
                    )
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if model.currentStep == .mic {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    if model.currentStep == .review {
                        Button(action: {
                            model.currentStep = .mic
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                        }
                    } else if model.currentStep == .edit {
                        Button(action: {
                            model.goToReview()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func handleConfirm() {
        // TODO: Check for existing items on same day and handle dedupe
        
        for item in model.draftItems {
            let noraItem = NoraItem(
                title: item.title,
                startAt: item.startAt,
                endAt: item.endAt,
                mode: nil,
                locationOrLink: nil,
                notes: nil
            )
            modelContext.insert(noraItem)
        }
        
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    TimeBlockFlowView()
        .modelContainer(for: NoraItem.self, inMemory: true)
}
