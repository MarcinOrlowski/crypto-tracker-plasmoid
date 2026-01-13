/**
 * Crypto Tracker widget for KDE
 *
 * @author    Marcin Orlowski <mail (#) marcinOrlowski (.) com>
 * @copyright 2021 Marcin Orlowski
 * @license   http://www.opensource.org/licenses/mit-license.php MIT
 * @link      https://github.com/MarcinOrlowski/crypto-tracker-plasmoid
 */

import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import "../../js/crypto.js" as Crypto
import ".."

Item {
	id: configExchanges

	Layout.fillWidth: true

	property alias cfg_exchanges: serializedExchanges.text

	Text {
		id: serializedExchanges
		visible: false
		onTextChanged: {
			exchangesModel.clear()
			JSON.parse(serializedExchanges.text).forEach(
				ex => exchangesModel.append(ex)
			)
		}
	}

	ExchangeModel {
		id: exchangesModel
	}

	RowLayout {
		anchors.fill: parent

		Layout.alignment: Qt.AlignTop | Qt.AlignRight

		// ListView replacement for deprecated TableView
		Rectangle {
			Layout.fillWidth: true
			Layout.fillHeight: true
			color: Kirigami.Theme.backgroundColor
			border.color: Kirigami.Theme.disabledTextColor
			border.width: 1

			ColumnLayout {
				anchors.fill: parent
				anchors.margins: 1
				spacing: 0

				// Header row
				Rectangle {
					Layout.fillWidth: true
					height: 30
					color: Kirigami.Theme.alternateBackgroundColor

					RowLayout {
						anchors.fill: parent
						anchors.leftMargin: 10
						anchors.rightMargin: 10
						spacing: 10

						PlasmaComponents.Label {
							Layout.preferredWidth: parent.width * 0.4
							text: i18n("Exchange")
							font.bold: true
						}
						PlasmaComponents.Label {
							Layout.preferredWidth: parent.width * 0.3
							text: i18n("Crypto")
							font.bold: true
						}
						PlasmaComponents.Label {
							Layout.fillWidth: true
							text: i18n("Pair")
							font.bold: true
						}
					}
				}

				// List view
				ListView {
					id: exchangesList
					Layout.fillWidth: true
					Layout.fillHeight: true
					clip: true
					model: exchangesModel
					currentIndex: -1

					delegate: Rectangle {
						width: exchangesList.width
						height: 35
						color: ListView.isCurrentItem ? Kirigami.Theme.highlightColor : (index % 2 === 0 ? Kirigami.Theme.backgroundColor : Kirigami.Theme.alternateBackgroundColor)

						RowLayout {
							anchors.fill: parent
							anchors.leftMargin: 10
							anchors.rightMargin: 10
							spacing: 10

							PlasmaComponents.Label {
								Layout.preferredWidth: parent.width * 0.4
								text: {
									var res = model.enabled ? '' : '(L) '
									return res + Crypto.getExchangeName(model.exchange)
								}
								color: ListView.isCurrentItem ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
							}
							PlasmaComponents.Label {
								Layout.preferredWidth: parent.width * 0.3
								text: Crypto.getCryptoName(model.crypto)
								color: ListView.isCurrentItem ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
							}
							PlasmaComponents.Label {
								Layout.fillWidth: true
								text: Crypto.getCurrencyName(model.pair)
								color: ListView.isCurrentItem ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
							}
						}

						MouseArea {
							anchors.fill: parent
							onClicked: exchangesList.currentIndex = index
							onDoubleClicked: {
								exchangesList.currentIndex = index
								editExchange(index)
							}
						}
					}

					PlasmaComponents.ScrollBar.vertical: PlasmaComponents.ScrollBar { }
				}
			}
		}

		ColumnLayout {
			id: tableActionButtons
			Layout.alignment: Qt.AlignTop

			PlasmaComponents.Button {
				text: i18n("Add")
				icon.name: "list-add"
				onClicked: addExchange()
			}

			PlasmaComponents.Button {
				text: i18n("Edit")
				icon.name: "edit-entry"
				onClicked: editExchange(exchangesList.currentIndex)
				enabled: {
					var idx = exchangesList.currentIndex
					return (idx !== -1) && (idx < exchangesModel.count)
				}
			}

			PlasmaComponents.Button {
				text: i18n("Remove")
				icon.name: "list-remove"
				onClicked: removeExchange(exchangesList.currentIndex)
				enabled: {
					var idx = exchangesList.currentIndex
					return (idx !== -1) && (idx < exchangesModel.count)
				}
			}

			PlasmaComponents.Button {
				text: i18n("Move Up")
				icon.name: "arrow-up"
				onClicked: {
					var from = exchangesList.currentIndex
					var to = from - 1
					exchangesModel.move(from, to, 1)
					exchangesList.currentIndex = to
					saveExchanges()
				}
				enabled: {
					var idx = exchangesList.currentIndex
					return (idx > 0) && (idx < exchangesModel.count)
				}
			}

			PlasmaComponents.Button {
				text: i18n("Move Down")
				icon.name: "arrow-down"
				onClicked: {
					var from = exchangesList.currentIndex
					var to = from + 1
					exchangesModel.move(from, to, 1)
					exchangesList.currentIndex = to
					saveExchanges()
				}
				enabled: {
					var idx = exchangesList.currentIndex
					return (idx !== -1) && ((idx + 1) < exchangesModel.count)
				}
			}


		} // ColumnLayout
	} // RowLayout

	// ------------------------------------------------------------------------------------------------------------------------

	property int selectedRow: -1

	function saveExchanges() {
		var exchanges = []
		for(var i=0; i<exchangesModel.count; i++) {
			exchanges.push(exchangesModel.get(i))
		}
		serializedExchanges.text = JSON.stringify(exchanges)
	}

	function addExchange() {
		exchange.init()
		selectedRow = -1
		exchangeEditDialog.visible = true
	}

	function editExchange(idx) {
		if (idx === -1) return

		if ((idx+1) > exchangesModel.count) return

		exchange.fromJson(exchangesModel.get(idx))

		selectedRow = idx
		exchangeEditDialog.visible = true
	}

	function removeExchange(idx) {
		if (idx === -1) return

		if ((idx+1) > exchangesModel.count) return

		exchangesModel.remove(idx)
		saveExchanges()
	}

	// ------------------------------------------------------------------------------------------------------------------------

	Dialog {
		id: exchangeEditDialog
		visible: false
		title: i18n("Exchange")
		standardButtons: Dialog.Save | Dialog.Cancel

		onAccepted: {
			var ex = exchange.toJson()
			if (selectedRow === -1) {
				exchangesModel.append(ex)
			} else {
				exchangesModel.set(selectedRow, ex)
			}
			saveExchanges();
		}

		ExchangeConfig {
			id: exchange
		}
	}

} // Item
