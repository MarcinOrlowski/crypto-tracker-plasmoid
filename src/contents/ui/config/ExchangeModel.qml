/**
 * Crypto Tracker widget for KDE
 *
 * @author    Marcin Orlowski <mail (#) marcinOrlowski (.) com>
 * @copyright 2021 Marcin Orlowski
 * @license   http://www.opensource.org/licenses/mit-license.php MIT
 * @link      https://github.com/MarcinOrlowski/crypto-tracker-plasmoid
 */

import Qt.labs.qmlmodels

TableModel {
    id: exchangeModel
    TableModelColumn { display: "exchange" }
    TableModelColumn { display: "crypto" }
    TableModelColumn { display: "pair" }
}