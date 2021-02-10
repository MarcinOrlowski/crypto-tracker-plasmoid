/**
 * Crypto Ticker widget for KDE
 *
 * @author    Marcin Orlowski <mail (#) marcinOrlowski (.) com>
 * @copyright 2021 Marcin Orlowski
 * @license   http://www.opensource.org/licenses/mit-license.php MIT
 * @link      https://github.com/MarcinOrlowski/crypto-plasmoid
 */

import QtQuick 2.1
import QtQuick.Layouts 1.1
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.core 2.0 as PlasmaCore
// import org.kde.plasma.plasmoid 2.0
// import "../js/meta.js" as Meta
import "../js/crypto.js" as Crypto

RowLayout {
    id: tickerRoot

    property string crypto: 'BTC'       // cryptocurrency code to use
    property string exchange: 'bitstamp'
    property string currency: 'PLN'
    property string localeToUse: plasmoid.configuration.useCustomLocale ? plasmoid.configuration.localeName : ''
    
    property int refreshRate: plasmoid.configuration.refreshRate
    property bool noDecimals: false
    property string colorUp: "#00ff00"
    property string colorDown: "#ff0000"

    // --------------------------------------------------------------------------------------------

    function getColor(direction) {
        var color = '#ffffff'
        switch(direction) {
            case +1: 
                color = colorUp
                break
            case -1:
                color = colorDown
                break
        }
        return color
    }

    // --------------------------------------------------------------------------------------------

	readonly property var trendingThreshold: 60 * 60 * 1000	// 1 hour
/*
	PlasmaCore.DataSource {
		id: timeDataSource
		engine: "time"
		connectedSources: ["Local"]
		interval: trendingThreshold
		intervalAlignment: PlasmaCore.Types.AlignToHour
		onNewData: updateTrending()
	}
*/

	property var lastTrendingUpdateStamp: 0
	property var lastTrendingRate: 0
	property int trendingDirection: undefined		// -1, 0, 1
	function updateTrending(rate) {
		var now = new Date()

		// one hour
		var updateRate = false
		if (lastTrendingUpdateStamp != 0) {
			if ((now.getTime() - lastTrendingUpdateStamp) >= (trendingThreshold)) {
				if (rate > lastTrendingRate) {
					trendingDirection = 1
				} else if (currentRate < lastTrendingRate) {
					trendingDirection = -1
				} else {
					trendingDirection = 0
				}

				updateRate = true

				console.debug('updateTrending() direction: ' + trendingDirection)
			}
		}

		if (lastTrendingUpdateStamp == 0 || updateRate) {
			lastTrendingUpdateStamp = now.getTime()
			lastTrendingRate = rate
		}

	}

    // --------------------------------------------------------------------------------------------

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: fetchRate()
    }

    // --------------------------------------------------------------------------------------------

    Rectangle {
        id: bgWall
        anchors.fill: parent
        opacity: 0
    }

	Timer {
        id: bgWallFadeTimer
        interval: 100
		running: false
		repeat: true
		triggeredOnStart: false
		onTriggered: {
            bgWall.opacity = (bgWall.opacity > 0) ? (bgWall.opacity -= 0.1) : 0
            running = (bgWall.opacity !== 0)
        }
	}

    // --------------------------------------------------------------------------------------------

    function getRateText() {
        if (typeof currentRate === 'undefined') return '---'

        var localeToUse = tickerRoot.localeToUse
        var noDecimals = tickerRoot.noDecimals

        var color = getColor(rateChangeDirection)

        var rate = currentRate
        if(noDecimals) rate = Math.round(rate)

        var rateText = ''

        // https://unicode-table.com/en/sets/arrow-symbols/
        // 1 hrs trending direction
        var color = getColor(trendingDirection)
        if (typeof trendingDirection != 'undefined' && trendingDirection !== 0) {
            // ↑ Upwards Arrow U+2191
            rateText += `<span style="color: ${color};">`
            if (trendingDirection == +1) rateText += '↑'
            // ↓ Downwards Arrow U+2193
            if (trendingDirection == -1) rateText += '↓'
            rateText += '</span> '
        }

        // var tmp = Number(rate).toLocaleCurrencyString(Qt.locale(localeToUse), Crypto.currencySymbols[currency])
        var tmp = Number(rate).toLocaleCurrencyString(Qt.locale(localeToUse), Crypto.currencySymbols[Crypto.exchanges[exchange]['currency']])
        if(noDecimals) tmp = tmp.replace(Qt.locale(localeToUse).decimalPoint + '00', '')
        rateText += `<span>${tmp}</span>`

        // echange rate change direction
        // • Bullet black small circle U+2022
        // var rateText = '• '
        color = getColor(rateChangeDirection)
        if (rateChangeDirection !== 0) {
            // ▲ Black Up-Pointing Triangle U+25B2
            rateText += ` <span style="color: ${color};">`
            if (rateChangeDirection == +1) rateText += '▲'
            // ▼ Black Down-Pointing Triangle U+25BC
            if (rateChangeDirection == -1) rateText += '▼'
            rateText += '</span>'
        }

        // console.debug(`${exchange}: ${rate} => ${rateText}`)

        return rateText
    }

    PlasmaComponents.Label {
        id: rateLabel

        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        Layout.alignment: Qt.AlignHCenter
        Layout.fillWidth: true
        height: 20

        textFormat: Text.RichText
        fontSizeMode: Text.Fit
        // minimumPixelSize: bitcoinIcon.width * 0.7
        minimumPixelSize: 8
        // font.pixelSize: 12			
        // text: 'N/A'
        text: getRateText()
    }

    // --------------------------------------------------------------------------------------------

    property var lastUpdateMillis: 0
    property var currentRate: undefined
    property var lastRate: undefined
    property int rateChangeDirection: 0             // -1, 0, 1

    property bool rateDirectionChanged: false
    onRateDirectionChangedChanged: {
        // console.debug('changed: ' + rateChangeDirection)
        if (rateChangeDirection !== 0) {
            bgWall.color = getColor(rateChangeDirection)
            bgWall.opacity = 1
            bgWallFadeTimer.running = true
            bgWallFadeTimer.start()
        }
    }

	Timer {
		interval: tickerRoot.refreshRate * 60 * 1000
        // interval: 15 * 1000
		running: true
		repeat: true
		triggeredOnStart: true
		onTriggered: fetchRate()
	}

    // --------------------------------------------------------------------------------------------

    property bool updateInProgress: false
    function fetchRate() {
        if (updateInProgress) return

        updateInProgress = true;

        var exchange = tickerRoot.exchange
        var currency = tickerRoot.currency
        Crypto.getRate(exchange, function(rate) {
            var now = new Date()
            lastUpdateMillis = now.getTime()

            lastRate = currentRate
            currentRate = rate

            var lastRateChangeDirection = rateChangeDirection
            if (currentRate > lastRate) {
                rateChangeDirection = 1
            } else if (currentRate < lastRate) {
                rateChangeDirection = -1
            } else { 
                rateChangeDirection = 0
            }
            rateDirectionChanged = (lastRateChangeDirection !== rateChangeDirection)

			updateTrending(currentRate)

            updateInProgress = false
        });
    }

    // --------------------------------------------------------------------------------------------

}
