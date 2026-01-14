/**
 * Crypto Tracker widget for KDE
 *
 * @author    Marcin Orlowski <mail (#) marcinOrlowski (.) com>
 * @copyright 2021-2026 Marcin Orlowski
 * @license   http://www.opensource.org/licenses/mit-license.php MIT
 * @link      https://github.com/MarcinOrlowski/crypto-tracker-plasmoid
 */

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami

PlasmoidItem {
	id: root

	// Context menu actions (Plasma 6 declarative style)
	Plasmoid.contextualActions: [
		PlasmaCore.Action {
			text: i18n("Check update…")
			icon.name: "update-none"
			onTriggered: updateChecker.checkUpdateAvailability(true)
		}
	]

	// ------------------------------------------------------------------------------------------------------------------------

	// Properties moved from Plasmoid.* to direct PlasmoidItem properties
	preferredRepresentation: compactRepresentation
	compactRepresentation: Component {
		ExchangeContainer {}
	}
	fullRepresentation: compactRepresentation

	// If ConfigurableBackground is set, the we most likely run on Plasma 5.19+ and if so, we prefer using
	// widget's background control features instead.
	Plasmoid.backgroundHints: (typeof PlasmaCore.Types.ConfigurableBackground !== "undefined"
		? PlasmaCore.Types.DefaultBackground | PlasmaCore.Types.ConfigurableBackground
		: Plasmoid.configuration.containerLayoutTransparentBackgroundEnabled ? PlasmaCore.Types.NoBackground : PlasmaCore.Types.DefaultBackground
	)

	// ------------------------------------------------------------------------------------------------------------------------

	UpdateChecker {
		id: updateChecker

		// once per 7 days
		checkInterval: (((1000*60)*60)*24*7)
	}

} // root
