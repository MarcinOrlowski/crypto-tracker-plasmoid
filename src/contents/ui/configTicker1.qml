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

	property alias cfg_exchange1: exchangeId.text
	property alias cfg_crypto1: cryptoId.text
	property alias cfg_fiat1: fiatId.text
	property alias cfg_refreshRate1: refreshRate.value
	property alias cfg_hidePriceDecimals1: hidePriceDecimals.checked

	property string exchange: cfg_exchange1
	property string crypto: cfg_crypto1
	property string fiat: cfg_fiat1

	// ------------------------------------------------------------------------------------------------------------------------

	// key of exchange
	Text {
		visible: false
		id: exchangeId
		text: exchange
		onTextChanged: {
			var model = Crypto.getAllExchangeCryptos(exchange)
			if (model !== null) {
				cryptoComboBox.model = model
				exchange = text
			}
		}
	}

	PlasmaComponents.ComboBox {
		Kirigami.FormData.label: i18n('Exchange')
		textRole: "text"
		Component.onCompleted: populateModel()
		onCurrentIndexChanged: exchangeId.text = model[currentIndex]['value']

		function populateModel() {
			var tmp = []
			var idx = 0
			var currentIdx = undefined
			for(const key in Crypto.exchanges) {
				tmp.push({'value': key, 'text': Crypto.getExchangeName(key)})
				if (key === plasmoid.configuration['exchange']) currentIdx = idx
				idx++
			}
			model = tmp
			if (typeof currentIdx !== 'undefined') currentIndex = currentIdx
		}
	}

	// ------------------------------------------------------------------------------------------------------------------------

	Text {
		visible: false
		id: cryptoId
		text: crypto
		onTextChanged: {
			var model = Crypto.getFiatsForCrypto(exchange, crypto)
			if (model !== null) {
				fiatComboBox.model = model
				crypto = text
			}
		}
	}

	PlasmaComponents.ComboBox {
		id: cryptoComboBox
		Kirigami.FormData.label: i18n('Crypto')
		textRole: "text"
		Component.onCompleted: populateModel()
		onCurrentIndexChanged: cryptoId.text = model[currentIndex]['value']

		function populateModel() {
			if (exchange in Crypto.exchanges) {
				var tmp = []
				var idx = 0
				var currentIdx = undefined

				for(const key in Crypto.exchanges[exchange]['pairs']) {
					tmp.push({'value': key, 'text': Crypto.getCryptoName(key)})
					if (typeof currentIdx !== 'undefined') currentIndex = currentIdx
					idx++
				}
				model = tmp
				if (typeof currentIdx !== 'undefined') currentIndex = currentIdx
			}
		}
	}

	// ------------------------------------------------------------------------------------------------------------------------

	Text {
		visible: false
		id: fiatId
		text: fiat
		onTextChanged: fiat = text
	}
	PlasmaComponents.ComboBox {
		id: fiatComboBox
		Kirigami.FormData.label: i18n('Fiat')

		textRole: "text"
		model: []
		Component.onCompleted: {
			if ((exchange in Crypto.exchanges) && (crypto in Crypto.exchanges[exchange]['pairs'])) {
				var tmp = []
				var idx = 0
				var currentIdx = undefined
				console.debug(`ex: '${exchange}'`)

				for(const key in Crypto.exchanges[exchange]['pairs'][crypto]) {
					tmp.push({'value': key, 'text': Crypto.getCurrencyName(key)})
					if (key === plasmoid.configuration['currency']) currentIdx = idx
					idx++
				}
				model = tmp
				if (typeof currentIdx !== 'undefined') currentIndex = currentIdx
			}
		}
		onCurrentIndexChanged: fiatId.text = model[currentIndex]['value']
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

	// FIXME should be per Pair as we may have i.e. LTCBTC pair soon
	// and this would make no sense then.
	PlasmaComponents.CheckBox {
		id: hidePriceDecimals
		text: i18n("Hide price decimals")
	}

	Item {
		height: 10
	}

}
