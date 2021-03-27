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
import "../../js/crypto.js" as Crypto
import ".."

ColumnLayout {
    Layout.fillWidth: true

    property string exchange: undefined
    property string crypto: undefined
    property string fiat: undefined

    // ------------------------------------------------------------------------------------------------------------------------

    function fromJson(json) {
        exchangeEnabled.checked = json.enabled

		exchange = json.exchange
		crypto = json.crypto
		hideCryptoLogo.checked = json.hideCryptoLogo
		fiat = json.fiat
		refreshRate.value = json.refreshRate
		hidePriceDecimals.checked = json.hidePriceDecimals
		useCustomLocale.checked = json.useCustomLocale
		customLocaleName.text = json.customLocaleName

		showPriceChangeMarker.checked = json.showPriceChangeMarker
		showTrendingMarker.checked = json.showTrendingMarker
		trendingTimeSpan.value = json.trendingTimeSpan

		flashOnPriceRaise.checked = json.flashOnPriceRaise
		flashOnPriceRaiseColor.color = json.flashOnPriceRaiseColor
		flashOnPriceDrop.checked = json.flashOnPriceDrop
		flashOnPriceDropColor.color = json.flashOnPriceDropColor
		markerColorPriceRaise.color = json.markerColorPriceRaise
		markerColorPriceDrop.color = json.markerColorPriceDrop
    }

    function toJson() {
        return {
            'enabled': exchangeEnabled.checked,

            'exchange': exchange,
            'crypto': crypto,
            'hideCryptoLogo': hideCryptoLogo.checked,
            'fiat': fiat,
            'refreshRate': refreshRate.value,
            'hidePriceDecimals': hidePriceDecimals.checked,
            'useCustomLocale': useCustomLocale.checked,
            'customLocaleName': customLocaleName.text,

            'showPriceChangeMarker': showPriceChangeMarker.checked,
            'showTrendingMarker': showTrendingMarker.checked,
            'trendingTimeSpan': trendingTimeSpan.value,

            'flashOnPriceRaise': flashOnPriceRaise.checked,
            'flashOnPriceRaiseColor': flashOnPriceRaiseColor.color.toString(),
            'flashOnPriceDrop': flashOnPriceDrop.checked,
            'flashOnPriceDropColor': flashOnPriceDropColor.color.toString(),
            'markerColorPriceRaise': markerColorPriceRaise.color.toString(),
            'markerColorPriceDrop': markerColorPriceDrop.color.toString(),
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
    }

    // ------------------------------------------------------------------------------------------------------------------------

    Kirigami.FormLayout {
        Layout.fillWidth: true
        CheckBox {
            id: exchangeEnabled
            Kirigami.FormData.label: i18n('Enabled')
            checked: true
        }

        PlasmaComponents.ComboBox {
            id: exchangeComboBox

            enabled: exchangeEnabled.checked
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
            id: refreshRate
            enabled: exchangeEnabled.checked
            editable: true
            from: 1
            to: 600
            stepSize: 15
            Kirigami.FormData.label: i18n("Update interval (minutes)")
        }

        // ------------------------------------------------------------------------------------------------------------------------

        RowLayout {
            Kirigami.FormData.label: i18n('Crypto')
            enabled: exchangeEnabled.checked

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
                id: hideCryptoLogo
                text: i18n("Hide currency icon")
            }
        }

        // ------------------------------------------------------------------------------------------------------------------------

        RowLayout {
            Kirigami.FormData.label: i18n('Fiat')
            enabled: exchangeEnabled.checked

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
                id: hidePriceDecimals
                text: i18n("Hide decimals")
            }
        }

        CheckBox {
            id: showPriceChangeMarker
            text: i18n("Show price change markers")
            enabled: exchangeEnabled.checked
        }

        CheckBox {
            id: showTrendingMarker
            text: i18n("Show trending markers")
            enabled: exchangeEnabled.checked
        }

        PlasmaComponents.SpinBox {
            id: trendingTimeSpan
            enabled: showTrendingMarker.checked && exchangeEnabled.checked
            editable: true
            from: 1
            to: 600
            stepSize: 15
            Kirigami.FormData.label: i18n("Trending span (minutes)")
        }

        KQControls.ColorButton {
            id: markerColorPriceRaise
            enabled: (showPriceChangeMarker.checked | showTrendingMarker.checked) && exchangeEnabled.checked
            Kirigami.FormData.label: i18n('Price raise markers')
            dialogTitle: i18n('Price raise marker color')
        }

        KQControls.ColorButton {
            id: markerColorPriceDrop
            enabled: (showPriceChangeMarker.checked | showTrendingMarker.checked) && exchangeEnabled.checked
            Kirigami.FormData.label: i18n('Price drop markers')
            dialogTitle: i18n('Price drop marker color')
        }

        // ------------------------------------------------------------------------------------------------------------------------

        RowLayout {
            enabled: exchangeEnabled.checked
            Kirigami.FormData.label: i18n('Use custom locale')
            CheckBox {
                id: useCustomLocale
            }

            TextField {
                id: customLocaleName
                enabled: useCustomLocale.checked
                placeholderText: "en_US"
            }
        }

        // ------------------------------------------------------------------------------------------------------------------------

        RowLayout {
            enabled: exchangeEnabled.checked
            Kirigami.FormData.label: i18n("Flash on price raise")
            CheckBox {
                id: flashOnPriceRaise
            }
            KQControls.ColorButton {
                id: flashOnPriceRaiseColor
                enabled: flashOnPriceRaise.checked
                dialogTitle: i18n('Price raise flash background color')
            }
        }

        RowLayout {
            enabled: exchangeEnabled.checked
            Kirigami.FormData.label: i18n("Flash on price drop")

            CheckBox {
                id: flashOnPriceDrop
            }
            KQControls.ColorButton {
                id: flashOnPriceDropColor
                enabled: flashOnPriceDrop.checked
                dialogTitle: i18n('Price drop flash background color')
            }
        }

        // ------------------------------------------------------------------------------------------------------------------------

    } // Kirigami.FormLayout
} // ColumnLayout
