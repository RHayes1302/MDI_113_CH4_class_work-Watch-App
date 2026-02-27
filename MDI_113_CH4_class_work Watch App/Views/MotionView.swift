import SwiftUI

struct MotionView: View {
    @StateObject private var viewModel = MotionViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Status Section
                VStack(spacing: 8) {
                    Image(systemName: viewModel.isTracking ? "figure.walking.motion" : "figure.stand")
                        .font(.system(size: 40))
                        .foregroundColor(viewModel.isTracking ? .green : .gray)
                        .symbolEffect(.pulse, isActive: viewModel.isTracking)
                    
                    Text(viewModel.isTracking ? "Tracking" : "Not Tracking")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 8)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Acceleration")
                        .font(.headline)
                        .foregroundColor(.blue)
                    MotionDataRow(label: "X", value: viewModel.accelerationX, color: .red)
                    MotionDataRow(label: "Y", value: viewModel.accelerationY, color: .green)
                    MotionDataRow(label: "Z", value: viewModel.accelerationZ, color: .blue)
                }
                .padding(.horizontal)
                
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Rotation Rate")
                        .font(.headline)
                        .foregroundColor(.purple)
                    
                    MotionDataRow(label: "X", value: viewModel.rotationX, color: .orange)
                    MotionDataRow(label: "Y", value: viewModel.rotationY, color: .pink)
                    MotionDataRow(label: "Z", value: viewModel.rotationZ, color: .cyan)
                }
                .padding(.horizontal)
                
                if let error = viewModel.trackingError {
                    Text(error)
                        .font(.caption2)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Button(action: {
                    if viewModel.isTracking {
                        viewModel.stopTracking()
                    } else {
                        viewModel.startTracking()
                    }
                }) {
                    Label(viewModel.isTracking ? "Stop" : "start", systemImage: viewModel.isTracking ? "sopt.fill" : "play.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .tint(viewModel.isTracking ? .red : .green)
                .padding(.horizontal)
            }
            .navigationTitle("Motion")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    NavigationStack {
        MotionView()
    }
}
