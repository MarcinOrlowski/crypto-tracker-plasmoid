/**
 * Crypto Tracker widget for KDE
 *
 * @author    Marcin Orlowski <mail (#) marcinOrlowski (.) com>
 * @copyright 2021 Marcin Orlowski
 * @license   http://www.opensource.org/licenses/mit-license.php MIT
 * @link      https://github.com/MarcinOrlowski/crypto-tracker-plasmoid
 */

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import "../js/crypto.js" as Crypto

Item {
    id: tickerRoot

    implicitWidth: contentLayout.implicitWidth
    implicitHeight: contentLayout.implicitHeight

    property var json: undefined

    property string exchange: ''
    property string crypto: ''
    property bool hideCryptoLogo: false
    property string pair: ''
    property bool useCustomLocale: false
    property string customLocaleName: ''
    property int refreshRate: 5
    property bool hidePriceDecimals: false

    property bool showPriceChangeMarker: true
    property bool showTrendingMarker: true
    property int trendingTimeSpan: 60          // minutes

    property bool flashOnPriceRaise: true
    property string flashOnPriceRaiseColor: '#78c625'
    property bool flashOnPriceDrop: true
    property string flashOnPriceDropColor: '#ff006e'

    property string markerColorPriceRaise: '#78c625'
    property string markerColorPriceDrop: '#ff006e'

    // --------------------------------------------------------------------------------------------

    Component.onCompleted: {
        if (json !== undefined) {
            exchange = json.exchange
            crypto = json.crypto
            hideCryptoLogo = json.hideCryptoLogo
            pair = json.pair
            refreshRate = json.refreshRate
            hidePriceDecimals = json.hidePriceDecimals
            useCustomLocale = json.useCustomLocale
            customLocaleName = json.customLocaleName

            showPriceChangeMarker = json.showPriceChangeMarker
            showTrendingMarker = json.showTrendingMarker
            trendingTimeSpan = json.trendingTimeSpan

            flashOnPriceRaise = json.flashOnPriceRaise
            flashOnPriceRaiseColor = json.flashOnPriceRaiseColor
            flashOnPriceDrop = json.flashOnPriceDrop
            flashOnPriceDropColor = json.flashOnPriceDropColor
            markerColorPriceRaise = json.markerColorPriceRaise
            markerColorPriceDrop = json.markerColorPriceDrop
        }
    }

    // --------------------------------------------------------------------------------------------

    onExchangeChanged: {
        invalidateExchangeData();
        fetchRate(exchange, crypto, pair)
    }
    onCryptoChanged: {
        invalidateExchangeData();
        fetchRate(exchange, crypto, pair)
    }
    onPairChanged: {
        invalidateExchangeData();
        fetchRate(exchange, crypto, pair)
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
        lastTrendingRate = 0
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
            rateText += '<span style="color: ' + color + ';">'
            if (trendingDirection == +1) rateText += '↑'
            // ↓ Downwards Arrow U+2193
            if (trendingDirection == -1) rateText += '↓'
            rateText += '</span> '
        }

        return rateText
    }

    // --------------------------------------------------------------------------------------------

    function getRateChangeMarkerText() {
        // echange rate change direction
        // • Bullet black small circle U+2022
        var color = getDirectionColor(rateChangeDirection, markerColorPriceRaise, markerColorPriceDrop)
        var rateText = ''
        if (rateChangeDirection !== 0) {
            // ▲ Black Up-Pointing Triangle U+25B2
            rateText += ' <span style="color: ' + color + ';">'
            if (rateChangeDirection == +1) rateText += '▲'
            // ▼ Black Down-Pointing Triangle U+25BC
            if (rateChangeDirection == -1) rateText += '▼'
            rateText += '</span>'
        }

        return rateText
    }

    function getCurrentRateText() {
        if (!currentRateValid) return '---'

        var color = '#0000ff'

        var rate = currentRate
        if(hidePriceDecimals) rate = Math.round(rate)

        var rateText = ''
        var localeName = useCustomLocale ? customLocaleName : ''
        var tmp = Number(rate).toLocaleCurrencyString(Qt.locale(localeName), Crypto.getCurrencySymbol(pair))
        if(hidePriceDecimals) tmp = tmp.replace(Qt.locale(localeName).decimalPoint + '00', '')
        rateText += '<span>' + tmp + '</span>'

        return rateText
    }

    // --------------------------------------------------------------------------------------------

    // Background for flash effect - must be behind content
    Rectangle {
        id: bgWall
        anchors.fill: parent
        opacity: 0
        z: -1
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

    // MouseArea for click handling
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        z: 1
        onClicked: {
            if (!dataDownloadInProgress) {
                tickerRoot.opacity = 0.5
                fetchRate(exchange, crypto, pair)
            }
        }
    }

    // --------------------------------------------------------------------------------------------

    RowLayout {
        id: contentLayout
        anchors.centerIn: parent

        Image {
            id: cryptoIcon
            visible: !hideCryptoLogo

            Layout.preferredWidth: 20
            Layout.preferredHeight: 20
            Layout.minimumWidth: 20
            Layout.minimumHeight: 20
            Layout.maximumWidth: 20
            Layout.maximumHeight: 20
            source: crypto ? Qt.resolvedUrl('../images/' + Crypto.getCryptoIcon(crypto)) : ''
        }

        PlasmaComponents.Label {
            visible: showTrendingMarker
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            Layout.alignment: Qt.AlignHCenter
            height: 20
            textFormat: Text.RichText
            fontSizeMode: Text.Fit
            minimumPixelSize: 8
            text: getTrendingMarkerText()
        }

        PlasmaComponents.Label {
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            Layout.alignment: Qt.AlignHCenter
            height: 20

            textFormat: Text.RichText
            fontSizeMode: Text.Fit
            minimumPixelSize: 8
            text: getCurrentRateText()
        }

        PlasmaComponents.Label {
            visible: showPriceChangeMarker

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            Layout.alignment: Qt.AlignHCenter
            height: 16

            textFormat: Text.RichText
            fontSizeMode: Text.Fit
            minimumPixelSize: 8
            text: getRateChangeMarkerText()
        }
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
        interval: refreshRate * 60 * 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: fetchRate(exchange, crypto, pair)
    }

    // --------------------------------------------------------------------------------------------

    property bool dataDownloadInProgress: false
    function fetchRate(exchange, crypto, pair) {
        if (dataDownloadInProgress) return

        if (!Crypto.exchangeExists(exchange)) {
            if (exchange !== '') console.debug("fetchRate(): unknown exchange: '" + exchange + "'")
            return
        }
        if (!Crypto.isCryptoSupported(exchange, crypto)) {
            if (crypto !== '') console.debug("fetchRate(): unsupported crypto: '" + crypto + "' on exchange: '" + exchange + "'")
            return
        }
        if (!Crypto.isPairSupported(exchange, crypto, pair)) {
            if (pair !== '')
            console.debug("fetchRate(): unsupported pair: '" + pair + "' for crypto: '" + crypto + "' on exchange: '" + exchange + "'")
            return
        }
        dataDownloadInProgress = true;

        // console.debug(`fetchRate(): ex: ${exchange}, crypto: ${crypto}, pair: ${pair}`)

        downloadExchangeRate(exchange, crypto, pair, function(rate) {
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

    function downloadExchangeRate(exchangeId, crypto, pair, callback) {
        var exchange = Crypto.exchanges[exchangeId]
        // var url = exchange.api_url.replace('{crypto}', crypto).replace('{pair}', pair)
        var url = exchange.getUrl(crypto, pair)

        // console.debug(`Download url: '${url}'`)

        request(url, function(data) {
            if(data.length !== 0) {
                try {
                    var json = JSON.parse(data)
                    callback(exchange.getRateFromExchangeData(json, crypto, pair))
                } catch (error) {
                    console.error("downloadExchangeRate(): Response parsing failed for '" + url + "'")
                    console.error("downloadExchangeRate(): error: '" + error + "'")
                    console.error("downloadExchangeRate(): data: '" + data + "'")
                }
            }
            tickerRoot.opacity = 1
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
