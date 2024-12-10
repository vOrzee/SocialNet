//
//  AudioPickerView.swift
//  SocialNet
//
//  Created by Роман Лешин on 10.12.2024.
//


import SwiftUI
import UniformTypeIdentifiers

struct AudioPickerView: UIViewControllerRepresentable {
    @Binding var audioData: Data?

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.audio])
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: AudioPickerView

        init(_ parent: AudioPickerView) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            
            // Попытка получить доступ к файлу
            do {
                if url.startAccessingSecurityScopedResource() {
                    defer {
                        url.stopAccessingSecurityScopedResource()
                    }
                    let data = try Data(contentsOf: url)
                    DispatchQueue.main.async {
                        self.parent.audioData = data
                    }
                } else {
                    print("Не удалось получить доступ к файлу.")
                }
            } catch {
                print("Ошибка загрузки аудиофайла: \(error.localizedDescription)")
            }
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            print("Выбор документа отменен.")
        }
    }
}
