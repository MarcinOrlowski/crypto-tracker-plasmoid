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
	property alias cfg_running5: exchange.running
	property alias cfg_exchange5: exchange.exchange
	property alias cfg_crypto5: exchange.crypto
	property alias cfg_fiat5: exchange.fiat
	property alias cfg_refreshRate5: exchange.refreshRate
	property alias cfg_hidePriceDecimals5: exchange.hidePriceDecimals
	property alias cfg_useCustomLocale5: exchange.useCustomLocale
	property alias cfg_customLocaleName5: exchange.customLocaleName

    property alias cfg_showPriceChangeMarker5: exchange.showPriceChangeMarker
    property alias cfg_showTrendingMarker5: exchange.showTrendingMarker
    property alias cfg_trendingTimeSpan5: exchange.trendingTimeSpan

	ExchangeConfig {
		id: exchange
	}
}
