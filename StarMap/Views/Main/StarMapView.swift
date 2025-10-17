//
//  StarMapView.swift
//  StarMap
//
//  Created by Francesco Albano on 10/08/25.
//

import SwiftUI
import CoreLocation
import simd
import Combine

/// The main view of the star map application.
struct StarMapView: View {
    @StateObject private var viewModel = StarMapViewModel()
    @StateObject private var motionManager = MotionManager()
    @StateObject private var locationManager = LocationManager.shared
    
    // This environment variable tracks the app's state (active, inactive, background).
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundGradient
                
                SkyCanvasView(
                    objects: viewModel.filteredObjects,
                    rotationMatrix: viewModel.isTrackingMode ? motionManager.rotationMatrix : nil,
                    manualPitch: viewModel.manualPitch,
                    manualYaw: viewModel.manualYaw,
                    isTrackingMode: viewModel.isTrackingMode,
                    fieldOfView: viewModel.fieldOfView
                )
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            viewModel.handleDrag(translation: value.translation, motionManager: motionManager, locationManager: locationManager)
                        }
                        .onEnded { _ in viewModel.endDrag() }
                )
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in viewModel.handleZoom(magnification: value) }
                        .onEnded { _ in viewModel.endZoom() }
                )
                .onTapGesture { location in
                    handleTap(at: location, screenSize: geometry.size)
                }
                
                uiOverlay
                
                if viewModel.showObjectInfo, let object = viewModel.selectedObject {
                    ObjectDetailPopup(
                        object: object,
                        isPresented: $viewModel.showObjectInfo,
                        userLocation: viewModel.currentLocation // 👈 FIX: Usa la location salvata nel ViewModel
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
                }
            }
            .onAppear {
                motionManager.startTracking()
                locationManager.startUpdating()
            }
            .onDisappear {
                motionManager.stopTracking()
                locationManager.stopUpdating()
            }
            // 👈 FIX: La sintassi `onChange(of:perform:)` è deprecata. Questa è la versione moderna.
            .onChange(of: scenePhase) { oldPhase, newPhase in
                if newPhase == .active {
                    viewModel.forceDataRefreshOnAppActive()
                }
            }
            // This modifier listens for location updates from the GPS.
            .onReceive(locationManager.$currentLocation) { newLocation in
                 if let location = newLocation {
                     viewModel.updateData(for: location)
                 }
            }
        }
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [Constants.Colors.skyGradientTop, Constants.Colors.skyGradientBottom],
            startPoint: .top, endPoint: .bottom
        ).ignoresSafeArea()
    }
    
    private var uiOverlay: some View {
        VStack {
            TopInfoOverlay(
                isTracking: viewModel.isTrackingMode,
                location: locationManager.currentLocation,
                compassHeading: locationManager.compassHeading,
                fieldOfView: viewModel.fieldOfView
            )
            
            Spacer()
            
            if !viewModel.isTrackingMode {
                Button(action: {
                    viewModel.resumeTracking()
                }) {
                    Image(systemName: "scope")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(18)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.3), radius: 10)
                }
                .transition(.opacity.combined(with: .scale(scale: 0.8)))
                .padding(.bottom)
            }
            
            BottomControlsOverlay(
                objectCount: viewModel.filteredObjects.count,
                activeFilter: $viewModel.activeFilter
            )
        }
    }
    
    private func handleTap(at location: CGPoint, screenSize: CGSize) {
        if let tappedObject = viewModel.findClosestObject(
            at: location,
            rotationMatrix: motionManager.rotationMatrix,
            screenSize: screenSize
        ) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                viewModel.selectObject(tappedObject)
            }
        }
    }
}
