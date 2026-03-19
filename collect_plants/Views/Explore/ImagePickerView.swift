import SwiftUI
import PhotosUI

struct ImagePickerView: UIViewControllerRepresentable {
    var completion: (UIImage, PHAsset?) -> Void
    @Environment(\.dismiss) var dismiss

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(completion: completion, dismiss: dismiss)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let completion: (UIImage, PHAsset?) -> Void
        let dismiss: DismissAction

        init(completion: @escaping (UIImage, PHAsset?) -> Void, dismiss: DismissAction) {
            self.completion = completion
            self.dismiss = dismiss
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            dismiss()
            
            guard let result = results.first else { return }
            
            var phAsset: PHAsset?
            if let assetID = result.assetIdentifier {
                print("[ImagePicker] Using assetIdentifier: \(assetID)")
                phAsset = PHAsset.fetchAssets(withLocalIdentifiers: [assetID], options: nil).firstObject
            } else {
                print("[ImagePicker] assetIdentifier is nil, fetching latest image")
                let options = PHFetchOptions()
                options.sortDescriptors = [NSSortDescriptor(keyPath: \PHAsset.creationDate, ascending: false)]
                options.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
                let assets = PHAsset.fetchAssets(with: options)
                if assets.count > 0 {
                    phAsset = assets.firstObject
                    print("[ImagePicker] Found latest PHAsset")
                }
            }
            
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                if let image = image as? UIImage {
                    print("[ImagePicker] Image loaded successfully")
                    DispatchQueue.main.async {
                        self?.completion(image, phAsset)
                    }
                } else {
                    print("[ImagePicker] Failed to load image: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }
}
