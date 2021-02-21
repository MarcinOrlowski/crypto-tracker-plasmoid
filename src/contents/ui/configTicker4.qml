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
	property alias cfg_running4: exchange.running
	property alias cfg_exchange4: exchange.exchange
	property alias cfg_crypto4: exchange.crypto
	property alias cfg_hideCryptoLogo4: exchange.hideCryptoLogo
	property alias cfg_fiat4: exchange.fiat
	property alias cfg_refreshRate4: exchange.refreshRate
	property alias cfg_hidePriceDecimals4: exchange.hidePriceDecimals
	property alias cfg_useCustomLocale4: exchange.useCustomLocale
	property alias cfg_customLocaleName4: exchange.customLocaleName

    property alias cfg_showPriceChangeMarker4: exchange.showPriceChangeMarker
    property alias cfg_showTrendingMarker4: exchange.showTrendingMarker
    property alias cfg_trendingTimeSpan4: exchange.trendingTimeSpan

    property alias cfg_flashOnPriceRaise4: exchange.flashOnPriceRaise
    property alias cfg_flashOnPriceDrop4: exchange.flashOnPriceDrop
	property alias cfg_flashOnPriceDropColor4: exchange.flashOnPriceDropColor
	property alias cfg_flashOnPriceRaiseColor4: exchange.flashOnPriceRaiseColor
	property alias cfg_markerColorPriceRaise4: exchange.markerColorPriceRaise
	property alias cfg_markerColorPriceDrop4: exchange.markerColorPriceDrop

	ExchangeConfig {
		id: exchange
	}
}
