"""Phase 3 — harmonisation du design system v2.1 -> v2.2.

Applique, sur le bundle compilé (composants + kits) et sur les données de démo :
  * la codification du §8.10 (PN, CL, CS, SS, SRT, SC, BL, TRM / TRF, MVC, CLT, SES, ZKT) ;
  * les listes de valeurs du §13 (types de caisse, de fournisseur, statuts des besoins, modes de paiement) ;
  * les corrections de libellés et de règles décidées en phase 0 (caisse sans magasin,
    principal par utilisateur, mot de passe oublié, export fiscal JSON, etc.).
Chaque remplacement est borné à un fichier du bundle et vérifie son nombre d'occurrences.
"""
import re, sys, subprocess, json

P = '/home/claude/caissedz-v22'
GLYPH_SVG = ('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32" fill="none" stroke="#fff" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round">'
             '<path d="M4 6h3l2.6 13.2a2 2 0 0 0 2 1.6h10.8a2 2 0 0 0 2-1.5L27 11H9.2"/><circle cx="12.5" cy="26" r="1.6" fill="#fff" stroke="none"/>'
             '<circle cx="22.5" cy="26" r="1.6" fill="#fff" stroke="none"/><path d="M17.5 13.2v4.6M15.2 15.5h4.6" stroke-width="2"/></svg>')
GLYPH = 'data:image/svg+xml;base64,' + __import__('base64').b64encode(GLYPH_SVG.encode()).decode()
PIXEL = 'data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7'


def decode(t):
    t = re.sub(r'\\u([0-9A-Fa-f]{4})', lambda m: chr(int(m.group(1), 16)), t)
    return re.sub(r'\\x([0-9A-Fa-f]{2})', lambda m: chr(int(m.group(1), 16)), t)


def normalize_codes(t):
    """Codification §8.10 sur les données de maquette (jamais sur des identifiants)."""
    t = t.replace('PAN000', 'PN0000')
    t = re.sub(r"(['\"`])CLI(['\"`])", r'\1CL\2', t)
    t = re.sub(r'\bCLI(?=\d)', 'CL', t)
    t = re.sub(r"(['\"`])CAI(['\"`])", r'\1CS\2', t)
    t = re.sub(r'\bCAI(?=\d)', 'CS', t)
    t = re.sub(r'\bENT(?=\d)', 'SS', t)
    t = re.sub(r'\bSOR(?=\d)', 'SRT', t)
    t = re.sub(r'\bSCT(?=\d)', 'SC', t)
    t = re.sub(r'\bBES(?=\d)', 'BL', t)
    t = re.sub(r'\bTRF(?=\d)', 'TRM', t)      # transferts de marchandise
    t = re.sub(r'\bTRC(?=\d)', 'TRF', t)      # transferts d'argent entre caisses
    t = re.sub(r'\bMVM(?=\d)', 'MVC', t)
    t = re.sub(r'\bZ-(\d{6})\b', r'CLT\1', t)
    t = re.sub(r'\bSES00(?=\d{6}\b)', 'SES', t)
    for y, n in (('2026', '3'), ('2025', '2'), ('2024', '1')):
        t = t.replace(f'ZKT-{y}-0001', f'ZKT00000{n}')
    return t


def scan_call_end(t, i):
    """Index juste après la parenthèse fermante de l'appel qui commence à t[i] == '('."""
    assert t[i] == '(', t[i:i + 20]
    depth, k, n = 0, i, len(t)
    while k < n:
        c = t[k]
        if c in '\'"`':
            q = c; k += 1
            while k < n and t[k] != q:
                k += 2 if t[k] == '\\' else 1
        elif c == '(':
            depth += 1
        elif c == ')':
            depth -= 1
            if depth == 0:
                return k + 1
        k += 1
    raise ValueError('unbalanced')


def flex(s):
    """Motif tolérant aux retours à la ligne et à l'indentation du code compilé."""
    parts = re.split(r'\s+', s.strip())
    return r'\s*'.join(re.escape(p) for p in parts)


def remove_element(t, marker, count=1):
    """Retire `/*#__PURE__*/React.createElement(...)` qui contient `marker` dès ses arguments, virgule suivante comprise."""
    done = 0
    rx = re.compile(flex(marker))
    while True:
        m = rx.search(t)
        if not m:
            break
        j = m.start()
        start = t.rfind('/*#__PURE__*/React.createElement(', 0, j)
        end = scan_call_end(t, start + len('/*#__PURE__*/React.createElement'))
        m2 = re.match(r',\s*', t[end:])
        if m2:
            end += m2.end()
        t = t[:start] + t[end:]
        done += 1
    assert done == count, (marker, done)
    return t


class Bundle:
    def __init__(self, text):
        self.t = text
        lines = text.split('\n')
        self.marks = [l[3:].strip() for l in lines if re.match(r'^// (ui_kits|components)/[A-Za-z0-9_./-]+\.(jsx|js)$', l)]

    def section(self, name):
        key = next(m for m in self.marks if m.endswith('/' + name))
        a = self.t.index('// ' + key + '\n')
        nxt = [self.t.index('// ' + m + '\n') for m in self.marks if self.t.index('// ' + m + '\n') > a]
        b = min(nxt) if nxt else len(self.t)
        return a, b

    def sub(self, name, old, new, count=1):
        a, b = self.section(name)
        seg, n = re.subn(flex(old), lambda m: new, self.t[a:b])
        assert n == count, f'{name}: {old[:70]!r} found {n}x, expected {count}'
        self.t = self.t[:a] + seg + self.t[b:]

    def resub(self, name, pattern, repl, count=1):
        a, b = self.section(name)
        seg, n = re.subn(pattern, repl, self.t[a:b])
        assert n == count, f'{name}: /{pattern}/ {n}x, expected {count}'
        self.t = self.t[:a] + seg + self.t[b:]

    def remove(self, name, marker, count=1):
        a, b = self.section(name)
        seg = remove_element(self.t[a:b], marker, count)
        self.t = self.t[:a] + seg + self.t[b:]


def patch_bundle(src):
    B = Bundle(decode(src))
    # ---------- Gestion caisse : caisse sans magasin, types Physique / Compte (M4, Q1b) ----------
    for old in ("'Caisse 1', 'Principale',", "'Caisse 2', 'Secondaire',", "'Caisse dépôt', 'Dépôt',", "'Coffre', 'Coffre',"):
        new = old.replace("'Principale'", "'Physique'").replace("'Secondaire'", "'Physique'").replace("'Dépôt',", "'Physique',").replace("'Coffre', 'Coffre',", "'Coffre', 'Physique',")
        B.sub('GestionKit.jsx', old, new)
        B.sub('LookupKit.jsx', old, new)
    B.sub('GestionKit.jsx', "options: ['Principale', 'Secondaire', 'Dépôt', 'Coffre'], defaultValue: c ? c.type : 'Secondaire'",
          "options: ['Physique', 'Compte'], defaultValue: c ? c.type : 'Physique'")
    B.remove('GestionKit.jsx', 'FormRow, { label: "Magasin", required: true }')
    B.sub('GestionKit.jsx', "tone: v === 'Coffre' ? 'accent' : v === 'Principale' ? 'primary' : 'neutral'", "tone: v === 'Compte' ? 'accent' : 'neutral'")
    B.sub('GestionKit.jsx', "{ key: 'mag', label: 'Magasin' }, ", '')
    B.sub('GestionKit.jsx', "CAISSES.filter(c => c.type !== 'Coffre')", "CAISSES.filter(c => c.nom !== 'Coffre' && c.type !== 'Compte')")
    B.sub('GestionKit.jsx', "['Crédit client', 2020]", "['Points', 2020]")
    B.sub('GestionKit.jsx', "['Crédit client', z.tv * 0.03]", "['Points', z.tv * 0.03]")
    # ---------- Export fiscal : JSON de contrôle dans l'archive (Q4) ----------
    B.sub('GestionKit.jsx', "description: 'PDF + CSV + empreintes (.zip)' }",
          "description: 'PDF + CSV + JSON de contrôle + empreintes (.zip)' }, { value: 'json', label: 'JSON de contrôle', icon: 'file-json', description: 'Chaîne vérifiable (§12.3)' }")
    # ---------- Historique attribuable par rôle (E5) ----------
    B.sub('GestionKit.jsx', "Journal de toutes les actions — réservé à l'administrateur", 'Journal de toutes les actions · accès selon le rôle')
    B.sub('UtilisateursKit.jsx', 'Paramètres et Historique sont réservés à l\'administrateur.', 'Paramètres et Historique s’attribuent comme les autres modules.')
    # ---------- Magasins : principal défini par utilisateur (M5) ----------
    B.remove('StockKit.jsx', 'FormRow, { label: "Principal" }')
    B.sub('StockKit.jsx', 'r.main && /*#__PURE__*/React.createElement(Badge, { tone: "primary" }, "Principal")', 'null')
    B.sub('StockKit.jsx', 'one.main && /*#__PURE__*/React.createElement(Badge, { tone: "primary" }, "Principal"),', 'null,')
    B.sub('StockKit.jsx', "m.main ? 'Magasin principal' :", "m.main ? 'Magasin principal d’un utilisateur' :")
    # ---------- Besoins : statuts du §13 (N4) ----------
    B.sub('StockKit.jsx', "38400, 'brouillon']", "38400, 'enAttente']")
    B.sub('StockKit.jsx', "14800, 'valide']", "14800, 'commande']")
    B.sub('StockKit.jsx', "22600, 'traite']", "22600, 'disponible']")
    B.sub('StockKit.jsx', "options: ['Tous', 'Brouillon', 'Validé', 'Traité']", "options: ['Tous', 'En attente', 'Commande', 'Disponible']")
    B.sub('StockKit.jsx', "statut === 'traite'", "statut === 'disponible'", count=4)
    B.sub('StatusBadge.jsx', "valide: ['success', 'Validé'],", "valide: ['success', 'Validé'], commande: ['info', 'Commande'], disponible: ['success', 'Disponible'],")
    # ---------- Modes de paiement : le crédit est un reste, pas un mode (W2) ----------
    B.sub('PaniersScreen.jsx', "options: ['Espèces', 'Carte CIB', 'Chèque', 'Virement', 'Crédit'], defaultValue: s.mode", "options: ['Espèces', 'Carte CIB', 'Chèque', 'Virement', 'Points fidélité'], defaultValue: s.mode")
    B.sub('CaisseKit.jsx', "26900, 0, 'Crédit', 'credit'", "26900, 0, 'Espèces', 'credit'")
    B.sub('CaisseKit.jsx', "['Tous'].concat(MODES, ['Crédit'])", "['Tous'].concat(MODES)")
    B.sub('CaisseScreen.jsx', "const MODES = ['Espèces', 'Carte CIB', 'Chèque', 'Virement', 'Crédit'];", "const MODES = ['Espèces', 'Carte CIB', 'Chèque', 'Virement', 'Points fidélité'];")
    # ---------- Types de fournisseur du §13 ----------
    B.sub('FournisseurKit.jsx', "const FRN_TYPES = ['Grossiste', 'Fabricant', 'Distributeur', 'Importateur'];",
          "const FRN_TYPES = ['Usine', 'Société', 'Importateur', 'Grossiste', 'Semi-Grossiste', 'Détaillant', 'Autre'];")
    t = B.t
    t = t.replace("'Fabricant'", "'Usine'").replace("'Distributeur'", "'Semi-Grossiste'")
    B.t = t
    # ---------- Libellés et règles (W4, H5, C3b, E1b) ----------
    B.sub('ProduitsScreen.jsx', "\"Date d'emprunt\"", "\"Date d'expiration\"")
    B.sub('RetoursScreen.jsx', "'Non — produit défectueux'", "'Non — défectueux, sortie « Casse »'")
    B.sub('LoginScreen.jsx', "/*#__PURE__*/React.createElement(\"a\", { href: \"#\", style: { font: '500 13px var(--font-sans)' } }, \"Mot de passe oublié ?\")",
          "/*#__PURE__*/React.createElement(\"span\", { style: { font: '400 12px var(--font-sans)', color: 'var(--text-muted)' } }, \"Mot de passe oublié ? Voyez l’administrateur\")")
    B.sub('LoginScreen.jsx', '"Fonctionne hors ligne · données stockées sur ce poste")',
          '"Fonctionne hors ligne · données stockées sur ce poste"), window.CDZ_DemoNotice ? React.createElement(window.CDZ_DemoNotice, null) : null')
    B.sub('LoginScreen.jsx', '"../../assets/images/login_back.png"', json.dumps(PIXEL))
    B.sub('LoginScreen.jsx', '"../../assets/brand/logo-mark-white.png"', json.dumps(GLYPH))
    B.sub('Logo.jsx', "glyphSrc = 'assets/brand/glyph-white.png'", "glyphSrc = " + json.dumps(GLYPH))
    # les données de démo embarquées dans le bundle (ui_kits/desktop/data.js) reçoivent les mêmes corrections
    a, b = B.section('data.js'); B.t = B.t[:a] + patch_data(B.t[a:b]) + B.t[b:]
    B.sub('ParametresScreen.jsx', "Multi-magasins, multi-caisses, Smart Scan IA · valide jusqu'au 31/12/2026", "Multi-magasins, multi-caisses · valide jusqu'au 31/12/2026")
    # ---------- Décisions de phase 0 complémentaires ----------
    # W2 : modes de paiement du §13 (le crédit est un reste, pas un mode ; Edahabia hors liste)
    B.sub('ParametresScreen.jsx', "{ 'Espèces': true, 'Carte CIB': true, 'Chèque': true, 'Virement': true, 'Crédit client': true, 'Points fidélité': false, 'Edahabia': false }",
          "{ 'Espèces': true, 'Carte CIB': true, 'Chèque': true, 'Virement': true, 'Points fidélité': true }")
    # T12 : la garde de stock n'est plus désactivable
    B.sub('ParametresScreen.jsx', 'React.createElement(Row, { title: "Bloquer la vente en rupture", desc: "Empêche d\'encaisser un produit dont le stock est à 0." }, /*#__PURE__*/React.createElement(Switch, null))',
          'React.createElement(Row, { title: "Garde de stock", desc: "Toujours active : le stock ne devient jamais négatif, un produit à 0 ne s\'encaisse pas." }, /*#__PURE__*/React.createElement(Switch, { checked: true, disabled: true }))')
    # E1b : Smart Scan IA indépendant du palier (quota serveur)
    B.sub('ShellKit.jsx', "'Avancé (multi-magasins, multi-caisses, Smart Scan IA)'", "'Avancé (multi-magasins, multi-caisses)'")
    B.sub('ShellKit.jsx', "['Magasins illimités et transferts', 'Plusieurs caisses', 'Smart Scan IA']", "['Magasins illimités et transferts', 'Plusieurs caisses', 'Smart Scan IA selon quota serveur']")
    B.sub('ShellKit.jsx', "['1 magasin', '1 caisse', 'Tous les modules de vente et stock']", "['1 magasin', '1 caisse', 'Smart Scan IA selon quota serveur']")
    # C1b : clé de licence SHA-256 (64 caractères hexadécimaux, 8 × 8)
    B.sub('ShellKit.jsx', 'React.createElement(KeyInput, { value: key,', 'React.createElement(KeyInput, { groups: 8, size: 8, value: key,')
    B.sub('ShellKit.jsx', 'React.createElement(Logo, { size: "md", glyphSrc: window.CDZ.G })', 'React.createElement(Logo, { size: 32, glyphSrc: window.CDZ.G })')
    B.sub('ShellKit.jsx', 'const full = key.length === 20;', 'const full = key.length === 64;')
    B.sub('ShellKit.jsx', "maxWidth: 620, display: 'flex', flexDirection: 'column', gap: 20, padding: 32", "maxWidth: 700, display: 'flex', flexDirection: 'column', gap: 20, padding: 32")
    # K7 : entrées vers le magasin principal par défaut ; répartition en option
    B.sub('EntreesScreen.jsx', 'React.createElement(FormRow, { label: "Magasin", required: true, labelWidth: lw }',
          'React.createElement(FormRow, { label: "Magasin", required: true, labelWidth: lw, hint: "Par défaut : votre magasin principal" }')
    B.sub('EntreesScreen.jsx', 'React.createElement(FormRow, { label: "Répartition", align: "start" }', 'React.createElement(FormRow, { label: "Répartition (option)", align: "start" }')
    # §8.10 : une facture BL porte le numéro du panier (PN), BL est le préfixe des listes de besoins
    B.sub('CaisseKit.jsx', "{ label: kind === 'blsc' ? 'N° BL' : 'N° panier', value: kind === 'blsc' ? 'BL000118' : ticketNo }", "{ label: 'N° panier', value: ticketNo }")
    # B21 : garde anti double-clic intégrée au Button (clic ignoré < 450 ms ; onClick async -> chargement automatique)
    B.sub('Button.jsx', "const off = disabled || loading;",
          "const [busy, setBusy] = React.useState(false); const last = React.useRef(0); "
          "const guarded = e => { const now = Date.now(); if (now - last.current < 450) return; last.current = now; const r = onClick && onClick(e); "
          "if (r && typeof r.then === 'function') { setBusy(true); r.then(() => setBusy(false), () => setBusy(false)); } }; "
          "const spin = loading || busy; const off = disabled || spin;")
    B.sub('Button.jsx', "onClick: off ? undefined : onClick,", "onClick: off ? undefined : guarded, 'aria-busy': spin || undefined,")
    B.sub('Button.jsx', "}, loading ? /*#__PURE__*/React.createElement(\"span\", {", "}, spin ? /*#__PURE__*/React.createElement(\"span\", {")
    # B8b : menu contextuel (clic droit) sur les lignes du DataTable
    B.sub('DataTable.jsx', "function DataTable({ hiddenColumns = [],", "function DataTable({ onRowContextMenu, hiddenColumns = [],")
    B.sub('DataTable.jsx', "key: k, title: onRowDoubleClick ? 'Double-clic : afficher le détail' : undefined,",
          "key: k, onContextMenu: onRowContextMenu ? e => { e.preventDefault(); onRowContextMenu(r, e); } : undefined, title: onRowDoubleClick ? 'Double-clic : afficher le détail' : undefined,")
    # E6 : état « Accès refusé » (permission manquante)
    B.sub('LicenseGate.jsx', "role: ['shield-off', 'Accès non autorisé', 'Demander l\\'accès'],",
          "role: ['shield-off', 'Accès non autorisé', 'Demander l\\'accès'], refuse: ['shield-x', 'Accès refusé', 'Retour au tableau de bord'],")
    # ---------- Codification §8.10 partout ----------
    B.t = normalize_codes(B.t)
    # Navigation entre pages de maquette -> navigation interne de la page unique
    for page, route, n in (("'22-situation.html'", "'situation'", 1), ("'02-dashboard.html'", "'dashboard'", 2)):
        B.t, k = re.subn(r'location\.href = ' + re.escape(page), 'window.CDZ_NAV && window.CDZ_NAV(' + route + ')', B.t)
        assert k == n, (page, k)
    return B.t


def patch_data(src):
    t = decode(src)
    rep = [
        ("type: 'Passage'", "type: 'Consommateur'", 1),
        ("type: 'Fidèle'", "type: 'Consommateur'", 3),
        ("tel: '0661 98 76 54', type: 'Grossiste'", "tel: '0661 98 76 54', type: 'Détaillant'", 1),
        ("type: 'Professionnel'", "type: 'Société'", 1),
        ("id: 'T-000231'", "id: 'PN0000231'", 1), ("id: 'T-000230'", "id: 'PN0000230'", 1),
        ("id: 'F-000088'", "id: 'PN0000226'", 1), ("id: 'T-000229'", "id: 'PN0000229'", 1),
        ("id: 'T-000228'", "id: 'PN0000228'", 1),
        ("mode: 'Crédit'", "mode: 'Espèces'", 1),
        ("G: '../../assets/brand/glyph-white.png'", f"G: '{GLYPH}'", 1),
    ]
    for old, new, n in rep:
        t, k = re.subn(flex(old), lambda m: new, t)
        assert k == n, (old, k)
    # thème : ne force plus le clair, respecte le choix du système (contrat de page)
    t = re.sub(r"try\s*\{\s*document\.documentElement\.setAttribute\('data-theme', localStorage\.getItem\('cdz-theme'\) \|\| 'light'\);\s*\}\s*catch \(e\) \{\}",
               "try { var th = localStorage.getItem('cdz-theme'); if (th) document.documentElement.setAttribute('data-theme', th); } catch (e) {}", t)
    assert "|| 'light'" not in t
    return normalize_codes(t)


if __name__ == '__main__':
    b = patch_bundle(open(f'{P}/base/ds-bundle.v21.js', encoding='utf-8').read())
    open(f'{P}/build/ds-bundle.patched.js', 'w', encoding='utf-8').write(b)
    d = patch_data(open(f'{P}/base/data.v21.js', encoding='utf-8').read())
    open(f'{P}/build/data.patched.js', 'w', encoding='utf-8').write(d)
    for f in ('build/ds-bundle.patched.js', 'build/data.patched.js'):
        r = subprocess.run(['node', '--check', f'{P}/{f}'], capture_output=True, text=True)
        print(f, 'syntax OK' if r.returncode == 0 else r.stderr[:2000])
    left = {k: len(re.findall(p, b)) for k, p in [('PAN', r'PAN0\d'), ('CAI', r'\bCAI\d'), ('ENT', r'\bENT\d'), ('SOR', r'\bSOR\d'), ('Z-', r'\bZ-\d'), ('TRC', r'\bTRC\d'), ('Date emprunt', "emprunt")]}
    print('restes:', left)
