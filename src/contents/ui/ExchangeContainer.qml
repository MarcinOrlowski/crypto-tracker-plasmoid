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
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasmoid
import "../js/crypto.js" as Crypto

GridLayout {
	readonly property bool vericalOrientation: Plasmoid.formFactor == PlasmaCore.Types.Vertical
	readonly property string defaultLocale: ''
	property var exchanges: JSON.parse(Plasmoid.configuration.exchanges).filter(ex => ex['enabled'])

	// Lame trick to force re-evaluation. It's needed because if we reorder exchanges, then
	// exchange count is unchanged, so (unless there's better way?) Repeater will not be
	// triggered and exchanges will not be redrawn in new order.
	property int exchangeCount: 0
	onExchangesChanged: {
		exchangeCount = 0
		exchangeCount = exchanges.length
	}

	rows: (!Plasmoid.configuration.customContainerLayoutEnabled)
			? (vericalOrientation ? exchangeCount : 1)
			: Plasmoid.configuration.containerLayoutRows
	columns: (!Plasmoid.configuration.customContainerLayoutEnabled)
			? (vericalOrientation ? 1 : exchangeCount)
			: Plasmoid.configuration.containerLayoutColumns

	PlasmaComponents.Label {
		visible: exchanges.length === 0
		Layout.alignment: Qt.AlignHCenter
		text: i18n("Edit me!")
	}

	Repeater {
		model: exchangeCount
		Exchange {
			json: exchanges[index]
			Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
		}
	}

} // ColumnLayout
