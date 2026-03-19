import SwiftUI
import CoreLocation
import CoreData

struct PlantEditView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @Binding var plant: PlantRecord
    
    @State private var selectedDate: Date
    @State private var locationNameInput: String
    @State private var isSearching = false
    @State private var searchError: String?
    @State private var isUpdating = false
    
    init(plant: Binding<PlantRecord>) {
        self._plant = plant
        _selectedDate = State(initialValue: plant.wrappedValue.date)
        _locationNameInput = State(initialValue: plant.wrappedValue.locationName)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("発見日") {
                    DatePicker(
                        "発見日時",
                        selection: $selectedDate,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.graphical)
                }
                
                Section("発見場所") {
                    VStack(spacing: 12) {
                        TextField("発見場所を入力", text: $locationNameInput)
                            .textFieldStyle(.roundedBorder)
                            .padding(.vertical, 4)
                        
                        if let error = searchError {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        
                        HStack(spacing: 12) {
                            Button(action: {
                                Task {
                                    await searchLocation()
                                }
                            }) {
                                HStack(spacing: 8) {
                                    if isSearching {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                    } else {
                                        Image(systemName: "magnifyingglass")
                                    }
                                    Text(isSearching ? "検索中..." : "位置情報を検索")
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(AppTheme.darkGreen)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                            .disabled(isSearching || locationNameInput.isEmpty)
                        }
                        
                        if plant.latitude != 0 || plant.longitude != 0 {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("現在の位置情報")
                                    .font(.caption.bold())
                                    .foregroundColor(.secondary)
                                HStack(spacing: 8) {
                                    Image(systemName: "mappin.circle.fill")
                                        .foregroundColor(AppTheme.accentGreen)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(plant.locationName)
                                            .font(.body)
                                        Text("(\(String(format: "%.4f", plant.latitude)), \(String(format: "%.4f", plant.longitude)))")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(AppTheme.cardBackground)
                                .cornerRadius(8)
                            }
                        }
                    }
                }
            }
            .navigationTitle("発見情報を編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        Task {
                            await savePlantChanges()
                        }
                    }) {
                        if isUpdating {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Text("保存")
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(plant.isDeleted || isUpdating || (selectedDate == plant.date && locationNameInput == plant.locationName))
                }
            }
            .background(AppTheme.background)
        }
        .onAppear {
            if plant.isDeleted {
                dismiss()
            }
        }
    }
    
    private func searchLocation() async {
        guard !locationNameInput.isEmpty else { return }
        
        isSearching = true
        searchError = nil
        
        do {
            // 住所文字列から位置情報を取得（ジオコーディング）
            let geocoder = CLGeocoder()
            let placemarks = try await geocoder.geocodeAddressString(locationNameInput)
            
            if let placemark = placemarks.first, let location = placemark.location {
                // 位置情報を更新
                plant.latitude = location.coordinate.latitude
                plant.longitude = location.coordinate.longitude
                
                // デバッグ出力
                print("[PlantEdit] ジオコーディング成功: \(locationNameInput) -> \(location.coordinate.latitude), \(location.coordinate.longitude)")
                searchError = "✓ 位置情報を取得しました"
                
                // 0.5秒後にエラーメッセージをクリア
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    searchError = nil
                }
            } else {
                searchError = "位置情報が見つかりません"
                print("[PlantEdit] ジオコーディング失敗: \(locationNameInput)")
            }
        } catch {
            searchError = "検索に失敗しました"
            print("[PlantEdit] ジオコーディングエラー: \(error.localizedDescription)")
        }
        
        isSearching = false
    }
    
    private func savePlantChanges() async {
        isUpdating = true
        
        do {
            // PlantRecord を更新
            plant.date = selectedDate
            plant.locationName = locationNameInput
            
            // CoreData に保存
            try managedObjectContext.save()
            
            print("[PlantEdit] 変更を保存しました")
            print("[PlantEdit] 発見日: \(selectedDate)")
            print("[PlantEdit] 発見場所: \(locationNameInput)")
            print("[PlantEdit] 位置情報: (\(plant.latitude), \(plant.longitude))")
            
            isUpdating = false
            dismiss()
        } catch {
            print("[PlantEdit] 保存エラー: \(error.localizedDescription)")
            isUpdating = false
        }
    }
}
