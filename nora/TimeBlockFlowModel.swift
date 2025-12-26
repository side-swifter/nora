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
    var isGeneratingPlan = false
    var transcript = ""
    var draftItems: [TimeBlockDraftItem] = []
    var selectedDraftItem: TimeBlockDraftItem?
    var errorMessage: String?
    
    private let plannerEngine = PlannerEngine()
    
    func startRecording() {
        isRecording = true
        errorMessage = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            self?.completeRecording()
        }
    }
    
    private func completeRecording() {
        isRecording = false
        
        transcript = "Tomorrow: Gym 7-8, Breakfast 8-8:30, CAD 9-11, Lunch 12:30-1, Meeting 5:30-6, Homework 6-8"
        
        Task { @MainActor in
            await generatePlanFromTranscript()
        }
    }
    
    private func generatePlanFromTranscript() async {
        isGeneratingPlan = true
        errorMessage = nil
        
        do {
            let calendar = Calendar.current
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()) ?? Date()
            
            draftItems = try await plannerEngine.generatePlan(
                rawText: transcript,
                referenceDate: tomorrow,
                timezone: .current
            )
            
            currentStep = .review
        } catch let error as PlannerError {
            handlePlannerError(error)
        } catch {
            errorMessage = "Failed to generate plan: \(error.localizedDescription)"
        }
        
        isGeneratingPlan = false
    }
    
    func retryGeneration() {
        Task { @MainActor in
            await generatePlanFromTranscript()
        }
    }
    
    private func handlePlannerError(_ error: PlannerError) {
        switch error {
        case .aiError(let aiError):
            switch aiError {
            case .missingAPIKey:
                errorMessage = "API key not configured. Please add AIML_API_KEY to Secrets.xcconfig"
            case .invalidURL:
                errorMessage = "Invalid API URL"
            case .requestFailed(let err):
                errorMessage = "Network error: \(err.localizedDescription)"
            case .invalidResponse:
                errorMessage = "Invalid response from AI"
            case .httpError(let code, let message):
                errorMessage = "API error (\(code)): \(message)"
            }
        case .invalidJSON:
            errorMessage = "Failed to parse AI response"
        case .invalidTimeFormat:
            errorMessage = "Invalid time format in response"
        case .invalidTimeRange:
            errorMessage = "Invalid time range (start must be before end)"
        case .overlappingBlocks:
            errorMessage = "Overlapping time blocks detected"
        }
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
