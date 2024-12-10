//
//  PhotosPickerView.swift
//  SocialNet
//
//  Created by Роман Лешин on 10.12.2024.
//

import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct PhotosPickerView: UIViewControllerRepresentable {
    @Binding var selectedMediaType: UTType?
    @Binding var attachmentData: Data?

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = PHPickerFilter.any(of: [.images, .videos])
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotosPickerView
        
        init(_ parent: PhotosPickerView) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard let provider = results.first?.itemProvider else { return }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                parent.selectedMediaType = .image
                provider.loadObject(ofClass: UIImage.self) { object, error in
                    if let error = error {
                        print("Ошибка загрузки изображения: \(error.localizedDescription)")
                        return
                    }
                    guard let image = object as? UIImage, let data = image.jpegData(compressionQuality: 1.0) else { return }
                    DispatchQueue.main.async {
                        self.parent.attachmentData = data
                    }
                }
            } else if provider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                provider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { url, error in
                    if let error = error {
                        print("Ошибка загрузки видео: \(error.localizedDescription)")
                        return
                    }
                    guard let url = url else { return }
                    do {
                        let data = try Data(contentsOf: url)
                        DispatchQueue.main.async {
                            self.parent.attachmentData = data
                            self.parent.selectedMediaType = .video
                        }
                    } catch {
                        print("Ошибка преобразования видео в данные: \(error.localizedDescription)")
                    }
                }
            } else {
                print("Тип медиафайла не поддерживается.")
            }
        }
    }
}
