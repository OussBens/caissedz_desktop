"""Supprime des trois ARB les clés jamais référencées dans lib/ et test/ (hors fichiers générés).

Usage : python3 tool/arb_nettoyer.py [--appliquer] [prefixe ...]
Sans --appliquer : liste seulement. Avec des préfixes : limite aux clés qui commencent par l'un d'eux.
"""
import json
import os
import re
import sys
from collections import OrderedDict

ARB = 'lib/core/i18n/arb/app_{}.arb'


def sources():
    for racine in ('lib', 'test'):
        for d, _, fichiers in os.walk(racine):
            if 'generated' in d:
                continue
            for f in fichiers:
                if f.endswith('.dart'):
                    yield open(os.path.join(d, f), encoding='utf-8').read()


def main(args):
    appliquer = '--appliquer' in args
    prefixes = [a for a in args if not a.startswith('--')]
    texte = '\n'.join(sources())
    utilisees = set(re.findall(r'\b(?:l10n|l|AppLocalizations\.of\([^)]*\))\.(\w+)', texte))
    utilisees |= set(re.findall(r'\.(\w+)\b', texte))
    fr = json.load(open(ARB.format('fr'), encoding='utf-8'), object_pairs_hook=OrderedDict)
    inutiles = [
        k for k in fr
        if not k.startswith('@') and k not in utilisees and (not prefixes or any(k.startswith(p) for p in prefixes))
    ]
    for k in inutiles:
        print(k)
    print(f'{len(inutiles)} clé(s) inutilisée(s)', file=sys.stderr)
    if not appliquer:
        return
    for langue in ('fr', 'ar', 'en'):
        f = ARB.format(langue)
        d = json.load(open(f, encoding='utf-8'), object_pairs_hook=OrderedDict)
        for k in inutiles:
            d.pop(k, None)
            d.pop('@' + k, None)
        with open(f, 'w', encoding='utf-8') as out:
            json.dump(d, out, ensure_ascii=False, indent=2)


if __name__ == '__main__':
    main(sys.argv[1:])
