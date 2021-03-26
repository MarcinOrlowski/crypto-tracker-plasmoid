/**
 * Crypto Tracker widget for KDE
 *
 * @author    Marcin Orlowski <mail (#) marcinOrlowski (.) com>
 * @copyright 2021 Marcin Orlowski
 * @license   http://www.opensource.org/licenses/mit-license.php MIT
 * @link      https://github.com/MarcinOrlowski/crypto-tracker-plasmoid
 */

import QtQuick 2.0
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import "../js/crypto.js" as Crypto

GridLayout {
	readonly property bool vericalOrientation: plasmoid.formFactor == PlasmaCore.Types.Vertical
	readonly property string defaultLocale: ''
	property var exchanges: JSON.parse(plasmoid.configuration.exchanges).filter(ex => ex['enabled'])

	// Lame trick to force re-evaluation. It's needed because if we reorder exchanges, then
	// exchange count is unchanged, so (unless there's better way?) Repeater will not be 
	// triggered and exchanges will not be redrawn in new order.
	property int maxExchangeCount: 0
	onExchangesChanged: {
		maxExchangeCount = 0
		maxExchangeCount = exchanges.length
	}
	
	rows: (!plasmoid.configuration.customContainerLayoutEnabled) 
			? (vericalOrientation ? maxExchangeCount : 1) 
			: plasmoid.configuration.containerLayoutRows
	columns: (!plasmoid.configuration.customContainerLayoutEnabled)
			? (vericalOrientation ? 1 : maxExchangeCount)
			: plasmoid.configuration.containerLayoutColumns

	PlasmaComponents.Label {
		visible: exchanges.length === 0
		Layout.alignment: Qt.AlignHCenter
		text: i18n("Edit me!")
	}

	Repeater {
		model: maxExchangeCount
		Exchange {
			json: exchanges[index]
		}
	}

} // ColumnLayout
