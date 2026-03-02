//
//  feedbackView.swift
//  ProLight
//
//  Created by Paul  on 7/26/25.
//

import SwiftUI
import MessageUI
import PhotosUI

struct feedbackView: View {
    @EnvironmentObject var appSubModel: appSubscriptionModel
    @AppStorage("isHapticsEnabled") private var isHapticsEnabled: Bool = true
    @Environment(\.presentationMode) var presentationMode
    @State private var isShowingMailView = false
    @State private var textBody: String = ""
    @State private var selectedTopic: String = "Feedback"
    private let topics = ["Feedback", "Question", "Request", "Bug Report", "Other"]
    
    @State private var selectedImage: UIImage? = nil
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var imageData: Data? = nil
    @State private var isKeyboardVisible = false
    @State private var hideTabBar: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                // MARK: - Topic Row
                LabeledContent("Topic") {
                    Picker("", selection: $selectedTopic) {
                        ForEach(topics, id: \.self) { topic in
                            Text(topic)
                        }
                    }
                    .tint(.gray)
                }
                
                // MARK: - Expanding TextField
                TextField("Enter text here...", text: $textBody, axis: .vertical)
                    .padding(.vertical, 8)
                    .frame(minHeight: 120, alignment: .top) /// <-- Ensures expansion
                
                Section(header: Text("Additional Info (Optional)"), footer: Text("Only send images related to your ''\(selectedTopic)''.")) {
                    HStack {
                        // MARK: - Image Preview
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 70, height: 70)
                                .cornerRadius(10)
                        }
                        
                        // MARK: - Image section
                        PhotosPicker(selection: $selectedItem, matching: .screenshots) {
                            Text("Select an image to attach...")
                        }
                        .onChange(of: selectedItem) { oldItem, newItem in
                            loadImage(from: newItem)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.gray)
                    }
                }
                
                // MARK: - Other sections
                Section(header: Text("Device Info")) {
                    LabeledContent("Device") {
                        Text("\(UIDevice.current.modelName)")
                    }
                    
                    LabeledContent("\(UIDevice.current.deviceOS)") {
                        Text("\(UIDevice.current.OSVersion)")
                    }
                }
                
                Section(header: Text("App Info")) {
                    LabeledContent("Name") {
                        Text(Bundle.main.appName)
                    }
                    
                    LabeledContent("Version") {
                        Text("\(Bundle.main.appVersion)")
                    }
                    
                    LabeledContent("Build") {
                        Text("\(Bundle.main.appBuild)")
                    }
                    
                    LabeledContent("Subscriber") {
                        Text(appSubModel.isSubscriptionActive ? "Yes" : "No")
                    }
                }
            }
            .onAppear {
                hideTabBar = true
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { _ in
                    isKeyboardVisible = true
                }
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                    isKeyboardVisible = false
                }
            }
            .onDisappear {
                NotificationCenter.default.removeObserver(self)
            }
            .navigationBarTitle("Send: \(selectedTopic)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    if #available(iOS 26.0, *) {
                        Button("Send", systemImage: "paperplane") {
                            isShowingMailView.toggle()
                            HapticManager.shared.notify(.impact(.light))
                        }
                        .disabled(textBody.isEmpty)
                        
                    } else {
                        Button("Send") {
                            isShowingMailView.toggle()
                            HapticManager.shared.notify(.impact(.light))
                        }
                        .disabled(textBody.isEmpty)
                    }
                }
            }
            .sheet(isPresented: $isShowingMailView) {
                MailView(
                    isShowing: $isShowingMailView,
                    recipient: "support@paulrodenjr.dev",
                    subject: "ProLight: \(selectedTopic)",
                    body: generateEmailBody(),
                    imageData: imageData
                ) {
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .hideFloatingTabBar(hideTabBar)
            
        }
    }
    
    // MARK: - Selection Screen
    struct TopicSelectionView: View {
        @Binding var selectedTopic: String
        let topics: [String]
        
        var body: some View {
            List {
                ForEach(topics, id: \.self) { topic in
                    Button {
                        selectedTopic = topic
                    } label: {
                        HStack {
                            Text(topic)
                            Spacer()
                            if selectedTopic == topic {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Topic")
        }
    }
    
    private func generateEmailBody() -> String {
        return """
            <html>
                  <body style="font-family: -apple-system; font-size: 16px; color: #ffffff; background-color: #000000;">
                    <p style="margin-bottom: 20px;">\(textBody)</p><br><br><br>
            
                    <table style="border-collapse: collapse; font-size: 16px;">
                      <tr><td><strong>Device:</strong></td><td style="padding-left: 15px;">\(UIDevice.current.modelName)</td></tr>
                      <tr><td><strong>\(UIDevice.current.deviceOS):</strong></td><td style="padding-left: 15px;">\(UIDevice.current.OSVersion)</td></tr>
                      <tr><td><strong>App:</strong></td><td style="padding-left: 15px;">\(Bundle.main.appName)</td></tr>
                      <tr><td><strong>Version:</strong></td><td style="padding-left: 15px;">\(Bundle.main.appVersion)</td></tr>
                      <tr><td><strong>Build:</strong></td><td style="padding-left: 15px;">\(Bundle.main.appBuild)</td></tr>
                      <tr><td><strong>Subscriber:</strong></td><td style="padding-left: 15px;">\(appSubModel.isSubscriptionActive ? "Yes" : "No")</td></tr>
                    </table>
                  </body>
                </html>
            """
    }
    
    // MARK: - Function to load image from PhotosPicker
    private func loadImage(from item: PhotosPickerItem?) {
        guard let item = item else { return }
        
        item.loadTransferable(type: Data.self) { result in
            switch result {
            case .success(let data):
                if let data = data, let uiImage = UIImage(data: data) {
                    selectedImage = uiImage
                    imageData = data
                }
            case .failure(let error):
                print("Error loading image: \(error)")
            }
        }
    }
}

#Preview {
    feedbackView()
}

// MARK: - MailView Wrapper
struct MailView: UIViewControllerRepresentable {
    @Binding var isShowing: Bool
    var recipient: String
    var subject: String
    var body: String
    var imageData: Data?
    var onDismiss: (() -> Void)?
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        var parent: MailView
        
        init(parent: MailView) {
            self.parent = parent
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true)
            parent.isShowing = false
            parent.onDismiss?()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.setToRecipients([recipient])
        mailComposeVC.setSubject(subject)
        mailComposeVC.setMessageBody(body, isHTML: true)
        mailComposeVC.mailComposeDelegate = context.coordinator
        
        // Attach the image if available
        if let imageData = imageData {
            mailComposeVC.addAttachmentData(imageData, mimeType: "image/jpeg", fileName: "feedback.jpg")
        }
        
        return mailComposeVC
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
}
