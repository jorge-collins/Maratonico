//
//  QuestionViewController.swift
//  Maratonico
//
//  Created by Jorge Collins Gómez on 06/08/22.
//

import UIKit

class QuestionViewController: UIViewController {
    
    // MARK: - Vars and vals
    var currentQuestion: Question? {
        didSet {
            print(#line, currentQuestion!)
        }
    }
    var questionAnswered = false
    
    // MARK: - Outlets
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var questionTextLabel: UILabel!
    @IBOutlet weak var showOptionsButton: UIButton!
    @IBOutlet weak var optionAButton: UIButton!
    @IBOutlet weak var optionBButton: UIButton!
    @IBOutlet weak var optionCButton: UIButton!
    
    
    // MARK: - Override functions
    override func viewDidLoad() {
        super.viewDidLoad()

        questionTextLabel.text = currentQuestion?.q
        optionAButton.setTitle(currentQuestion?.a1, for: .normal)
        optionBButton.setTitle(currentQuestion?.a2, for: .normal)
        optionCButton.setTitle(currentQuestion?.a3, for: .normal)
        
        // Agregamos la funcionalidad al boton de mostrar opciones
        showOptionsButton.addTarget(self, action: #selector(showButtons), for: .touchUpInside)
        
        siriSpeak(with: (currentQuestion?.q)!!)
    }
    
    // MARK: - Actions
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func showOptionsPressed(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5) {
            sender.alpha = 0.0
        }
        siriSpeak(with: "opción uno: \((currentQuestion?.a1)!!), opción dos: \((currentQuestion?.a2)!!), opción tres: \((currentQuestion?.a3)!!)")
    }
    
    @IBAction func verifyAnswer(_ sender: UIButton) {
        print(#line, sender.tag, currentQuestion?.correctAnswer ?? "")
        
        if !questionAnswered {
            sender.setTitleColor(.systemYellow, for: .normal)
            questionAnswered = !questionAnswered
        }
        
        updateUI()
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
