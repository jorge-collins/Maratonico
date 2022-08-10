//
//  QuestionViewController.swift
//  Maratonico
//
//  Created by Jorge Collins Gómez on 06/08/22.
//

import UIKit

class QuestionViewController: UIViewController {
    
    // MARK: - Vars and lets
    var currentQuestion: Question? {
        didSet {
            siriSpeak(with: (currentQuestion?.q)!!)
        }
    }
    var questionAnswered = false
    
    let attrFont = UIFont(name: "Verdana", size: 18)
    

    // MARK: - Outlets
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var speakerQuestion: UIButton!
    
    @IBOutlet weak var questionTextLabel: UILabel!
    
    @IBOutlet weak var buttonsStackView: UIStackView!
    @IBOutlet weak var showOptionsButton: UIButton!
    @IBOutlet weak var responseButton: UIButton!
    
    @IBOutlet weak var speakerOptions: UIButton!
    @IBOutlet weak var optionAButton: UIButton!
    @IBOutlet weak var optionBButton: UIButton!
    @IBOutlet weak var optionCButton: UIButton!
    
    
    // MARK: - Override functions
    override func viewDidLoad() {
        super.viewDidLoad()

        questionTextLabel.text = currentQuestion?.q
        
        let attrTitleA = NSAttributedString(string: (currentQuestion?.a1)!, attributes: [NSAttributedString.Key.font: attrFont!])
        let attrTitleB = NSAttributedString(string: (currentQuestion?.a2)!, attributes: [NSAttributedString.Key.font: attrFont!])
        let attrTitleC = NSAttributedString(string: (currentQuestion?.a3)!, attributes: [NSAttributedString.Key.font: attrFont!])
        optionAButton.setAttributedTitle(attrTitleA, for: UIControl.State.normal)
        optionBButton.setAttributedTitle(attrTitleB, for: UIControl.State.normal)
        optionCButton.setAttributedTitle(attrTitleC, for: UIControl.State.normal)
        
        // Agregamos la funcionalidad al boton de mostrar opciones
        showOptionsButton.addTarget(self, action: #selector(showButtons), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIView.animate(withDuration: 1.0, animations: {
            self.speakerQuestion.alpha = 1
        })
    }
    
    
    // MARK: - Actions
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func speakerQuestionPressed(_ sender: UIButton) {
        siriSpeak(with: (currentQuestion?.q)!!)
    }
    
    @IBAction func showOptionsPressed(_ sender: UIButton) {
        showOptions()
    }
    
    func showOptions() {
        UIView.animate(withDuration: 0.5) {
            self.buttonsStackView.alpha = 0.0
            self.speakerOptions.alpha = 1.0
        }
    }
    
    @IBAction func responsePressed(_ sender: UIButton) {
        
        // Mostrar alert con el numero que salio en el dado
        let alert = UIAlertController(title: "Escribe tu respuesta", message: "", preferredStyle: .alert)
        let alertActionCancel = UIAlertAction(title: "Cancelar", style: .cancel)

        // Crear action para notificar el resultado del dado y la categoria
        var textFieldAnswer = UITextField()
        alert.addTextField { field in
            textFieldAnswer = field
            textFieldAnswer.placeholder = "Respuesta"
        }
        let alertAction = UIAlertAction(title: "Enviar", style: .default) { action in
            self.verifyTextAnswer(with: textFieldAnswer.text!)
        }
        
        alert.addAction(alertAction)
        alert.addAction(alertActionCancel)
        present(alert, animated: true)
        
        print(#line, currentQuestion!)
    }
    
    @IBAction func speakerOptionsPressed(_ sender: UIButton) {
        siriSpeak(with: "opción uno: \((currentQuestion?.a1)!!), opción dos: \((currentQuestion?.a2)!!), opción tres: \((currentQuestion?.a3)!!)")
    }
    
    // Action ejecutada por los tres botones de respuesta
    @IBAction func verifyAnswer(_ sender: UIButton) {
        
        if !questionAnswered {
            
            changeButtonFont(at: sender)
            questionAnswered = !questionAnswered
        }
        updateUI()
    }
    
    func changeButtonFont(at sender: UIButton) {
        let attrFont = UIFont(name: "Verdana Bold", size: 18)
        let attrTitle = NSAttributedString(string: (sender.titleLabel?.text)!, attributes: [NSAttributedString.Key.font: attrFont!])
        sender.setAttributedTitle(attrTitle, for: UIControl.State.normal)
    }
    
    // Verifica la respuesta directa
    func verifyTextAnswer(with answer: String) {
        
        var cAnswerIndex: Int = 0
        if let cAnswer = currentQuestion?.correctAnswer {
            cAnswerIndex = Int(cAnswer)! - 1
        }
        
        let answersData = [currentQuestion?.a1, currentQuestion?.a2, currentQuestion?.a3]
        
        let correctAnswer = answersData[cAnswerIndex]!
        
        guard (answer.count * 2) > (correctAnswer.count) else {
            print("Respuesta demasiado corta")
            notifyInvalidAnswer(with: "Respuesta demasiado corta")
            return
        }
        
        let upperCA = correctAnswer.uppercased()
        let upperA = answer.uppercased()
        
        print(correctAnswer)
        
        if upperCA.contains(upperA) {
            print("Respuesta valida")
            showOptions()
            showButtons()
            updateUI()
        } else {
            notifyInvalidAnswer(with: "Respuesta invalida")
        }
    }
    
    func notifyInvalidAnswer(with str: String) {
        let alert = UIAlertController(title: str, message: "", preferredStyle: .actionSheet)
        let alertAction = UIAlertAction(title: "Ok", style: .default)

        alert.addAction(alertAction)
        present(alert, animated: true)

    }
    // MARK: - Animations methods
    
    func updateUI() {
        // Mostramos el boton de siguiente turno
        UIView.animate(withDuration: 0.5) {
            self.nextButton.alpha = 1
        }
        
        let btns = [optionAButton, optionBButton, optionCButton]

        for btn in btns {

            if let cTag = btn?.tag {

                UIView.animate(withDuration: 0.25) {
                    if String(cTag) == self.currentQuestion?.correctAnswer {
                        btn?.backgroundColor = .green.darken(byPercentage: 0.5)
                    } else {
                        btn?.backgroundColor = .systemRed.darken(byPercentage: 0.5)
                    }
                }
            }
        }
    }
    
    // Funcion que realiza una animacion de 1 segundo de duracion (fadeIn a los botones)
    @objc func showButtons() {
       UIView.animate(withDuration: 0.6, animations: {
           self.optionAButton.alpha = 1
           self.optionBButton.alpha = 1
           self.optionCButton.alpha = 1
       })
    }

}
