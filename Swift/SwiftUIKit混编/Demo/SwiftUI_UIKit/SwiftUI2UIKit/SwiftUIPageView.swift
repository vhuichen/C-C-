//
//  SwiftUIPageView.swift
//  SwiftUI_UIKit
//
//  Created by ChenHui on 2025/2/11.
//

import SwiftUI

struct SwiftUIPageView: View {
    @State private var isImagePickerPresented = false
    @State private var selectedImage: UIImage?
    
    var body: some View {
        VStack {
            Button("Select Image") {
                isImagePickerPresented = true
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            Text("Hello, World!")
            MyUILabel(text: isImagePickerPresented ? "点击图片" : "UIKit 嵌套 SwiftUI\n\nHello from UIKit!")
                .fixedSize()
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            } else {
                Text("No image selected")
            }
        }.sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(selectedImage: $selectedImage)
        }
    }
}

#Preview {
    SwiftUIPageView()
}

private struct MyUILabel: UIViewRepresentable {
    var text: String
    
    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.backgroundColor = .lightGray
        label.textAlignment = .center
        label.textColor = .red
        return label
    }
    
    func updateUIView(_ uiView: UILabel, context: Context) {
        uiView.text = text
        uiView.sizeToFit()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // 协调器类，用于处理 UIKit 视图的事件
    class Coordinator: NSObject {
        var parent: MyUILabel
        init(_ parent: MyUILabel) {
            self.parent = parent
        }
    }
    
}

// 1. 创建 UIViewControllerRepresentable 包装器
private struct ImagePicker: UIViewControllerRepresentable {
    // 2. 定义一个 Binding，用于将选中的图片传递回 SwiftUI
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    // 3. 实现 makeUIViewController 方法
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator // 设置代理
        picker.sourceType = .photoLibrary // 设置图片来源为相册
        return picker
    }
    
    // 4. 实现 updateUIViewController 方法
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // 这里可以更新 UIViewController 的状态
    }
    
    // 5. 创建 Coordinator 处理代理方法
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // 6. Coordinator 类
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        // 7. 处理图片选择完成的事件
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image // 将选中的图片传递给 SwiftUI
            }
            parent.presentationMode.wrappedValue.dismiss() // 关闭图片选择器
        }
        
        // 8. 处理取消选择的事件
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss() // 关闭图片选择器
        }
    }
}
