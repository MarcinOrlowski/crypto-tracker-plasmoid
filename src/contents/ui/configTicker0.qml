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
	property alias cfg_running0: exchange.running
	property alias cfg_exchange0: exchange.exchange
	property alias cfg_crypto0: exchange.crypto
	property alias cfg_fiat0: exchange.fiat
	property alias cfg_refreshRate0: exchange.refreshRate
	property alias cfg_hidePriceDecimals0: exchange.hidePriceDecimals
	property alias cfg_useCustomLocale0: exchange.useCustomLocale
	property alias cfg_customLocaleName0: exchange.customLocaleName

    property alias cfg_showPriceChangeMarker0: exchange.showPriceChangeMarker
    property alias cfg_showTrendingMarker0: exchange.showTrendingMarker
    property alias cfg_trendingTimeSpan0: exchange.trendingTimeSpan

    property alias cfg_flashOnPriceRaise0: exchange.flashOnPriceRaise
    property alias cfg_flashOnPriceDrop0: exchange.flashOnPriceDrop

	ExchangeConfig {
		id: exchange
	}
}
