//
//  AudioRecording.swift
//  MDI_113_CH4_class_work
//
//  Created by Ramone Hayes on 3/2/26.
//

import SwiftUI

struct AudioRecorderView: View {
    @StateObject private var viewModel = AudioRecorderViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Recording Status
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(viewModel.isRecording ? Color.red.opacity(0.2) : Color.gray.opacity(0.2))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: viewModel.isRecording ? "mic.fill" : "mic.slash.fill")
                            .font(.system(size: 32))
                            .foregroundColor(viewModel.isRecording ? .red : .gray)
                            .symbolEffect(.pulse, isActive: viewModel.isRecording)
                    }
                    
                    if viewModel.isRecording {
                        Text(formatTime(viewModel.recordingTime))
                            .font(.system(size: 24, weight: .bold, design: .monospaced))
                            .foregroundColor(.red)
                            .contentTransition(.numericText())
                    } else {
                        Text("Ready")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 8)
                
                // Error Message
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.caption2)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Permission Request
                if !viewModel.permissionGranted {
                    Button("Grant Microphone Access") {
                        viewModel.requestPermission()
                    }
                    .buttonStyle(.bordered)
                    .tint(.blue)
                }
                
                // Record Button
                Button(action: {
                    if viewModel.isRecording {
                        viewModel.stopRecording()
                    } else {
                        viewModel.startRecording()
                    }
                }) {
                    Label(
                        viewModel.isRecording ? "Stop Recording" : "Start Recording",
                        systemImage: viewModel.isRecording ? "stop.circle.fill" : "record.circle"
                    )
                    .font(.system(size: 14, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .tint(viewModel.isRecording ? .red : .purple)
                .padding(.horizontal)
                .disabled(!viewModel.permissionGranted)
                
                // Recordings List
                if !viewModel.recordings.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Recordings")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(viewModel.recordings) { recording in
                            RecordingRow(recording: recording)
                        }
                        .onDelete { indexSet in
                            viewModel.deleteRecording(at: indexSet)
                        }
                    }
                }
            }
            .padding(.bottom, 8)
        }
        .navigationTitle("Voice Notes")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let milliseconds = Int((time.truncatingRemainder(dividingBy: 1)) * 10)
        return String(format: "%02d:%02d.%01d", minutes, seconds, milliseconds)
    }
}

struct RecordingRow: View {
    let recording: Recording
    @State private var isPlaying = false
    
    var body: some View {
        HStack(spacing: 8) {
            // Play button (placeholder - actual playback would need AVAudioPlayer)
            Button(action: {
                isPlaying.toggle()
            }) {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.purple)
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(recording.formattedDuration)
                    .font(.system(size: 14, weight: .semibold))
                
                Text(recording.formattedDate)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        AudioRecorderView()
    }
}
