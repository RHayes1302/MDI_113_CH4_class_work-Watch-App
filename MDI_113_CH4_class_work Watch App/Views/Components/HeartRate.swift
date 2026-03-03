//
//  HeartRate.swift
//  MDI_113_CH4_class_work
//
//  Created by Ramone Hayes on 3/2/26.
//

import SwiftUI

struct HeartRateView: View {
    @StateObject private var viewModel = HeartRateViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center) {
                VStack {
                    Image(systemName: "heart.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .padding()
                        .foregroundStyle(Color(.red))
                        .symbolEffect(.pulse, isActive: viewModel.isMonitoring)
                }
                VStack(spacing: 4) {
                    Text("\(viewModel.currentHearthRate)")
                        .font(.system(size: 72, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .contentTransition(.numericText())
                        .animation(.spring(), value: viewModel.currentHearthRate)
                    
                    Text("BPM")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .tracking(2)
                }
                Button(action: {
                    if viewModel.isMonitoring{
                        viewModel.stopMonitoring()
                    } else {
                        viewModel.authorizationStatus == "Authorized" ?
                        viewModel.startMonitorinHeartRate() :
                        viewModel.requestAuthorization()
                    }
                }) {
                    Label(viewModel.isMonitoring ? "Stop" : "Start", systemImage: viewModel.isMonitoring ? "stop.fill" : "play.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .tint(viewModel.isMonitoring ? .red : .green)
                .padding(.horizontal)
            }
        }
        .navigationTitle("Heartrate")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    HeartRateView()
}
