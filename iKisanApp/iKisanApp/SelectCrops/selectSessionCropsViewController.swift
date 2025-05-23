//
//  OnBodingViewController.swift
//  iKisanApp
//
//  Created by Batch - 1 on 20/02/25.
//

import UIKit

class selectSessionCropsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var datacontroller = IKisanDataController()
    var cropList: [Crop] = []
    var selectedCrops: Set<String> = []
    var enteredText: [String: String] = [:]
    
    @IBOutlet weak var OnBoardingTableView: UITableView!
    
    @IBOutlet weak var continueButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the title with large appearance
        self.title = "Choose crops you sow"
        self.navigationItem.title = "Choose crops you sow"
        
        // Configure large title display
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
        
        // Ensure navigation bar is visible
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        cropList = datacontroller.getAllCropsForSelection()
        OnBoardingTableView.dataSource = self
        OnBoardingTableView.delegate = self
        OnBoardingTableView.register(UINib(nibName: "OnBoardingTableViewCell", bundle: nil), forCellReuseIdentifier: "OnBoardingTableViewCell")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cropList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "OnBoardingTableViewCell", for: indexPath) as? OnBoardingTableViewCell else {
            return UITableViewCell()
        }
        
        let crop = cropList[indexPath.row]
        let isSelected = selectedCrops.contains(crop.name)
        let text = enteredText[crop.name]
        
        cell.configure(with: crop, isSelected: isSelected, enteredText: text)
        
        // Handle text changes
        cell.onTextChanged = { [weak self] newText in
            if let newText = newText, !newText.isEmpty {
                self?.enteredText[crop.name] = newText
            } else {
                self?.enteredText.removeValue(forKey: crop.name)
            }
            // Reload cell to update height
            tableView.reloadRows(at: [indexPath], with: .none)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let crop = cropList[indexPath.row]
        let isSelected = selectedCrops.contains(crop.name)
        let hasText = enteredText[crop.name] != nil && !enteredText[crop.name]!.isEmpty
        
        // Cell should be expanded if:
        // 1. It's currently selected OR
        // 2. It has text entered
        return (isSelected || hasText) ? 95 : 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCrop = cropList[indexPath.row].name
        
        // Handle previous selection
        selectedCrops.forEach { previousSelectedCrop in
            if previousSelectedCrop != selectedCrop {
                // Only remove selection if there's no text
                if enteredText[previousSelectedCrop] == nil || enteredText[previousSelectedCrop]!.isEmpty {
                    selectedCrops.remove(previousSelectedCrop)
                }
            }
        }
        
        // Handle new selection
        if selectedCrops.contains(selectedCrop) {
            // If deselecting, only remove if no text
            if enteredText[selectedCrop] == nil || enteredText[selectedCrop]!.isEmpty {
                selectedCrops.remove(selectedCrop)
            }
        } else {
            selectedCrops.insert(selectedCrop)  // Allow checkmark even if no text
        }
        
        // Animate all changes
        UIView.animate(withDuration: 0.3) {
            tableView.performBatchUpdates({
                tableView.reloadData()
            })
        }
    }
    @IBAction func continueButtonTapped(_ sender: Any) {
        // Mark onboarding as completed
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        
        // Save selected crops if needed
        for crop in selectedCrops {
            if let text = enteredText[crop] {
                UserDefaults.standard.set(text, forKey: "crop_\(crop)")
            }
        }
        
        // Set all selected crops in the data controller
        datacontroller.setSelectedCrops(selectedCrops)
        
        // Switch to main interface
        if let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate {
            sceneDelegate.switchToMainInterface()
        }
    }
    
}
