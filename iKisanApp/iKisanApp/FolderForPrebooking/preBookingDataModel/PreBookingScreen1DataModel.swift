//
//  PreBookingDataModel.swift
//  iKisanApp
//
//  Created by Batch - 1 on 23/01/25.
//

import Foundation

struct PreBookingSection1Data {
    var equipmentName: String
    var equipmentImage: String
    var equipmentDescription: String
}

struct PreBookingSection3Data {
    var equipmentName: String
    var equipmentImage: String
    var equipmentDate: String
    var equipmentStatus: String
}

struct PreBookingSection4Data {
    var needHelp: String
}


class PreBookingScreenData {
    
    static var preBookingSection1Data: [PreBookingSection1Data] = [
        PreBookingSection1Data(equipmentName: "Hammer Drill", equipmentImage: "Image 7", equipmentDescription: "Pre-book today for seamless spraying this season."),
        
        PreBookingSection1Data(equipmentName: "Angle Grinder", equipmentImage: "Image 6", equipmentDescription: "Pre-book today for seamless spraying this season."),
        
        PreBookingSection1Data(equipmentName: "Welding Machine", equipmentImage: "Image 8", equipmentDescription: "Pre-book today for seamless spraying this season."),
        
        PreBookingSection1Data(equipmentName: "Concrete Mixer", equipmentImage: "Image 6", equipmentDescription: "Pre-book today for seamless spraying this season."),
        
        PreBookingSection1Data(equipmentName: "Circular Saw", equipmentImage: "Image 7", equipmentDescription: "Pre-book today for seamless spraying this season.")
        
    ]
    
    static var preBookingSection3Data: [PreBookingSection3Data] = [
        PreBookingSection3Data(equipmentName: "Hammer Drill", equipmentImage: "Image 7", equipmentDate: "Fri, 24 Jan", equipmentStatus: "Confirmed"),
        
        PreBookingSection3Data(equipmentName: "Angle Grinder", equipmentImage: "Image 6", equipmentDate: "Sat, 22 Jan", equipmentStatus: "Pending"),
        
        PreBookingSection3Data(equipmentName: "Welding Machine", equipmentImage: "Image 8", equipmentDate: "Sun, 21 Jan", equipmentStatus: "Confirmed"),
        
        PreBookingSection3Data(equipmentName: "Concrete Mixer", equipmentImage: "Image 6", equipmentDate: "Mon, 20 Jan", equipmentStatus: "Pending"),
        PreBookingSection3Data(equipmentName: "Hammer Drill", equipmentImage: "Image 7", equipmentDate: "Tue, 25 Jan", equipmentStatus: "Confirmed")
    ]
    
    
    
    static var preBookingSection4Data:[PreBookingSection4Data] = [
        PreBookingSection4Data(needHelp: "How does prebooking work?"),
        PreBookingSection4Data(needHelp: "What if equipment is unavailable?"),
        PreBookingSection4Data(needHelp: "Can I cancel or modify a booking?")
        
    ]

    
    static var preBookingSectionHeaderNames:[String] = [
        "Recommended for You ",
        "Calendar",
        "Available Equipments",
        "Your Prebookings",
        "Need Help?"
       
    ]
}

