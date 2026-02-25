import SwiftUI

struct DashboardView: View {
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    // C Motion Or Class 1
                    NavigationLink(destination: MotionView()) {
                        DashboardCard(
                            icon: "figure.walk.motion",
                            title: "C Motion",
                            subtitle: "Track Sensor Data",
                            gradientColors: [.blue, .cyan]
                        )
                    }
                }
            }
        }
    }
}

#Preview {
    DashboardView()
}
