/**
 * Crypto Ticker widget for KDE
 *
 * @author    Marcin Orlowski <mail (#) marcinOrlowski (.) com>
 * @copyright 2021 Marcin Orlowski
 * @license   http://www.opensource.org/licenses/mit-license.php MIT
 * @link      https://github.com/MarcinOrlowski/crypto-plasmoid
 */

import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.1
import org.kde.kirigami 2.5 as Kirigami
import org.kde.kquickcontrols 2.0 as KQControls
import org.kde.plasma.components 3.0 as PlasmaComponents
import "../js/crypto.js" as Crypto

Kirigami.FormLayout {
	Layout.fillWidth: true

	property alias cfg_exchange: exchangeId.text
	property alias cfg_refreshRate: refreshRate.value
	// property alias cfg_currency: currencyId.text


	property string exchange: cfg_exchange
	onExchangeChanged: {
		// update currency ComboBox
		var currencyModel = []
		for(const key in Crypto.exchanges[exchange]['ccc']) {
			currencyModel.push({'value': key, 'text': Crypto.getCurrencyName(key)})
		}
		console.debug(exchange + ' ' + JSON.stringify(currencyModel))

		currencyComboBox.model = currencyModel
	}

	// key of exchange
	Text {
		visible: false
		id: exchangeId
	}
	PlasmaComponents.ComboBox {
		Kirigami.FormData.label: i18n('Exchange')

		textRole: "text"
		model: []
		Component.onCompleted: {
			// populate model from Theme object
			var tmp = []
			var idx = 0
			var currentIdx = undefined
			for(const key in Crypto.exchanges) {
				tmp.push({'value': key, 'text': Crypto.getExchangeName(key)})
				if (key === plasmoid.configuration['exchange']) currentIdx = idx
				idx++
			}
			model = tmp
			if (currentIdx !== undefined) currentIndex = currentIdx
		}
		onCurrentIndexChanged: exchange = model[currentIndex]['value']
	}

	Kirigami.FormLayout {
		anchors.left: parent.left
		anchors.right: parent.right

		PlasmaComponents.SpinBox {
			id: refreshRate
			editable: true
			from: 1
			to: 600
			stepSize: 15
			Kirigami.FormData.label: i18n("Data poll interval (minutes)")
		}
	}

	Text {
		visible: false
		id: currencyId
	}
	PlasmaComponents.ComboBox {
		id: currencyComboBox
		Kirigami.FormData.label: i18n('Currency')

		textRole: "text"
		model: []
		// Component.onCompleted: {
		// 	// populate model from Theme object
		// 	var tmp = []
		// 	var idx = 0
		// 	var currentIdx = undefined
		// 	for(const key in Crypto.currencySymbols) {
		// 		var name = key + ' (' + Crypto.currencySymbols[key] + ')'
		// 		tmp.push({'value': key, 'text': name})
		// 		if (key === plasmoid.configuration['currency']) currentIdx = idx
		// 		idx++
		// 	}
		// 	model = tmp

		// 	if (currentIdx !== undefined) currentIndex = currentIdx
		// }
		// onCurrentIndexChanged: cfg_themeName = model[currentIndex]['value']
	}

	PlasmaComponents.CheckBox {
		id: useUserTheme
		text: i18n("Use user theme")
	}

	Item {
		height: 10
	}

}

