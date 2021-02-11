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
	property alias cfg_running2: exchange.running
	property alias cfg_exchange2: exchange.exchange
	property alias cfg_crypto2: exchange.crypto
	property alias cfg_fiat2: exchange.fiat
	property alias cfg_refreshRate2: exchange.refreshRate
	property alias cfg_hidePriceDecimals2: exchange.hidePriceDecimals
	property alias cfg_useCustomLocale2: exchange.useCustomLocale
	property alias cfg_customLocaleName2: exchange.customLocaleName

    property alias cfg_showPriceChangeMarker2: exchange.showPriceChangeMarker
    property alias cfg_showTrendingMarker2: exchange.showTrendingMarker
    property alias cfg_trendingTimeSpan2: exchange.trendingTimeSpan

	ExchangeConfig {
		id: exchange
	}
}
