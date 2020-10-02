//
//  TaskListViewController.swift
//  CoreDataDemoApp
//
//  Created by Alexey Efimov on 30.09.2020.
//

import UIKit
import CoreData

class TaskListViewController: UITableViewController {
    
    private let storageManager = StorageManager.shared
    private let context = (UIApplication.shared.delegate as! AppDelegate).storageManager.persistentContainer.viewContext
    
    private let cellID = "cell"
    private var tasks: [Task] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigationBar()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
        tableView.reloadData()
    }
    
    private func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Navigation bar appearance
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navBarAppearance.backgroundColor = UIColor(
            red: 21/255,
            green: 101/255,
            blue: 192/255,
            alpha: 194/255
        )
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        // Add button to navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addTask)
        )
        
        navigationController?.navigationBar.tintColor = .white
    }
    
    @objc private func addTask() {
        /*
         let newTaskVC = NewTaskViewController()
         newTaskVC.modalPresentationStyle = .fullScreen
         present(newTaskVC, animated: true)
         */
        
        showAlert(with: "New Task", and: "What do you want to do?")
    }
    
    private func fetchData() {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        do {
            tasks = try context.fetch(fetchRequest)
        } catch let error {
            print(error)
        }
    }
    
    private func showAlert(with title: String, and message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
            self.save(task)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
        
    }
    
    private func save(_ task: String) {
        storageManager.save(task) { task in
            self.tasks.append(task)
        }
        let cellIndex = IndexPath(row: tasks.count - 1, section: 0)
        tableView.insertRows(at: [cellIndex], with: .automatic)
        
    }
    
    private func showAlertUpdate(with title: String, and message: String, index: Int) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let updateAction = UIAlertAction(title: "Update", style: .default) { _ in
            guard let nameTask = alert.textFields?.first?.text else { return }
            self.update(index, nameTask)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addTextField { (text) in
            text.text = self.tasks[index].name
        }
        alert.addAction(updateAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func update(_ index: Int,_ nameTask: String) {
        let task = tasks[index]
        storageManager.update(task, nameTask)
        task.name = nameTask
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        let task = tasks[indexPath.row]
        cell.textLabel?.text = task.name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        if editingStyle == .delete {
            tasks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            storageManager.delete(task)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showAlertUpdate(with: "Update", and: "Edit task", index: indexPath.row)
    }
}
