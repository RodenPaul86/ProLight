//
//  ComplicationController.swift
//  ProLightWatch Extension
//
//  Created by Paul on 7/7/19.
//  Copyright © 2019 Studio4Designsoftware. All rights reserved.
//

import ClockKit

class ComplicationController: NSObject, CLKComplicationDataSource {
    
    //MARK: - Timeline Configuration
    
    func requestedUpdateDidBegin() {
        let server = CLKComplicationServer.sharedInstance()
        guard let activeComplications = server.activeComplications else { return }
        activeComplications.forEach { server.reloadTimeline(for: $0) }
    }
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([.forward, .backward])
    }
    
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(nil)
    }
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(nil)
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    //MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        // Call the handler with the current timeline entry
        if complication.family == .modularSmall {
            let modularSmall = CLKComplicationTemplateModularSmallSimpleImage()
            modularSmall.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "proLightSmall.png")!)
            modularSmall.tintColor = UIColor.green
            handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: modularSmall))
            
        } else if complication.family == .circularSmall {
            let circularSmall = CLKComplicationTemplateCircularSmallSimpleImage()
            circularSmall.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "proLightSmall.png")!)
            handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: circularSmall))
        }
    }
    
    func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries prior to the given date
        handler(nil)
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries after to the given date
        handler(nil)
    }
    
    //MARK: - Placeholder Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        if complication.family == .modularSmall {
            let modularSmall = CLKComplicationTemplateModularSmallSimpleImage()
            modularSmall.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "proLightSmall.png")!)
            modularSmall.tintColor = UIColor.green
            handler(modularSmall)
            
        } else if complication.family == .circularSmall {
            let circularSmall = CLKComplicationTemplateCircularSmallSimpleImage()
            circularSmall.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "proLightSmall.png")!)
            handler(circularSmall)
        }
    }
    
    
    func getPlaceholderTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        if complication.family == .modularSmall {
            let modularSmall = CLKComplicationTemplateModularSmallSimpleImage()
            modularSmall.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "proLightSmall.png")!)
            modularSmall.tintColor = UIColor.green
            handler(modularSmall)
            
        } else if complication.family == .circularSmall {
            let circularSmall = CLKComplicationTemplateCircularSmallSimpleImage()
            circularSmall.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "proLightSmall.png")!)
            handler(circularSmall)
        }
    }
    
    
    
    
    
    
    
    
    
    
}



