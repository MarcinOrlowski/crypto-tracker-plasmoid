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

GridLayout {
    id: tickerRoot

    columns: 4
    rows: 1

    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
    Layout.fillWidth: true

    property bool running: false
    property string exchange: ''
    property string crypto: ''
    property bool hideCryptoLogo: false
    property string fiat: ''
    property string localeToUse: ''     // plasmoid.configuration.useCustomLocale ? plasmoid.configuration.localeName : ''
    property int refreshRate: 5
    property bool noDecimals: false

    property bool showPriceChangeMarker: true
    property bool showTrendingMarker: true
    property int trendingTimeSpan: 60          // minutes

    property bool flashOnPriceRaise: true
    property string flashOnPriceRaiseColor: '#00ff00'
    property bool flashOnPriceDrop: true
    property string flashOnPriceDropColor: '#ff0000'

    property string markerColorPriceRaise: '#00ff00'
    property string markerColorPriceDrop: '#ff0000'

    // --------------------------------------------------------------------------------------------

    onExchangeChanged: {
        invalidateExchangeData();
        fetchRate(exchange, crypto, fiat)
    }
    onCryptoChanged: {
        invalidateExchangeData();
        fetchRate(exchange, crypto, fiat)
    }
    onFiatChanged: {
        invalidateExchangeData();
        fetchRate(exchange, crypto, fiat)
    }

    // --------------------------------------------------------------------------------------------

    function getDirectionColor(direction, colorUp, colorDown) {
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

	property var lastTrendingUpdateStamp: 0
	property var lastTrendingRate: 0
	property int trendingDirection: 0		// -1, 0, 1
    property bool trendingCalculated: false

    function invalidateExchangeData() {
        lastTrendingUpdateStamp = 0
        lastTrendingRate: 0
        trendingDirection = 0
        trendingCalculated = false

        currentRate = 0
        currentRateValid = false
        lastRate = 0
        lastRateValid = false

        rateChangeDirection = 0
        rateChangeDirectionCalculated = false
    }

	function updateTrending(rate) {
		var now = new Date()
		var updateTrending = false
		if (lastTrendingUpdateStamp != 0) {
			if ((now.getTime() - lastTrendingUpdateStamp) >= (trendingTimeSpan * 60 * 1000)) {
				if (rate > lastTrendingRate) {
					trendingDirection = 1
				} else if (currentRate < lastTrendingRate) {
					trendingDirection = -1
				} else {
					trendingDirection = 0
				}
				updateTrending = true
                trendingCalculated = true
			}
		}

		if (lastTrendingUpdateStamp == 0 || updateTrending) {
			lastTrendingUpdateStamp = now.getTime()
			lastTrendingRate = rate
		}
	}

    function getTrendingMarkerText() {
        // https://unicode-table.com/en/sets/arrow-symbols/
        var color = getDirectionColor(trendingDirection, markerColorPriceRaise, markerColorPriceDrop)
        var rateText = ''
        if (trendingCalculated && (trendingDirection !== 0)) {
            // ↑ Upwards Arrow U+2191
            rateText += `<span style="color: ${color};">`
            if (trendingDirection == +1) rateText += '↑'
            // ↓ Downwards Arrow U+2193
            if (trendingDirection == -1) rateText += '↓'
            rateText += '</span> '
        }

        return rateText
    }

    // --------------------------------------------------------------------------------------------

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: fetchRate(exchange, crypto, fiat)
    }

    // --------------------------------------------------------------------------------------------

    function getRateChangeMarkerText() {
        // echange rate change direction
        // • Bullet black small circle U+2022
        var color = getDirectionColor(rateChangeDirection, markerColorPriceRaise, markerColorPriceDrop)
        var rateText = ''
        if (rateChangeDirection !== 0) {
            // ▲ Black Up-Pointing Triangle U+25B2
            rateText += ` <span style="color: ${color};">`
            if (rateChangeDirection == +1) rateText += '▲'
            // ▼ Black Down-Pointing Triangle U+25BC
            if (rateChangeDirection == -1) rateText += '▼'
            rateText += '</span>'
        }

        return rateText
    }

    function getCurrentRateText() {
        if (!currentRateValid) return '---'

        var localeToUse = tickerRoot.localeToUse
        var noDecimals = tickerRoot.noDecimals

        var color = '#0000ff'

        var rate = currentRate
        if(noDecimals) rate = Math.round(rate)

        var rateText = ''

        var tmp = Number(rate).toLocaleCurrencyString(Qt.locale(localeToUse), Crypto.getCurrencySymbol(fiat))
        if(noDecimals) tmp = tmp.replace(Qt.locale(localeToUse).decimalPoint + '00', '')
        rateText += `<span>${tmp}</span>`

        return rateText
    }

    // --------------------------------------------------------------------------------------------

    // must be first item in the layout hierarchy to stay behind all other elements
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

    Image {
        id: cryptoIcon
        visible: !hideCryptoLogo

        width: 20
        height: 20
        Layout.minimumWidth: 20
        Layout.minimumHeight: 20
        Layout.maximumWidth: 20
        Layout.maximumHeight: 20
        // Layout.alignment: Qt.AlignHCenter
        // fillMode: Image.PreserveAspectFit
        source: plasmoid.file('', 'images/' + Crypto.getCryptoIcon(crypto))
    }

    PlasmaComponents.Label {
        visible: showTrendingMarker
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        Layout.alignment: Qt.AlignHCenter
        // Layout.fillWidth: true
        height: 20
        textFormat: Text.RichText
        fontSizeMode: Text.Fit
        // minimumPixelSize: bitcoinIcon.width * 0.7
        minimumPixelSize: 8
        // font.pixelSize: 12			
        text: getTrendingMarkerText()
    }

    PlasmaComponents.Label {
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        Layout.alignment: Qt.AlignHCenter
        // Layout.fillWidth: true
        height: 20

        textFormat: Text.RichText
        fontSizeMode: Text.Fit
        // minimumPixelSize: bitcoinIcon.width * 0.7
        minimumPixelSize: 8
        // font.pixelSize: 12			
        text: getCurrentRateText()
    }

    PlasmaComponents.Label {
        visible: showPriceChangeMarker

        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        Layout.alignment: Qt.AlignHCenter
        // Layout.fillWidth: true
        height: 16

        textFormat: Text.RichText
        fontSizeMode: Text.Fit
        // minimumPixelSize: bitcoinIcon.width * 0.7
        minimumPixelSize: 8
        // font.pixelSize: 12			
        text: getRateChangeMarkerText()
    }

    // --------------------------------------------------------------------------------------------

    property var lastUpdateMillis: 0
    property bool currentRateValid: false
    property var currentRate: 0
    property bool lastRateValid: false
    property var lastRate: 0
    property int rateChangeDirection: 0             // -1, 0, 1
    property bool rateChangeDirectionCalculated: false

    property bool rateDirectionChanged: false
    onRateDirectionChangedChanged: {
        // console.debug('changed: ' + rateChangeDirection)
        if (rateChangeDirectionCalculated && (rateChangeDirection !== 0)) {
            var flash = false

            if (rateChangeDirection === +1 && flashOnPriceRaise) flash = true
            if (rateChangeDirection === -1 && flashOnPriceDrop) flash = true

            if (flash) {
                bgWall.color = getDirectionColor(rateChangeDirection, flashOnPriceRaiseColor, flashOnPriceDropColor)
                bgWall.opacity = 1
                bgWallFadeTimer.running = true
                bgWallFadeTimer.start()
            }
        }
    }

	Timer {
		interval: tickerRoot.refreshRate * 60 * 1000
		running: parent.running
		repeat: true
		triggeredOnStart: true
		onTriggered: fetchRate(exchange, crypto, fiat)
	}

    // --------------------------------------------------------------------------------------------

    property bool dataDownloadInProgress: false
    function fetchRate(exchange, crypto, fiat) {
        if (dataDownloadInProgress) return
        dataDownloadInProgress = true;

        if (!Crypto.isExchangeValid(exchange)) {
            console.debug(`fetchRate(): unknown exchange: '${exchange}'`)
            return
        }
        if (!Crypto.isCryptoSupported(exchange, crypto)) {
            console.debug(`fetchRate(): unsupported crypto: '${crypto}' on exchange: '${exchange}'`)
            return
        }
        if (!Crypto.isFiatSupported(exchange, crypto, fiat)) {
            console.debug(`fetchRate(): unsupported fiat: '${fiat}' for crypto: '${crypto}' on exchange: '${exchange}'`)
            return
        }

        // console.debug(`fetchRate(): ex: ${exchange}, crypto: ${crypto}, fiat: ${fiat}`)

        downloadExchangeRate(exchange, crypto, fiat, function(rate) {
            var now = new Date()
            lastUpdateMillis = now.getTime()

            if (currentRateValid) {
                lastRate = currentRate
                lastRateValid = true
            }
            currentRate = rate
            currentRateValid = true

            if (lastRateValid) {
                var lastRateChangeDirection = rateChangeDirection
                if (currentRate > lastRate) {
                    rateChangeDirection = 1
                } else if (currentRate < lastRate) {
                    rateChangeDirection = -1
                } else { 
                    rateChangeDirection = 0
                }
                rateDirectionChanged = (lastRateChangeDirection !== rateChangeDirection)
                rateChangeDirectionCalculated = true
            }

            updateTrending(currentRate)
        });
    }

    // --------------------------------------------------------------------------------------------

    function downloadExchangeRate(exchangeId, crypto, fiat, callback) {
        var exchange = Crypto.exchanges[exchangeId]
        var url = exchange.getUrl(crypto, fiat)

        // console.debug(`Download url: '${url}'`)

        request(url, function(data) {
            if(data.length !== 0) {
                try {
                    var json = JSON.parse(data)
                    callback(exchange.getRateFromExchangeData(json))
                } catch (error) {
                    console.error(`downloadExchangeRate(): Response parsing failed for '${url}'`)
                    console.error(`downloadExchangeRate(): error: '${error}'`)
                    console.error(`downloadExchangeRate(): data: '${data}'`)
                }
            }
            dataDownloadInProgress = false
        })
        return true
    }

    function request(url, callback) {
        var xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function() {
            if(xhr.readyState === 4) {
                callback(xhr.responseText)
            }
        }
        xhr.open('GET', url, true)
        xhr.send('')
    }

    // --------------------------------------------------------------------------------------------

}
