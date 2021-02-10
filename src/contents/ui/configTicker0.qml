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

	property alias cfg_exchange0: exchangeId.text
	property alias cfg_crypto0: cryptoId.text
	property alias cfg_fiat0: fiatId.text
	property alias cfg_refreshRate0: refreshRate.value
	property alias cfg_hidePriceDecimals0: hidePriceDecimals.checked

	property string exchange: cfg_exchange0
	property string crypto: cfg_crypto0
	property string fiat: cfg_fiat0

	// ------------------------------------------------------------------------------------------------------------------------

	function getAllExchangeCryptos(exchange) {
		console.debug('1')
		var cryptoModel = []
		for(const key in Crypto.exchanges[exchange]['pairs']) {
			cryptoModel.push({'value': key, 'text': Crypto.getCryptoName(key)})
		}
		return cryptoModel
	}
	function getFiatsForCrypto(exchange, crypto) {
	console.debug('')	
		var currencyModel = []
		for(const key in Crypto.exchanges[exchange]['pairs'][crypto]) {
			currencyModel.push({'value': key, 'text': Crypto.getCurrencyName(key)})
		}
		return currencyModel
	}

	// ------------------------------------------------------------------------------------------------------------------------

	onExchangeChanged: cryptoComboBox.model = getAllExchangeCryptos(exchange)
	onCryptoChanged: fiatComboBox.model = getFiatsForCrypto(exchange, crypto)

	// ------------------------------------------------------------------------------------------------------------------------

	// key of exchange
	Text {
		visible: false
		id: exchangeId
		text: exchange
	}
	PlasmaComponents.ComboBox {
		Kirigami.FormData.label: i18n('Exchange')

		textRole: "text"
		model: []
		Component.onCompleted: {
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
		onCurrentIndexChanged: exchange = model[currentIndex]['value']
	}

	// ------------------------------------------------------------------------------------------------------------------------

	Text {
		visible: false
		id: cryptoId
		text: crypto
	}
	PlasmaComponents.ComboBox {
		id: cryptoComboBox
		Kirigami.FormData.label: i18n('Crypto')

		textRole: "text"
		model: []
		Component.onCompleted: {
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
		onCurrentIndexChanged: crypto = model[currentIndex]['value']
	}

	// ------------------------------------------------------------------------------------------------------------------------

	Text {
		visible: false
		id: fiatId
		text: fiat
	}
	PlasmaComponents.ComboBox {
		id: fiatComboBox
		Kirigami.FormData.label: i18n('Currency')

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
		onCurrentIndexChanged: fiat = model[currentIndex]['value']
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

