import SwiftUI
import PhotosUI

struct ProfileHeaderView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @State private var selectedItem: PhotosPickerItem?
    
    var body: some View {
        Button(action: {
            if !viewModel.isEditMode {
                viewModel.enterEditMode()
            }
        }) {
            VStack(spacing: 12) {
                // Profile image with PhotosPicker
                ZStack {
                    if let avatar = viewModel.avatar {
                        Image(uiImage: avatar)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .foregroundColor(viewModel.ikisanGreen)
                    }
                    
                    if viewModel.isEditMode {
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            Circle()
                                .fill(Color.black.opacity(0.3))
                                .frame(width: 80, height: 80)
                                .overlay(
                                    Image(systemName: "camera.fill")
                                        .foregroundColor(.white)
                                        .font(.system(size: 24))
                                )
                        }
                    }
                }
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(viewModel.isEditMode ? viewModel.ikisanGreen : Color.clear, lineWidth: 2)
                )
                .padding(.top, 8)
                
                if viewModel.isEditMode {
                    TextField("Name", text: $viewModel.editName)
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Text(viewModel.email)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    TextField("Phone", text: $viewModel.editPhone)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                } else {
                    Text(viewModel.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(viewModel.email)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(viewModel.phone)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .onChange(of: selectedItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    await MainActor.run {
                        viewModel.updateAvatar(with: uiImage)
                    }
                }
            }
        }
    }
}
