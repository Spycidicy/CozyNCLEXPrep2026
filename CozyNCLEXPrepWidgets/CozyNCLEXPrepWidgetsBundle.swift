//
//  CozyNCLEXPrepWidgetsBundle.swift
//  CozyNCLEXPrepWidgets
//
//  Created by Ethan Long on 1/27/26.
//

import WidgetKit
import SwiftUI

@main
struct CozyNCLEXPrepWidgetsBundle: WidgetBundle {
    var body: some Widget {
        AffirmationWidget()
        StreakWidget()
        DailyGoalsWidget()
        StudyStatsWidget()
        CardOfTheDayWidget()
    }
}
