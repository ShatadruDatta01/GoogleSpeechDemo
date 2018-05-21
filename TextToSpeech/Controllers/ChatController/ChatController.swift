//
//  ChatController.swift
//  ChatBot_Demo
//
//  Created by Shatadru Datta on 3/31/18.
//  Copyright © 2018 ARBSoftware. All rights reserved.
//

import UIKit
import ApiAI
import Speech
import AVFoundation
import googleapis
import SwiftyJSON

let speechRecognitionTimeout: Double = 3
let maximumAllowedTimeDuration = 3

class ChatController: UIViewController, SFSpeechRecognizerDelegate, AVSpeechSynthesizerDelegate, AudioControllerDelegate {

    var isAudioRunning = false
    var senderText: String!
    var botText: String!
    @IBOutlet weak var btnLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var chatViewLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var tblChatBot: UITableView!
    var checkText = false
    var isFinal: Bool!
    var isEnd = false
    var text: String!
    var arrData = [AnyObject]()
    @IBOutlet weak var messageField: UITextField!
    @IBOutlet weak var chipResponse: UILabel!
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    let speechSynthesizer = AVSpeechSynthesizer()
    var audioData: NSMutableData!
    
    var speechRecognizerUtility: SpeechRecognitionUtility?
    
    private var timer: Timer?
    private var totalTime: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.voiceIntro()
        AudioController.sharedInstance.delegate = self
        
        self.tblChatBot.estimatedRowHeight = 70.0
        self.tblChatBot.rowHeight = UITableViewAutomaticDimension
        self.messageField.placeholder = "Type message"
        
        speechSynthesizer.delegate = self
        speechRecognizer.delegate = self
    
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            
            switch authStatus {
                
            case .authorized:
                print("Success")

            case .denied:
                print("User denied access to speech recognition")
                
            case .restricted:
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                print("Speech recognition not yet authorized")
            }
        }
        
        // Do any additional setup after loading the view.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.setupNotifications()
    }
    
    
    func voiceIntro() {
        let audioSession = AVAudioSession.sharedInstance()  //2
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with: AVAudioSessionCategoryOptions.defaultToSpeaker)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            //try audioSession.setMode(AVAudioSessionModeDefault)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        let speechSynthesizer = AVSpeechSynthesizer()
        let speechUtterance = AVSpeechUtterance(string: "Welcome to KAUST Artificial Intelligence. My name is KIA. How may I help you?")
        speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-US")!
        speechUtterance.rate = 0.4
        speechSynthesizer.speak(speechUtterance)
    }
    
    @IBAction func playVoice(_ sender: UIButton) {
        if sender.isSelected {
            self.messageField.placeholder = "Type message"
            sender.isSelected = false
            _ = AudioController.sharedInstance.stop()
            SpeechRecognitionService.sharedInstance.stopStreaming()
            btnPlay.setImage(UIImage(named: "mic"), for: .normal)
            
        } else {
            self.messageField.placeholder = "Say something..."
            sender.isSelected = true
            btnPlay.setImage(UIImage(named: "mic_active"), for: .normal)
            self.recording()
           
        }
    }
    
    @IBAction func sendMessage(_ sender: UIButton) {
        
        if (self.messageField.text?.isEmpty)! {
            //.........//
        } else {
            self.arrData.append(self.messageField.text as AnyObject)
            self.tblChatBot.reloadData()
            self.scrollToBottom()
            self.senderText = self.messageField.text
            self.sendMessage(text: self.messageField.text!)
        }
    }
    
    func scrollToBottom() {
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: self.arrData.count-1, section: 0)
            self.tblChatBot.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }

    func recording() {
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
                    } else if let response = response {
                        var finished = false
                        //print(response)
                        for result in response.resultsArray! {
                            if let result = result as? StreamingRecognitionResult {
                                //print(result.isFinal)
                                if result.isFinal {
                                    _ = AudioController.sharedInstance.stop()
                                    SpeechRecognitionService.sharedInstance.stopStreaming()
                                    //print(result.alternativesArray)
                                    for alternative in result.alternativesArray {
                                        if let alternative1 = alternative as? SpeechRecognitionAlternative {
                                            //strongSelf.labelHindiText.text = alternative1.transcript!
                                            print(alternative1.transcript!)
                                            self?.messageField.text = alternative1.transcript!
                                            self?.senderText = alternative1.transcript!
                                            self?.sendMessage(text: (self?.messageField.text!)!)
                                            self?.arrData.append(self?.senderText as AnyObject)
                                            self?.tblChatBot.reloadData()
                                            self?.scrollToBottom()
                                            
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
    
    
    @objc func sendMessage(text: String) {
        let request = ApiAI.shared().textRequest()
        if let text = self.messageField.text, text != "" {
            request?.query = text
        } else {
            return
        }
        
        request?.setMappedCompletionBlockSuccess({ (request, response) in
            let response = response as! AIResponse
            print(response)
            if let textResponse = response.result.fulfillment.speech {
                print(textResponse)
                
                let swiftyJsonVar   = JSON.parse(textResponse);
                if swiftyJsonVar.count == 1 {
                    _ = AudioController.sharedInstance.stop()
                    SpeechRecognitionService.sharedInstance.stopStreaming()
                    let detailsViewController = self.storyboard?.instantiateViewController(withIdentifier: "DetailsViewController") as? DetailsViewController
                    detailsViewController?.jsonEmployeeList = textResponse
                    for value in swiftyJsonVar.arrayObject! {
                        let objEmpList = Employee(withDictionary: value as! [String : AnyObject])
                        detailsViewController?.phno = objEmpList.mobileNo!
                        detailsViewController?.emailId = objEmpList.emailId!
                        detailsViewController?.name = objEmpList.displayName!
                        detailsViewController?.arrContextValue.append(objEmpList.userId!)
                        detailsViewController?.arrContextValue.append(objEmpList.displayName!)
                        detailsViewController?.arrContextValue.append(objEmpList.identity!)
                        detailsViewController?.arrContextValue.append(objEmpList.department!)
                        detailsViewController?.arrContextValue.append(objEmpList.position!)
                        detailsViewController?.arrContextValue.append(objEmpList.KAUSTID!)
                    }
                    self.navigationController?.pushViewController(detailsViewController!, animated: true)
                } else if swiftyJsonVar.count > 1 {
                    _ = AudioController.sharedInstance.stop()
                    SpeechRecognitionService.sharedInstance.stopStreaming()
                    let secondviewController = self.storyboard?.instantiateViewController(withIdentifier: "EmployeeListController") as? EmployeeListController
                    secondviewController?.jsonEmployeeList = textResponse
                    self.navigationController?.pushViewController(secondviewController!, animated: true)
                } else {
                    self.speechAndText(text: textResponse)
                }
            }
        }, failure: { (request, error) in
            print(error!)
        })
        
        ApiAI.shared().enqueue(request)
        messageField.text = ""
    }
    
    
    
    func speechAndText(text: String) {
        
        let audioSession = AVAudioSession.sharedInstance()  //2
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback, with: AVAudioSessionCategoryOptions.defaultToSpeaker)
//            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setMode(AVAudioSessionModeDefault)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }

        
        let speechUtterance = AVSpeechUtterance(string: text)
        speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-US")!
        speechUtterance.rate = 0.4
        speechSynthesizer.speak(speechUtterance)
        UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseInOut, animations: {
            if text == "Welcome to KAUST Artificial Intelligence. My name is KIA. How may I help you?" {
                
            } else {
                self.chipResponse.text = text
                self.arrData.append(text as AnyObject)
                self.tblChatBot.reloadData()
                self.scrollToBottom()
            }
            
        }, completion: nil)
        
    }
    
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("all done")
        self.recording()
    }
}

// MARK: - TextFieldDelegate
extension ChatController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        self.startRecordingSecondMethod()
        
       
        btnSend.isSelected = false
        btnSend.setImage(UIImage(named: "send"), for: .normal)
        
        self.btnLayoutConstraint.constant = 26
        self.chatViewLayoutConstraint.constant = 0
        self.checkText = false
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        btnSend.isSelected = true
        btnSend.setImage(UIImage(named: "send_active"), for: .normal)

        self.btnLayoutConstraint.constant = 284
        self.chatViewLayoutConstraint.constant = 258
        self.checkText = true
        return true
    }
}



// MARK: - TableViewDelegate, TableViewDatasource
extension ChatController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row % 2 == 0) {
            let senderCell = tableView.dequeueReusableCell(withIdentifier: "SenderCell", for: indexPath) as! SenderCell
            senderCell.datasource = self.arrData[indexPath.row]
            return senderCell

        } else {
            let receiverCell = tableView.dequeueReusableCell(withIdentifier: "ReceiverCell", for: indexPath) as! ReceiverCell
            receiverCell.datasource = self.arrData[indexPath.row]
            return receiverCell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

