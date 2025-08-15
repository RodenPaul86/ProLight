//
//  PoisonousPlantsListView.swift
//  ProLight
//
//  Created by Paul  on 8/15/25.
//

import SwiftUI
import Vision
import CoreML
import PhotosUI
import AVFoundation
import FoundationModels

// MARK: - Data Models
struct PoisonousPlant: Identifiable, Codable, Hashable {
    var id: UUID = .init()
    let name: String
    let imageName: String // asset name (for the catalog list)
    let description: String
    let symptoms: String
    let treatment: String
    let dangerLevel: DangerLevel
    
    enum DangerLevel: String, Codable, CaseIterable { case low, medium, high }
}

struct PlantPrediction: Identifiable, Hashable {
    let id: UUID = .init()
    let label: String
    let confidence: Float
    var isPoisonous: Bool
}

// MARK: - Demo Data (replace/expand via JSON later)
let demoPlants: [PoisonousPlant] = [
    .init(
        name: "Poison Ivy",
        imageName: "poison_ivy",
        description: "Climbing plant with three leaflets; contains urushiol that causes dermatitis.",
        symptoms: "Itchy rash, redness, swelling, blisters.",
        treatment: "Wash skin promptly with soap and water; avoid scratching; seek care if severe.",
        dangerLevel: .medium
    ),
    .init(
        name: "Water Hemlock",
        imageName: "water_hemlock",
        description: "Highly toxic member of the carrot family; white umbrella clusters, purple-spotted stems.",
        symptoms: "Seizures, nausea, vomiting, respiratory failure.",
        treatment: "Call emergency services immediately.",
        dangerLevel: .high
    ),
    .init(
        name: "Deadly Nightshade",
        imageName: "deadly_nightshade",
        description: "Bell-shaped purple flowers, shiny black berries; contains tropane alkaloids.",
        symptoms: "Dilated pupils, confusion, hallucinations, seizures; can be fatal if ingested.",
        treatment: "Seek emergency medical care; do not induce vomiting.",
        dangerLevel: .high
    ),
    .init(
        name: "Poison Sumac",
        imageName: "poison_sumac",
        description: "Tall shrub or small tree with smooth, gray bark; leaves in clusters of 7–13.",
        symptoms: "Severe itching, redness, swelling, blisters; more potent than poison ivy or oak.",
        treatment: "Wash affected area immediately; use topical corticosteroids; seek medical attention if severe.",
        dangerLevel: .high
    ),
    .init(
        name: "Poison Oak",
        imageName: "poison_oak",
        description: "Shrub or vine with lobed leaves resembling oak; contains urushiol.",
        symptoms: "Itchy rash, redness, blisters, swelling.",
        treatment: "Wash skin promptly with soap and water; apply anti-itch creams; avoid scratching.",
        dangerLevel: .medium
    )
]

// For the classifier poison mapping; extend as your model labels grow
let poisonousLabels: Set<String> = [
    "poison ivy", "toxicodendron radicans", "water hemlock", "cicuta", "deadly nightshade", "atropa belladonna"
]

// MARK: - Classifier (Vision + CoreML)
@available(iOS 26.0, *)
final class PlantClassifier: ObservableObject {
    @Published var predictions: [PlantPrediction] = []
    private var model: VNCoreMLModel?
    
    // FoundationModels session for advanced classification using language model
    private var fmSession: LanguageModelSession? = {
        let session = LanguageModelSession(
            instructions: "You are a plant identification expert. Classify the given plant and state if it is poisonous. Only answer with 'Poisonous', 'Not Poisonous', or 'Unknown'."
        )
        return session
    }()
    
    init() {
        // Try to load your custom model first. Name it PoisonPlants.mlmodel in Xcode.
        if let url = Bundle.main.url(forResource: "PoisonPlants", withExtension: "mlmodelc"),
           let compiled = try? MLModel(contentsOf: url),
           let vn = try? VNCoreMLModel(for: compiled) {
            self.model = vn
        } else {
            // Model could not be loaded; classifier will not function.
            // TODO: Add a fallback model (.mlmodel) to your project if you want demo/testing fallback behavior.
            self.model = nil
        }
    }
    
    func analyze(_ uiImage: UIImage) {
        guard let cgImage = uiImage.cgImage, let model else {
            predictions = []
            return
        }
        let request = VNCoreMLRequest(model: model) { [weak self] req, _ in
            guard let results = req.results as? [VNClassificationObservation] else { return }
            let top = results.prefix(5).map { obs -> PlantPrediction in
                let label = obs.identifier.lowercased()
                let toxic = poisonousLabels.contains(label) || poisonousLabels.contains(label.components(separatedBy: ",").first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? label)
                return PlantPrediction(label: obs.identifier, confidence: obs.confidence, isPoisonous: toxic)
            }
            DispatchQueue.main.async { self?.predictions = top }
        }
        request.imageCropAndScaleOption = .centerCrop
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([request])
        }
    }
    
    /// Uses FoundationModels LanguageModelSession to classify the image with a textual prompt.
    /// This is a demo and not a substitute for professional advice.
    func classifyWithFoundationModel(image: UIImage) async {
        guard let session = fmSession else { return }
        // For demo, we use a static string prompt. To improve, use Vision OCR or CoreML to get candidate label, then ask FM.
        let prompt = "Does this plant look poisonous? Answer only: Poisonous / Not Poisonous / Unknown."
        do {
            let response = try await session.respond(to: prompt)
            let answer = response.content.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            var isPoisonous = false
            if answer.contains("poisonous") && !answer.contains("not poisonous") {
                isPoisonous = true
            } else if answer.contains("not poisonous") {
                isPoisonous = false
            } else {
                // Unknown, leave default
            }
            DispatchQueue.main.async {
                self.predictions = [PlantPrediction(label: "FoundationModel: \(answer.capitalized)", confidence: 0.5, isPoisonous: isPoisonous)]
            }
        } catch {
            print("Foundation Model error: \(error)")
        }
    }
}

// MARK: - Scanner View (Camera/Photo picker + Results)
@available(iOS 26.0, *)
struct PlantScannerView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var classifier = PlantClassifier()
    @State private var showCamera = false
    @State private var pickedItem: PhotosPickerItem? = nil
    @State private var image: UIImage? = nil
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Group {
                    if let img = image {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.secondary.opacity(0.2)))
                    } else {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16).fill(Color.secondary.opacity(0.1))
                            VStack(spacing: 8) {
                                Image(systemName: "leaf")
                                    .font(.system(size: 36, weight: .regular))
                                Text("Pick or Scan a Plant")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .frame(height: 220)
                    }
                }
                .animation(.easeInOut, value: image)
                
                HStack(spacing: 12) {
                    PhotosPicker(selection: $pickedItem, matching: .images, photoLibrary: .shared()) {
                        Label("Photos", systemImage: "photo")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    Button {
                        showCamera = true
                    } label: {
                        Label("Camera", systemImage: "camera")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .sheet(isPresented: $showCamera) {
                        CameraView(image: $image)
                    }
                }
                
                if !classifier.predictions.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Results", systemImage: "waveform.path.ecg")
                            .font(.headline)
                        ForEach(classifier.predictions) { pred in
                            HStack {
                                let isToxic = pred.isPoisonous
                                Text(pred.label)
                                    .font(.body)
                                    //.lineLimit(2)
                                Spacer()
                                Text(String(format: "%.0f%%", pred.confidence * 100))
                                    .monospaced()
                                    .foregroundStyle(.secondary)
                                Text(isToxic ? "Poisonous" : "Unknown")
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(isToxic ? Color.red.opacity(0.9) : Color.gray.opacity(0.25))
                                    .foregroundStyle(isToxic ? .white : .primary)
                                    .clipShape(Capsule())
                            }
                        }
                        Text("Always verify visually; when in doubt, avoid contact. Not medical advice.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Scan Plant")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .onChange(of: pickedItem) { _, newItem in
            guard let item = newItem else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let uiImg = UIImage(data: data) {
                    image = uiImg
                    classifier.analyze(uiImg)
                    await classifier.classifyWithFoundationModel(image: uiImg)
                }
            }
        }
        .onChange(of: image) { _, newImg in
            Task {
                if let newImg {
                    classifier.analyze(newImg)
                    await classifier.classifyWithFoundationModel(image: newImg)
                }
            }
        }
    }
}

// MARK: - Camera (UIKit bridge)
struct CameraView: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    @Binding var image: UIImage?
    
    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        init(parent: CameraView) { self.parent = parent }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let img = info[.originalImage] as? UIImage {
                parent.image = img
            }
            parent.dismiss()
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - List/Grid UI with Scan button
struct PoisonousPlantsListView: View {
    @State private var showScanner: Bool = false
    @State private var hideTabBar: Bool = false

    let plants: [PoisonousPlant]
    
    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(plants) { plant in
                    NavigationLink(destination: PoisonousPlantDetailView(plant: plant)) {
                        VStack(alignment: .center, spacing: 8) {
                            Image(plant.imageName)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 150, height: 120)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(alignment: .topLeading) {
                                    DangerTag(level: plant.dangerLevel)
                                        .padding(6)
                                }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text(plant.name)
                                    .font(.headline)
                                    .lineLimit(1)
                                
                                Text(plant.description)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                            }
                        }
                        .padding(8)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(radius: 1)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Poisonous Plants")
        .hideFloatingTabBar(hideTabBar)
        .onAppear {
            hideTabBar = true
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showScanner = true
                } label: {
                    Label("Scan", systemImage: "camera.viewfinder")
                }
            }
        }
        .sheet(isPresented: $showScanner) {
            if #available(iOS 26.0, *) {
                PlantScannerView()
            } else {
                // Fallback on earlier versions
            }
        }
    }
}

// MARK: - Detail View
struct PoisonousPlantDetailView: View {
    let plant: PoisonousPlant
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Image(plant.imageName)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                
                HStack {
                    Text(plant.name).font(.largeTitle).bold()
                    Spacer()
                    DangerTag(level: plant.dangerLevel)
                }
                
                SectionHeader("Description")
                Text(plant.description)
                
                SectionHeader("Symptoms")
                Text(plant.symptoms)
                
                SectionHeader("Treatment")
                Text(plant.treatment).foregroundStyle(.red)
                
                Text("Information is for quick reference only; if exposure or ingestion is suspected, contact emergency services or poison control.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .navigationTitle(plant.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Small UI Helpers
struct DangerTag: View {
    let level: PoisonousPlant.DangerLevel
    var body: some View {
        let text: String
        let color: Color
        switch level {
        case .low: text = "Caution"; color = .yellow
        case .medium: text = "Warning"; color = .orange
        case .high: text = "Danger"; color = .red
        }
        return Text(text)
            .font(.caption).bold()
            .padding(.horizontal, 8).padding(.vertical, 4)
            .background(color.opacity(0.9))
            .foregroundStyle(.white)
            .clipShape(Capsule())
    }
}

struct SectionHeader: View {
    var title: String
    init(_ title: String) { self.title = title }
    var body: some View {
        Text(title).font(.title2).bold()
    }
}

// MARK: - Preview / Entry
struct PoisonousPlantsEntryView: View {
    var body: some View {
        PoisonousPlantsListView(plants: demoPlants)
    }
}

#Preview {
    PoisonousPlantsEntryView()
}

