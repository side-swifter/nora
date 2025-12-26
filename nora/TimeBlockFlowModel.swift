//
//  TimeBlockFlowModel.swift
//  nora
//
//  Created by Akshayraj Sanjai on 12/26/25.
//

import Foundation
import SwiftUI

enum TimeBlockFlowStep {
    case mic
    case review
    case edit
}

@Observable
class TimeBlockFlowModel {
    var currentStep: TimeBlockFlowStep = .mic
    var isRecording = false
    var transcript = ""
    var draftItems: [TimeBlockDraftItem] = []
    var selectedDraftItem: TimeBlockDraftItem?
    
    private let plannerEngine = PlannerEngine()
    
    func startRecording() {
        isRecording = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            self?.completeRecording()
        }
    }
    
    private func completeRecording() {
        isRecording = false
        
        transcript = "Tomorrow: Gym 7-8, Breakfast 8-8:30, CAD 9-11, Lunch 12:30-1, Meeting 5:30-6, Homework 6-8"
        
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        
        draftItems = plannerEngine.generatePlan(rawText: transcript, referenceDate: tomorrow)
        
        currentStep = .review
    }
    
    func goToEdit() {
        currentStep = .edit
    }
    
    func goToReview() {
        currentStep = .review
    }
    
    func updateDraftItem(_ item: TimeBlockDraftItem) {
        if let index = draftItems.firstIndex(where: { $0.id == item.id }) {
            draftItems[index] = item
        }
    }
    
    func deleteDraftItem(_ item: TimeBlockDraftItem) {
        draftItems.removeAll { $0.id == item.id }
    }
}
