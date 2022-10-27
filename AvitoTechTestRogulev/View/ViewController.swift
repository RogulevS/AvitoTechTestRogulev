//
//  ViewController.swift
//  AvitoTechTestRogulev
//
//  Created by Rogulev Sergey on 21.10.2022.
//

import UIKit
import CoreData

class ViewController: UIViewController {
        
    let cellIdentifier = Constants.Strings.cellIdentifier
    
    private var employees = [EmployeeModel]()
    private var employeesCoreData: [Employee] = []
    private let coreData = CoreData()
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        fetchData()
        if employees.isEmpty {
            loadData()
            deleteCash()
        }
    }
    
    
    private func configureTableView() {
        title = Constants.Strings.title
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func fetchData() {
        let context = coreData.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Employee> = Employee.fetchRequest()
        
        do {
            employeesCoreData = try context.fetch(fetchRequest)
            var fetchedEmployees = [EmployeeModel]()
            
            employeesCoreData.forEach { employee in
                guard let name = employee.name else { return }
                guard let phoneNumber = employee.phoneNumber else { return }
                guard let skills = employee.skills else { return }
                
                let modelObject = EmployeeModel(name: name,
                                                      phoneNumber: phoneNumber,
                                                      skills: skills)
                fetchedEmployees.append(modelObject)
            }
            employees = fetchedEmployees
            
            if !fetchedEmployees.isEmpty {
                deleteCash()
            }
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        } catch let error as NSError {
            DispatchQueue.main.async { [weak self] in
                self?.showAlert(message: Constants.Strings.error + error.localizedDescription)
            }
        }
    }
    
    
    private func loadData() {
        let parse = Parser()
        let url = Constants.Strings.urlString
        
        parse.loadData(url: url) { [weak self] (result: Result<DataModel, Error>) in
            
            switch result {
            case .success(let model):
                let company = model.company
                let employees = company.employees
                employees.forEach { employee in
                    let loadedEmployee = EmployeeModel(name: employee.name,
                                         phoneNumber: employee.phoneNumber,
                                         skills: employee.skills)
                    
                    self?.employees.append(loadedEmployee)
                    
                    self?.coreData.saveEmployee(name: employee.name,
                                              phoneNumber: employee.phoneNumber,
                                              skills: employee.skills,
                                              doCompletion: { taskObject in
                        self?.employeesCoreData.append(taskObject)
                    }, errorCompletion: { error in
                        DispatchQueue.main.async {
                            self?.showAlert(message: Constants.Strings.error)
                        }
                    })
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showAlert(message: Constants.Strings.error + error.localizedDescription)
                }
            }
        }
    }
    
    private func deleteCash() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3600) { [weak self] in
            self?.coreData.remove {
                self?.fetchData()
                self?.loadData()
            }
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: Constants.Strings.error, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: Constants.Strings.alertOkButton, style: .default)
        alert.addAction(action)
        self.present(alert, animated: true)
    }
}


//MARK: - UITableViewDelegate, UITableViewDataSource

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return employees.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! CustomCell
        
        let sorted = self.employees.sorted(by: { $0.name < $1.name })
        let employee = sorted[indexPath.row]
        
        cell.labelName.text = employee.name
        cell.labelSkills.text = Constants.Strings.skillsText + " \(employee.skills.joined(separator: ", "))"
        cell.labelPhone.text = Constants.Strings.phoneNumText + " \(employee.phoneNumber)"

        return cell
    }
}
    
    

