// CaisseDZ desktop UI kit — shared nav + demo data
(function () {
  const sections = [
    { label: 'Général', items: [
      { route: 'dashboard', label: 'Tableau de bord', icon: 'layout-dashboard' },
      { route: 'caisse', label: 'Caisse', icon: 'monitor-smartphone' },
      { route: 'ventes', label: 'Ventes', icon: 'receipt-text' },
      { route: 'retours', label: 'Retours', icon: 'undo-2' }] },
    { label: 'Stock', items: [
      { route: 'produits', label: 'Produits', icon: 'package' },
      { route: 'stock', label: 'Stock', icon: 'boxes' },
      { route: 'entrees', label: 'Entrées', icon: 'scan-line', badge: 'IA' },
      { route: 'sorties', label: 'Sorties', icon: 'package-minus' },
      { route: 'magasins', label: 'Magasins', icon: 'store' },
      { route: 'besoins', label: 'Besoins', icon: 'triangle-alert', badge: 3 }] },
    { label: 'Tiers', items: [
      { route: 'clients', label: 'Clients', icon: 'users' },
      { route: 'fournisseurs', label: 'Fournisseurs', icon: 'truck' }] },
    { label: 'Gestion', items: [
      { route: 'gestion-caisse', label: 'Gestion caisse', icon: 'wallet' },
      { route: 'utilisateurs', label: 'Utilisateurs', icon: 'user-cog' },
      { route: 'zakat', label: 'Zakat', icon: 'hand-coins' },
      { route: 'historique', label: 'Historique', icon: 'history' },
      { route: 'parametres', label: 'Paramètres', icon: 'settings' }] },
  ];
  const products = [
    { id: 1, nom: 'Café moulu 250 g', code: 'PRD000005', cat: 'Épicerie', marque: 'El Djazair', stock: 5, seuil: 10, achat: 250, vente: 320, statut: 'Actif' },
    { id: 2, nom: 'Coca-Cola 1,5 L', code: 'PRD000002', cat: 'Boissons', marque: 'Coca-Cola', stock: 48, seuil: 24, achat: 90, vente: 120, statut: 'Actif' },
    { id: 3, nom: 'Eau minérale Saïda 1,5 L', code: 'PRD000010', cat: 'Boissons', marque: 'Saïda', stock: 96, seuil: 48, achat: 40, vente: 60, statut: 'Actif' },
    { id: 4, nom: 'Farine 1 kg', code: 'PRD000006', cat: 'Épicerie', marque: 'Soummam', stock: 32, seuil: 20, achat: 60, vente: 80, statut: 'Actif' },
    { id: 5, nom: 'Huile Elio 1 L', code: 'PRD000003', cat: 'Épicerie', marque: 'Elio', stock: 40, seuil: 15, achat: 350, vente: 420, statut: 'Actif' },
    { id: 6, nom: 'Lait Candia 1 L', code: 'PRD000001', cat: 'Frais', marque: 'Candia', stock: 60, seuil: 30, achat: 80, vente: 100, statut: 'Actif' },
    { id: 7, nom: 'Pâtes spaghetti 500 g', code: 'PRD000007', cat: 'Épicerie', marque: 'Sim', stock: 74, seuil: 30, achat: 70, vente: 95, statut: 'Actif' },
    { id: 8, nom: 'Sucre cristal 1 kg', code: 'PRD000004', cat: 'Épicerie', marque: 'Cevital', stock: 0, seuil: 20, achat: 90, vente: 110, statut: 'Rupture' },
    { id: 9, nom: 'Tomate concentrée 400 g', code: 'PRD000008', cat: 'Conserves', marque: 'Rouiba', stock: 22, seuil: 12, achat: 120, vente: 150, statut: 'Actif' },
    { id: 10, nom: 'Yaourt Danone x4', code: 'PRD000009', cat: 'Frais', marque: 'Danone', stock: 8, seuil: 12, achat: 150, vente: 190, statut: 'Actif' },
  ];
  const clients = [
    { id: 1, nom: 'Comptoir', tel: '—', type: 'Consommateur', achats: 1284500, credit: 0, dernier: '10/10/2026' },
    { id: 2, nom: 'Yacine Benali', tel: '0550 12 34 56', type: 'Consommateur', achats: 186400, credit: 4200, dernier: '10/10/2026' },
    { id: 3, nom: 'Supérette El Amel', tel: '0661 98 76 54', type: 'Détaillant', achats: 942000, credit: 38500, dernier: '09/10/2026' },
    { id: 4, nom: 'Amina Kaci', tel: '0770 45 67 89', type: 'Consommateur', achats: 54300, credit: 0, dernier: '07/10/2026' },
    { id: 5, nom: 'Restaurant Le Tassili', tel: '0555 33 22 11', type: 'Société', achats: 412800, credit: 12750, dernier: '05/10/2026' },
    { id: 6, nom: 'Karim Ouali', tel: '0662 11 00 99', type: 'Consommateur', achats: 23900, credit: 0, dernier: '28/09/2026' },
  ];
  const sales = [
    { id: 'PN0000231', heure: '17:42', client: 'Comptoir', articles: 4, mode: 'Espèces', total: 1290, statut: 'Payé' },
    { id: 'PN0000230', heure: '17:31', client: 'Yacine Benali', articles: 9, mode: 'Espèces', total: 4200, statut: 'Crédit' },
    { id: 'PN0000226', heure: '16:58', client: 'Supérette El Amel', articles: 46, mode: 'Carte CIB', total: 38500, statut: 'Payé' },
    { id: 'PN0000229', heure: '16:20', client: 'Comptoir', articles: 2, mode: 'Espèces', total: 420, statut: 'Payé' },
    { id: 'PN0000228', heure: '15:47', client: 'Amina Kaci', articles: 6, mode: 'Espèces', total: 1860, statut: 'Annulé' },
  ];
  const remises = [
    { id: 'r0', nom: 'Aucune remise', type: '%', v: 0, cond: '—' },
    { id: 'r1', nom: 'Fidélité', type: '%', v: 5, cond: 'Clients fidèles' },
    { id: 'r2', nom: 'Grossiste', type: '%', v: 10, cond: 'Dès 10 000 DA' },
    { id: 'r3', nom: 'Promo Ramadan', type: '%', v: 15, cond: 'Jusqu\'au 30/03' },
    { id: 'r4', nom: 'Remise fixe', type: 'DA', v: 200, cond: 'Dès 2 000 DA' },
  ].map((r) => ({ ...r, label: r.v ? r.nom + ' · ' + r.v + (r.type === '%' ? ' %' : ' DA') : r.nom }));
  const stores = [
    { code: 'MAG000001', nom: 'Magasin Central', adresse: 'Rue Didouche Mourad, Alger-Centre', main: true, etat: true, produits: 9, valeur: 61240, users: 3, transferts: 6 },
    { code: 'MAG000002', nom: 'Dépôt Bab Ezzouar', adresse: 'Zone d\'activité, Bab Ezzouar', etat: true, produits: 7, valeur: 38900, users: 1, transferts: 4 },
    { code: 'MAG000003', nom: 'Boutique Hydra', adresse: 'Rue des Pins, Hydra', etat: true, produits: 5, valeur: 14320, users: 1, transferts: 2 },
    { code: 'MAG000004', nom: 'Ancien dépôt Rouiba', adresse: 'Rouiba', etat: false, produits: 0, valeur: 0, users: 0, transferts: 1 },
  ];
  const U = {
    f2: (n) => (n || 0).toLocaleString('fr-FR', { minimumFractionDigits: 2, maximumFractionDigits: 2 }),
    da: (n) => U.f2(n) + ' DA',
    W: (inline, w) => (inline ? '100%' : w),
    num: (s) => { const n = parseFloat(String(s == null ? '' : s).replace(/\s/g, '').replace(',', '.')); return isNaN(n) ? 0 : n; },
    useBusy: (cb) => { const [b, setB] = React.useState(false); return [b, function () { const a = arguments; setB(true); setTimeout(() => { setB(false); cb && cb.apply(null, a); }, 600); }]; },
    useToast: () => {
      const [t, setT] = React.useState(null);
      const say = (title, description, tone) => { setT({ title, description, tone: tone || 'success' }); clearTimeout(window.__cdzT); window.__cdzT = setTimeout(() => setT(null), 3200); };
      const el = t ? React.createElement('div', { style: { position: 'fixed', insetInlineEnd: 24, bottom: 24, zIndex: 120 } }, React.createElement(window.CaisseDZDesignSystem_9ce617.Toast, { tone: t.tone, title: t.title, description: t.description, onClose: () => setT(null) })) : null;
      return [el, say];
    },
    // Colonnes secondaires (masquées par défaut) : x(['email', 'E-mail'], ['tva', 'TVA', { align: 'right' }])
    x: function () { return [].slice.call(arguments).map((d) => ({ key: d[0], label: d[1], hidden: true, ...(d[2] || {}) })); },
    // Colonnes d'audit communes à tous les tableaux CaisseDZ (créé / modifié / annulé)
    audit: (o) => {
      o = o || {};
      const can = (r) => r.statut === 'annule' || r.statut === 'Annulé' || r.etat === false || r.actif === false;
      const d = (r) => { const x = String(r.date || r.d || r.du || r.ouv || '01/10/2026').split(' ')[0]; return x.length <= 5 ? x + '/2026' : x; };
      const who = (r) => r.caissier || r.u || r.user || r.par || 'Admin';
      const dash = (b, v) => (b ? v : '—');
      const cols = [
        { key: 'dateCree', label: 'Créé le', muted: true, render: (v, r) => v || d(r) },
        { key: 'creeParCode', label: 'Créé par', render: (v, r) => v || who(r) },
        { key: 'dateModif', label: 'Modifié le', muted: true },
        { key: 'modifParCode', label: 'Modifié par' },
        { key: 'dateAnnul', label: 'Annulé le', muted: true, render: (v, r) => v || dash(can(r), '11/10/2026') },
        { key: 'annulParCode', label: 'Annulé par', render: (v, r) => v || dash(can(r), 'Admin') },
        { key: 'motifAnnul', label: "Motif d'annulation", render: (v, r) => v || r.motif || dash(can(r), 'Erreur de saisie') },
      ];
      return cols.filter((c) => !(o.skip || []).includes(c.key)).map((c) => ({ ...c, hidden: !(o.show || []).includes(c.key) }));
    },
  };
  window.CDZU = U;
  window.CDZ = { sections, products, clients, sales, stores, remises, G: 'data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAzMiAzMiIgZmlsbD0ibm9uZSIgc3Ryb2tlPSIjZmZmIiBzdHJva2Utd2lkdGg9IjIuNCIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIj48cGF0aCBkPSJNNCA2aDNsMi42IDEzLjJhMiAyIDAgMCAwIDIgMS42aDEwLjhhMiAyIDAgMCAwIDItMS41TDI3IDExSDkuMiIvPjxjaXJjbGUgY3g9IjEyLjUiIGN5PSIyNiIgcj0iMS42IiBmaWxsPSIjZmZmIiBzdHJva2U9Im5vbmUiLz48Y2lyY2xlIGN4PSIyMi41IiBjeT0iMjYiIHI9IjEuNiIgZmlsbD0iI2ZmZiIgc3Ryb2tlPSJub25lIi8+PHBhdGggZD0iTTE3LjUgMTMuMnY0LjZNMTUuMiAxNS41aDQuNiIgc3Ryb2tlLXdpZHRoPSIyIi8+PC9zdmc+', all: [].concat(...sections.map((s) => s.items)) };
  try { var th = localStorage.getItem('cdz-theme'); if (th) document.documentElement.setAttribute('data-theme', th); } catch (e) {}
})();
