//
//  PoisonousPlantsListView.swift
//  ProLight
//
//  Created by Paul  on 8/15/25.
//

import SwiftUI
import PhotosUI

// MARK: - Data Models
struct PoisonousPlant: Identifiable, Codable, Hashable {
    var id: UUID = .init()
    let name: String
    let scientificName: String
    let imageName: String // asset name (for the catalog list) — add these images to your asset catalog
    let category: Category
    let description: String
    let symptoms: String
    let treatment: String
    let dangerLevel: DangerLevel
    
    enum DangerLevel: String, Codable, CaseIterable, Comparable {
        case low, medium, high
        
        private var sortRank: Int {
            switch self {
            case .low: return 0
            case .medium: return 1
            case .high: return 2
            }
        }
        
        static func < (lhs: DangerLevel, rhs: DangerLevel) -> Bool {
            lhs.sortRank < rhs.sortRank
        }
    }
    
    enum Category: String, Codable, CaseIterable, Identifiable {
        case houseplant = "Houseplant"
        case garden = "Garden"
        case wild = "Wild / Outdoor"
        case tree = "Tree / Shrub"
        
        var id: String { rawValue }
        
        var icon: String {
            switch self {
            case .houseplant: return "house"
            case .garden: return "leaf"
            case .wild: return "mountain.2"
            case .tree: return "tree"
            }
        }
    }
}

// MARK: - Demo Data (replace/expand via JSON later)
let demoPlants: [PoisonousPlant] = [
    // MARK: Wild / Outdoor
    .init(
        name: "Poison Ivy",
        scientificName: "Toxicodendron radicans",
        imageName: "poison_ivy",
        category: .wild,
        description: "Climbing plant with three leaflets; contains urushiol oil that causes contact dermatitis.",
        symptoms: "Itchy rash, redness, swelling, blisters, often in streaks or patches.",
        treatment: "Wash skin promptly with soap and water; avoid scratching; seek care if severe or widespread.",
        dangerLevel: .medium
    ),
    .init(
        name: "Poison Oak",
        scientificName: "Toxicodendron diversilobum",
        imageName: "poison_oak",
        category: .wild,
        description: "Shrub or vine with lobed leaves resembling oak leaves; contains urushiol like poison ivy.",
        symptoms: "Itchy rash, redness, blisters, swelling.",
        treatment: "Wash skin promptly with soap and water; apply anti-itch creams; avoid scratching.",
        dangerLevel: .medium
    ),
    .init(
        name: "Poison Sumac",
        scientificName: "Toxicodendron vernix",
        imageName: "poison_sumac",
        category: .tree,
        description: "Tall shrub or small tree with smooth gray bark; leaves in clusters of 7–13 leaflets.",
        symptoms: "Severe itching, redness, swelling, blisters; more potent than poison ivy or oak.",
        treatment: "Wash affected area immediately; use topical corticosteroids; seek medical attention if severe.",
        dangerLevel: .high
    ),
    .init(
        name: "Water Hemlock",
        scientificName: "Cicuta maculata",
        imageName: "water_hemlock",
        category: .wild,
        description: "One of the most toxic plants in North America; white umbrella-shaped flower clusters, purple-streaked stems, often near wet areas.",
        symptoms: "Violent seizures, nausea, vomiting, abdominal pain, respiratory failure.",
        treatment: "Call emergency services immediately — this is a medical emergency.",
        dangerLevel: .high
    ),
    .init(
        name: "Poison Hemlock",
        scientificName: "Conium maculatum",
        imageName: "poison_hemlock",
        category: .wild,
        description: "Tall biennial with fern-like leaves, small white flower clusters, and purple-blotched stems; often confused with wild carrot or parsley.",
        symptoms: "Muscle paralysis ascending from the legs, tremors, respiratory failure; can be fatal if ingested.",
        treatment: "Seek emergency medical care immediately; do not induce vomiting.",
        dangerLevel: .high
    ),
    .init(
        name: "Giant Hogweed",
        scientificName: "Heracleum mantegazzianum",
        imageName: "giant_hogweed",
        category: .wild,
        description: "Very large plant with thick, purple-blotched stems and huge umbrella-shaped white flower clusters; sap is phototoxic.",
        symptoms: "Severe skin burns and blistering when sap contacts skin and is exposed to sunlight; possible scarring and eye damage.",
        treatment: "Wash skin thoroughly, avoid sunlight on the area, and seek medical attention for burns; flush eyes with water immediately if exposed.",
        dangerLevel: .high
    ),
    .init(
        name: "Death Camas",
        scientificName: "Toxicoscordion venenosum",
        imageName: "death_camas",
        category: .wild,
        description: "Grass-like plant with creamy white flower clusters; bulbs closely resemble edible wild onions but lack the onion smell.",
        symptoms: "Nausea, vomiting, low blood pressure, weakness, and cardiac arrhythmia.",
        treatment: "Seek emergency medical care immediately.",
        dangerLevel: .high
    ),
    .init(
        name: "White Snakeroot",
        scientificName: "Ageratina altissima",
        imageName: "white_snakeroot",
        category: .wild,
        description: "Woodland perennial with clusters of small white flowers; toxic to livestock and, historically, to humans via contaminated milk.",
        symptoms: "Tremors, weakness, vomiting, and (via milk sickness) potential fatality.",
        treatment: "Seek medical attention if ingestion is suspected.",
        dangerLevel: .medium
    ),
    .init(
        name: "Stinging Nettle",
        scientificName: "Urtica dioica",
        imageName: "stinging_nettle",
        category: .wild,
        description: "Common wild plant covered in fine hollow hairs that inject irritants on contact.",
        symptoms: "Immediate stinging, burning, redness, and localized hives.",
        treatment: "Rinse the area with water; over-the-counter antihistamines or hydrocortisone cream can ease symptoms.",
        dangerLevel: .low
    ),
    
    // MARK: Garden
    .init(
        name: "Deadly Nightshade",
        scientificName: "Atropa belladonna",
        imageName: "deadly_nightshade",
        category: .garden,
        description: "Bell-shaped purple flowers and shiny black berries; contains tropane alkaloids.",
        symptoms: "Dilated pupils, confusion, hallucinations, rapid heartbeat, seizures; can be fatal if ingested.",
        treatment: "Seek emergency medical care; do not induce vomiting.",
        dangerLevel: .high
    ),
    .init(
        name: "Foxglove",
        scientificName: "Digitalis purpurea",
        imageName: "foxglove",
        category: .garden,
        description: "Tall spikes of tubular, bell-shaped flowers; contains cardiac glycosides used medicinally in controlled doses.",
        symptoms: "Nausea, vomiting, irregular heartbeat, visual disturbances; can be fatal if ingested.",
        treatment: "Seek emergency medical care immediately.",
        dangerLevel: .high
    ),
    .init(
        name: "Monkshood",
        scientificName: "Aconitum napellus",
        imageName: "monkshood",
        category: .garden,
        description: "Tall plant with hood-shaped purple flowers; also called wolfsbane, among the most toxic garden plants.",
        symptoms: "Numbness and tingling, vomiting, cardiac arrhythmia, paralysis; can be fatal even from skin contact with sap.",
        treatment: "Seek emergency medical care immediately.",
        dangerLevel: .high
    ),
    .init(
        name: "Larkspur",
        scientificName: "Delphinium spp.",
        imageName: "larkspur",
        category: .garden,
        description: "Tall spikes of blue, purple, pink, or white flowers; all parts contain toxic alkaloids, young plants most potent.",
        symptoms: "Nausea, vomiting, muscle weakness, cardiac and respiratory issues.",
        treatment: "Seek medical attention if ingestion is suspected.",
        dangerLevel: .high
    ),
    .init(
        name: "Autumn Crocus",
        scientificName: "Colchicum autumnale",
        imageName: "autumn_crocus",
        category: .garden,
        description: "Crocus-like pink or purple flowers that bloom in fall without leaves; contains colchicine.",
        symptoms: "Burning in mouth and throat, vomiting, diarrhea, organ failure in severe cases; can be fatal.",
        treatment: "Seek emergency medical care immediately.",
        dangerLevel: .high
    ),
    .init(
        name: "Castor Bean",
        scientificName: "Ricinus communis",
        imageName: "castor_bean",
        category: .garden,
        description: "Large ornamental plant with spiky seed pods; seeds contain ricin, one of the most toxic natural substances.",
        symptoms: "Severe vomiting, diarrhea, dehydration, organ failure; a few chewed seeds can be fatal.",
        treatment: "Seek emergency medical care immediately.",
        dangerLevel: .high
    ),
    .init(
        name: "Rosary Pea",
        scientificName: "Abrus precatorius",
        imageName: "rosary_pea",
        category: .garden,
        description: "Vine with small red-and-black seeds often used in jewelry; seeds contain abrin, extremely toxic if the seed coat is broken.",
        symptoms: "Nausea, vomiting, seizures, organ failure; a single chewed seed can be lethal.",
        treatment: "Seek emergency medical care immediately.",
        dangerLevel: .high
    ),
    .init(
        name: "Angel's Trumpet",
        scientificName: "Brugmansia spp.",
        imageName: "angels_trumpet",
        category: .garden,
        description: "Large, fragrant, trumpet-shaped hanging flowers; contains tropane alkaloids similar to jimsonweed.",
        symptoms: "Hallucinations, dilated pupils, rapid heartbeat, delirium, seizures.",
        treatment: "Seek emergency medical care immediately.",
        dangerLevel: .high
    ),
    .init(
        name: "Jimsonweed",
        scientificName: "Datura stramonium",
        imageName: "jimsonweed",
        category: .garden,
        description: "Trumpet-shaped white or purple flowers and spiny seed pods; contains potent tropane alkaloids.",
        symptoms: "Hallucinations, extreme confusion, rapid heartbeat, seizures; can be fatal.",
        treatment: "Seek emergency medical care immediately.",
        dangerLevel: .high
    ),
    .init(
        name: "Lily of the Valley",
        scientificName: "Convallaria majalis",
        imageName: "lily_of_the_valley",
        category: .garden,
        description: "Small, fragrant, bell-shaped white flowers on arching stems; contains cardiac glycosides.",
        symptoms: "Nausea, vomiting, irregular heartbeat, confusion; can be fatal if ingested in quantity.",
        treatment: "Seek medical attention immediately.",
        dangerLevel: .high
    ),
    .init(
        name: "Pokeweed",
        scientificName: "Phytolacca americana",
        imageName: "pokeweed",
        category: .garden,
        description: "Tall plant with clusters of dark purple berries on bright pink stems; roots and mature leaves are most toxic.",
        symptoms: "Vomiting, diarrhea, cramping, low blood pressure.",
        treatment: "Seek medical attention if ingestion is suspected, especially in children.",
        dangerLevel: .medium
    ),
    .init(
        name: "Buttercup",
        scientificName: "Ranunculus spp.",
        imageName: "buttercup",
        category: .garden,
        description: "Common glossy yellow wildflower; sap contains an irritant compound that breaks down when dried.",
        symptoms: "Mouth and GI irritation if chewed, skin irritation from sap.",
        treatment: "Rinse skin or mouth with water; symptoms are usually mild and self-limited.",
        dangerLevel: .low
    ),
    .init(
        name: "Hydrangea",
        scientificName: "Hydrangea macrophylla",
        imageName: "hydrangea",
        category: .garden,
        description: "Popular ornamental shrub with large round flower clusters; leaves and buds contain cyanogenic compounds.",
        symptoms: "Nausea, vomiting, diarrhea, weakness if a significant amount is ingested.",
        treatment: "Seek medical attention if a large quantity is ingested; most cases are mild.",
        dangerLevel: .low
    ),
    
    // MARK: Trees / Shrubs
    .init(
        name: "Oleander",
        scientificName: "Nerium oleander",
        imageName: "oleander",
        category: .tree,
        description: "Evergreen shrub with narrow leaves and clusters of pink, white, or red flowers; every part is toxic, including smoke from burning it.",
        symptoms: "Nausea, vomiting, irregular heartbeat, drowsiness; can be fatal even in small amounts.",
        treatment: "Seek emergency medical care immediately.",
        dangerLevel: .high
    ),
    .init(
        name: "Yew",
        scientificName: "Taxus baccata",
        imageName: "yew",
        category: .tree,
        description: "Evergreen conifer with flat needles and red berry-like arils; needles and seeds are highly toxic (the red aril flesh is not).",
        symptoms: "Dizziness, dry mouth, cardiac arrhythmia, cardiac arrest; can be fatal.",
        treatment: "Seek emergency medical care immediately.",
        dangerLevel: .high
    ),
    .init(
        name: "Manchineel",
        scientificName: "Hippomane mancinella",
        imageName: "manchineel",
        category: .tree,
        description: "Caribbean and Florida coastal tree with small green apple-like fruit; sap is extremely caustic and trees are often marked with warning signs.",
        symptoms: "Severe blistering on skin contact, blindness from eye contact, and severe internal burns and possible death if fruit is eaten.",
        treatment: "Avoid all contact; if exposed, rinse thoroughly and seek emergency medical care.",
        dangerLevel: .high
    ),
    .init(
        name: "Rhododendron / Azalea",
        scientificName: "Rhododendron spp.",
        imageName: "rhododendron",
        category: .tree,
        description: "Popular flowering shrub with clusters of showy blooms; leaves and nectar contain grayanotoxins.",
        symptoms: "Nausea, vomiting, low blood pressure, irregular heart rhythm; even honey made from the nectar can cause illness.",
        treatment: "Seek medical attention if ingestion is suspected.",
        dangerLevel: .medium
    ),
    .init(
        name: "Mistletoe",
        scientificName: "Viscum album / Phoradendron spp.",
        imageName: "mistletoe",
        category: .tree,
        description: "Parasitic plant with white berries, commonly used as a holiday decoration.",
        symptoms: "Nausea, vomiting, low blood pressure; berries are more toxic than leaves.",
        treatment: "Seek medical attention if a significant amount is ingested, especially by children or pets.",
        dangerLevel: .medium
    ),
    .init(
        name: "Holly",
        scientificName: "Ilex aquifolium",
        imageName: "holly",
        category: .tree,
        description: "Evergreen shrub with spiny leaves and bright red berries, common in holiday decor.",
        symptoms: "Vomiting, diarrhea, and drowsiness if berries are eaten in quantity.",
        treatment: "Symptoms are usually mild; seek medical attention if a large amount is ingested.",
        dangerLevel: .low
    ),
    .init(
        name: "Cerbera / Suicide Tree",
        scientificName: "Cerbera odollam",
        imageName: "cerbera_odollam",
        category: .tree,
        description: "Southeast Asian tree with fragrant white flowers and mango-like fruit; seeds contain potent cardiac glycosides.",
        symptoms: "Vomiting, cardiac arrhythmia, cardiac arrest; historically responsible for many fatal poisonings.",
        treatment: "Seek emergency medical care immediately.",
        dangerLevel: .high
    ),
    
    // MARK: Houseplants
    .init(
        name: "Dumb Cane",
        scientificName: "Dieffenbachia seguine",
        imageName: "dumb_cane",
        category: .houseplant,
        description: "Common houseplant with large variegated leaves; contains calcium oxalate crystals.",
        symptoms: "Intense burning and swelling of the mouth and throat if chewed, drooling, difficulty speaking or swallowing.",
        treatment: "Rinse mouth with water, seek medical attention if swelling affects breathing.",
        dangerLevel: .medium
    ),
    .init(
        name: "Peace Lily",
        scientificName: "Spathiphyllum spp.",
        imageName: "peace_lily",
        category: .houseplant,
        description: "Popular houseplant with glossy leaves and white hooded flowers; contains calcium oxalate crystals like dieffenbachia.",
        symptoms: "Burning mouth, drooling, difficulty swallowing, mild GI upset.",
        treatment: "Rinse mouth with water; seek medical attention if swelling is severe.",
        dangerLevel: .low
    ),
    .init(
        name: "Philodendron",
        scientificName: "Philodendron spp.",
        imageName: "philodendron",
        category: .houseplant,
        description: "Trailing or climbing houseplant with heart-shaped leaves; contains calcium oxalate crystals.",
        symptoms: "Mouth and throat irritation, drooling, swelling if chewed.",
        treatment: "Rinse mouth with water; seek medical attention if symptoms are severe, especially in pets.",
        dangerLevel: .low
    ),
    .init(
        name: "Sago Palm",
        scientificName: "Cycas revoluta",
        imageName: "sago_palm",
        category: .houseplant,
        description: "Popular ornamental palm-like plant; all parts are toxic, seeds most of all — especially dangerous to pets.",
        symptoms: "Vomiting, diarrhea, liver failure; can be fatal, particularly to dogs.",
        treatment: "Seek emergency medical or veterinary care immediately.",
        dangerLevel: .high
    ),
    .init(
        name: "English Ivy",
        scientificName: "Hedera helix",
        imageName: "english_ivy",
        category: .houseplant,
        description: "Common trailing or climbing vine grown indoors and outdoors; leaves contain irritant saponins.",
        symptoms: "Vomiting, diarrhea, skin irritation from contact with leaves or sap.",
        treatment: "Wash skin with water; seek medical attention if a large amount is ingested.",
        dangerLevel: .low
    ),
]

// MARK: - AI Configuration
enum AIProvider {
    case anthropic
    case openai
}

/// Centralizes API key access. **Never hardcode real keys in source or commit them to git.**
///
/// Setup:
/// 1. Create a `Secrets.xcconfig` file (add it to `.gitignore`) with:
///        ANTHROPIC_API_KEY = sk-ant-...
///        OPENAI_API_KEY = sk-...
/// 2. Reference `Secrets.xcconfig` from your target's build configuration.
/// 3. Add matching keys to your target's Info.plist as:
///        ANTHROPIC_API_KEY = $(ANTHROPIC_API_KEY)
///        OPENAI_API_KEY = $(OPENAI_API_KEY)
/// This keeps the actual key values out of source control while still letting the
/// app read them at runtime via Bundle.main. For extra safety in production, proxy
/// these calls through your own backend instead of embedding a client-side key.
enum APIConfig {
    static var anthropicAPIKey: String {
        Bundle.main.object(forInfoDictionaryKey: "ANTHROPIC_API_KEY") as? String ?? ""
    }
    
    static var openAIAPIKey: String {
        Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String ?? ""
    }
    
    /// Which provider PlantClassifier uses. Swap this to try the other backend.
    static let activeProvider: AIProvider = .anthropic
    
    static func makeVisionService() -> PlantVisionService {
        switch activeProvider {
        case .anthropic:
            return AnthropicVisionService(apiKey: anthropicAPIKey)
        case .openai:
            return OpenAIVisionService(apiKey: openAIAPIKey)
        }
    }
}

// MARK: - AI Result Model
struct PlantIdentification: Decodable, Equatable {
    let commonName: String
    let scientificName: String
    let isPoisonous: Bool
    let dangerLevel: String
    let confidence: Double
    let reasoning: String
}

enum PlantVisionError: LocalizedError {
    case missingAPIKey
    case invalidImage
    case requestFailed(String)
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "No API key configured. Add ANTHROPIC_API_KEY / OPENAI_API_KEY to your Info.plist (see APIConfig)."
        case .invalidImage:
            return "Couldn't prepare that image for analysis."
        case .requestFailed(let message):
            return message
        case .invalidResponse:
            return "Received an unexpected response. Please try again."
        }
    }
}

enum PlantVisionPrompt {
    static let system = """
    You are a careful botanist and plant-safety expert. When shown a photo of a plant, \
    identify it as specifically as you reasonably can, and determine whether it is \
    poisonous, toxic, or an irritant to humans on contact or if ingested.
    
    Be conservative: if the plant closely resembles a known toxic species but you can't \
    be fully certain of the exact species, still flag it as possibly poisonous and lower \
    your confidence score rather than guessing it's safe. If you cannot identify the plant \
    at all, set commonName to "Unknown Plant" and explain why in your reasoning.
    
    Respond with ONLY a raw JSON object — no markdown code fences, no prose before or after \
    — matching exactly this schema:
    {"commonName": "string", "scientificName": "string", "isPoisonous": true, "dangerLevel": "low", "confidence": 0.0, "reasoning": "string"}
    dangerLevel must be exactly one of: "low", "medium", "high".
    """
    
    static let user = "Identify the plant in this photo and determine whether it's poisonous or dangerous to touch or ingest."
    
    /// Strips common wrapping (markdown fences, stray whitespace) models sometimes add
    /// despite being told to return raw JSON, then decodes it.
    static func decode(_ text: String) throws -> PlantIdentification {
        let cleaned = text
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard let data = cleaned.data(using: .utf8) else {
            throw PlantVisionError.invalidResponse
        }
        do {
            return try JSONDecoder().decode(PlantIdentification.self, from: data)
        } catch {
            throw PlantVisionError.invalidResponse
        }
    }
}

protocol PlantVisionService {
    func identify(image: UIImage) async throws -> PlantIdentification
}

// MARK: - Anthropic (Claude) vision backend
final class AnthropicVisionService: PlantVisionService {
    private let apiKey: String
    private let model: String
    
    init(apiKey: String, model: String = "claude-sonnet-5") {
        self.apiKey = apiKey
        self.model = model
    }
    
    func identify(image: UIImage) async throws -> PlantIdentification {
        guard !apiKey.isEmpty else { throw PlantVisionError.missingAPIKey }
        guard let jpegData = image.jpegData(compressionQuality: 0.7) else {
            throw PlantVisionError.invalidImage
        }
        let base64Image = jpegData.base64EncodedString()
        
        var request = URLRequest(url: URL(string: "https://api.anthropic.com/v1/messages")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        
        let body: [String: Any] = [
            "model": model,
            "max_tokens": 500,
            "system": PlantVisionPrompt.system,
            "messages": [
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "image",
                            "source": [
                                "type": "base64",
                                "media_type": "image/jpeg",
                                "data": base64Image
                            ]
                        ],
                        [
                            "type": "text",
                            "text": PlantVisionPrompt.user
                        ]
                    ]
                ]
            ]
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            let message = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw PlantVisionError.requestFailed("Anthropic API error: \(message)")
        }
        
        struct AnthropicResponse: Decodable {
            struct ContentBlock: Decodable { let type: String; let text: String? }
            let content: [ContentBlock]
        }
        
        let decoded = try JSONDecoder().decode(AnthropicResponse.self, from: data)
        guard let text = decoded.content.first(where: { $0.type == "text" })?.text else {
            throw PlantVisionError.invalidResponse
        }
        return try PlantVisionPrompt.decode(text)
    }
}

// MARK: - OpenAI vision backend
final class OpenAIVisionService: PlantVisionService {
    private let apiKey: String
    private let model: String
    
    init(apiKey: String, model: String = "gpt-4o") {
        self.apiKey = apiKey
        self.model = model
    }
    
    func identify(image: UIImage) async throws -> PlantIdentification {
        guard !apiKey.isEmpty else { throw PlantVisionError.missingAPIKey }
        guard let jpegData = image.jpegData(compressionQuality: 0.7) else {
            throw PlantVisionError.invalidImage
        }
        let dataURI = "data:image/jpeg;base64,\(jpegData.base64EncodedString())"
        
        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "model": model,
            "response_format": ["type": "json_object"],
            "messages": [
                ["role": "system", "content": PlantVisionPrompt.system],
                [
                    "role": "user",
                    "content": [
                        ["type": "text", "text": PlantVisionPrompt.user],
                        ["type": "image_url", "image_url": ["url": dataURI]]
                    ]
                ]
            ]
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            let message = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw PlantVisionError.requestFailed("OpenAI API error: \(message)")
        }
        
        struct OpenAIResponse: Decodable {
            struct Choice: Decodable {
                struct Message: Decodable { let content: String }
                let message: Message
            }
            let choices: [Choice]
        }
        
        let decoded = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        guard let text = decoded.choices.first?.message.content else {
            throw PlantVisionError.invalidResponse
        }
        return try PlantVisionPrompt.decode(text)
    }
}

// MARK: - Classifier (cloud AI vision)
/// Sends the captured photo to a cloud vision-capable LLM (Anthropic or OpenAI, per
/// APIConfig.activeProvider) for real species-level plant identification. This makes
/// a network request and requires a valid API key — see APIConfig for setup.
@MainActor
final class PlantClassifier: ObservableObject {
    @Published var result: PlantIdentification?
    @Published var isAnalyzing = false
    @Published var errorMessage: String?
    
    private let service: PlantVisionService
    
    init(service: PlantVisionService = APIConfig.makeVisionService()) {
        self.service = service
    }
    
    func analyze(_ uiImage: UIImage) async {
        errorMessage = nil
        result = nil
        isAnalyzing = true
        defer { isAnalyzing = false }
        
        do {
            result = try await service.identify(image: uiImage)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

// MARK: - Scanner View (Camera/Photo picker + cloud AI result)
struct PlantScannerView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var classifier = PlantClassifier()
    @State private var showCamera = false
    @State private var pickedItem: PhotosPickerItem? = nil
    @State private var image: UIImage? = nil
    
    /// If the AI's identified common or scientific name matches something in our local
    /// database, we can link straight to the full symptoms/treatment detail page.
    private var matchedPlant: PoisonousPlant? {
        guard let result = classifier.result else { return nil }
        return demoPlants.first { plant in
            plant.name.localizedCaseInsensitiveContains(result.commonName) ||
            result.commonName.localizedCaseInsensitiveContains(plant.name) ||
            (result.scientificName.lowercased() != "unknown" &&
             plant.scientificName.localizedCaseInsensitiveContains(result.scientificName))
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    Group {
                        if let img = image {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.secondary.opacity(0.2)))
                                .overlay {
                                    if classifier.isAnalyzing {
                                        ZStack {
                                            Color.black.opacity(0.25)
                                            ProgressView("Analyzing photo…")
                                                .tint(.white)
                                                .foregroundStyle(.white)
                                        }
                                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                    }
                                }
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
                    
                    if let errorMessage = classifier.errorMessage {
                        Label(errorMessage, systemImage: "exclamationmark.triangle")
                            .font(.subheadline)
                            .foregroundStyle(.orange)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    if let result = classifier.result {
                        resultCard(for: result)
                    }
                    
                    Spacer(minLength: 0)
                    
                    Label("AI scanning can make mistakes, please double-check.", systemImage: "exclamationmark.circle")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding()
            }
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
                    await classifier.analyze(uiImg)
                }
            }
        }
        .onChange(of: image) { _, newImg in
            guard let newImg else { return }
            Task { await classifier.analyze(newImg) }
        }
    }
    
    @ViewBuilder
    private func resultCard(for result: PlantIdentification) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("AI Identification", systemImage: "sparkles")
                .font(.headline)
            
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(result.commonName)
                        .font(.title3.bold())
                    if result.scientificName.lowercased() != "unknown" {
                        Text(result.scientificName)
                            .font(.subheadline)
                            .italic()
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                if let level = PoisonousPlant.DangerLevel(rawValue: result.dangerLevel.lowercased()) {
                    DangerTag(level: level)
                } else {
                    Text(result.isPoisonous ? "Poisonous" : "Likely Safe")
                        .font(.caption).bold()
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(result.isPoisonous ? Color.red.opacity(0.9) : Color.green.opacity(0.8))
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
            }
            
            HStack {
                Text("Confidence")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                ProgressView(value: result.confidence)
                    .tint(result.confidence > 0.6 ? .green : .orange)
                Text(String(format: "%.0f%%", result.confidence * 100))
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            
            Text(result.reasoning)
                .font(.subheadline)
            
            if let matchedPlant {
                Divider()
                NavigationLink(destination: PoisonousPlantDetailView(plant: matchedPlant)) {
                    Label("View full symptoms & treatment for \(matchedPlant.name)", systemImage: "book.pages")
                        .font(.subheadline.weight(.medium))
                }
            }
            
            Text("AI identification can be wrong. Always verify visually, and when in doubt, avoid contact. Not medical advice.")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
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

// MARK: - List/Grid UI with Scan button, search, and category/danger filters
struct PoisonousPlantsListView: View {
    @State private var showScanner: Bool = false
    @State private var hideTabBar: Bool = false
    @State private var searchText: String = ""
    @State private var selectedCategory: PoisonousPlant.Category? = nil
    @State private var selectedDanger: PoisonousPlant.DangerLevel? = nil
    
    let plants: [PoisonousPlant]
    
    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
    
    private var filteredPlants: [PoisonousPlant] {
        plants
            .filter { plant in
                selectedCategory == nil || plant.category == selectedCategory
            }
            .filter { plant in
                selectedDanger == nil || plant.dangerLevel == selectedDanger
            }
            .filter { plant in
                searchText.isEmpty ||
                plant.name.localizedCaseInsensitiveContains(searchText) ||
                plant.scientificName.localizedCaseInsensitiveContains(searchText)
            }
            .sorted { $0.dangerLevel > $1.dangerLevel }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                filterBar
                
                if filteredPlants.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                        Text("No plants match your filters")
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
                } else {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(filteredPlants) { plant in
                            NavigationLink(destination: PoisonousPlantDetailView(plant: plant)) {
                                PlantGridCell(plant: plant)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .searchable(text: $searchText, prompt: "Search plants")
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
            PlantScannerView()
        }
    }
    
    private var filterBar: some View {
        VStack(alignment: .leading, spacing: 10) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterChip(title: "All", isSelected: selectedCategory == nil) {
                        selectedCategory = nil
                    }
                    ForEach(PoisonousPlant.Category.allCases) { category in
                        FilterChip(title: category.rawValue, systemImage: category.icon, isSelected: selectedCategory == category) {
                            selectedCategory = (selectedCategory == category) ? nil : category
                        }
                    }
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterChip(title: "Any Danger", isSelected: selectedDanger == nil) {
                        selectedDanger = nil
                    }
                    ForEach(PoisonousPlant.DangerLevel.allCases, id: \.self) { level in
                        FilterChip(title: level.rawValue.capitalized, isSelected: selectedDanger == level) {
                            selectedDanger = (selectedDanger == level) ? nil : level
                        }
                    }
                }
            }
        }
    }
}

private struct PlantGridCell: View {
    let plant: PoisonousPlant
    
    var body: some View {
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
            
            VStack(alignment: .leading, spacing: 4) {
                Text(plant.name)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(plant.scientificName)
                    .font(.caption2)
                    .italic()
                    .foregroundStyle(.secondary)
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

private struct FilterChip: View {
    let title: String
    var systemImage: String? = nil
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let systemImage {
                    Image(systemName: systemImage)
                }
                Text(title)
            }
            .font(.caption.weight(.medium))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.accentColor : Color(.secondarySystemBackground))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
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
                    VStack(alignment: .leading, spacing: 2) {
                        Text(plant.name).font(.largeTitle).bold()
                        Text(plant.scientificName)
                            .font(.subheadline)
                            .italic()
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    DangerTag(level: plant.dangerLevel)
                }
                
                Label(plant.category.rawValue, systemImage: plant.category.icon)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
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
        NavigationStack {
            PoisonousPlantsListView(plants: demoPlants)
        }
    }
}

#Preview {
    PoisonousPlantsEntryView()
}
