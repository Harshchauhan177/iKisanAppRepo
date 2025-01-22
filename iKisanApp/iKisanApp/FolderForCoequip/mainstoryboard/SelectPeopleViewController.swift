//
//  SelectViewController.swift
//  iKisanApp
//
//  Created by Batch - 1 on 22/01/25.
//

import UIKit

class SelectPeopleViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{
   
    

    @IBOutlet weak var selectPeopleListTable: UITableView!
    
    var peopleList: [Person] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        loadPeopleData()
        
    }
    func setupTableView() {
            selectPeopleListTable.delegate = self
            selectPeopleListTable.dataSource = self
//            selectPeopleListTable.register(UINib(nibName: "SelectPeopleTableViewCell", bundle: nil), forCellReuseIdentifier: "SelectPeopleCell")
        }

        func loadPeopleData() {
            peopleList = [
                Person(name: "John Doe", image: UIImage(named: "john")),
                Person(name: "Jane Smith", image: UIImage(named: "jane")),
                Person(name: "Alice Johnson", image: UIImage(named: "alice")),
                Person(name: "Robert Brown", image: UIImage(named: "robert"))
            ]
            selectPeopleListTable.reloadData()
        }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        peopleList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SelectPeopleCell", for: indexPath) as? SelectPeopleTableViewCell else {
                   return UITableViewCell()
               }
               let person = peopleList[indexPath.row]
               cell.configure(with: person)
               return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let selectedPerson = peopleList[indexPath.row]
            print("Selected: \(selectedPerson.name)")
        }

}

