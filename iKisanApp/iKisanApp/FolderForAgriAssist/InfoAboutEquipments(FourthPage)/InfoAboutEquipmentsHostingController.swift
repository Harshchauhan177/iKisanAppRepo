import UIKit
import SwiftUI

class InfoAboutEquipmentsHostingController: UIViewController {
    
    var selectedEquipmentId: UUID!
    var dataController: DataController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let swiftUIView = InfoAboutEquipmentsView(
            selectedEquipmentId: selectedEquipmentId,
            dataController: dataController
        )
        
        let hostingController = UIHostingController(rootView: swiftUIView)
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        hostingController.didMove(toParent: self)
    }
} 