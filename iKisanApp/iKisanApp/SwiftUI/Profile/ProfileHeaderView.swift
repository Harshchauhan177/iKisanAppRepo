import SwiftUI
import PhotosUI

struct ProfileHeaderView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @State private var selectedItem: PhotosPickerItem?
    
    var body: some View {
        VStack(spacing: 12) {
            // Profile image with PhotosPicker (accessible in both normal and edit modes)
            PhotosPicker(selection: $selectedItem, matching: .images) {
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
                    
                    // Dark overlay and camera icon for edit mode
                    if viewModel.isEditMode {
                        Circle()
                            .fill(Color.black.opacity(0.35))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Image(systemName: "camera.fill")
                                    .foregroundColor(.white)
                                    .font(.system(size: 24, weight: .medium))
                            )
                    } else {
                        // Subtle camera icon badge at bottom right of the image in normal mode
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Image(systemName: "camera.circle.fill")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .symbolRenderingMode(.multicolor)
                                    .foregroundStyle(viewModel.ikisanGreen, Color.white)
                                    .shadow(color: Color.black.opacity(0.15), radius: 2, x: 0, y: 1)
                            }
                        }
                        .frame(width: 80, height: 80)
                    }
                    
                    // Uploading loading overlay
                    if viewModel.isUploadingAvatar {
                        Circle()
                            .fill(Color.black.opacity(0.5))
                            .frame(width: 80, height: 80)
                            .overlay(
                                ProgressView()
                                    .tint(.white)
                                    .scaleEffect(1.0)
                            )
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(viewModel.ikisanGreen.opacity(0.3), lineWidth: 1.5)
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
                
                if !viewModel.address.isEmpty {
                    Text(viewModel.address)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
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
