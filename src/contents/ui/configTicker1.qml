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
	property alias cfg_running1: exchange.running
	property alias cfg_exchange1: exchange.exchange
	property alias cfg_crypto1: exchange.crypto
	property alias cfg_hideCryptoLogo1: exchange.hideCryptoLogo
	property alias cfg_fiat1: exchange.fiat
	property alias cfg_refreshRate1: exchange.refreshRate
	property alias cfg_hidePriceDecimals1: exchange.hidePriceDecimals
	property alias cfg_useCustomLocale1: exchange.useCustomLocale
	property alias cfg_customLocaleName1: exchange.customLocaleName

    property alias cfg_showPriceChangeMarker1: exchange.showPriceChangeMarker
    property alias cfg_showTrendingMarker1: exchange.showTrendingMarker
    property alias cfg_trendingTimeSpan1: exchange.trendingTimeSpan

    property alias cfg_flashOnPriceRaise1: exchange.flashOnPriceRaise
    property alias cfg_flashOnPriceDrop1: exchange.flashOnPriceDrop
	property alias cfg_flashOnPriceDropColor1: exchange.flashOnPriceDropColor
	property alias cfg_flashOnPriceRaiseColor1: exchange.flashOnPriceRaiseColor
	property alias cfg_markerColorPriceRaise1: exchange.markerColorPriceRaise
	property alias cfg_markerColorPriceDrop1: exchange.markerColorPriceDrop

	ExchangeConfig {
		id: exchange
	}
}
