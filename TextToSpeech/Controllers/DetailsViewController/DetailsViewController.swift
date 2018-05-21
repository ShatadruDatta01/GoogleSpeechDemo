//
//  CheckViewController.swift
//  TouchIDIntegration
//
//  Created by Shatadru Datta on 4/13/18.
//  Copyright © 2018 Shatadru. All rights reserved.
//

import UIKit
import AVFoundation
import ApiAI
import MessageUI
import Speech
import googleapis

class DetailsViewController: UIViewController,SFSpeechRecognizerDelegate, AVSpeechSynthesizerDelegate, AudioControllerDelegate {

    var audioData: NSMutableData!
    let speechSynthesizer = AVSpeechSynthesizer()
    var jsonEmployeeList = ""
    var isAudioRunning = false
    var senderText: String!
    var speechRecognizerUtility: SpeechRecognitionUtility?
    private var timer: Timer?
    private var totalTime: Int = 0
    var phno = ""
    var name = ""
    var emailId = ""
    var arrContext = ["UserId:", "Name:", "Identity:", "Department:", "Position:", "KAUSTID:"]
    var arrContextValue = [String]()
    @IBOutlet weak var tblDetails: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        AudioController.sharedInstance.delegate = self
        speechSynthesizer.delegate = self
        self.tblDetails.tableFooterView = UIView()
        self.recording()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func notification(_ sender: UIButton) {
        
    }
    
    @IBAction func call(_ sender: UIButton) {
        if self.phno == "" {
            self.voice(text: "Sorry, employee doesn't have any mobile number")
        } else {
            if let url = URL(string: "tel://\(self.phno)"), UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }
    
    @IBAction func sms(_ sender: UIButton) {
        if self.phno == "" {
            self.voice(text: "Sorry, employee doesn't have any sms sending number")
        } else {
            if (MFMessageComposeViewController.canSendText()) {
                let controller = MFMessageComposeViewController()
                controller.body = ""
                controller.recipients = ["\(self.phno)"]
                controller.messageComposeDelegate = self
                self.present(controller, animated: true, completion: nil)
            }
        }
        
    }
    
    @IBAction func email(_ sender: UIButton) {
        
        if self.emailId == "" {
            self.voice(text: "Sorry, employee doesn't have any emailid")
        } else {
            if MFMailComposeViewController.canSendMail() {
                let composeVC = MFMailComposeViewController()
                composeVC.mailComposeDelegate = self
                
                // Configure the fields of the interface.
                composeVC.setToRecipients([self.emailId])
                composeVC.setSubject("KIA")
                composeVC.setMessageBody("Feedback", isHTML: false)
                
                // Present the view controller modally.
                self.present(composeVC, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func videoCall(_ sender: UIButton) {
        
        if self.phno == "" {
            self.voice(text: "Sorry, employee doesn't have any mobile number for facetime video call")
        } else {
            if let facetimeURL:NSURL = NSURL(string: "facetime://\(self.phno)") {
                let application = UIApplication.shared
                if (application.canOpenURL(facetimeURL as URL)) {
                    application.openURL(facetimeURL as URL);
                }
            }
        }
    }
    
    func voice(text: String) {
        let audioSession = AVAudioSession.sharedInstance()  //2
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback, with: AVAudioSessionCategoryOptions.defaultToSpeaker)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            //try audioSession.setMode(AVAudioSessionModeDefault)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        let speechUtterance = AVSpeechUtterance(string: text)
        speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-US")!
        speechUtterance.rate = 0.4
        self.speechSynthesizer.speak(speechUtterance)
    }
    
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("all done")
        
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
                                            self?.checkAudio(str: alternative1.transcript!)
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
    
    
    func checkAudio(str: String) {
        self.senderText = str
        if self.senderText == "audio call" || self.senderText == "call" || self.senderText == "phone call" {
            
            if self.phno == "" {
                self.voice(text: "Sorry, employee doesn't have any mobile number")
            } else {
                if let url = URL(string: "tel://\(self.phno)"), UIApplication.shared.canOpenURL(url) {
                    if #available(iOS 10, *) {
                        UIApplication.shared.open(url)
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                }
                self.recording()
            }
        } else if self.senderText == "video call" || self.senderText == "video" {
            
            if self.phno == "" {
                self.voice(text: "Sorry, employee doesn't have any mobile number for facetime video call")
            } else {
                if let facetimeURL:NSURL = NSURL(string: "facetime://\(self.phno)") {
                    let application = UIApplication.shared
                    if (application.canOpenURL(facetimeURL as URL)) {
                        application.openURL(facetimeURL as URL);
                    }
                }
                self.recording()
            }
        } else if self.senderText == "send message" || self.senderText == "send SMS" || self.senderText == "SMS" {
            
            if self.phno == "" {
                self.voice(text: "Sorry, employee doesn't have any sms sending number")
            } else {
                if (MFMessageComposeViewController.canSendText()) {
                    let controller = MFMessageComposeViewController()
                    controller.body = ""
                    controller.recipients = ["\(self.videoCall)"]
                    controller.messageComposeDelegate = self
                    self.present(controller, animated: true, completion: nil)
                }
                self.recording()
            }
        } else if self.senderText == "mail" || self.senderText == "send mail" || self.senderText == "email" || self.senderText == "Send email" {
            
            if self.emailId == "" {
                self.voice(text: "Sorry, employee doesn't have any emailid")
            } else {
                if MFMailComposeViewController.canSendMail() {
                    let composeVC = MFMailComposeViewController()
                    composeVC.mailComposeDelegate = self
                    
                    // Configure the fields of the interface.
                    composeVC.setToRecipients([self.emailId])
                    composeVC.setSubject("KIA")
                    composeVC.setMessageBody("Feedback", isHTML: false)
                    
                    // Present the view controller modally.
                    self.present(composeVC, animated: true, completion: nil)
                }
                self.recording()
            }
        } else {
            self.recording()
        }
    }
}

//Sending SMS/Messages
extension DetailsViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        //... handle sms screen actions
        self.dismiss(animated: true, completion: nil)
    }
}

//Sending Mail
extension DetailsViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        // Check the result or perform other tasks.
        
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
    }
}




//  TableViewDelegate, TableViewDatasource
extension DetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        default:
            return 6
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let profileCell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as! ProfileCell
            profileCell.lblName.text = self.name
            if self.phno == "" {
                profileCell.lblPhno.text = "Not available"
            } else {
                profileCell.lblPhno.text = self.phno
            }
            profileCell.lblEmailId.text = self.emailId
            profileCell.selectionStyle = .none
            return profileCell
        default:
            let detailsCell = tableView.dequeueReusableCell(withIdentifier: "DetailsViewCell", for: indexPath) as! DetailsViewCell
            detailsCell.lblContext.text = self.arrContext[indexPath.row]
            detailsCell.lblContextValue.text = self.arrContextValue[indexPath.row]
            detailsCell.selectionStyle = .none
            return detailsCell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 180.0
        default:
            return 50.0
        }
    }
}


extension DetailsViewController {
    func startRecordingSecondMethod() {
        
        if speechRecognizerUtility == nil {
            // Initialize the speech recognition utility here
            speechRecognizerUtility = SpeechRecognitionUtility(speechRecognitionAuthorizedBlock: { [weak self] in
                self?.toggleSpeechRecognitionState()
                }, stateUpdateBlock: { [weak self] (currentSpeechRecognitionState, finalOutput) in
                    // A block to update the status of speech recognition. This block will get called every time Speech framework recognizes the speech input
                    self?.stateChangedWithNew(state: currentSpeechRecognitionState)
                    // We won't perform translation until final input is ready. We will usually wait for users to finish speaking their input until translation request is sent
                    if finalOutput {
                        //self?.stopTimeCounter()
                        self?.toggleSpeechRecognitionState()
                        self?.speechRecognitionDone()
                    }
                }, timeoutPeriod: speechRecognitionTimeout) // We will set the Speech recognition Timeout to make sure we get the full string output once user has stopped talking. For example, if we specify timeout as 2 seconds. User initiates speech recognition, speaks continuously (Hopegully way less than full one minute), and if pauses for more than 2 seconds, value of finalOutput in above block will be true. Before that you will keep getting output, but that won't be the final one.
        } else {
            // We will call this method to toggle the state on/off of speech recognition operation.
            self.toggleSpeechRecognitionState()
        }
    }
    
    func speechRecognitionDone() {
        // Trigger the request to get translations as soon as user has done providing full speech input. Don't trigger until query length is at least one.
        if let query = self.senderText, query.count > 0 {
            // Disable the toggle speech button while we're getting translations from server.
            NetworkRequest.sendRequestWith(query: query, completion: { (translation) in
                OperationQueue.main.addOperation {
                    // Explicitly execute the code on main thread since the request we get back need not be on the main thread.
                    if self.senderText == "Audio call" || self.senderText == "Call" || self.senderText == "Phone call" {
                        
                        if self.phno == "" {
                            self.voice(text: "Sorry, employee doesn't have any mobile number")
                        } else {
                            if let url = URL(string: "tel://\(self.phno)"), UIApplication.shared.canOpenURL(url) {
                                if #available(iOS 10, *) {
                                    UIApplication.shared.open(url)
                                } else {
                                    UIApplication.shared.openURL(url)
                                }
                            }
                            self.startRecordingSecondMethod()
                        }
                    } else if self.senderText == "Video call" || self.senderText == "Video" {
                        
                        if self.phno == "" {
                            self.voice(text: "Sorry, employee doesn't have any mobile number for facetime video call")
                        } else {
                            if let facetimeURL:NSURL = NSURL(string: "facetime://\(self.phno)") {
                                let application = UIApplication.shared
                                if (application.canOpenURL(facetimeURL as URL)) {
                                    application.openURL(facetimeURL as URL);
                                }
                            }
                            self.startRecordingSecondMethod()
                        }
                    } else if self.senderText == "Send message" || self.senderText == "Send SMS" || self.senderText == "SMS" {
                        
                        if self.phno == "" {
                            self.voice(text: "Sorry, employee doesn't have any sms sending number")
                        } else {
                            if (MFMessageComposeViewController.canSendText()) {
                                let controller = MFMessageComposeViewController()
                                controller.body = ""
                                controller.recipients = ["\(self.videoCall)"]
                                controller.messageComposeDelegate = self
                                self.present(controller, animated: true, completion: nil)
                            }
                            self.startRecordingSecondMethod()
                        }
                    } else if self.senderText == "Mail" || self.senderText == "Send mail" || self.senderText == "Email" || self.senderText == "Send email" {
                        
                        if self.emailId == "" {
                            self.voice(text: "Sorry, employee doesn't have any emailid")
                        } else {
                            if MFMailComposeViewController.canSendMail() {
                                let composeVC = MFMailComposeViewController()
                                composeVC.mailComposeDelegate = self
                                
                                // Configure the fields of the interface.
                                composeVC.setToRecipients([self.emailId])
                                composeVC.setSubject("KIA")
                                composeVC.setMessageBody("Feedback", isHTML: false)
                                
                                // Present the view controller modally.
                                self.present(composeVC, animated: true, completion: nil)
                            }
                            self.startRecordingSecondMethod()
                        }
                    } else {
                        self.startRecordingSecondMethod()
                    }
                    
                    
                    //translation
                    // Re-enable the toggle speech button once translations are ready.
                }
            })
        }
    }
    
    // A method to toggle the speech recognition state between on/off
    private func toggleSpeechRecognitionState() {
        do {
            try self.speechRecognizerUtility?.toggleSpeechRecognitionActivity()
        } catch SpeechRecognitionOperationError.denied {
            print("Speech Recognition access denied")
        } catch SpeechRecognitionOperationError.notDetermined {
            print("Unrecognized Error occurred")
        } catch SpeechRecognitionOperationError.restricted {
            print("Speech recognition access restricted")
        } catch SpeechRecognitionOperationError.audioSessionUnavailable {
            print("Audio session unavailable")
        } catch SpeechRecognitionOperationError.invalidRecognitionRequest {
            print("Recognition request is null. Expected non-null value")
        } catch SpeechRecognitionOperationError.audioEngineUnavailable {
            print("Audio engine is unavailable. Cannot perform speech recognition")
        } catch {
            print("Unknown error occurred")
        }
    }
    
    private func stateChangedWithNew(state: SpeechRecognitionOperationState) {
        switch state {
        case .authorized:
            print("State: Speech recognition authorized")
        case .audioEngineStart:
            self.isAudioRunning = true
            self.startTimeCounterAndUpdateUI()
            print("State: Audio Engine Started")
        case .audioEngineStop:
            print("State: Audio Engine Stopped")
        case .recognitionTaskCancelled:
            self.isAudioRunning = false
            print("State: Recognition Task Cancelled")
        case .speechRecognized(let recognizedString):
            senderText = recognizedString
            print("State: Recognized String \(recognizedString)")
        case .speechNotRecognized:
            print("State: Speech Not Recognized")
        case .availabilityChanged(let availability):
            print("State: Availability changed. New availability \(availability)")
        case .speechRecognitionStopped(let finalRecognizedString):
            self.stopTimeCounter()
            print("State: Speech Recognition Stopped with final string \(finalRecognizedString)")
        }
    }
    
    
    private func startTimeCounterAndUpdateUI() {
        
//        let audioSession = AVAudioSession.sharedInstance()  //2
//        do {
//            try audioSession.setCategory(AVAudioSessionCategoryRecord)
//            try audioSession.setMode(AVAudioSessionModeMeasurement)
//            //try audioSession.setMode(AVAudioSessionModeDefault)
//            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
//            //try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
//        } catch {
//            print("audioSession properties weren't set because of an error.")
//        }
        
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] (timer) in
            guard let weakSelf = self else { return }
            
            guard weakSelf.totalTime < maximumAllowedTimeDuration else {
                //weakSelf.stopTimeCounter()
                return
            }
            
            weakSelf.totalTime = weakSelf.totalTime + 1
        })
    }
    
    private func stopTimeCounter() {
        self.timer?.invalidate()
        self.timer = nil
        self.totalTime = 0
    }
}



