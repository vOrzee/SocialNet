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
            guard let url = urls.first else {
                print("Не удалось получить URL выбранного файла.")
                return
            }
            
            print("Выбранный файл URL: \(url)")
            print("Путь к файлу: \(url.path)")
            print("Схема файла: \(url.scheme ?? "Нет схемы")")

            // Проверяем доступ к ресурсу
            if url.startAccessingSecurityScopedResource() {
                defer { url.stopAccessingSecurityScopedResource() }
                print("Доступ к защищенному ресурсу предоставлен.")
                
                // Копируем файл в локальное хранилище
                let fileManager = FileManager.default
                let destinationURL = fileManager.temporaryDirectory.appendingPathComponent(url.lastPathComponent)
                
                do {
                    if fileManager.fileExists(atPath: destinationURL.path) {
                        try fileManager.removeItem(at: destinationURL)
                    }
                    try fileManager.copyItem(at: url, to: destinationURL)
                    print("Файл успешно скопирован в локальное хранилище: \(destinationURL.path)")
                    
                    // Читаем данные из локального файла
                    let data = try Data(contentsOf: destinationURL)
                    DispatchQueue.main.async {
                        self.parent.audioData = data
                    }
                } catch {
                    print("Ошибка копирования файла: \(error.localizedDescription)")
                }
            } else {
                print("Не удалось получить доступ к защищенному ресурсу.")
            }
            
        }



        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            print("Пользователь отменил выбор файла")
        }
    }
}



//struct AudioPickerView2: UIViewControllerRepresentable {
//    @Binding var audioData: Data?
//
//    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
//        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.audio])
//        picker.delegate = context.coordinator
//        return picker
//    }
//
//    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    class Coordinator: NSObject, UIDocumentPickerDelegate {
//        let parent: AudioPickerView
//
//        init(_ parent: AudioPickerView) {
//            self.parent = parent
//        }
//
//        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
//            guard let url = urls.first else { return }
//            
//            // Попытка получить доступ к файлу
//            do {
//                if url.startAccessingSecurityScopedResource() {
//                    defer {
//                        url.stopAccessingSecurityScopedResource()
//                    }
//                    let data = try Data(contentsOf: url)
//                    DispatchQueue.main.async {
//                        self.parent.audioData = data
//                    }
//                } else {
//                    print("Не удалось получить доступ к файлу.")
//                }
//            } catch {
//                print("Ошибка загрузки аудиофайла: \(error.localizedDescription)")
//            }
//        }
//
//        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
//            print("Выбор документа отменен.")
//        }
//    }
//}
