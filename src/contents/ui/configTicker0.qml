/**
 * Crypto Ticker widget for KDE
 *
 * @author    Marcin Orlowski <mail (#) marcinOrlowski (.) com>
 * @copyright 2021 Marcin Orlowski
 * @license   http://www.opensource.org/licenses/mit-license.php MIT
 * @link      https://github.com/MarcinOrlowski/crypto-plasmoid
 */

import QtQuick 2.0

Item {
	property alias cfg_exchange0: exchange.exchange
	property alias cfg_crypto0: exchange.crypto
	property alias cfg_fiat0: exchange.fiat
	property alias cfg_refreshRate0: exchange.refreshRate
	property alias cfg_hidePriceDecimals0: exchange.hidePriceDecimals
	property alias cfg_useCustomLocale0: exchange.useCustomLocale
	property alias cfg_customLocaleName0: exchange.customLocaleName

	ExchangeConfig {
		id: exchange

		exchange: cfg_exchange0
		crypto: cfg_crypto0
		fiat: cfg_fiat0
		refreshRate: cfg_refreshRate0
		hidePriceDecimals: cfg_hidePriceDecimals0
		useCustomLocale: cfg_useCustomLocale0
		customLocaleName: cfg_customLocaleName0
	}
}
