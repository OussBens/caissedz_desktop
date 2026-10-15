"""Ajoute (ou remplace) des clés dans les trois ARB FR / AR / EN.

Usage : python3 tool/arb_ajouter.py fichier.json
Le JSON : {"cle": ["texte fr", "texte ar", "texte en"], ...}
Les paramètres {n}, {total}, {nb}, {ok}, {count} sont typés int ; les autres String.
"""
import json
import re
import sys
from collections import OrderedDict

INT = {'n', 'total', 'nb', 'ok', 'count', 'max', 'min', 'jours', 'page', 'pages'}
ARB = 'lib/core/i18n/arb/app_{}.arb'


def main(chemin):
    cles = json.load(open(chemin, encoding='utf-8'), object_pairs_hook=OrderedDict)
    for i, langue in enumerate(['fr', 'ar', 'en']):
        f = ARB.format(langue)
        d = json.load(open(f, encoding='utf-8'), object_pairs_hook=OrderedDict)
        for cle, textes in cles.items():
            texte = textes[i]
            d[cle] = texte
            params = sorted(set(re.findall(r'\{(\w+)\}', textes[0])))
            if langue == 'fr' and params:
                d['@' + cle] = {'placeholders': {p: {'type': 'int' if p in INT else 'String'} for p in params}}
            elif langue == 'fr':
                d.pop('@' + cle, None)
        with open(f, 'w', encoding='utf-8') as out:
            json.dump(d, out, ensure_ascii=False, indent=2)
            out.write('\n')
    print(f'{len(cles)} clés écrites')


if __name__ == '__main__':
    main(sys.argv[1])
