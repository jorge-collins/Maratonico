//
//  Multimedia.swift
//  Maratonico
//
//  Created by Jorge Collins Gómez on 08/08/22.
//

import Foundation
import AVFoundation


func siriSpeak(with string: String) {
    
    let utterance = AVSpeechUtterance(string: string)
    utterance.voice = AVSpeechSynthesisVoice(language: "es-MX")

    let synth = AVSpeechSynthesizer()
    synth.speak(utterance)
}
