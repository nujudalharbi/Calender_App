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

class CalenderViewController: DayViewController , EKEventEditViewDelegate{
    
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
        
        presentDetailView(ekEvent)
//        let eventViewController  = EKEventViewController()
//        eventViewController.event = ekEvent
//        eventViewController.allowsCalendarPreview = true
//        eventViewController.allowsEditing = true
//        navigationController?.pushViewController(eventViewController, animated: true)
    }
    private func presentDetailView(_ ekEvent: EKEvent){
        let eventViewController  = EKEventViewController()
        eventViewController.event = ekEvent
        eventViewController.allowsCalendarPreview = true
        eventViewController.allowsEditing = true
        navigationController?.pushViewController(eventViewController, animated: true)
        
        
    }
    override func dayViewDidLongPressEventView(_ eventView: EventView) {
        endEventEditing()
        guard let ckEvent = eventView.descriptor as? EKWrapper else {
            
            return
        }
        
        beginEditing(event:ckEvent , animated: true)
    }
    
    override func dayView(dayView: DayView, didUpdate event: EventDescriptor) {
        guard let editingEvent = event as? EKWrapper else {
            return
        }
        if let originalEvent = event.editedEvent{
            
            
            
            
            editingEvent.commitEditing()
            
            
            if originalEvent === editingEvent{
                
                
                presentEditingViewForEvent(editingEvent.ekEvent)
            }else {
                
                try! eventStore.save(editingEvent.ekEvent, span: .thisEvent)
                
            }
           
        }
        reloadData()
    }
    func presentEditingViewForEvent(_ ekEvent : EKEvent){
        
        let editingViewController = EKEventViewController()
//        editingViewController.editViewDelegate = self
        editingViewController.event = ekEvent
//        editingViewController.eventStore = eventStore
        present(editingViewController, animated: true, completion: nil)
        
    }
    
    
    override func dayView(dayView: DayView, didTapTimelineAt date: Date) {
        endEventEditing()
    }
    override func dayViewDidBeginDragging(dayView: DayView) {
        endEventEditing()
    }
    override func dayView(dayView: DayView, didLongPressTimelineAt date: Date) {
        let newEKEvent = EKEvent(eventStore: eventStore)
        newEKEvent.calendar = eventStore.defaultCalendarForNewEvents
        
        var oneHourComponents = DateComponents()
        oneHourComponents.hour = 1
        
        let endDate = calendar.date(byAdding: oneHourComponents,  to: date)
        newEKEvent.startDate = date
        newEKEvent.endDate = endDate
        newEKEvent.title = "New Event"
        
        let newEKWrapper = EKWrapper(eventKitEvent: newEKEvent)
        newEKWrapper.editedEvent = newEKWrapper
        
        create(event: newEKWrapper, animated: true)
    }
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        endEventEditing()
        reloadData()
        controller.dismiss(animated: true, completion: nil)
    }
}

