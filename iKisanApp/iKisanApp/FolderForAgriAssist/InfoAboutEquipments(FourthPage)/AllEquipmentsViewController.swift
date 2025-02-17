import UIKit

class AllEquipmentsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var equipmentList: [EquipmentAgri] = []
    private var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        let screenWidth = view.bounds.width
        let itemWidth = (screenWidth - 48) / 2 // 48 = padding (16) * 3
        layout.itemSize = CGSize(width: itemWidth, height: 250)
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Register the same cell as used in the second section
        let cellNib = UINib(nibName: "InfoAboutEquipmentSection2CollectionViewCell", bundle: nil)
        collectionView.register(cellNib, forCellWithReuseIdentifier: "Second")
        
        view.addSubview(collectionView)
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return equipmentList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Second", for: indexPath) as? InfoAboutEquipmentSection2CollectionViewCell,
              let equipment = equipmentList[safe: indexPath.item] else {
            return UICollectionViewCell()
        }
        
        cell.configure(with: equipment)
        cell.layer.cornerRadius = 7
        return cell
    }
} 