//
//  ViewController.swift
//  TextToSpeech
//
//  Created by Dhiman on 19/05/18.
//  Copyright © 2018 Samrat. All rights reserved.
//

import UIKit
import AVFoundation
import googleapis

let SAMPLE_RATE = 16000

class ViewController: UIViewController, AudioControllerDelegate  {

    @IBOutlet weak var labelHindiText: UILabel!
    @IBOutlet weak var labelEnglishText: UILabel!
    @IBOutlet weak var buttonStopRecording: UIButton!
    @IBOutlet weak var buttonStartRecording: UIButton!
    
    var audioData: NSMutableData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AudioController.sharedInstance.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func buttonStartRecording(_ sender: Any) {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
        } catch {
            
        }
        audioData = NSMutableData()
        _ = AudioController.sharedInstance.prepare(specifiedSampleRate: SAMPLE_RATE)
        SpeechRecognitionService.sharedInstance.sampleRate = SAMPLE_RATE
        _ = AudioController.sharedInstance.start()
    }
    
    @IBAction func buttonStopRecording(_ sender: Any) {
        _ = AudioController.sharedInstance.stop()
        SpeechRecognitionService.sharedInstance.stopStreaming()
    }
    
    
    func processSampleData(_ data: Data) -> Void {
        audioData.append(data)
        
        // We recommend sending samples in 100ms chunks
        let chunkSize : Int /* bytes/chunk */ = Int(0.1 /* seconds/chunk */
            * Double(SAMPLE_RATE) /* samples/second */
            * 2 /* bytes/sample */);
        
        if (audioData.length > chunkSize) {
            SpeechRecognitionService.sharedInstance.streamAudioData(audioData,
                                                                    completion:
                { [weak self] (response, error) in
                    guard let strongSelf = self else {
                        return
                    }
                    
                    if let error = error {
                        strongSelf.labelHindiText.text = error.localizedDescription
                    } else if let response = response {
                        var finished = false
                        //print(response)
                        for result in response.resultsArray! {
                            if let result = result as? StreamingRecognitionResult {
                                //print(result.isFinal)
                                if result.isFinal {
                                    strongSelf.buttonStopRecording(strongSelf)
                                    //print(result.alternativesArray)
                                    for alternative in result.alternativesArray {
                                        if let alternative1 = alternative as? SpeechRecognitionAlternative {
                                            strongSelf.labelHindiText.text = alternative1.transcript!
                                        }
                                    }
                                }
                            }
                        }
                    }
            })
            self.audioData = NSMutableData()
        }
    }
}
