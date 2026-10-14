// v2.2 · Phase 1-2 — aperçus et maquettes d'impression (B19, V1, V2, V6, F13)
import { ds, da, f2 } from './charts.jsx';
import { Code128, QRCode } from './components.jsx';

export const SHOP = { nom: 'Supérette El Baraka', adresse: '12 rue Larbi Ben M’hidi, Alger-Centre', tel: '023 45 67 89', email: 'contact@elbaraka.dz', rc: '16/00-1234567 B 21', nif: '002116123456789', nis: '1981 1601 2345 678', art: '16012345678', message: 'Merci de votre visite — à bientôt !', ar: { nom: 'متجر البركة', adresse: '12 شارع العربي بن مهيدي، الجزائر الوسطى', message: 'شكرا لزيارتكم — إلى اللقاء!' } };
export const TICKET = {
  no: 'PN0000233', date: '10/10/2026 11:48', caissier: 'Yacine B.', caisse: 'Caisse 1', client: 'Yacine Benali',
  lines: [
    { nom: 'Lait Candia 1 L', ar: 'حليب كانديا 1 ل', q: 3, pu: 100 },
    { nom: 'Huile Elio 1 L', ar: 'زيت إليو 1 ل', q: 2, pu: 420 },
    { nom: 'Viande hachée', ar: 'لحم مفروم', q: 1.25, pu: 1450, nb: 2 },
    { nom: 'Coca-Cola 1,5 L', ar: 'كوكا كولا 1.5 ل', q: 3, pu: 120 },
  ],
  remise: 50, verse: 3000, mode: 'Espèces', points: 30, solde: 412, hash: '9F2C·71A0·E4B3·5D18',
};
const sum = (t) => t.lines.reduce((s, l) => s + l.q * l.pu, 0);
const n2 = (v) => f2(v);

const L = {
  fr: { ticket: 'Ticket', caissier: 'Caissier', client: 'Client', art: 'Article', qte: 'Qté', total: 'TOTAL', sous: 'Sous-total', remise: 'Remise', verse: 'Versé', rendu: 'Rendu', reste: 'Reste (crédit)', mode: 'Paiement', pts: 'Points gagnés', solde: 'Solde fidélité', nb: 'nombre', emp: 'Empreinte', da: 'DA', rc: 'RC', nif: 'NIF' },
  ar: { ticket: 'تذكرة', caissier: 'الصندوقي', client: 'الزبون', art: 'المنتج', qte: 'الكمية', total: 'المجموع', sous: 'المجموع الجزئي', remise: 'تخفيض', verse: 'المدفوع', rendu: 'الباقي للزبون', reste: 'المتبقي (دين)', mode: 'الدفع', pts: 'النقاط المكتسبة', solde: 'رصيد الوفاء', nb: 'عدد', emp: 'البصمة', da: 'دج', rc: 'س.ت', nif: 'ر.ج' },
};

/** Ticket thermique 58 / 80 mm, FR ou AR, avec code-barres CODE128, versé / rendu et points gagnés. */
export function TicketThermique({ width = 80, lang = 'fr', t = TICKET, shop = SHOP, credit = false }) {
  const l = L[lang], ar = lang === 'ar';
  const px = width === 58 ? 220 : 302;
  const sub = sum(t), tot = sub - t.remise;
  const verse = credit ? 2000 : t.verse;
  const dash = <div style={{ borderTop: '1px dashed #999', margin: '6px 0' }} />;
  const row = (a, b, bold) => <div style={{ display: 'flex', justifyContent: 'space-between', gap: 8, fontWeight: bold ? 800 : 400 }}><span>{a}</span><span style={{ fontVariantNumeric: 'tabular-nums', direction: 'ltr', unicodeBidi: 'isolate' }}>{b}</span></div>;
  const fs = width === 58 ? 10.5 : 11.5;
  return (
    <div data-no-ar dir={ar ? 'rtl' : 'ltr'} lang={ar ? 'ar' : 'fr'} style={{ width: px, maxWidth: '100%', padding: '14px 12px 18px', background: '#fff', color: '#111', font: `400 ${fs}px/1.45 ${ar ? 'var(--font-arabic), Cairo, sans-serif' : 'var(--font-mono), ui-monospace, monospace'}`, boxShadow: '0 1px 0 #e5e5e5, 0 8px 24px rgba(20,10,40,.12)', borderRadius: 2, backgroundImage: 'linear-gradient(135deg,#fff 0,#fff 100%)' }}>
      <div style={{ textAlign: 'center', display: 'flex', flexDirection: 'column', gap: 1 }}>
        <span style={{ display: 'inline-flex', alignSelf: 'center', width: 34, height: 34, borderRadius: 8, background: '#111', color: '#fff', alignItems: 'center', justifyContent: 'center', font: '800 13px var(--font-sans)', marginBottom: 4 }}>EB</span>
        <b style={{ fontSize: fs + 2.5 }}>{ar ? shop.ar.nom : shop.nom}</b>
        <span>{ar ? shop.ar.adresse : shop.adresse}</span>
        <span style={{ direction: 'ltr', unicodeBidi: 'isolate' }}>{shop.tel}</span>
        <span>{l.rc} <bdi>{shop.rc}</bdi> · {l.nif} <bdi>{shop.nif}</bdi></span>
      </div>
      {dash}
      {row(l.ticket + ' ' + '⁦' + t.no + '⁩', t.date)}
      {row(l.caissier + ' : ' + t.caissier, t.caisse)}
      {row(l.client + ' : ' + t.client, '')}
      {dash}
      {t.lines.map((x, i) => (
        <div key={i} style={{ marginBottom: 3 }}>
          <div style={{ fontWeight: 600 }}>{ar ? x.ar : x.nom}{x.nb ? <span style={{ fontWeight: 400 }}> · {x.nb} {l.nb}</span> : null}</div>
          {row('⁦' + String(x.q).replace('.', ',') + ' × ' + n2(x.pu) + '⁩', n2(x.q * x.pu))}
        </div>
      ))}
      {dash}
      {row(l.sous, n2(sub))}
      {row(l.remise, '−' + n2(t.remise))}
      <div style={{ fontSize: fs + 4, margin: '4px 0' }}>{row(l.total, n2(tot) + ' ' + l.da, true)}</div>
      {row(l.mode, ar ? 'نقدا' : t.mode)}
      {row(l.verse, n2(verse))}
      {credit ? row(l.reste, n2(tot - verse), true) : row(l.rendu, n2(verse - tot))}
      {dash}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '5px 7px', border: '1px solid #111', borderRadius: 4, fontWeight: 700 }}><span>★ {l.pts}</span><bdi>+{t.points}</bdi></div>
      <div style={{ marginTop: 3 }}>{row(l.solde, String(t.solde))}</div>
      {dash}
      <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4 }}>
        <Code128 value={t.no} height={width === 58 ? 34 : 42} width={width === 58 ? 1.2 : 1.5} />
        <bdi style={{ letterSpacing: '.12em' }}>{t.no}</bdi>
        <span style={{ fontSize: fs - 1.5, color: '#555' }}>{l.emp} : <bdi>{t.hash}</bdi></span>
        <span style={{ marginTop: 4, textAlign: 'center' }}>{ar ? shop.ar.message : shop.message}</span>
      </div>
    </div>
  );
}

// Montant en lettres (mention légale des factures algériennes)
const U0 = ['zéro', 'un', 'deux', 'trois', 'quatre', 'cinq', 'six', 'sept', 'huit', 'neuf', 'dix', 'onze', 'douze', 'treize', 'quatorze', 'quinze', 'seize'];
const T0 = ['', '', 'vingt', 'trente', 'quarante', 'cinquante', 'soixante', 'soixante', 'quatre-vingt', 'quatre-vingt'];
function lt100(n) {
  if (n <= 16) return U0[n];
  if (n < 20) return 'dix-' + U0[n - 10];
  const d = Math.floor(n / 10), u = n % 10;
  if (d === 7 || d === 9) return T0[d] + (d === 7 && u === 1 ? ' et ' : '-') + lt100(10 + u);
  if (u === 0) return T0[d] + (d === 8 ? 's' : '');
  return T0[d] + (u === 1 && d !== 8 ? ' et un' : '-' + U0[u]);
}
function lt1000(n) {
  const c = Math.floor(n / 100), r = n % 100;
  const cs = c === 0 ? '' : c === 1 ? 'cent' : U0[c] + ' cent' + (r === 0 ? 's' : '');
  return [cs, r ? lt100(r) : ''].filter(Boolean).join(' ') || 'zéro';
}
export function enLettres(v) {
  const n = Math.floor(v), cts = Math.round((v - n) * 100);
  const m = Math.floor(n / 1e6), k = Math.floor((n % 1e6) / 1000), r = n % 1000;
  const parts = [];
  if (m) parts.push(lt1000(m) + ' million' + (m > 1 ? 's' : ''));
  if (k) parts.push(k === 1 ? 'mille' : lt1000(k).replace(/cents$/, 'cent') + ' mille');
  if (r || !parts.length) parts.push(lt1000(r));
  const s = parts.join(' ') + ' dinars algériens' + (cts ? ' et ' + lt100(cts) + ' centimes' : '');
  return s.charAt(0).toUpperCase() + s.slice(1);
}

export const A4_LINES = [
  ['PRD000002', 'Coca-Cola 1,5 L', 'كوكا كولا 1.5 ل', 'Carton ×24', 2, 2700],
  ['PRD000010', 'Eau minérale Saïda 1,5 L', 'مياه سعيدة 1.5 ل', 'Pack ×6', 12, 330],
  ['PRD000003', 'Huile Elio 1 L', 'زيت إليو 1 ل', 'Carton ×12', 1, 4900],
  ['PRD000005', 'Café moulu 250 g', 'قهوة مطحونة 250 غ', 'Unité', 10, 300],
];
/** Facture A4 (BL / BL_SC) — latin ou arabe, mentions légales, montant en lettres. */
export function FactureA4({ lang = 'fr', scale = 1 }) {
  const ar = lang === 'ar';
  const ht = A4_LINES.reduce((s, l) => s + l[4] * l[5], 0);
  const tva = Math.round(ht * 0.19 * 100) / 100, ttc = ht + tva, verse = 10000;
  const T = ar
    ? { doc: 'فاتورة', no: 'رقم', date: 'التاريخ', client: 'الزبون', code: 'الرمز', des: 'التعيين', colis: 'التعبئة', q: 'الكمية', pu: 'السعر', mt: 'المبلغ', ht: 'المجموع خارج الرسم', tva: 'الرسم على القيمة المضافة 19%', ttc: 'المجموع بكل الرسوم', verse: 'المدفوع', reste: 'المتبقي', arrete: 'أوقفت هذه الفاتورة بمبلغ', sign: 'الختم والإمضاء' }
    : { doc: 'Facture', no: 'N°', date: 'Date', client: 'Client', code: 'Code', des: 'Désignation', colis: 'Colis', q: 'Qté', pu: 'P.U.', mt: 'Montant', ht: 'Total HT', tva: 'TVA 19 %', ttc: 'Total TTC', verse: 'Versé', reste: 'Reste', arrete: 'Arrêtée la présente facture à la somme de', sign: 'Cachet et signature' };
  const th = { padding: '7px 8px', textAlign: 'start', font: '700 10px var(--font-sans)', letterSpacing: '.03em', textTransform: ar ? 'none' : 'uppercase', background: '#f3f0fa', color: '#3b2a72', borderBottom: '1px solid #d9d2ef' };
  const td = { padding: '7px 8px', borderBottom: '1px solid #eee', font: '400 11px var(--font-sans)' };
  const num = { ...td, textAlign: 'end', fontVariantNumeric: 'tabular-nums', direction: 'ltr', unicodeBidi: 'isolate' };
  return (
    <div data-no-ar dir={ar ? 'rtl' : 'ltr'} lang={ar ? 'ar' : 'fr'} style={{ width: 595 * scale, maxWidth: '100%', aspectRatio: '595 / 842', background: '#fff', color: '#1a1530', padding: 36 * scale, boxSizing: 'border-box', boxShadow: '0 10px 30px rgba(20,10,40,.14)', borderRadius: 3, display: 'flex', flexDirection: 'column', gap: 14, fontFamily: ar ? 'var(--font-arabic), Cairo, sans-serif' : 'var(--font-sans)', overflow: 'hidden' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', gap: 16 }}>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 2, fontWeight: 400, fontSize: 10, lineHeight: 1.45 }}>
          <b style={{ fontWeight: 800, fontSize: 16, color: '#3b2a72' }}>{ar ? SHOP.ar.nom : SHOP.nom}</b>
          <span>{ar ? SHOP.ar.adresse : SHOP.adresse}</span>
          <span><bdi>{SHOP.tel}</bdi> · <bdi>{SHOP.email}</bdi></span>
          <span>RC <bdi>{SHOP.rc}</bdi> · NIF <bdi>{SHOP.nif}</bdi></span>
          <span>NIS <bdi>{SHOP.nis}</bdi> · Art. <bdi>{SHOP.art}</bdi></span>
        </div>
        <div style={{ textAlign: 'end', display: 'flex', flexDirection: 'column', gap: 3, alignItems: 'flex-end' }}>
          <b style={{ fontWeight: 800, fontSize: 18, letterSpacing: ar ? 0 : '-.01em' }}>{T.doc}</b>
          <span style={{ fontWeight: 600, fontSize: 11 }}>{T.no} <bdi>PN0000231</bdi> · BL</span>
          <span style={{ fontWeight: 400, fontSize: 10 }}>{T.date} : <bdi>10/10/2026</bdi></span>
          <QRCode value={"PN0000231|BL|" + n2(ttc)} size={54} />
        </div>
      </div>
      <div style={{ padding: '8px 10px', border: '1px solid #e4def5', borderRadius: 6, fontWeight: 400, fontSize: 10.5, lineHeight: 1.5 }}>
        <b>{T.client} :</b> {ar ? 'سوبيرات الأمل' : 'Supérette El Amel'} · <bdi>0770 11 22 33</bdi> · RC <bdi>16/00-7654321 B 19</bdi>
      </div>
      <table style={{ width: '100%', borderCollapse: 'collapse' }}>
        <thead><tr><th style={th}>{T.code}</th><th style={th}>{T.des}</th><th style={th}>{T.colis}</th><th style={{ ...th, textAlign: 'end' }}>{T.q}</th><th style={{ ...th, textAlign: 'end' }}>{T.pu}</th><th style={{ ...th, textAlign: 'end' }}>{T.mt}</th></tr></thead>
        <tbody>{A4_LINES.map((l) => <tr key={l[0]}><td style={{ ...td, fontFamily: 'var(--font-mono)', fontSize: 10 }}><bdi>{l[0]}</bdi></td><td style={td}>{ar ? l[2] : l[1]}</td><td style={td}>{ar ? l[3].replace('Carton', 'كرتون').replace('Pack', 'حزمة').replace('Unité', 'وحدة') : l[3]}</td><td style={num}>{l[4]}</td><td style={num}>{n2(l[5])}</td><td style={num}>{n2(l[4] * l[5])}</td></tr>)}</tbody>
      </table>
      <div style={{ display: 'flex', justifyContent: 'flex-end' }}>
        <div style={{ width: '52%', display: 'flex', flexDirection: 'column', fontWeight: 400, fontSize: 11 }}>
          {[[T.ht, ht], [T.tva, tva], [T.ttc, ttc, 1], [T.verse, verse], [T.reste, ttc - verse, 1]].map(([k, v, b]) => (
            <div key={k} style={{ display: 'flex', justifyContent: 'space-between', padding: '5px 8px', fontWeight: b ? 800 : 400, background: k === T.ttc ? '#f3f0fa' : 'transparent', borderBottom: '1px solid #eee' }}><span>{k}</span><bdi style={{ fontVariantNumeric: 'tabular-nums' }}>{n2(v)} {ar ? 'دج' : 'DA'}</bdi></div>
          ))}
        </div>
      </div>
      <div style={{ fontWeight: 400, fontSize: 10.5, lineHeight: 1.5 }}>{T.arrete} : <b>{ar ? 'عشرون ألفا وخمسمائة وتسعة وثلاثون دينارا جزائريا وأربعون سنتيما' : enLettres(ttc)}</b></div>
      <div style={{ marginTop: 'auto', display: 'flex', justifyContent: 'space-between', alignItems: 'flex-end', fontWeight: 400, fontSize: 9.5, color: '#666' }}>
        <span>CaisseDZ · <bdi>{SHOP.rc}</bdi> · 1/1</span>
        <span style={{ width: 150, height: 54, border: '1px dashed #bbb', borderRadius: 6, display: 'flex', alignItems: 'flex-start', justifyContent: 'center', paddingTop: 4 }}>{T.sign}</span>
      </div>
    </div>
  );
}

/** Aperçu Excel — feuille, en-têtes figés, lignes filtrées, avant enregistrement (V6). */
export function ExcelSheet({ columns, rows, sheet = 'Ventes', filters = 'Période : 10/10/2026 · Statut : tous' }) {
  const letters = 'ABCDEFGHIJ';
  const cell = { padding: '5px 8px', borderInlineEnd: '1px solid #e2e5e9', borderBottom: '1px solid #e2e5e9', font: '400 12px Calibri, Carlito, var(--font-sans)', whiteSpace: 'nowrap', color: '#1f2328', background: '#fff' };
  const hd = { ...cell, background: '#f3f4f6', color: '#5b6270', textAlign: 'center', font: '500 11px var(--font-sans)' };
  return (
    <div data-no-ar style={{ border: '1px solid #d0d5dd', borderRadius: 8, overflow: 'hidden', background: '#fff', direction: 'ltr' }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 8, padding: '6px 10px', background: '#107c41', color: '#fff', font: '600 12px var(--font-sans)' }}>
        <span style={{ width: 18, height: 18, borderRadius: 3, background: '#fff', color: '#107c41', display: 'inline-flex', alignItems: 'center', justifyContent: 'center', font: '800 11px var(--font-sans)' }}>X</span>
        ventes_2026-10-10.xlsx<span style={{ marginInlineStart: 'auto', fontWeight: 400, opacity: 0.85 }}>{filters}</span>
      </div>
      <div style={{ overflowX: 'auto', maxHeight: 300 }}>
        <table style={{ borderCollapse: 'collapse', minWidth: '100%' }}>
          <thead><tr><th style={{ ...hd, width: 34 }} />{columns.map((c, i) => <th key={c.key} style={hd}>{letters[i]}</th>)}</tr></thead>
          <tbody>
            <tr><td style={hd}>1</td>{columns.map((c) => <td key={c.key} style={{ ...cell, fontWeight: 700, background: '#e8f3ec', position: 'sticky', top: 0 }}>{c.label}</td>)}</tr>
            {rows.map((r, i) => <tr key={i}><td style={hd}>{i + 2}</td>{columns.map((c) => <td key={c.key} style={{ ...cell, textAlign: c.num ? 'right' : 'left', fontVariantNumeric: 'tabular-nums' }}>{c.num ? n2(r[c.key]) : r[c.key]}</td>)}</tr>)}
            <tr><td style={hd}>{rows.length + 2}</td>{columns.map((c, i) => <td key={c.key} style={{ ...cell, fontWeight: 700, borderTop: '2px solid #107c41', textAlign: c.num ? 'right' : 'left' }}>{i === 0 ? 'Total' : c.num && c.sum ? n2(rows.reduce((s, r) => s + r[c.key], 0)) : ''}</td>)}</tr>
          </tbody>
        </table>
      </div>
      <div style={{ display: 'flex', gap: 0, borderTop: '1px solid #d0d5dd', background: '#f8f9fa', font: '500 11.5px var(--font-sans)' }}>
        <span style={{ padding: '5px 14px', background: '#fff', color: '#107c41', borderInlineEnd: '1px solid #d0d5dd', borderBottom: '2px solid #107c41' }}>{sheet}</span>
        <span style={{ padding: '5px 14px', color: '#5b6270' }}>Filtres</span>
        <span style={{ marginInlineStart: 'auto', padding: '5px 10px', color: '#5b6270' }}>{rows.length} lignes</span>
      </div>
    </div>
  );
}

const XL_COLS = [{ key: 'code', label: 'N° panier' }, { key: 'date', label: 'Date' }, { key: 'client', label: 'Client' }, { key: 'mode', label: 'Paiement' }, { key: 'montant', label: 'Montant', num: true, sum: true }, { key: 'verse', label: 'Versé', num: true, sum: true }, { key: 'reste', label: 'Reste', num: true, sum: true }];
const XL_ROWS = [['PN0000232', '10/10 11:42', 'Comptoir', 'Espèces', 1520, 1520], ['PN0000231', '10/10 11:30', 'Supérette El Amel', 'Chèque', 18400, 10000], ['PN0000230', '10/10 11:12', 'Comptoir', 'Espèces', 640, 640], ['PN0000227', '10/10 10:02', 'Café Les Pins', 'Virement', 7250, 7250], ['PN0000226', '10/10 09:48', 'Comptoir', 'Espèces', 980, 980], ['PN0000225', '10/10 09:20', 'Hôtel Safir', 'Espèces', 26900, 0], ['PN0000224', '10/10 08:41', 'Comptoir', 'Espèces', 360, 360]]
  .map(([code, date, client, mode, montant, verse]) => ({ code, date, client, mode, montant, verse, reste: montant - verse }));

/** PreviewDialog — aperçu unique avant d'imprimer / enregistrer : ticket, PDF A4, Excel. */
export function PreviewDialog({ kind = 'ticket', onClose, inline }) {
  const { Dialog, Button, SegmentedControl, Badge } = ds();
  const [k, setK] = React.useState(kind);
  const [w, setW] = React.useState(80);
  const [lang, setLang] = React.useState('fr');
  const [credit, setCredit] = React.useState(false);
  const meta = { ticket: ['receipt', 'Aperçu du ticket', 'Imprimer', 'printer'], pdf: ['file-text', 'Aperçu du PDF A4', 'Enregistrer le PDF', 'file-down'], excel: ['file-spreadsheet', 'Aperçu de l’export Excel', 'Enregistrer .xlsx', 'file-down'] }[k];
  return (
    <Dialog inline={inline} open width={inline ? '100%' : 860} icon={meta[0]} title={meta[1]} description={k === 'excel' ? 'Lignes filtrées du module, telles qu’elles seront enregistrées.' : 'Vérifiez la mise en page avant de l’envoyer.'} onClose={onClose}
      footer={<><Button variant="secondary" onClick={onClose}>Fermer</Button>{k !== 'excel' && <Button variant="secondary" icon="share-2">Partager</Button>}<Button icon={meta[3]} onClick={() => new Promise((r) => setTimeout(r, 900))}>{meta[2]}</Button></>}>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
        <div style={{ display: 'flex', flexWrap: 'wrap', gap: 10, alignItems: 'center' }}>
          <SegmentedControl size="sm" value={k} onChange={setK} options={[{ value: 'ticket', label: 'Ticket' }, { value: 'pdf', label: 'PDF A4' }, { value: 'excel', label: 'Excel' }]} />
          {k === 'ticket' && <SegmentedControl size="sm" value={w} onChange={setW} options={[{ value: 58, label: '58 mm' }, { value: 80, label: '80 mm' }]} />}
          {k !== 'excel' && <SegmentedControl size="sm" value={lang} onChange={setLang} options={[{ value: 'fr', label: 'Latin' }, { value: 'ar', label: 'العربية' }]} />}
          {k === 'ticket' && <SegmentedControl size="sm" value={credit ? 'c' : 'p'} onChange={(v) => setCredit(v === 'c')} options={[{ value: 'p', label: 'Payé' }, { value: 'c', label: 'Avec reste' }]} />}
          {k === 'excel' && <Badge tone="info" icon="filter">7 lignes filtrées</Badge>}
        </div>
        <div style={{ display: 'flex', justifyContent: 'center', padding: k === 'excel' ? 0 : 20, borderRadius: 12, background: k === 'excel' ? 'transparent' : 'var(--surface-sunken)', maxHeight: 560, overflow: 'auto' }}>
          {k === 'ticket' && <TicketThermique width={w} lang={lang} credit={credit} />}
          {k === 'pdf' && <FactureA4 lang={lang} />}
          {k === 'excel' && <div style={{ width: '100%', minWidth: 0 }}><ExcelSheet columns={XL_COLS} rows={XL_ROWS} /></div>}
        </div>
      </div>
    </Dialog>
  );
}
