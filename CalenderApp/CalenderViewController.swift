//
//  ViewController.swift
//  CalenderApp
//
//  Created by نجود  on 16/01/1444 AH.
//

import UIKit
import CalendarKit
import EventKit
import EventKitUI

class CalenderViewController: DayViewController {
    
   private let eventStore = EKEventStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       title = "Calender"
        requestAccessToCalender()
        subscribeToNatifications()
        
        // Do any additional setup after loading the view.
    }
   
    func requestAccessToCalender(){
        
        eventStore.requestAccess(to: .event) { success , error in
            
        }
        
    }
    
    
    func subscribeToNatifications(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(storeChange(_ :)), name: .EKEventStoreChanged, object: nil)
        
    }
    
    @objc func storeChange(_ notification : Notification){
        
        reloadData()
        
    }
    
    
    override func eventsForDate(_ date: Date) -> [EventDescriptor] {
        let startDate = date
        var oneDayComponents = DateComponents()
        oneDayComponents.day = 1
        let endDate = calendar.date(byAdding: oneDayComponents, to: startDate )!
        
        
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
        
        let eventKitEvents = eventStore.events(matching: predicate)
        
        
        let calenderKitEvents = eventKitEvents.map(EKWrapper.init)
//        {
//            ekEvent   -> Event in
//           let ckEvent = Event()
//            let ckEvent1 = ekEvent
//            ckEvent1.startDate = ekEvent.startDate
//            ckEvent1.endDate = ekEvent.endDate
//            ckEvent.isAllDay = ekEvent.isAllDay
//            ckEvent.text = ekEvent.title
//            if let eventColor = ekEvent.calendar.cgColor {
//
//                ckEvent.color = UIColor(cgColor: eventColor)
//            }
//
//            return ckEvent
//
//        }

        return calenderKitEvents
    }
    
    
    override func dayViewDidSelectEventView(_ eventView: EventView) {
        guard let ckEvent = eventView.descriptor as?  EKWrapper else {
            
            return
        }
        
        let ekEvent = ckEvent.ekEvent
        let eventViewController  = EKEventViewController()
        eventViewController.event = ekEvent
        eventViewController.allowsCalendarPreview = true
        eventViewController.allowsEditing = true
        navigationController?.pushViewController(eventViewController, animated: true)
    }
    
}

