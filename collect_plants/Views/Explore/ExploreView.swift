import SwiftUI
import PhotosUI

struct ExploreView: View {
    @State private var viewModel = ExploreViewModel()
    @State private var showImagePicker = false

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isIdentifying {
                    // ローディング画面
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(AppTheme.darkGreen)
                        
                        VStack(spacing: 8) {
                            Text("植物を識別中...")
                                .font(.headline)
                                .foregroundColor(AppTheme.darkGreen)
                            Text("しばらくお待ちください")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(AppTheme.background)
                } else if viewModel.showResult {
                    resultView
                } else {
                    cameraView
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("探す")
                        .font(.headline)
                        .foregroundColor(AppTheme.darkGreen)
                }
            }
            .toolbarBackground(AppTheme.cardBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .sheet(isPresented: $showImagePicker) {
                ImagePickerView { image, phAsset in
                    Task {
                        // ギャラリーから選択した場合は、デフォルト値を使用
                        // 発見日時は現在時刻、発見場所は不明
                        // 後から詳細画面で手入力修正可能
                        await viewModel.identifyFromGalleryImage(image)
                        showImagePicker = false
                    }
                }
            }
        }
    }

    private var cameraView: some View {
        ZStack {
            CameraPreviewView(session: viewModel.cameraService.session, cameraService: viewModel.cameraService)
                .ignoresSafeArea()
                .onAppear {
                    viewModel.cameraService.startSession()
                }
                .onDisappear {
                    viewModel.cameraService.stopSession()
                }

            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        viewModel.cameraService.switchCamera()
                    }) {
                        Image(systemName: "camera.rotate.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    .padding(.trailing, 16)
                    .padding(.top, 18)
                }

                Spacer()

                if viewModel.isIdentifying {
                    HStack(spacing: 10) {
                        ProgressView()
                            .tint(AppTheme.darkGreen)
                        Text("識別中...")
                            .font(.subheadline.bold())
                            .foregroundColor(AppTheme.darkGreen)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
                }

                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.white)
                        .font(.subheadline)
                        .padding()
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(12)
                        .padding()
                }

                VStack {
                    Spacer()
                    
                    ZStack {
                        // 撮影ボタン（中央）
                        Button(action: {
                            Task { await viewModel.captureAndIdentify() }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(AppTheme.primaryGradient)
                                    .frame(width: 80, height: 80)
                                    .shadow(color: AppTheme.accentGreen.opacity(0.5), radius: 8, x: 0, y: 4)
                                Circle()
                                    .stroke(Color.white, lineWidth: 3)
                                    .frame(width: 70, height: 70)
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(.white)
                            }
                        }
                        .disabled(viewModel.isIdentifying)
                        .frame(maxWidth: .infinity, alignment: .center)
                        
                        // ギャラリーボタン（右隅）
                        HStack {
                            Spacer()
                            Button(action: {
                                showImagePicker = true
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(Color.white.opacity(0.2))
                                        .frame(width: 60, height: 60)
                                    Image(systemName: "photo.fill")
                                        .font(.system(size: 22))
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(.trailing, 24)
                        }
                    }
                }
                .padding(.bottom, 36)
            }
        }
    }

    private var resultView: some View {
        ScrollView {
            VStack(spacing: 16) {
                if let image = viewModel.capturedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)
                        .cornerRadius(AppTheme.cornerRadius)
                        .shadow(color: AppTheme.accentGreen.opacity(0.2), radius: 8, x: 0, y: 3)
                        .padding(.horizontal)
                }

                if let selected = viewModel.selectedCandidate {
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "leaf.fill")
                                .foregroundColor(AppTheme.accentGreen)
                            Text(selected.plantName)
                                .font(.title2.bold())
                                .foregroundColor(AppTheme.darkGreen)
                        }
                        Text(selected.scientificName)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .italic()
                        Text("信頼度: \(selected.score.confidencePercentage)")
                            .font(.caption.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(AppTheme.accentGreen)
                            .cornerRadius(12)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .natureCardStyle()
                    .padding(.horizontal)
                }

                if viewModel.candidates.count > 1 {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "list.bullet")
                                .foregroundColor(AppTheme.accentGreen)
                            Text("他の候補")
                                .font(.headline)
                                .foregroundColor(AppTheme.darkGreen)
                        }
                        .padding(.horizontal)

                        ForEach(viewModel.candidates) { candidate in
                            Button(action: {
                                viewModel.selectCandidate(candidate)
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(candidate.plantName)
                                            .font(.body)
                                            .foregroundColor(.primary)
                                        Text(candidate.scientificName)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Text(candidate.score.confidencePercentage)
                                        .font(.caption.bold())
                                        .foregroundColor(AppTheme.accentGreen)
                                    if candidate.id == viewModel.selectedCandidate?.id {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(AppTheme.accentGreen)
                                    }
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                                        .fill(candidate.id == viewModel.selectedCandidate?.id
                                              ? AppTheme.primaryGreen.opacity(0.3)
                                              : AppTheme.background)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius)
                                                .stroke(AppTheme.primaryGreen.opacity(0.5), lineWidth: 1)
                                        )
                                )
                            }
                            .padding(.horizontal)
                        }
                    }
                }

                // PlantNet Attribution
                VStack(spacing: 10) {
                    if let image = UIImage(named: "plantnet_logo") {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 40)
                    }
                    
                    Text("The image-based plant species identification service used, is based on the Pl@ntNet recognition API, regularly updated and accessible through the site https://my.plantnet.org/")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(nil)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(AppTheme.cardBackground)
                .cornerRadius(AppTheme.cornerRadius)
                .padding(.horizontal)
                .padding(.vertical, 8)

                HStack(spacing: 16) {
                    Button("キャンセル") {
                        viewModel.resetState()
                    }
                    .font(.body.bold())
                    .foregroundColor(AppTheme.darkGreen)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                            .stroke(AppTheme.accentGreen, lineWidth: 1.5)
                    )

                    Button(action: {
                        Task { await viewModel.registerPlant() }
                    }) {
                        HStack {
                            if viewModel.isSaving {
                                ProgressView().tint(.white)
                            }
                            Text("登録する")
                                .font(.body.bold())
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                                .fill(AppTheme.accentGreen)
                        )
                        .shadow(color: AppTheme.accentGreen.opacity(0.4), radius: 4, x: 0, y: 2)
                    }
                    .disabled(viewModel.isSaving)
                }
                .padding()
            }
            .padding(.vertical)
        }
        .background(AppTheme.background)
        .navigationTitle("識別結果")
    }
}
