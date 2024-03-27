/**
 * Crypto Tracker widget for KDE
 *
 * @author    Marcin Orlowski <mail (#) marcinOrlowski (.) com>
 * @copyright 2021 Marcin Orlowski
 * @license   http://www.opensource.org/licenses/mit-license.php MIT
 * @link      https://github.com/MarcinOrlowski/crypto-tracker-plasmoid
 */

import QtQuick 2.1
import QtQuick.Layouts 1.1
import org.kde.plasma.workspace.calendar 2.0 as PlasmaCalendar
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0

import "../js/meta.js" as Meta

PlasmoidItem {
	id: root

	Plasmoid.contextualActions: [
		PlasmaCore.Action {
			text: i18n('About2 %1…', Meta.title)
			onTriggered: {
				aboutDialog.visible = true
			}
		},
		PlasmaCore.Action {
			text: i18n("Check update…")
			onTriggered: {
				updateChecker.checkUpdateAvailability(true)
			}
		}
	]

	AboutDialog {
		id: aboutDialog
	}

	// ------------------------------------------------------------------------------------------------------------------------

	preferredRepresentation: fullRepresentation
	fullRepresentation: ExchangeContainer {}

	// If ConfigurableBackground is set, the we most likely run on Plasma 5.19+ and if so, we prefer using
	// widget's background control features instead.
	Plasmoid.backgroundHints: (typeof PlasmaCore.Types.ConfigurableBackground !== "undefined"
		? PlasmaCore.Types.DefaultBackground | PlasmaCore.Types.ConfigurableBackground
		: plasmoid.configuration.containerLayoutTransparentBackgroundEnabled ? PlasmaCore.Types.NoBackground : PlasmaCore.Types.DefaultBackground
	)

	// ------------------------------------------------------------------------------------------------------------------------

	UpdateChecker {
		id: updateChecker

		// once per 7 days
		checkInterval: (((1000*60)*60)*24*7)
	}

} // root
