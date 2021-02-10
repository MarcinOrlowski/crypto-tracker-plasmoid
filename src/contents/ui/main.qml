/**
 * Crypto Ticker widget for KDE
 *
 * @author    Marcin Orlowski <mail (#) marcinOrlowski (.) com>
 * @copyright 2021 Marcin Orlowski
 * @license   http://www.opensource.org/licenses/mit-license.php MIT
 * @link      https://github.com/MarcinOrlowski/crypto-plasmoid
 */

import QtQuick 2.1
import QtQuick.Layouts 1.1
import org.kde.plasma.calendar 2.0 as PlasmaCalendar
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0
import "../js/meta.js" as Meta

Item {
	id: root

	Component.onCompleted: {
		plasmoid.setAction("showAboutDialog", i18n('About %1…', Meta.title));
		plasmoid.setAction("checkUpdateAvailability", i18n("Check update…"));
	}

	function action_checkUpdateAvailability() {
		updateChecker.checkUpdateAvailability(true)
	}

	function action_showAboutDialog() {
		aboutDialog.visible = true
	}
	AboutDialog {
		id: aboutDialog
	}

	// ------------------------------------------------------------------------------------------------------------------------

	property string tooltipMainText: ''
	property string tooltipSubText: ''

/*
	PlasmaCore.DataSource {
		engine: "time"
		connectedSources: ["Local"]
		interval: 1000
		intervalAlignment: PlasmaCore.Types.NoAlignment
		onDataChanged: {
			var mainText = i18n("Widget is in Fake Parameters mode now.")
			var subText = i18n("Disable it in Settings/User Theme.")

			if (!plasmoid.configuration.useFakeParameters) {
				var localeToUse = plasmoid.configuration.useSpecificLocaleEnabled
						? plasmoid.configuration.useSpecificLocaleLocaleName
						: ''

				mainText = DTF.format(plasmoid.configuration.tooltipFirstLineFormat, localeToUse)
				subText = DTF.format(plasmoid.configuration.tooltipSecondLineFormat, localeToUse)
			}

			tooltipMainText = mainText
			tooltipSubText = subText
		}
	}
*/

	// Plasmoid.toolTipMainText: tooltipMainText
	// Plasmoid.toolTipSubText: tooltipSubText

	// ------------------------------------------------------------------------------------------------------------------------

	Plasmoid.preferredRepresentation: Plasmoid.compactRepresentation
	Plasmoid.compactRepresentation: Crypto { }
//	Plasmoid.fullRepresentation: CalendarView { }

	// ------------------------------------------------------------------------------------------------------------------------

/*
	UpdateChecker {
		id: updateChecker

		// once per 7 days
		checkInterval: (((1000*60)*60)*24*7)
	}
*/


} // root