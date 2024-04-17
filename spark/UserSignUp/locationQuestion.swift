import SwiftUI
import CoreLocation

class CustomLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        authorizationStatus = locationManager.authorizationStatus
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func requestAlwaysPermission() {
        locationManager.requestAlwaysAuthorization()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            authorizationStatus = manager.authorizationStatus
            if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
                // Trigger navigation to the next page
                NotificationCenter.default.post(name: .locationAuthorizationChanged, object: nil)
            }
        }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        print("Current location: \(location)")
    }
}
extension Notification.Name {
    static let locationAuthorizationChanged = Notification.Name("LocationAuthorizationChanged")
}


struct LocationQuestion: View {
    @State private var yOffset: CGFloat = 600
    @State private var isOverlayActive: Bool = false
    @State private var isAllowButtonPressed: Bool = false
    @EnvironmentObject var authViewModel: AuthViewModel
    @ObservedObject var locationManager = CustomLocationManager()
    @State private var shouldNavigateToNextPage = false
    @State private var showLocationDeniedAlert = false

    var body: some View {
        ZStack {
            if isOverlayActive {
                Color.black.opacity(0.001)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation {
                            yOffset = 600
                            isOverlayActive = false
                        }
                    }
            }

            Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isAllowButtonPressed = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    isAllowButtonPressed = false
                                    locationManager.requestLocationPermission()
                                }
                            }
                        }) {
                ZStack {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 375, height: 58)
                        .background(Color(red: 0, green: 0.57, blue: 0.80))
                        .cornerRadius(100)
                        .scaleEffect(isAllowButtonPressed ? 0.95 : 1.0)

                    Text("Allow")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .scaleEffect(isAllowButtonPressed ? 0.95 : 1.0)
                }
            }
            .offset(x: 0, y: 250)
            .animation(.easeInOut(duration: 0.2), value: isAllowButtonPressed)

            Text("So, are you from around here?")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding()
                .offset(x: 0, y: -300)

            Text("Set your location to see your friends and events nearby. Don't miss out on what's happening otherwise.")
                .font(.system(size: 17))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding()
                .offset(x: 0, y: -128.50)

            Circle()
                .frame(width: 100, height: 100)
                .foregroundColor(.white)
                .offset(x: 0, y: 120)

            Image("gps_4120467")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .offset(x: 0, y: 120)

            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 400, height: 554)
                .background(Color.white)
                .cornerRadius(60)
                .offset(x: 0, y: yOffset)
                .animation(.easeOut(duration: 0.5), value: yOffset)
                .onTapGesture {
                    withAnimation {
                        yOffset = 100
                        isOverlayActive = true
                    }
                }

            Text("How is my location used?")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.black)
                .offset(x: 0, y: yOffset - 235)
                .animation(.easeOut(duration: 0.5), value: yOffset)

            Text("Don't worry —— ")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
                .offset(x: 0, y: yOffset - 40)
                .animation(.easeOut(duration: 0.5), value: yOffset)

            Text("Your location helps us show friends and events nearby. Your location is only shown to approved friends, never publicly shared.")
                .font(.system(size: 18))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(40)
                .offset(x: 0, y: yOffset + 20)
                .animation(.easeOut(duration: 0.5), value: yOffset)
        }
        .frame(width: 430, height: 932)
        .background(Color.black)
        .onChange(of: locationManager.authorizationStatus) { status in
                    switch status {
                    case .notDetermined:
                        locationManager.requestLocationPermission()
                    case .authorizedWhenInUse, .authorizedAlways:
                        shouldNavigateToNextPage = true
                    case .denied, .restricted:
                        showLocationDeniedAlert = true
                    @unknown default:
                        print("Unknown location authorization status")
                    }
                }
                .onChange(of: shouldNavigateToNextPage) { shouldNavigate in
                    if shouldNavigate {
                        authViewModel.userSignUpProgress = .bitmoji1
                        print("SET TO TRUE")
                    }
                }
                .alert(isPresented: $showLocationDeniedAlert) {
                    Alert(
                        title: Text("Location Access Denied"),
                        message: Text("Please allow location access to continue."),
                        primaryButton: .default(Text("Open Settings")) {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        },
                        secondaryButton: .cancel()
                    )
                }
                .onReceive(NotificationCenter.default.publisher(for: .locationAuthorizationChanged)) { _ in
                    shouldNavigateToNextPage = true
                }
            }
        }
struct LocationQuestion_Previews: PreviewProvider {
    static var previews: some View {
        LocationQuestion()
                    .environmentObject(AuthViewModel())
    }
}


