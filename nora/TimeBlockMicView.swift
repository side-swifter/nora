//
//  TimeBlockMicView.swift
//  nora
//
//  Created by Akshayraj Sanjai on 12/26/25.
//

import SwiftUI

struct TimeBlockMicView: View {
    let model: TimeBlockFlowModel
    
    @State private var pulseAnimation = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(spacing: 16) {
                Text("Time-block with Nora")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                if model.isRecording {
                    Text("Listening…")
                        .font(.title3)
                        .foregroundColor(.secondary)
                } else {
                    Text("Tap to record")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            ZStack {
                if model.isRecording {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 200, height: 200)
                        .scaleEffect(pulseAnimation ? 1.3 : 1.0)
                        .opacity(pulseAnimation ? 0 : 1)
                        .animation(
                            Animation.easeOut(duration: 1.5)
                                .repeatForever(autoreverses: false),
                            value: pulseAnimation
                        )
                    
                    Circle()
                        .fill(Color.blue.opacity(0.3))
                        .frame(width: 180, height: 180)
                        .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                        .opacity(pulseAnimation ? 0 : 1)
                        .animation(
                            Animation.easeOut(duration: 1.5)
                                .repeatForever(autoreverses: false)
                                .delay(0.3),
                            value: pulseAnimation
                        )
                }
                
                Button(action: handleMicTap) {
                    ZStack {
                        Circle()
                            .fill(model.isRecording ? Color.red : Color.blue)
                            .frame(width: 120, height: 120)
                            .shadow(color: model.isRecording ? Color.red.opacity(0.4) : Color.blue.opacity(0.4), radius: 20, x: 0, y: 10)
                        
                        Image(systemName: "mic.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                    }
                }
                .disabled(model.isRecording)
            }
            .frame(height: 250)
            
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .onChange(of: model.isRecording) { _, isRecording in
            pulseAnimation = isRecording
        }
    }
    
    private func handleMicTap() {
        pulseAnimation = true
        model.startRecording()
    }
}

#Preview {
    TimeBlockMicView(model: TimeBlockFlowModel())
}
