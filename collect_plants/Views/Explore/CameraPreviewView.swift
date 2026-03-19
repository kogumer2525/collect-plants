import SwiftUI
import AVFoundation

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession
    let cameraService: CameraService?

    func makeUIView(context: Context) -> PreviewContainerView {
        let view = PreviewContainerView()
        view.cameraService = cameraService
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        view.previewLayer = previewLayer
        context.coordinator.previewLayer = previewLayer
        return view
    }

    func updateUIView(_ uiView: PreviewContainerView, context: Context) {
        context.coordinator.previewLayer?.frame = uiView.bounds
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        var previewLayer: AVCaptureVideoPreviewLayer?
    }
}

class PreviewContainerView: UIView {
    var previewLayer: AVCaptureVideoPreviewLayer?
    var cameraService: CameraService?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTapGesture()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTapGesture()
    }

    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tapGesture)
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let tapPoint = gesture.location(in: self)
        //print("[Preview] タップ検出: \(tapPoint)")
        
        cameraService?.focusAtPoint(tapPoint, in: bounds)
        
        // フォーカスフレームを描画
        drawFocusFrame(at: tapPoint)
    }
    
    private func drawFocusFrame(at point: CGPoint) {
        // 既存のフォーカスフレームを削除
        layer.sublayers?.removeAll { $0.name == "focusFrame" }
        
        let frameSize: CGFloat = 80
        let frameRect = CGRect(
            x: point.x - frameSize / 2,
            y: point.y - frameSize / 2,
            width: frameSize,
            height: frameSize
        )
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.name = "focusFrame"
        shapeLayer.path = UIBezierPath(rect: frameRect).cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.yellow.cgColor
        shapeLayer.lineWidth = 2
        
        layer.addSublayer(shapeLayer)
        //print("[Preview] フォーカスフレーム表示: \(frameRect)")
        
        // 1秒後にアニメーション付きで消す
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            CATransaction.begin()
            CATransaction.setCompletionBlock {
                shapeLayer.removeFromSuperlayer()
                //print("[Preview] フォーカスフレーム消去")
            }
            
            let fadeOut = CABasicAnimation(keyPath: "opacity")
            fadeOut.toValue = 0
            fadeOut.duration = 0.3
            shapeLayer.add(fadeOut, forKey: nil)
            
            CATransaction.commit()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = bounds
    }
}
