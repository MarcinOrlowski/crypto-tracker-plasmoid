/**
 * Crypto Tracker widget for KDE
 *
 * @author    Marcin Orlowski <mail (#) marcinOrlowski (.) com>
 * @copyright 2021 Marcin Orlowski
 * @license   http://www.opensource.org/licenses/mit-license.php MIT
 * @link      https://github.com/MarcinOrlowski/crypto-tracker-plasmoid
 */

import QtQuick 2.1
import QtQuick.Controls 1.4 as QtControls
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import org.kde.plasma.components 3.0 as PlasmaComponents
import "../js/crypto.js" as Crypto
import "../js/layouts.js" as Layouts

Item {
	id: configExchanges

	Layout.fillWidth: true

	property alias cfg_exchanges: serializedExchanges.text

	Text {
		id: serializedExchanges
		visible: false
		onTextChanged: {
			exchangesModel.clear()
			var ex = JSON.parse(serializedExchanges.text)
			for(var i=0; i<ex.length; i++) {
				exchangesModel.append(ex[i])
			}
		}
	}

	ExchangeModel {
		id: exchangesModel
	}

	RowLayout {
		anchors.fill: parent

		Layout.alignment: Qt.AlignTop | Qt.AlignRight

		QtControls.TableView {
			id: exchangesTable
			model: exchangesModel
			Layout.fillWidth: true

			anchors.top: parent.top
			anchors.right: tableActionButtons.left
			anchors.bottom: parent.bottom
			anchors.left: parent.left
			anchors.rightMargin: 10

			itemDelegate: Item {
				PlasmaComponents.Label {
					text: {
						switch (styleData.column) {
							case 0: return Crypto.getExchangeName(styleData.value)
							case 1: return Crypto.getCryptoName(styleData.value)
							case 2: return Crypto.getCurrencyName(styleData.value)
						}

						return '??? col: ' + column + ' val: ' + value
					}
				}
			}

			QtControls.TableViewColumn {
				role: "exchange"
				title: "Exchange"
			}
			QtControls.TableViewColumn {
				role: "crypto"
				title: "Crypto"
			}
			QtControls.TableViewColumn {
				role: "fiat"
				title: "Fiat"
			}

			onDoubleClicked: editExchange(exchangesTable.currentRow)
		} // TableView

		ColumnLayout {
			id: tableActionButtons
			anchors.top: parent.top

			PlasmaComponents.Button {
				text: i18n("Add")
				icon.name: "list-add"
				onClicked: addExchange()
			}

			PlasmaComponents.Button {
				text: i18n("Edit")
				icon.name: "edit-entry"
				onClicked: editExchange(exchangesTable.currentRow)
				enabled: {
					// TableView seem to have a bug that makes it think row 0 is selected
					// even if there's no data in model and table view is empty. So we need
					// to check for that case here.
					var idx = exchangesTable.currentRow
					return (idx !== -1) && ((idx+1) <= exchangesModel.count)
				}
			}
			PlasmaComponents.Button {
				text: i18n("Remove")
				icon.name: "list-remove"
				onClicked: removeExchange(exchangesTable.currentRow)
				enabled: {
					// TableView seem to have a bug that makes it think row 0 is selected
					// even if there's no data in model and table view is empty. So we need
					// to check for that case here.
					var idx = exchangesTable.currentRow
					return (idx !== -1) && ((idx+1) <= exchangesModel.count)
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

		console.debug('SAVE: ' + serializedExchanges.text)
	}

	function addExchange() {
		selectedRow = -1
		exchangeEditDialog.visible = true
	}

	function editExchange(idx) {
		if (idx === -1) return

		// TableView seem to have a bug that makes it think row 0 is selected
		// even if there's no data in model and table view is empty. So we need
		// to check for that case here.
		if ((idx+1) > exchangesModel.count) return

		exchange.fromJson(exchangesModel.get(idx))

		selectedRow = idx
		exchangeEditDialog.visible = true
	}

	function removeExchange(idx) {
		if (idx === -1) return

		// TableView seem to have a bug that makes it think row 0 is selected
		// even if there's no data in model and table view is empty. So we need
		// to check for that case here.
		if ((idx+1) > exchangesModel.count) return

		exchangesTable.model.remove(idx)
		saveExchanges()
	}

	// ------------------------------------------------------------------------------------------------------------------------

	Dialog {
		id: exchangeEditDialog
		visible: false
		title: i18n("Exchange")
		standardButtons: StandardButton.Save | StandardButton.Cancel

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
