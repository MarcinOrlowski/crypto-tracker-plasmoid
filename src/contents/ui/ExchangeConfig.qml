/**
 * Crypto Tracker widget for KDE
 *
 * @author    Marcin Orlowski <mail (#) marcinOrlowski (.) com>
 * @copyright 2021 Marcin Orlowski
 * @license   http://www.opensource.org/licenses/mit-license.php MIT
 * @link      https://github.com/MarcinOrlowski/crypto-tracker-plasmoid
 */

import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.1
import org.kde.kirigami 2.5 as Kirigami
import org.kde.kquickcontrols 2.0 as KQControls
import org.kde.plasma.components 3.0 as PlasmaComponents
import "../js/crypto.js" as Crypto

ColumnLayout {
    Layout.fillWidth: true

    property string exchange: undefined
    property string crypto: undefined
    property bool hideCryptoLogo: false
    property string fiat: undefined
    property int refreshRate: 5                 // minutes
    property bool hidePriceDecimals: false

    property bool useCustomLocale: false
    property string customLocaleName: ''

    property bool showPriceChangeMarker: true

    property bool showTrendingMarker: true
    property int trendingTimeSpan: 60          // minutes

    property bool flashOnPriceRaise: true
    property string flashOnPriceRaiseColor: '#00ff00'
    property bool flashOnPriceDrop: true
    property string flashOnPriceDropColor: '#ff0000'

    property string markerColorPriceRaise: '#00ff00'
    property string markerColorPriceDrop: '#ff0000'

    // ------------------------------------------------------------------------------------------------------------------------

    function fromJson(json) {
		exchange = json.exchange
		crypto = json.crypto
		hideCryptoLogo = json.hideCryptoLogo
		fiat = json.fiat
		refreshRate = json.refreshRate
		hidePriceDecimals = json.hidePriceDecimals
		useCustomLocale = json.useCustomLocale
		customLocaleName = json.customLocaleName

		showPriceChangeMarker = json.showPriceChangeMarker
		showTrendingMarker = json.showTrendingMarker
		trendingTimeSpan = json.trendingTimeSpan

		flashOnPriceRaise = json.flashOnPriceRaise
		flashOnPriceDrop = json.flashOnPriceDrop
		flashOnPriceDropColor = json.flashOnPriceDropColor
		flashOnPriceRaiseColor = json.flashOnPriceRaiseColor
		markerColorPriceRaise = json.markerColorPriceRaise
		markerColorPriceDrop = json.markerColorPriceDrop
    }

    function toJson() {
        return {
            exchange: exchange,
            crypto: crypto,
            hideCryptoLogo: hideCryptoLogo,
            fiat: fiat,
            refreshRate: refreshRate,
            hidePriceDecimals: hidePriceDecimals,
            useCustomLocale: useCustomLocale,
            customLocaleName: customLocaleName,

            showPriceChangeMarker: showPriceChangeMarker,
            showTrendingMarker: showTrendingMarker,
            trendingTimeSpan: trendingTimeSpan,

            flashOnPriceRaise: flashOnPriceRaise,
            flashOnPriceDrop: flashOnPriceDrop,
            flashOnPriceDropColor: flashOnPriceDropColor,
            flashOnPriceRaiseColor: flashOnPriceRaiseColor,
            markerColorPriceRaise: markerColorPriceRaise,
            markerColorPriceDrop: markerColorPriceDrop,
        }
    }

    // ------------------------------------------------------------------------------------------------------------------------

    onExchangeChanged: updateModels()
    onCryptoChanged: updateModels()
    onFiatChanged: updateModels()

    function updateModels() {
        if (typeof exchange === 'undefined' || exchange === '') {
            return
        }
        if (typeof crypto === 'undefined' || crypto === '' || !Crypto.isCryptoSupported(exchange, crypto)) {
            var cryptos = Crypto.getAllExchangeCryptos(exchange);
            crypto = cryptos[0].value
        }
        if (typeof fiat === 'undefined' || fiat === '' || !Crypto.isFiatSupported(exchange, crypto, fiat)) {
            var fiats = Crypto.getFiatsForCrypto(exchange, crypto)
            fiat = fiats[0].value
        }

        exchangeComboBox.updateModel(exchange)
        cryptoComboBox.updateModel(exchange, crypto)
        fiatComboBox.updateModel(exchange, crypto, fiat)

    // ------------------------------------------------------------------------------------------------------------------------

    Kirigami.FormLayout {
        Layout.fillWidth: true

        PlasmaComponents.ComboBox {
            id: exchangeComboBox
            Kirigami.FormData.label: i18n('Exchange')
            textRole: "text"
            // Component.onCompleted: populateExchageModel()
            onCurrentIndexChanged: exchange = model[currentIndex]['value']

            function updateModel(exchange) {
                var tmp = []
                var idx = 0
                var currentIdx = 0
                for(const key in Crypto.exchanges) {
                    tmp.push({'value': key, 'text': Crypto.getExchangeName(key)})
                    if (key === exchange) currentIdx = idx
                    idx++
                }
                model = tmp
                currentIndex = currentIdx
            }

            Component.onCompleted: updateModel(exchange)
        }

        ClickableLabel { 
            text: '<u>' + Crypto.getExchangeUrl(exchange) + '</u>'
            url: Crypto.getExchangeUrl(exchange)
        }

        PlasmaComponents.SpinBox {
            editable: true
            from: 1
            to: 600
            stepSize: 15
            Kirigami.FormData.label: i18n("Update interval (minutes)")
            value: refreshRate
            onValueChanged: refreshRate = value
        }

        // ------------------------------------------------------------------------------------------------------------------------

        RowLayout {
            Kirigami.FormData.label: i18n('Crypto')

            PlasmaComponents.ComboBox {
                id: cryptoComboBox
                textRole: "text"
                onCurrentIndexChanged: crypto = model[currentIndex]['value']

                function updateModel(exchange, crypto) {
                    var tmp = []
                    var currentIdx = 0
                    if (exchange in Crypto.exchanges) {
                        var tmp = Crypto.getAllExchangeCryptos(exchange);
                        for (var i=0; i<tmp.length; i++) {
                            if (tmp[i].value == crypto) currentIdx = i
                        }
                    }
                    model = tmp
                    currentIndex = currentIdx

                    // as the model is swapped, different crypto can be at already set index
                    // so we need to ensure we do not use old value any more.
                    crypto = model[currentIndex]['value']
                }
            }

            CheckBox {
                text: i18n("Hide icon")
                checked: hideCryptoLogo
                onCheckedChanged: hideCryptoLogo = checked
            }
        }

        // ------------------------------------------------------------------------------------------------------------------------

        RowLayout {
            Kirigami.FormData.label: i18n('Fiat')

            PlasmaComponents.ComboBox {
                id: fiatComboBox
                textRole: "text"
                onCurrentIndexChanged: fiat = model[currentIndex]['value']

                function updateModel(exchange, crypto, fiat) {
                    var tmp = []
                    var currentIdx = 0
                    if ((exchange in Crypto.exchanges) && (crypto in Crypto.exchanges[exchange]['pairs'])) {
                        tmp = Crypto.getFiatsForCrypto(exchange, crypto)
                        for (var i=0; i<tmp.length; i++) {
                            if (tmp[i].value === fiat) currentIdx = i
                        }
                    }
                    model = tmp
                    currentIndex = currentIdx

                    // as the model is swapped, different fiat can be at already set index
                    // so we need to ensure we do not use old value any more.
                    fiat = model[currentIndex]['value']
                }
            }

            // FIXME should be per Pair as we may have i.e. LTCBTC pair soon
            // and this would make no sense then.
            PlasmaComponents.CheckBox {
                text: i18n("Hide decimals")
                checked: hidePriceDecimals
                onCheckedChanged: hidePriceDecimals = checked
            }
        }

        CheckBox {
            text: i18n("Show price change markers")
            checked: showPriceChangeMarker
            onCheckedChanged: showPriceChangeMarker = checked
        }

        CheckBox {
            text: i18n("Show trending markers")
            checked: showTrendingMarker
            onCheckedChanged: showTrendingMarker = checked
        }

        PlasmaComponents.SpinBox {
            enabled: showTrendingMarker
            editable: true
            from: 1
            to: 600
            stepSize: 15
            Kirigami.FormData.label: i18n("Trending span (minutes)")
            value: trendingTimeSpan
            onValueChanged: trendingTimeSpan = value
        }

        KQControls.ColorButton {
            enabled: showPriceChangeMarker | showTrendingMarker
            Kirigami.FormData.label: i18n('Price raise markers')
            dialogTitle: i18n('Price raise marker color')
            color: markerColorPriceRaise
            onColorChanged: markerColorPriceRaise = color.toString()
        }

        KQControls.ColorButton {
            enabled: showPriceChangeMarker | showTrendingMarker
            Kirigami.FormData.label: i18n('Price drop markers')
            dialogTitle: i18n('Price drop marker color')
            color: markerColorPriceDrop
            onColorChanged: markerColorPriceDrop = color.toString()
        }

        // ------------------------------------------------------------------------------------------------------------------------

        RowLayout {
            Kirigami.FormData.label: i18n('Use custom locale')
            CheckBox {
                checked: useCustomLocale
                onCheckedChanged: useCustomLocale = checked
            }

            TextField {
                enabled: useCustomLocale
                placeholderText: "en_US"
                text: customLocaleName
                onTextChanged: customLocaleName = text
            }
        }

        // ------------------------------------------------------------------------------------------------------------------------

        RowLayout {
            Kirigami.FormData.label: i18n("Flash on price raise")
            CheckBox {
                checked: flashOnPriceRaise
                onCheckedChanged: flashOnPriceRaise = checked
            }
            KQControls.ColorButton {
                enabled: flashOnPriceRaise
                dialogTitle: i18n('Price raise flash background color')
                color: flashOnPriceRaiseColor
                onColorChanged: flashOnPriceRaiseColor = color.toString()
            }
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Flash on price drop")

            CheckBox {
                checked: flashOnPriceDrop
                onCheckedChanged: flashOnPriceDrop = checked
            }
            KQControls.ColorButton {
                enabled: flashOnPriceDrop
                dialogTitle: i18n('Price raise flash background color')
                color: flashOnPriceDropColor
                onColorChanged: flashOnPriceDropColor = color.toString()
            }

        }

        // ------------------------------------------------------------------------------------------------------------------------

    } // Kirigami.FormLayout

}
