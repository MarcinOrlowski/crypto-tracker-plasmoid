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
import "../js/layouts.js" as Layouts

GridLayout {
	readonly property bool vericalOrientation: plasmoid.formFactor == PlasmaCore.Types.Vertical
	readonly property string defaultLocale: ''
	property var exchanges: {
		console.debug('xxxxxx ' + plasmoid.configuration.exchanges)
		return JSON.parse(plasmoid.configuration.exchanges)
	}
	readonly property int maxExchangeCount: exchanges.length

	property string containerLayoutId: plasmoid.configuration.containerLayoutGridLayout

	rows: {
		var rows = vericalOrientation ? maxExchangeCount : 1
		if (containerLayoutId !== Layouts.DEFAULT) {
			var layout = Layouts.getLayout(containerLayoutId)
			rows = layout.rows
		}
		return rows
	}

	columns: {
		var columns = vericalOrientation ? 1 : maxExchangeCount
		if (containerLayoutId !== Layouts.DEFAULT) {
			var layout = Layouts.getLayout(containerLayoutId)
			columns = layout.columns
		}
		return columns
	}

	readonly property bool anythingVisible: exchanges.length > 0

	PlasmaComponents.Label {
		visible: !anythingVisible
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
