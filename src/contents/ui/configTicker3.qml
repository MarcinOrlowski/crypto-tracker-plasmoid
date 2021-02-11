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
	property alias cfg_running3: exchange.running
	property alias cfg_exchange3: exchange.exchange
	property alias cfg_crypto3: exchange.crypto
	property alias cfg_fiat3: exchange.fiat
	property alias cfg_refreshRate3: exchange.refreshRate
	property alias cfg_hidePriceDecimals3: exchange.hidePriceDecimals
	property alias cfg_useCustomLocale3: exchange.useCustomLocale
	property alias cfg_customLocaleName3: exchange.customLocaleName

	ExchangeConfig {
		id: exchange
	}
}
