/**
 * Crypto Tracker widget for KDE
 *
 * @author    Marcin Orlowski <mail (#) marcinOrlowski (.) com>
 * @copyright 2021 Marcin Orlowski
 * @license   http://www.opensource.org/licenses/mit-license.php MIT
 * @link      https://github.com/MarcinOrlowski/crypto-tracker-plasmoid
 */

import QtQuick 2.0

Item {
	property alias cfg_running3: exchange.running
	property alias cfg_exchange3: exchange.exchange
	property alias cfg_crypto3: exchange.crypto
	property alias cfg_hideCryptoLogo3: exchange.hideCryptoLogo
	property alias cfg_fiat3: exchange.fiat
	property alias cfg_refreshRate3: exchange.refreshRate
	property alias cfg_hidePriceDecimals3: exchange.hidePriceDecimals
	property alias cfg_useCustomLocale3: exchange.useCustomLocale
	property alias cfg_customLocaleName3: exchange.customLocaleName

    property alias cfg_showPriceChangeMarker3: exchange.showPriceChangeMarker
    property alias cfg_showTrendingMarker3: exchange.showTrendingMarker
    property alias cfg_trendingTimeSpan3: exchange.trendingTimeSpan

    property alias cfg_flashOnPriceRaise3: exchange.flashOnPriceRaise
    property alias cfg_flashOnPriceDrop3: exchange.flashOnPriceDrop
	property alias cfg_flashOnPriceDropColor3: exchange.flashOnPriceDropColor
	property alias cfg_flashOnPriceRaiseColor3: exchange.flashOnPriceRaiseColor
	property alias cfg_markerColorPriceRaise3: exchange.markerColorPriceRaise
	property alias cfg_markerColorPriceDrop3: exchange.markerColorPriceDrop

	ExchangeConfig {
		id: exchange
	}
}
