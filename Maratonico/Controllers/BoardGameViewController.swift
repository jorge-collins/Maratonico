//
//  BoardGameViewController.swift
//  Maratonico
//
//  Created by Jorge Collins Gómez on 20/07/22.
//

import UIKit
import CoreData
import ChameleonFramework

class BoardGameViewController: SwipeTableViewController {
    
    var boardGames = [BoardGame]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        
        // Descomentar la siguiente linea para obtener la ubicacion de la DB
        // print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!)
        // Descomentar las siguientes lineas subir los datos a la DB
        // let resultLoadCSV = loadCSV(from: "Clasico")
        // print(#line, "resultLoadCSV: \(resultLoadCSV)")

        loadBoardGames()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        guard let navBar = navigationController?.navigationBar else { fatalError("No existe navigationController.")}
        navBar.backgroundColor = UIColor.flatForestGreen()
        navBar.tintColor = ContrastColorOf(UIColor.flatForestGreen(), returnFlat: true)
    }

    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return boardGames.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = boardGames[indexPath.row].title
        
        if let colour = FlatGreen().darken(byPercentage: CGFloat(indexPath.row) / CGFloat(boardGames.count*4) ) {
            
            cell.backgroundColor = colour
            cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
        }
        
        return cell
    }

    
    //MARK: - Data manipulation methods
    
    func saveBoardGames() {
        
        do {
            try context.save()
        } catch {
            print("Error saveBoardGames \(error)")
        }
        
        // Cargamos desde CoreData para que se ordene cada que se actualiza
        loadBoardGames()
    }
    
    
    func loadBoardGames() {
            
        let request: NSFetchRequest<BoardGame> = BoardGame.fetchRequest()
        
        // Agregando el selector los ordena sin importar si estan en mayusculas o minusculas
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))
        
        request.sortDescriptors = [sortDescriptor]
        
        do {
            boardGames = try context.fetch(request)
        } catch {
            print("Error loadBoardGames \(error)")
        }
        
        tableView.reloadData()
    }
    
    
    //MARK: - Delete data from swipe
    
    override func updateModel(at indexPath: IndexPath) {
        
        self.context.delete(self.boardGames[indexPath.row])
        self.boardGames.remove(at: indexPath.row)

        do {
            try self.context.save()
        } catch {
            print("Error saveBoardGames \(error)")
        }
    }
    
    //MARK: - Delete all boards and questions
    
    @IBAction func deleteAllButtonPressed(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Confirmar", message: "Se borraran todos los tableros y preguntas", preferredStyle: .alert)
        let actionCancel = UIAlertAction(title: "Cancelar", style: .cancel) { action in
            self.dismiss(animated: true)
        }
        let actionConfirm = UIAlertAction(title: "Ok", style: .default) { action in
            self.deleteAllEntities()
            self.loadBoardGames()
        }
        alert.addAction(actionCancel)
        alert.addAction(actionConfirm)
        present(alert, animated: true)
    }
    
    //MARK: - Add new board game
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Agregar tablero", message: "", preferredStyle: .alert)
        let actionCancel = UIAlertAction(title: "Cancelar", style: .cancel) { action in
            self.dismiss(animated: true)
        }
        let action = UIAlertAction(title: "Agregar", style: .default) { action in
        
            let newBoardGame = BoardGame(context: self.context)
            newBoardGame.title = textField.text!
            newBoardGame.currentIndex = "0"
            
            self.boardGames.append(newBoardGame)
            self.saveBoardGames()
        }
        
        alert.addAction(action)
        alert.addAction(actionCancel)
        
        alert.addTextField { field in
            textField = field
            textField.placeholder = "Agregar un nuevo tablero"
        }
        
        present(alert, animated: true)
    }
    
    
    //MARK: - Delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        performSegue(withIdentifier: "goToQuestions", sender: self)
        performSegue(withIdentifier: "goToDicee", sender: self)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
//        let destinationVC = segue.destination as! MaratonicoTableViewController
//
//        if let indexPath = tableView.indexPathForSelectedRow {
//            destinationVC.selectedBoardGame = boardGames[indexPath.row]
//        }
        let destinationVC = segue.destination as! DiceeViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedBoardGame = boardGames[indexPath.row]
        }
    }
    
    
    //MARK: - Delete all data methods
    
    func deleteAllEntities() {
        let entities = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.managedObjectModel.entities

        for entity in entities {
            delete(entityName: entity.name!)
        }
    }

    func delete(entityName: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(deleteRequest)
        } catch let error as NSError {
            debugPrint(error)
        }
    }

}
