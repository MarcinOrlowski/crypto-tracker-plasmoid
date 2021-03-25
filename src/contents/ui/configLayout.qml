/**
 * Crypto Tracker widget for KDE
 *
 * @author    Marcin Orlowski <mail (#) marcinOrlowski (.) com>
 * @copyright 2021 Marcin Orlowski
 * @license   http://www.opensource.org/licenses/mit-license.php MIT
 * @link      https://github.com/MarcinOrlowski/crypto-tracker-plasmoid
 */

import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.1
import org.kde.kirigami 2.5 as Kirigami
import org.kde.kquickcontrols 2.0 as KQControls
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.core 2.0 as PlasmaCore
import "../js/crypto.js" as Crypto
import "../js/layouts.js" as Layouts


Kirigami.FormLayout {
	Layout.fillWidth: true
	id: controlRoot

	property alias cfg_containerLayoutGridLayout: layoutGrid.gridLayout
	property alias cfg_containerLayoutTransparentBackgroundEnabled: transparentBackground.checked

	// ------------------------------------------------------------------------------------------------------------------------

	PlasmaComponents.ComboBox {
		id: layoutGrid

		property string gridLayout: cfg_containerLayoutGridLayout

		Kirigami.FormData.label: i18n('Exchange grid layout')
		textRole: "text"
		onCurrentIndexChanged: gridLayout = model[currentIndex]['value']

		function updateModel(layout) {
			var tmp = []
			var idx = 0
			var currentIdx = 0
			for(const key in Layouts.layouts) {
				tmp.push({'value': key, 'text': Layouts.getLayoutName(key)})
					if (key === layout) currentIdx = idx
					idx++
			}
			model = tmp
			currentIndex = currentIdx
		}
		Component.onCompleted: updateModel(cfg_containerLayoutGridLayout)
	}

	CheckBox {
		id: transparentBackground
		text: i18n("Transparent background")
		checked: cfg_containerLayoutTransparentBackgroundEnabled

		// If ConfigurableBackground is set, the we most likely run on Plasma 5.19+ and if so,
		// we prefer using widget's background control features instead.
		visible: typeof PlasmaCore.Types.ConfigurableBackground === "undefined"
	}

	Item {
		Layout.fillWidth: true
		Layout.fillHeight: true
	}

}
