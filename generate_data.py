#!/usr/bin/env python3

######################################################################
#
# Crypto Tracker widget for KDE
#
# @author    Marcin Orlowski <mail (#) marcinOrlowski (.) com>
# @copyright 2021 Marcin Orlowski
# @license   http://www.opensource.org/licenses/mit-license.php MIT
# @link      https://github.com/MarcinOrlowski/crypto-tracker-plasmoid
#
######################################################################
#
# Purpose of this script:
# - Validates data integrity and completenes
# - Generates exchange data matrix for the widget
#
# Usage (use -h or --help for more info):
#   generate_data.py -o src/contents/js/crypto_data.js
#
######################################################################

import argparse
import collections
import json
import math
import multiprocessing as mp
import os
import requests as req
import sys
import time

######################################################################

def default_ticker_validator(response, crypto, pair):
    return response.status_code == req.codes.ok

# validates if provided HTTP response contains valid ticker
def bitbay_ticker_validator(response, crypto, pair):
    if response.status_code != req.codes.ok:
        return False

    resp = json.loads(response.text)
    for field in ['min','max','last','bid','ask',]:
        if field not in resp:
            return False
    return True

def kraken_ticker_validator(response, crypto, pair):
    if response.status_code != req.codes.ok:
        return False

    resp = json.loads(response.text)
    if len(resp.get('error', [])) > 0:
        return False
    if 'result' not in resp:
        return False

    key = list(resp['result'].keys())[0]
    if key not in resp['result']:
        return False
    for field in ['a','b','c','l',]:
        if field not in resp['result'][key]:
            return False
    return True

def coinmate_ticker_validator(response, crypto, pair):
    if response.status_code != req.codes.ok:
        return False

    resp = json.loads(response.text)
    if resp.get('error', False):
        return False
    if 'data' not in resp:
        return False
    for field in ['ask','bid','change','last',]:
        if field not in resp['data']:
            return False

    return True
 


######################################################################

ada = 'ADA'
bch = 'BCH'
bsv = 'BSV'
btc = 'BTC'
btg = 'BTG'
comp = 'COMP'
dash = 'DASH'
dot = 'DOT'
etc = 'ETC'
eth = 'ETH'
eur = 'EUR'
game = 'GAME'
gbp = 'GBP'
link = 'LINK'
lsk = 'LSK'
ltc = 'LTC'
luna = 'LUNA'
mkr = 'MKR'
pln = 'PLN'
usd = 'USD'
usdt = 'USDT'
xrp = 'XRP'
zec = 'ZEC'
doge = 'DOGE'
bnb = 'BNB'
fil = 'FIL'
czk = 'CZK'
jpy = 'JPY'
busd = 'BUSD'
usdc = 'USDC'
uni = 'UNI'


######################################################################

currencies = {
    bch:    {'name': 'Bitcoin Cash', 'symbol': '฿', },
    bsv:    {'name': 'BSV', },
    btc:    {'name': 'Bitcoin', 'symbol': '₿', },
    btg:    {'name': 'Bitcoin Gold', },
    comp:   {'name': 'COMP', },
    dash:   {'name': 'DASH', },
    dot:    {'name': 'PolkaDot', },
    etc:    {'name': 'Ethereum Classic', },
    eth:    {'name': 'Ethereum', 'symbol': 'Ξ', },
    eur:    {'name': 'Euro', 'symbol': '€', },
    game:   {'name': 'GAME', },
    gbp:    {'name': 'British Pound', 'symbol': '£', },
    link:   {'name': 'Chainlink', },
    lsk:    {'name': 'Lisk', },
    ltc:    {'name': 'Litecoin', 'symbol': 'Ł', },
    luna:   {'name': 'LUNA', },
    mkr:    {'name': 'MKR', },
    pln:    {'name': 'Polish Zloty', 'symbol': 'zł', },
    usd:    {'name': 'US Dollar', 'symbol': '$', },
    usdt:   {'name': 'USD Tether', },
    xrp:    {'name': 'Ripple', 'symbol': 'Ʀ', },
    zec:    {'name': 'ZCash', },
    ada:    {'name': 'Cardano', },
    bnb:    {'name': 'Binance Coin', },
    doge:   {'name': 'Doge Coin', },
    fil:    {'name': 'Filecoin', },
    czk:    {'name': 'Czech Krown', 'symbol': 'Kč', },
    jpy:    {'name': 'Japanese Yen', 'symbol': '¥', },
    busd:   {'name': 'BUSD', },
    usdc:   {'name': 'USDC', },
    uni:    {'name': 'Uniswap', },
}

src_exchanges = collections.OrderedDict()
src_exchanges['binance-com'] = {
#    'disabled': True,

    'name': 'Binance',
    'url': 'https://binance.com/',
    'api_url': 'https://api1.binance.com/api/v3/trades?limit=1&symbol={crypto}{pair}',

    # https://www.binance.com/en/markets
    'crypto': [
        btc, etc, eth, xrp, ada, bnb, doge, fil, link, ltc,
        # FIXME we need a BNB/USDT pair for example
    ],
    'fiats': [
        usdt, eur, gbp, bnb, busd, 
    ],

    'functions': {
        'getUrl': "return 'https://api1.binance.com/api/v3/trades?limit=1&symbol=' + crypto + fiat",
        'getRateFromExchangeData': 'return data[0].price',
    },
}

src_exchanges['bitstamp-net'] = {
#    'disabled': True,

    'name': 'Bitstamp',
    'url': 'https://bitstamp.net/',
    'api_url': 'https://www.bitstamp.net/api/v2/ticker/{crypto}{pair}',

    # https://www.bitstamp.net/markets/
    'crypto': [
        btc, etc, ltc, xrp, uni, eth,
    ],
    'fiats': [
        usd, eur, gbp, usdc
    ],

    'functions': {
        'getUrl': "return 'https://www.bitstamp.net/api/v2/ticker/' + crypto + fiat",
        'getRateFromExchangeData': 'return data.ask',
    },
}

src_exchanges['bitbay-net'] = {
#    'disabled': True,

    'name': 'BitBay',
    'url': 'https://bitbay.net/',
    'api_url': 'https://bitbay.net/API/Public/{crypto}{pair}/ticker.json',
    'validator': bitbay_ticker_validator,

    'crypto': [
        btc, bsv, btg, comp, dash, dot, etc, eth, game, link, lsk, ltc, luna, mkr, xrp, zec,
    ],
    'fiats': [
        eur, gbp, pln, usd,
    ],

    'functions': {
        'getUrl': "return 'https://bitbay.net/API/Public/' + crypto + fiat + '/ticker.json'",
        'getRateFromExchangeData': 'return data.ask',
    },
}

src_exchanges['coinmate-io'] = {
#    'disabled': True,

    'name': 'Coinmate',
    'url': 'https://coinmate.io/',
    'api_url': 'https://coinmate.io/api/ticker?currencyPair={crypto}_{pair}',
    'validator': coinmate_ticker_validator,

    # https://coinmate.io/trade
    'crypto': [
        btc, eth, ltc, xrp, dash, bch,
    ],
    'fiats': [
        czk, eur,
    ],

    'functions': {
        'getUrl': "return 'https://coinmate.io/api/ticker?currencyPair=' + crypto + '_' + fiat",
        'getRateFromExchangeData': 'return data.data.ask',
    },
}


src_exchanges['kraken-com'] = {
#    'disabled': True,

    'name': 'Kraken',
    'url': 'https://kraken.com/',
    'api_url': 'https://api.kraken.com/0/public/Ticker?pair={crypto}{pair}',
    'validator': kraken_ticker_validator,

    # https://support.kraken.com/hc/en-us/articles/360001185506
    # https://support.kraken.com/hc/en-us/articles/201893658-Currency-pairs-available-for-trading-on-Kraken
    'crypto': [
        btc, eth, ltc, xrp, ada, doge, dot, etc, zec,
    ],
    'fiats': [
        usd, eur, gbp, jpy, usdt,
    ],

    'functions': {
        'getUrl': "return 'https://api.kraken.com/0/public/Ticker?pair=' + crypto + fiat",
        # some tricker to work around odd asset naming used in returned reponse as main key
        'getRateFromExchangeData': "return data.result[Object.keys(data['result'])[0]].a[0]",
    },
}

######################################################################

def abort(msg='Aborted'):
    print('*** {}'.format(msg))
    sys.exit(1)


######################################################################

def do_api_call(queue, exchange, ex_data, crypto, pair):
    url = ex_data['api_url'].format(crypto=crypto, pair=pair)
    response = req.get(url)
#    print('#{}: {}'.format(response.status_code, url), end='')
#    time.sleep(0.5)

    validator = ex_data.get('validator', default_ticker_validator)
    rc = validator(response, crypto, pair)
    queue.put({
        'rc': rc, 'stamp': int(round(time.time() * 1000)),
        'name': exchange, 'crypto': crypto, 'pair': pair,
        })

def do_api_call_error_callback(msg):
    print('Error Callback: {}'.format(msg))


######################################################################

def build_header():
    return [
        '// This file is auto-generated. DO NOT EDIT BY HAND',
        '// Use generate_data.py to rebuild this file if needed',
        '',
        '// https://doc.qt.io/qt-5/qtqml-javascript-resources.html',
        '.pragma library',
        '',
        ]

def build_currencies(currencies):
    # currency and token info
    result = [
        'var currencies = {',
        ]

    keys = list(currencies.keys())
    keys.sort()
    for key in keys:
        data = currencies[key]
        symbol = None if 'symbol' not in data else '"{}"'.format(data['symbol'])

        row = '\t"{}": {{'.format(key)
        code = key.upper()

        row += '"code": "{}", '.format(code)
        if data['name'] != code:
            row += '"name": "{}", '.format(data['name'])
        if symbol:
            row += '"symbol": {}, '.format(symbol)
        row += '},'
        result.append(row)
    result.append('}')

    return result

def build_exchanges(exchanges):
    result = [
        'var exchanges = {',
        ]

    for exchange, ex_data in exchanges.items():
        if 'pairs' in ex_data:
            result += [
                '\t"{}": {{'.format(exchange),
                '\t\t"name": "{}",'.format(ex_data['name']),
                '\t\t"url": "{}",'.format(ex_data['url']),
                ]

            result += [
                '\t\t"getUrl": function(crypto, fiat) {',
                '\t\t\t{}'.format(ex_data['functions']['getUrl']),
                '\t\t},',
                ]

            result += [
                '\t\t"getRateFromExchangeData": function(data, crypto, fiat) {',
                '\t\t\t{}'.format(ex_data['functions']['getRateFromExchangeData']),
                '\t\t},'
                ]

            result.append('\t\t"pairs": {')
            for crypto, pairs in ex_data['pairs'].items():
                pairs.sort()
                row = '\t\t\t"{crypto}": ['.format(crypto=crypto)
                row += ''.join(['"{}",'.format(pair) for pair in pairs])
                row += '],'
                result.append(row)
            result += [
                '\t\t},',
                '\t},',
                ]

    result += ['}', '']

    return result



#############################G#########################################

# preprocess data first

def process_exchanges(src_exchanges, args):
    cache_threshold = args.threshold
    no_cache = args.no_cache

    result = collections.OrderedDict()

    print('Processing exchange data')
    for exchange, ex_data in src_exchanges.items():
        if ex_data.get('disabled', False):
            print('  {}: DISABLED'.format(exchange))
            continue

        cache_dir = os.path.join('.gen-cache', exchange)

        result[exchange] = collections.OrderedDict({
            'name': ex_data['name'],
            'url': ex_data['url'],
            'functions': ex_data['functions'],
            'pairs': collections.OrderedDict(),
            })

        # total number of tries needed:
        all_items = ex_data['crypto'] + ex_data['fiats']
        # remove duplicates
        all_items = list(dict.fromkeys(all_items))
        all_items.sort()

        ex_pairs = collections.OrderedDict()

        # we need to use Manager to allow subprocesses to access our queue
        queue = mp.Manager().Queue()
        with mp.Pool(processes=6) as pool:
            total_checks_cnt = 0
            for item in all_items:
                # skip pairs FIAT-CRYPTO
                if item in ex_data['fiats']:
                   continue

                for pair in all_items:
                    # just in case of any dupes in source data
                    if item == pair or (item in result[exchange]['pairs']
                        and pair in result[exchange]['pairs'][item]):
                        continue

                    # see if we have old cache file already
                    use_cached_data = False
                    cache_rc = False

                    if no_cache == False:
                        cache_file = os.path.join(cache_dir, '{}-{}'.format(item, pair))
                        if os.path.exists(cache_file):
                            with open(cache_file, 'r') as fh:
                                cache = json.load(fh)
                                now = int(round(time.time() * 1000))
                                if (now < (cache['stamp'] + (cache_threshold * 60 * 1000))):
                                    use_cached_data = True
                                    cache_rc = cache['rc']
                                now = int(round(time.time() * 1000))

                    if use_cached_data:
                        queue.put({'rc': cache_rc, 'name': exchange, 'crypto': item, 'pair': pair,'cache': True})
                    else:
                        pool.apply_async(func=do_api_call, args=(queue, exchange, ex_data, item, pair),
#                            callback=do_api_call_success_callback,
                            error_callback=do_api_call_error_callback)
                    total_checks_cnt += 1

            # No more pool submissions
            pool.close()

            # Waiting for processes to complete...
            pair_success_cnt = pair_fail_cnt = pair_from_cache = 0
            cnt = 0
            while cnt < total_checks_cnt:
                response = queue.get()
                resp_exchange = result[response['name']]
                resp_crypto = response['crypto']
                resp_pair = response['pair']

                cache_file = os.path.join(cache_dir, '{}-{}'.format(resp_crypto, resp_pair))
                if not os.path.exists(cache_dir):
                    os.makedirs(cache_dir)
 
                if response['rc']:
                    if resp_crypto not in resp_exchange['pairs']:
                        resp_exchange['pairs'][resp_crypto] = []
                    resp_exchange['pairs'][resp_crypto].append(resp_pair)
                    pair_success_cnt += 1
                else:
                    pair_fail_cnt += 1

                if response.get('cache', False):
                    pair_from_cache += 1
                else:
                    # create fresh cache entry
                    with open(cache_file, 'w') as fh:
                        cache = {
                            'rc': response['rc'],
                            'stamp': response['stamp'],
                            }
                        fh.write(json.dumps(cache))

                cnt += 1
                print('  {}: {} of {}...'.format(exchange, cnt, total_checks_cnt), end='\r')

            # to ensure we do not leave too early (shoud not happen though)
            pool.join()

            # Summary
            print('  {}: total: {}, paired: {}, skipped: {}, cache hits: {} ({:>.0f}%)'.format(
                exchange, cnt, pair_success_cnt, pair_fail_cnt,
                pair_from_cache, (pair_from_cache * 100)/cnt))

    return result


######################################################################

def check_icons(result_exchanges):
    img_dir = 'src/contents/images/'

    print('Checking SVG icons...')

    all_pairs = []
    for ex, ex_data in result_exchanges.items():
        for crypto, pairs in ex_data['pairs'].items():
            for pair in pairs:
                if pair not in all_pairs:
                    all_pairs.append(pair)

    cnt = 0
    for pair in all_pairs:
        icon_file = os.path.join(img_dir, '{}.svg'.format(pair))
        res = os.path.exists(icon_file)
        if not res:
            print('  File not found: {}'.format(icon_file))
            cnt += 1

    print('Total {} coins in use, {} icons missing'.format(len(all_pairs), cnt))

    return cnt == 0


######################################################################

CACHE_THRESHOLD = 1440

parser = argparse.ArgumentParser()
ag = parser.add_argument_group('Flags')
ag.add_argument('-t', '--threshold', action='store', dest='threshold', type=int,
    help='Cache threshold, in minutes. Default {} mins'.format(CACHE_THRESHOLD),
    default=CACHE_THRESHOLD)
ag.add_argument('-n', '--nocache', action='store_true', dest='no_cache', default=False,
    help='Ignore validation result cache and always do the full API check.')
ag.add_argument('-o', '--out', action='store', dest='file', type=str,
    help='Optional. Name of JS file to be generated.')
ag.add_argument('-f', '--force', action='store_true', dest='force',
    help='Enforce certain operations. Mainly file overwrite.')
ag.add_argument('-v', '--verbose', action='store_true', dest='verbose', default=False)
args = parser.parse_args()

if args.file is not None and not args.force and os.path.exists(args.file):
    abort('File already exists: {}'.format(args.file))

# preprocess data first
result_exchanges = process_exchanges(src_exchanges, args)

# check for icons of used coins
check_result = check_icons(result_exchanges)
if not check_result and not args.force:
    abort('Some icon files are missing.')

result = build_header()
result += build_currencies(currencies)
result += build_exchanges(result_exchanges)

if args.verbose:
    print('\n'.join(result))

if args.file is not None:
    try:
        with open(args.file, 'w') as fh:
            fh.writelines('\n'.join(result))
    except IOError:
        abort('Failed writing to: {}'.format(args.file))

