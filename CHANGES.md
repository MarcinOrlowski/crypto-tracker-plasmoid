* v3.0.0 (2026-01-14)
  * Added support for Plasma 6
  * Changed Binance API url to use `/v3/ticker/price` endpoint.
  * Bitstamp ticker queries now lowercase the pairs to make API happy.
  * Added 1INCH, BNT, BTT, EOS, GLM, SOL, THETA, WBTC, XTZ, ZRX.
  * Added new 29 pairs among supported exchanges.
  * Fixed setting not storing number of layout grid column.

* v2.1.0 (2021-05-29)
  * Added support for Binance.
  * Significantly increased number of supported pairs to 365 total.
  * Added ability to cross pair currencies with bigger flexibility.
  * Improved Kraken's API response handling.

* v2.0.0 (2021-05-10)
  * [IMPORTANT] Your current config will NOT be migrated and you will have to re-set
    all the exchanges you had before from scrach. Sorry for the inconvenience.
  * Reworked exchange management and added support for unlimited number of exchanges.
  * Exchanges can be now easily reordered.
  * Added support for Plasma 5.19+ widget background controls.
  * Added support for ETH Classic (patch by César Valadez).

* v1.2.0 (2021-03-24)
  * Internal widget layout grid is configurable now. Requested by @Foul [#11]
  * Widget background can now be set transparent.

* v1.1.2 (2021-03-23)
  * Removed use of backtick syntax due to problems on Debian 10 using old Plasma.

* v1.1.1 (2021-02-25)
  * Fixed exchange configuration not allowing to change fiats under some circumstances.

* v1.1.0 (2021-02-21)
  * Added more pairs for Kraken and Bitstamp.
  * Added support for coinmate.io and CZK fiat.
  * Widget now fades during data downloading for manually triggered refreshes.
  * Added clickable exchange URL to configuration panel.

* v1.0.0 (2021-02-13)
  * Initial public release.

