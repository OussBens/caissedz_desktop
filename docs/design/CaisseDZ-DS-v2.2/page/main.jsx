// CaisseDZ Design System v2.2 — page unique : fondations, composants, écrans, nouveautés, plan appliqué, référentiels, conformité
import GRID from './data/grid.json';
import { LISTES, CODES } from './data/ref.js';
import { ds, da, kda, LineChart, RankedBars } from './v22/charts.jsx';
import { ContextMenu, rowMenu, Calculator, CalculatorDialog, Code128, BarcodeCardV22, CodeBarrePickerDialog, CartLineQN, QuantiteNombreDialog, AccessDenied } from './v22/components.jsx';
import { PreviewDialog } from './v22/previews.jsx';
import * as S from './v22/screens.jsx';
import { AR_EXTRA } from './v22/ar-extra.js';

window.CDZ_DemoNotice = S.DemoNotice;
window.CDZ_AR_T = AR_EXTRA;

const LangCtx = React.createContext('fr');
const go = (id) => { const el = document.getElementById(id); if (el) el.scrollIntoView({ behavior: 'smooth', block: 'start' }); };
const bus = { listeners: [], show(a) { this.listeners.forEach((f) => f(a)); } };
/** Ouvre l'endroit où une correction est visible : écran (scr-), nouveauté (n-) ou section. */
const show = (anchor) => bus.show(anchor);

/** Maquette : applique le mode arabe (RTL + traduction) à son seul contenu. */
function Mock({ children, className = '', style }) {
  const lang = React.useContext(LangCtx);
  const ref = React.useRef(null);
  React.useEffect(() => { if (lang !== 'ar' || !window.CDZ_AR) return; return window.CDZ_AR(ref.current); }, [lang]);
  return <div ref={ref} className={'v22-mock ' + className} style={style} dir="ltr">{children}</div>;
}

function Section({ id, kicker, title, lead, children, actions }) {
  return (
    <section id={id} className="v22-section">
      <header className="v22-section-head">
        <div style={{ minWidth: 0 }}>
          <div className="v22-kicker">{kicker}</div>
          <h2>{title}</h2>
          {lead && <p className="v22-lead">{lead}</p>}
        </div>
        {actions && <div className="v22-section-actions">{actions}</div>}
      </header>
      {children}
    </section>
  );
}
const Tag = ({ children, tone = 'new' }) => <span className={'v22-tag v22-tag-' + tone}>{children}</span>;
const Specimen = ({ id, title, tags, children, note, wide }) => (
  <article id={id} className={'v22-specimen' + (wide ? ' v22-wide' : '')}>
    <div className="v22-specimen-head"><h3>{title}</h3><div className="v22-tags">{tags}</div></div>
    {note && <p className="v22-note">{note}</p>}
    <Mock className="v22-specimen-body">{children}</Mock>
  </article>
);

/* ============================================================ Barre de navigation */
const NAV = [['apercu', 'Aperçu'], ['fondations', 'Fondations'], ['composants', 'Composants'], ['ecrans', 'Écrans'], ['nouveautes', 'Flux v2.2'], ['plan', 'Plan appliqué'], ['referentiels', 'Référentiels'], ['conformite', 'Conformité']];
function TopNav({ theme, setTheme, lang, setLang }) {
  const { Logo } = ds();
  const [active, setActive] = React.useState('apercu');
  React.useEffect(() => {
    const io = new IntersectionObserver((es) => es.forEach((e) => e.isIntersecting && setActive(e.target.id)), { rootMargin: '-45% 0px -50% 0px' });
    NAV.forEach(([id]) => { const el = document.getElementById(id); if (el) io.observe(el); });
    return () => io.disconnect();
  }, []);
  return (
    <header className="v22-top">
      <div className="v22-top-in">
        <a href="#apercu" className="v22-brand" onClick={(e) => { e.preventDefault(); go('apercu'); }}><Logo size={26} glyphSrc={window.CDZ.G} /><span className="v22-ver">DS v2.2</span></a>
        <nav className="v22-nav" aria-label="Sections">
          {NAV.map(([id, l]) => <a key={id} href={'#' + id} className={active === id ? 'on' : ''} onClick={(e) => { e.preventDefault(); go(id); }}>{l}</a>)}
        </nav>
        <div className="v22-switches">
          <div className="v22-seg" role="group" aria-label="Langue des maquettes">
            <button className={lang === 'fr' ? 'on' : ''} onClick={() => setLang('fr')}>FR</button>
            <button className={lang === 'ar' ? 'on' : ''} onClick={() => setLang('ar')} lang="ar">عربي</button>
          </div>
          <div className="v22-seg" role="group" aria-label="Thème">
            {[['system', 'Auto'], ['light', 'Clair'], ['dark', 'Sombre']].map(([k, l]) => <button key={k} className={theme === k ? 'on' : ''} onClick={() => setTheme(k)}>{l}</button>)}
          </div>
        </div>
      </div>
    </header>
  );
}

/* ============================================================ Aperçu */
function Hero() {
  const decisions = GRID.rows.filter((r) => r.mode === 'decision').length;
  const fixed = GRID.rows.filter((r) => r.v21 !== 'C').length;
  return (
    <section id="apercu" className="v22-hero">
      <div className="v22-hero-text">
        <div className="v22-kicker">CaisseDZ · design system · octobre 2026</div>
        <h1>Design System v2.2</h1>
        <p className="v22-lead">La v2.1 couvrait 83,6 % de la spécification 06. Cette version applique les cinq phases du plan d’action : composants manquants, écrans et flux, harmonisation des listes et des codes, re-notation de la grille. Tout tient sur cette page — tokens, composants, les 17 modules dans leur shell, en français ou en arabe, clair ou sombre.</p>
        <div className="v22-hero-links">
          <button className="v22-btn" onClick={() => go('ecrans')}>Parcourir les écrans</button>
          <button className="v22-btn ghost" onClick={() => go('conformite')}>Voir la grille re-notée</button>
        </div>
      </div>
      <dl className="v22-hero-stats">
        <div className="big"><dt>Cohérence pondérée</dt><dd><s>{String(GRID.v21).replace('.', ',')} %</s> {String(GRID.v22).replace('.', ',')} %</dd><span>{GRID.n} exigences · poids {GRID.poids}</span></div>
        <div><dt>Écarts corrigés</dt><dd>{fixed}</dd><span>{GRID.counts.A} absents · {GRID.counts.P} partiels · {GRID.counts.D} divergents</span></div>
        <div><dt>Arbitrages</dt><dd>19</dd><span>dont {decisions} par acceptation du design</span></div>
        <div><dt>Ajouts v2.2</dt><dd>{ITEMS.length + 6}</dd><span>composants, flux et états</span></div>
      </dl>
    </section>
  );
}

/* ============================================================ Fondations */
const SWATCHES = [
  ['Surfaces', ['surface-app', 'surface-card', 'surface-raised', 'surface-sunken', 'surface-sidebar', 'surface-inverse']],
  ['Texte et bordures', ['text-primary', 'text-secondary', 'text-muted', 'text-link', 'border-subtle', 'border-default', 'border-strong', 'border-focus']],
  ['Marque', ['primary', 'primary-hover', 'primary-tint', 'accent', 'accent-tint', 'brand']],
  ['Statuts', ['success', 'success-tint', 'warning', 'warning-tint', 'danger', 'danger-tint', 'info', 'info-tint']],
  ['Graphiques', ['chart-1', 'chart-2', 'chart-3', 'chart-4', 'chart-5', 'chart-6']],
];
const RAMPS = [['violet', [25, 50, 100, 200, 300, 400, 500, 600, 700, 800, 900]], ['ink', [600, 700, 750, 800, 850, 900, 950]], ['n', [0, 25, 50, 100, 200, 300, 400, 500, 600, 700, 800]], ['teal', [50, 100, 300, 500, 600, 700]]];
const TYPE = [['display', 'Caisse DZ, la caisse qui pense'], ['page-title', 'Tableau de bord'], ['heading', 'Ventes de la période'], ['card-title', 'Modes de paiement'], ['kpi', '1 054 600,00'], ['body', 'Le ticket encaissé n’est plus modifiable.'], ['label', 'Prix de vente'], ['caption', 'Dernière synchro 10/10 11:40'], ['overline', 'COMPLÉMENTS V2.2']];
function useTokenValues(names, theme) {
  const [v, setV] = React.useState({});
  React.useEffect(() => {
    const t = setTimeout(() => { const cs = getComputedStyle(document.documentElement); setV(Object.fromEntries(names.map((n) => [n, cs.getPropertyValue('--' + n).trim()]))); }, 30);
    return () => clearTimeout(t);
  }, [theme]);
  return v;
}
function Foundations({ theme }) {
  const { Icon } = ds();
  const all = SWATCHES.flatMap((g) => g[1]);
  const vals = useTokenValues(all, theme);
  return (
    <Section id="fondations" kicker="01 · Fondations" title="Tokens, typographie, effets" lead="Les composants n’utilisent que les alias sémantiques ; chaque alias a une valeur claire et une valeur sombre. Les valeurs ci-dessous suivent le thème choisi en haut de page.">
      <div className="v22-swatch-groups">
        {SWATCHES.map(([g, list]) => (
          <div key={g} className="v22-swatch-group">
            <h3>{g}</h3>
            <div className="v22-swatches">
              {list.map((n) => <div key={n} className="v22-swatch"><span style={{ background: `var(--${n})` }} /><code>--{n}</code><small>{vals[n] || ''}</small></div>)}
            </div>
          </div>
        ))}
      </div>
      <div className="v22-ramps">
        {RAMPS.map(([r, steps]) => (
          <div key={r} className="v22-ramp"><code>{r}</code><div>{steps.map((s) => <span key={s} title={`--${r}-${s}`} style={{ background: `var(--${r}-${s})` }}><i>{s}</i></span>)}</div></div>
        ))}
      </div>
      <div className="v22-two">
        <div className="v22-panel">
          <h3>Échelle typographique</h3>
          <div className="v22-type">
            {TYPE.map(([k, t]) => <div key={k}><code>--type-{k}</code><span style={{ font: `var(--type-${k})`, letterSpacing: k === 'overline' ? 'var(--tracking-caps)' : undefined, color: 'var(--text-primary)', fontVariantNumeric: k === 'kpi' ? 'tabular-nums' : undefined }}>{t}</span></div>)}
          </div>
          <div className="v22-arabic" lang="ar" dir="rtl"><code dir="ltr">Cairo · [dir=rtl]</code><span>الصندوق · المبيعات · <bdi>1 054 600,00</bdi> دج</span></div>
        </div>
        <div className="v22-panel">
          <h3>Rayons, ombres, espacements, mouvement</h3>
          <div className="v22-fx">
            {['xs', 'sm', 'md', 'lg', 'xl', '2xl'].map((r) => <div key={r}><span style={{ borderRadius: `var(--radius-${r})` }} /><code>radius-{r}</code></div>)}
          </div>
          <div className="v22-fx">
            {['xs', 'sm', 'md', 'lg'].map((r) => <div key={r}><span style={{ boxShadow: `var(--shadow-${r})`, borderRadius: 10 }} /><code>shadow-{r}</code></div>)}
          </div>
          <div className="v22-space">{[1, 2, 3, 4, 5, 6, 8, 10, 12, 16].map((s) => <div key={s}><span style={{ width: `var(--space-${s})` }} /><code>space-{s}</code></div>)}</div>
          <p className="v22-note">Durées : <code>dur-instant</code> · <code>dur-fast</code> · <code>dur-base</code> · <code>dur-slow</code> · <code>dur-slower</code>, courbes <code>ease-standard</code> / <code>ease-emphasized</code> ; respect de <code>prefers-reduced-motion</code>.</p>
          <h3 style={{ marginTop: 16 }}>Icônes Lucide</h3>
          <div className="v22-icons">{['monitor-smartphone', 'receipt-text', 'undo-2', 'package', 'boxes', 'scan-line', 'package-minus', 'store', 'triangle-alert', 'users', 'truck', 'wallet', 'user-cog', 'hand-coins', 'history', 'settings', 'sparkles', 'barcode', 'calculator', 'printer', 'hash', 'star', 'shield-x', 'cloud'].map((n) => <span key={n} title={n}><Icon name={n} size={20} /></span>)}</div>
        </div>
      </div>
    </Section>
  );
}

/* ============================================================ Composants */
function GuardDemo() {
  const { Button } = ds();
  const [n, setN] = React.useState(0);
  return (
    <div className="v22-row">
      <Button icon="check" onClick={() => new Promise((r) => setTimeout(() => { setN((x) => x + 1); r(); }, 1200))}>Encaisser (async)</Button>
      <span className="v22-note" style={{ margin: 0 }}>Encaissements enregistrés : <b>{n}</b> — double-cliquez : un seul passe.</span>
    </div>
  );
}
function TableMenuDemo() {
  const { DataTable, StatusBadge } = ds();
  const [m, setM] = React.useState(null);
  const [last, setLast] = React.useState('');
  const rows = [{ id: 'PN0000232', client: 'Comptoir', total: 1520, statut: 'paye' }, { id: 'PN0000231', client: 'Supérette El Amel', total: 18400, statut: 'credit' }, { id: 'PN0000228', client: 'Comptoir', total: 420, statut: 'annule' }];
  return (<>
    <DataTable dense rows={rows} onRowContextMenu={(r, e) => setM({ x: e.clientX, y: e.clientY, r })} columns={[{ key: 'id', label: 'N° panier', muted: true }, { key: 'client', label: 'Client', strong: true }, { key: 'total', label: 'Montant', align: 'right', render: (v) => da(v) }, { key: 'statut', label: 'Statut', render: (v) => <StatusBadge status={v} /> }]} />
    <p className="v22-note">Clic droit sur une ligne{last ? ' · dernière action : ' + last : ''}.</p>
    {m && <ContextMenu x={m.x} y={m.y} title={m.r.id} items={rowMenu(m.r).map((it) => (it.divider ? it : { ...it, onClick: () => setLast(it.label + ' ' + m.r.id) }))} onClose={() => setM(null)} />}
  </>);
}
function Components() {
  const D = ds();
  const { Button, IconButton, TextField, Select, Switch, Checkbox, SegmentedControl, ChoiceCards, KeyInput, StatCard, Badge, StatusBadge, ProgressBar, BarChart, DonutChart, CartLineHeader, CartLine, Numpad, TotalPanel, LicenseGate, EmptyState, Toast, DateField } = D;
  const [key, setKey] = React.useState('9F2C71A0E4B35D18C2A94B0E77F31D6A');
  const [np, setNp] = React.useState('1500');
  const [qn, setQn] = React.useState({ q: 2, nb: '3' });
  return (
    <Section id="composants" kicker="02 · Composants" title="Bibliothèque" lead="Les 66 composants de la v2.1, avec les ajouts et corrections de la phase 1 signalés « v2.2 ».">
      <div className="v22-specimens">
        <Specimen id="cmp-actions" title="Actions" tags={<Tag>B21 · garde anti double-clic</Tag>} note="Button ignore un second clic en moins de 450 ms ; un onClick qui renvoie une promesse affiche le chargement tout seul.">
          <div className="v22-row">{['primary', 'secondary', 'soft', 'accent', 'ghost', 'danger'].map((v) => <Button key={v} variant={v} size="sm">{v}</Button>)}</div>
          <div className="v22-row"><Button icon="printer" kbd="F6">Encaisser</Button><Button variant="secondary" icon="save" kbd="F5">Enregistrer</Button><IconButton icon="settings" title="Réglages" /><IconButton icon="bell" badge={9} title="Alertes" /></div>
          <GuardDemo />
        </Specimen>
        <Specimen id="cmp-forms" title="Formulaires" tags={<Tag tone="fix">C1b · clé 8 × 8</Tag>}>
          <div className="v22-form-grid">
            <TextField label="Prix de vente" numeric suffix="DA" defaultValue="1 450,00" />
            <Select label="Mode de paiement" options={['Espèces', 'Carte CIB', 'Chèque', 'Virement', 'Points fidélité']} defaultValue="Espèces" />
            <DateField defaultValue="2026-10-10" />
            <SegmentedControl options={['Montant', 'Pourcentage']} defaultValue="Pourcentage" />
          </div>
          <div className="v22-row"><Switch defaultChecked label="Bonus fidélité" /><Checkbox defaultChecked label="Imprimer le ticket" /></div>
          <ChoiceCards size="sm" columns={2} defaultValue="physique" options={[{ value: 'physique', label: 'Physique', icon: 'wallet', description: 'Tiroir-caisse' }, { value: 'compte', label: 'Compte', icon: 'landmark', description: 'Banque, CCP' }]} />
          <div style={{ overflowX: 'auto' }}><div style={{ minWidth: 620 }}><KeyInput groups={8} size={8} value={key} onChange={setKey} /></div></div>
        </Specimen>
        <Specimen id="cmp-data" title="Données et statuts" tags={<Tag tone="fix">N4 · statuts besoins</Tag>}>
          <div className="v22-form-grid"><StatCard icon="banknote" title="Ventes" value={782900} suffix="DA" trend={12.4} /><StatCard icon="truck" title="Dette fournisseurs" value={128600} suffix="DA" trend={-6.3} trendInvert /></div>
          <div className="v22-row">{['paye', 'credit', 'annule', 'retourne', 'enAttente', 'commande', 'disponible'].map((s) => <StatusBadge key={s} status={s} />)}</div>
          <div className="v22-row">{['neutral', 'primary', 'accent', 'success', 'warning', 'danger', 'info'].map((t) => <Badge key={t} tone={t}>{t}</Badge>)}</div>
          <ProgressBar value={42} max={60} showLabel />
        </Specimen>
        <Specimen id="cmp-menu" title="Tableau : menu contextuel" tags={<Tag>B8b</Tag>} note="Prop onRowContextMenu du DataTable + ContextMenu (mêmes actions que la barre du module).">
          <TableMenuDemo />
        </Specimen>
        <Specimen id="cmp-charts" title="Graphiques" tags={<Tag>B18 · LineChart, RankedBars</Tag>} wide>
          <div className="v22-chart-grid">
            <div><h4>LineChart</h4><LineChart labels={['04/10', '05/10', '06/10', '07/10', '08/10', '09/10', '10/10']} series={[{ name: 'Semaine', values: [64200, 81500, 118400, 52800, 97300, 70100, 104600] }, { name: 'Semaine précédente', values: [59000, 72400, 98100, 57600, 83900, 66500, 89700], dashed: true, color: 'var(--text-muted)' }]} height={200} /></div>
            <div><h4>RankedBars</h4><RankedBars formatValue={(v) => kda(v) + ' DA'} data={[{ label: 'Yacine Benali', value: 389400 }, { label: 'Amina Kaci', value: 276100 }, { label: 'Riad Ouali', value: 117700 }]} /></div>
            <div><h4>BarChart</h4><BarChart height={170} highlight={2} data={[{ label: 'Dim', value: 64200 }, { label: 'Lun', value: 81500 }, { label: 'Mar', value: 118400 }, { label: 'Mer', value: 52800 }, { label: 'Jeu', value: 97300 }]} formatValue={kda} /></div>
            <div><h4>DonutChart</h4><div style={{ display: 'flex', justifyContent: 'center' }}><DonutChart size={160} centerLabel="Total" centerValue="783 k" data={[{ label: 'Espèces', value: 498300 }, { label: 'Carte CIB', value: 186900 }, { label: 'Chèque', value: 58400 }, { label: 'Virement', value: 31200 }, { label: 'Points', value: 8400 }]} /></div></div>
          </div>
        </Specimen>
        <Specimen id="cmp-pos" title="Caisse" tags={<><Tag>F5 · CartLineQN</Tag><Tag>B16b · Calculator</Tag></>} wide>
          <div className="v22-pos-grid">
            <div style={{ minWidth: 0, display: 'flex', flexDirection: 'column', gap: 10 }}>
              <div style={{ border: '1px solid var(--border-default)', borderRadius: 12, overflow: 'hidden', overflowX: 'auto' }}><div style={{ minWidth: 520 }}>
                <CartLineHeader />
                <CartLine name="Huile Elio 1 L" code="PRD000003" price={420} qty={2} pack="Unité" pieces={2} />
                <CartLine name="Coca-Cola 1,5 L" code="PRD000002" price={2700} qty={1} pack="Carton ×24" pieces={24} unitLabel="carton" />
                <CartLineQN name="Viande hachée (barquette)" code="PRD000014" price={1450} qty={qn.q} nombre={qn.nb} nombreUnit="barq." onInc={() => setQn({ ...qn, q: qn.q + 1 })} onDec={() => setQn({ ...qn, q: Math.max(1, qn.q - 1) })} onNombre={(v) => setQn({ ...qn, nb: v })} />
              </div></div>
              <TotalPanel total={6440 + qn.q * 1450 - 50} subtotal={6440 + qn.q * 1450} discount={50} items={3} />
            </div>
            <div style={{ minWidth: 0 }}><h4>Numpad</h4><Numpad value={np} onChange={setNp} quickAmounts={[500, 1000, 2000]} /></div>
            <div style={{ minWidth: 0 }}><h4>Calculator</h4><Calculator /></div>
          </div>
        </Specimen>
        <Specimen id="cmp-codes" title="Codes-barres" tags={<Tag>I7 · QR, code auto</Tag>}>
          <BarcodeCardV22 />
          <div style={{ background: '#fff', padding: 10, borderRadius: 8, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4, color: '#111' }}><Code128 value="PN0000233" height={36} /><code style={{ fontSize: 11 }}>CODE128 · PN0000233 (ticket)</code></div>
        </Specimen>
        <Specimen id="cmp-states" title="États : licence, accès, vide" tags={<Tag>E6 · accès refusé</Tag>}>
          <LicenseGate compact kind="licence" description="Plusieurs magasins et transferts." actionLabel="Passer au palier Avancé" onAction={() => {}} />
          <AccessDenied compact module="Gestion caisse" />
          <EmptyState size="sm" icon="inbox" title="Aucune sortie" description="Aucune sortie sur la période." />
          <Toast title="Export prêt" description="ventes_2026-10-10.xlsx · aperçu vérifié" />
        </Specimen>
      </div>
    </Section>
  );
}

/* ============================================================ Écrans */
const ROUTES = [
  ['Général', [['dashboard', 'Tableau de bord'], ['situation', 'Situation'], ['caisse', 'Caisse'], ['ventes', 'Ventes'], ['retours', 'Retours']]],
  ['Stock', [['produits', 'Produits'], ['stock', 'Stock'], ['entrees', 'Entrées'], ['sorties', 'Sorties'], ['magasins', 'Magasins'], ['besoins', 'Besoins']]],
  ['Tiers', [['clients', 'Clients'], ['fournisseurs', 'Fournisseurs']]],
  ['Gestion', [['gestion-caisse', 'Gestion caisse'], ['utilisateurs', 'Utilisateurs'], ['zakat', 'Zakat'], ['historique', 'Historique'], ['parametres', 'Paramètres']]],
  ['Démarrage', [['login', 'Connexion'], ['activation', 'Activation'], ['demo', 'Mode démo']]],
];
const SCREEN = { caisse: 'CaisseScreen', ventes: 'PaniersScreen', retours: 'RetoursScreen', produits: 'ProduitsScreen', stock: 'StockScreen', entrees: 'EntreesScreen', sorties: 'SortiesScreen', magasins: 'MagasinsScreen', besoins: 'BesoinsScreen', clients: 'ClientsScreen', fournisseurs: 'FournisseursTemplateScreen', 'gestion-caisse': 'GestionCaisseScreen', utilisateurs: 'UtilisateursScreen', zakat: 'ZakatScreen', historique: 'HistoriqueScreen', parametres: 'ParametresScreen', situation: 'SituationScreen' };
const ADDON = {
  produits: ['Nouveau produit : mode IA et mode détaillé, synchro du catalogue', [['Mode IA', 'sparkles', 'ia'], ['Mode détaillé', 'package-plus', 'produit']], () => <S.CatalogueSyncCard />],
  stock: ['2ᵉ stock « nombre »', [], () => <S.NombreShowcase />],
  sorties: ['Onglet Ventes', [], () => <S.SortiesVentesTab />],
  ventes: ['Aperçus et état « période clôturée »', [['Aperçu ticket', 'receipt', 'ticket'], ['Aperçu PDF A4', 'file-text', 'pdf'], ['Aperçu Excel', 'file-spreadsheet', 'excel'], ['Annuler PN0000212', 'ban', 'cloture']]],
  clients: ['Versements par document', [['Nouveau versement', 'hand-coins', 'versement'], ['Versement lié à un retour', 'lock', 'verrou']]],
  entrees: ['Smart Scan IA', [['Quota atteint', 'sparkles', 'quota'], ['Code-barres', 'barcode', 'codebarre']]],
  utilisateurs: ['Effets des permissions', [], () => <S.PermissionsDemo />],
  parametres: ['Paramètres ajoutés', [['Configuration initiale', 'settings-2', 'setup']], () => <S.ParametresV22 />],
};
const DIALOGS = {
  ia: S.ProduitIADialog, produit: S.ProduitDetailleDialog, ticket: (p) => <PreviewDialog kind="ticket" {...p} />, pdf: (p) => <PreviewDialog kind="pdf" {...p} />, excel: (p) => <PreviewDialog kind="excel" {...p} />,
  cloture: S.AnnulationClotureDialog, versement: S.VersementImputationDialog, verrou: S.VersementVerrouilleDialog, quota: S.QuotaIADialog, codebarre: CodeBarrePickerDialog, setup: S.InitialSetupMargeDialog,
  raccourcis: S.ShortcutsDialog, reserve: S.StockReserveDialog, points: S.PointsGagnesResult, qn: QuantiteNombreDialog, calc: CalculatorDialog, identifiant: S.ChangerIdentifiantDialog,
};
function Addon({ route, open }) {
  const { Button, Icon } = ds();
  const a = ADDON[route]; if (!a) return null;
  return (
    <div className="v22-addon">
      <div className="v22-addon-head"><span className="v22-tag v22-tag-new">v2.2</span><b>{a[0]}</b><div className="v22-row" style={{ marginInlineStart: 'auto' }}>{a[1].map(([l, ic, k]) => <Button key={k} size="sm" variant="secondary" icon={ic} onClick={() => open(k)}>{l}</Button>)}</div></div>
      {a[2] && a[2]()}
    </div>
  );
}
function Screens() {
  const { Select, Button, SegmentedControl } = ds();
  const [route, setRoute] = React.useState('dashboard');
  const [dlg, setDlg] = React.useState(null);
  const frame = React.useRef(null);
  React.useEffect(() => {
    window.CDZ_NAV = (r) => { setRoute(r); setDlg(null); };
    const f = (a) => { if (a.startsWith('scr-')) { setRoute(a.slice(4)); setDlg(null); go('ecrans'); } };
    bus.listeners.push(f);
    return () => { bus.listeners = bus.listeners.filter((x) => x !== f); };
  }, []);
  React.useEffect(() => { if (frame.current) frame.current.scrollTop = 0; }, [route]);
  React.useEffect(() => {
    if (route !== 'caisse') return;
    const h = (e) => { const t = e.target.tagName; if ((e.key === '?' || e.key === 'F1') && t !== 'INPUT' && t !== 'TEXTAREA') { e.preventDefault(); setDlg('raccourcis'); } };
    window.addEventListener('keydown', h); return () => window.removeEventListener('keydown', h);
  }, [route]);
  const W = window;
  const nav = (r) => { setRoute(r); setDlg(null); };
  let body;
  if (route === 'login') body = <W.LoginScreen onLogin={() => nav('dashboard')} />;
  else if (route === 'activation') body = <W.ActivationScreen onActivated={() => nav('login')} onBack={() => nav('login')} />;
  else {
    const C = route === 'dashboard' || route === 'demo' ? S.DashboardV22 : W[SCREEN[route]];
    body = (
      <W.AppShell route={route === 'demo' ? 'dashboard' : route} onNavigate={nav} onLogout={() => nav('login')} user={route === 'demo' ? 'Démo' : 'Yacine Benali'}>
        {route === 'demo' && <S.DemoBanner />}
        {C ? <C onNavigate={nav} /> : <W.Placeholder route={route} />}
        <Addon route={route} open={setDlg} />
      </W.AppShell>
    );
  }
  const D = dlg && DIALOGS[dlg];
  const opts = ROUTES.flatMap(([g, l]) => l.map(([v, t]) => ({ value: v, label: g + ' · ' + t })));
  return (
    <Section id="ecrans" kicker="03 · Écrans" title="Les 17 modules dans leur shell" lead="Naviguez avec la barre latérale de l’application ou le sélecteur. Les compléments v2.2 apparaissent sous l’écran concerné ; la langue et le thème se règlent en haut de page.">
      <div className="v22-toolbar">
        <div style={{ width: 280, maxWidth: '100%' }}><Select options={opts} value={route} onChange={nav} icon="layout-grid" /></div>
        {route === 'caisse' && <div className="v22-row">
          <Button size="sm" variant="secondary" icon="keyboard" kbd="?" onClick={() => setDlg('raccourcis')}>Raccourcis</Button>
          <Button size="sm" variant="secondary" icon="hash" onClick={() => setDlg('qn')}>Quantité + nombre</Button>
          <Button size="sm" variant="secondary" icon="lock" onClick={() => setDlg('reserve')}>Stock réservé</Button>
          <Button size="sm" variant="secondary" icon="star" onClick={() => setDlg('points')}>Points gagnés</Button>
          <Button size="sm" variant="secondary" icon="calculator" onClick={() => setDlg('calc')}>Calculatrice</Button>
          <Button size="sm" variant="secondary" icon="receipt" onClick={() => setDlg('ticket')}>Aperçu ticket</Button>
        </div>}
      </div>
      <div className="v22-frame-scroll">
        <Mock className="v22-frame"><div ref={frame} className="v22-frame-in">{body}{D && <D onClose={() => setDlg(null)} />}</div></Mock>
      </div>
    </Section>
  );
}

/* ============================================================ Flux v2.2 (catalogue des ajouts) */
const ITEMS = [
  ['n-ia', 'Nouveau produit — mode IA', 'Phase 2', 'I4', () => <S.ProduitIADialog inline />],
  ['n-produit', 'Nouveau produit — mode détaillé', 'Phase 2', 'I3', () => <S.ProduitDetailleDialog inline />],
  ['n-sync', 'Synchro du catalogue partagé', 'Phase 2', 'I5', () => <S.CatalogueSyncCard />],
  ['n-nombre', '2ᵉ stock « nombre » dans chaque flux', 'Phase 2', 'F5 · J5', () => <S.NombreShowcase />],
  ['n-qn', 'Quantité, colis et nombre', 'Phase 1', 'F5', () => <QuantiteNombreDialog inline />],
  ['n-apercu', 'Aperçus : ticket, PDF A4, Excel', 'Phase 1-2', 'B19 · V1 · V2 · V6', () => <PreviewDialog inline />],
  ['n-versement', 'Versement imputé aux documents', 'Phase 3', 'O4', () => <S.VersementImputationDialog inline />],
  ['n-verrou', 'Versement lié à un retour', 'Phase 2', 'O6', () => <S.VersementVerrouilleDialog inline />],
  ['n-cloture', 'Annulation en période clôturée', 'Phase 2', 'G5', () => <S.AnnulationClotureDialog inline />],
  ['n-reserve', 'Stock réservé par un autre panier', 'Phase 2', 'F16', () => <S.StockReserveDialog inline />],
  ['n-quota', 'Quota IA atteint, demande d’offre', 'Phase 2', 'K4', () => <S.QuotaIADialog inline />],
  ['n-raccourcis', 'Aide des raccourcis de caisse', 'Phase 2', 'F7', () => <S.ShortcutsDialog inline />],
  ['n-points', 'Points gagnés à l’encaissement', 'Phase 2', 'F13', () => <S.PointsGagnesResult inline />],
  ['n-permissions', 'Permissions : colonnes masquées, accès refusé', 'Phase 1-2', 'E3 · E6', () => <S.PermissionsDemo />],
  ['n-identifiant', 'Mon compte : changer d’identifiant', 'Phase 2', 'D5', () => <S.ChangerIdentifiantDialog inline />],
  ['n-setup', 'Configuration initiale : étape Marge', 'Phase 2', 'C4', () => <S.InitialSetupMargeDialog inline />],
  ['n-codebarre', 'Sélection d’un code-barres', 'Phase 1', 'B13b', () => <CodeBarrePickerDialog inline />],
  ['n-calc', 'Calculatrice', 'Phase 1', 'B16b', () => <CalculatorDialog inline />],
];
function Flows() {
  const [cur, setCur] = React.useState('n-ia');
  React.useEffect(() => {
    const f = (a) => { if (a.startsWith('n-')) { setCur(a); go('nouveautes'); } };
    bus.listeners.push(f); return () => { bus.listeners = bus.listeners.filter((x) => x !== f); };
  }, []);
  const it = ITEMS.find((x) => x[0] === cur);
  return (
    <Section id="nouveautes" kicker="04 · Flux v2.2" title="Écrans, dialogs et états ajoutés" lead="Chaque ajout est rendu en place, interactif, avec l’identifiant de l’exigence qu’il couvre.">
      <div className="v22-flows">
        <ul className="v22-flow-list" role="listbox" aria-label="Ajouts v2.2">
          {ITEMS.map(([id, l, ph, req]) => (
            <li key={id}><button role="option" aria-selected={cur === id} className={cur === id ? 'on' : ''} onClick={() => setCur(id)}><span>{l}</span><small>{ph} · {req}</small></button></li>
          ))}
        </ul>
        <div className="v22-flow-stage">
          <div className="v22-flow-head"><b>{it[1]}</b><span className="v22-tag v22-tag-new">{it[3]}</span></div>
          <Mock className="v22-flow-body" key={cur}>{it[4]()}</Mock>
        </div>
      </div>
    </Section>
  );
}

/* ============================================================ Plan appliqué */
const PHASES = [
  ['Phase 0', 'Arbitrages', '19 divergences tranchées selon la recommandation (tableau ci-dessous) ; extensions du design gardées ou reportées comme proposé.', [['Décisions reportées dans la grille et les référentiels', 'referentiels']]],
  ['Phase 1', 'Composants manquants', 'Publiés avec aperçu clair, sombre et RTL.', [['LineChart, RankedBars', 'cmp-charts'], ['Menu contextuel du DataTable', 'cmp-menu'], ['Garde anti double-clic du Button', 'cmp-actions'], ['Aperçus ticket 58 / 80 mm FR / AR, PDF A4, Excel', 'n-apercu'], ['Calculatrice', 'n-calc'], ['Sélection « code-barres »', 'n-codebarre'], ['Quantité + nombre (CartLine, LineItemsEditor, dialog)', 'n-qn'], ['Accès refusé, colonnes masquables', 'n-permissions'], ['QR et code auto dans BarcodeCard', 'cmp-codes']]],
  ['Phase 2', 'Écrans et flux', 'Chaque flux du §9 se parcourt dans les maquettes.', [['2ᵉ stock « nombre » partout', 'n-nombre'], ['Nouveau produit en mode IA, synchro catalogue', 'n-ia'], ['Formulaire produit détaillé', 'n-produit'], ['Tableau de bord : 6 KPI, 5 graphiques', 'scr-dashboard'], ['Paramètres : marge, fidélité, zakat, RC, e-mail, imprimante, seuils', 'scr-parametres'], ['Étape Marge de la configuration initiale', 'n-setup'], ['voirPrixAchat dans la grille des rôles', 'n-permissions'], ['Mode démo, changement d’identifiant', 'scr-demo'], ['États : période clôturée, versement verrouillé, stock réservé, quota IA', 'n-reserve'], ['Raccourcis et points gagnés', 'n-raccourcis'], ['Ticket thermique et facture A4, latin et arabe', 'n-apercu'], ['Onglet Ventes des sorties', 'scr-sorties']]],
  ['Phase 3', 'Harmonisation', 'Zéro divergence ouverte dans les maquettes.', [['Versements imputés aux documents', 'n-versement'], ['Caisse sans magasin, types Physique / Compte, export JSON', 'scr-gestion-caisse'], ['Magasin principal par utilisateur', 'scr-magasins'], ['Référentiel unique des listes FR / AR / EN', 'referentiels'], ['Codification §8.10, « Date d’expiration »', 'codification']]],
  ['Phase 4', 'Recette', 'Grille re-notée, parcours croisés FR / AR, clair / sombre ; v2.2 prête à être gelée puis traduite en ThemeExtension Flutter.', [['Grille re-notée : 100 %', 'conformite']]],
];
const DECISIONS = [
  ['O4', 'Versements', 'Imputation sur les documents ouverts, plus ancien d’abord, modifiable', 'n-versement'], ['W2', 'Listes de valeurs', 'Référentiel unique ; le crédit est un reste, pas un mode (Crédit, Edahabia retirés)', 'referentiels'],
  ['M4', 'Caisse et magasin', 'Champ Magasin retiré de la caisse', 'scr-gestion-caisse'], ['M5', 'Magasin principal', 'Drapeau global retiré', 'scr-magasins'],
  ['K7', 'Destination des entrées', 'Principal par défaut, répartition en option', 'scr-entrees'], ['T12', 'Garde de stock', 'Option retirée : garde toujours active', 'scr-parametres'],
  ['H5', 'Retour client', 'Accepté : retour défectueux suivi d’une sortie « Casse »', 'scr-retours'], ['E5', 'Paramètres et Historique', 'Texte aligné : attribuables par rôle', 'scr-utilisateurs'],
  ['E1b', 'Smart Scan IA', 'Indépendant du palier, selon quota serveur', 'scr-activation'], ['T3', 'Seuil de rupture', 'Accepté par produit, seuils globaux par défaut', 'scr-parametres'],
  ['L2', 'Types de sortie', 'Liste du design acceptée (Expiration → Périmé)', 'referentiels'], ['N4', 'Statuts des besoins', 'En attente / Commande / Disponible', 'scr-besoins'],
  ['Q1b', 'Types de caisse', 'Physique / Compte ; « Coffre » devient un nom', 'scr-gestion-caisse'], ['Q4', 'Export fiscal', 'JSON vérifiable ajouté à l’archive', 'scr-gestion-caisse'],
  ['W3', 'Codification', 'Préfixes §8.10 sur toutes les données', 'codification'], ['W4', 'Libellé produit', '« Date d’expiration »', 'scr-produits'],
  ['C1b', 'Clé de licence', 'SHA-256, 64 caractères en 8 × 8', 'scr-activation'], ['C3b', 'Mot de passe oublié', '« Voyez l’administrateur »', 'scr-login'],
  ['D2', 'Catégories du menu', 'Accepté : Général, Stock, Tiers, Gestion', 'scr-dashboard'],
];
const Where = ({ a, children }) => <button className="v22-link" onClick={() => (a.startsWith('scr-') || a.startsWith('n-') ? show(a) : go(a))}>{children || 'Voir'}</button>;
function Plan() {
  return (
    <Section id="plan" kicker="05 · Plan appliqué" title="Les cinq phases, faites" lead="Chaque tâche du plan renvoie à l’endroit de la page où elle se vérifie.">
      <ol className="v22-phases">
        {PHASES.map(([p, t, d, tasks]) => (
          <li key={p} className="v22-phase">
            <div className="v22-phase-head"><span className="v22-phase-no">{p}</span><h3>{t}</h3><span className="v22-done">Appliquée</span></div>
            <p className="v22-note">{d}</p>
            <ul>{tasks.map(([l, a]) => <li key={l}><span className="v22-check" aria-hidden>✓</span><span>{l}</span><Where a={a} /></li>)}</ul>
          </li>
        ))}
      </ol>
      <h3 className="v22-h3">Décisions de la phase 0</h3>
      <div className="v22-table-wrap">
        <table className="v22-table">
          <thead><tr><th>ID</th><th>Sujet</th><th>Décision appliquée</th><th /></tr></thead>
          <tbody>{DECISIONS.map(([id, s, d, a]) => <tr key={id}><td><code>{id}</code></td><td>{s}</td><td>{d}</td><td><Where a={a} /></td></tr>)}</tbody>
        </table>
      </div>
      <p className="v22-note">Quatre décisions acceptent le design plutôt que la spécification (D2, H5, L2, T3) : la spécification 06 doit être mise à jour en conséquence (§5, §9.3, §13, §8.1).</p>
    </Section>
  );
}

/* ============================================================ Référentiels */
function Referentiels() {
  const [l, setL] = React.useState('modePaiement');
  const cur = LISTES.find((x) => x[0] === l);
  return (
    <Section id="referentiels" kicker="06 · Référentiels" title="Listes de valeurs et codification" lead="Une seule source : la valeur est stockée en français, l’interface affiche le libellé de la langue active.">
      <div className="v22-two">
        <div className="v22-panel">
          <div className="v22-chips">{LISTES.map(([k, t]) => <button key={k} className={l === k ? 'on' : ''} onClick={() => setL(k)}>{t}</button>)}</div>
          <div className="v22-table-wrap">
            <table className="v22-table">
              <thead><tr><th>Valeur stockée</th><th>FR</th><th>AR</th><th>EN</th></tr></thead>
              <tbody>{cur[3].map((r) => <tr key={r[0]}><td><code>{r[0]}</code></td><td>{r[1]}</td><td lang="ar" dir="rtl" className="v22-ar">{r[2]}</td><td>{r[3]}</td></tr>)}</tbody>
            </table>
          </div>
          <p className="v22-note"><code>{cur[0]}</code>{cur[2] ? ' · ' + cur[2] : ''}</p>
        </div>
        <div className="v22-panel" id="codification">
          <h3>Codification §8.10</h3>
          <div className="v22-table-wrap">
            <table className="v22-table">
              <thead><tr><th>Entité</th><th>Préfixe</th><th>Exemple v2.2</th><th>Maquette v2.1</th></tr></thead>
              <tbody>{CODES.map((r) => <tr key={r[0]}><td>{r[0]}</td><td><code>{r[1]}</code></td><td><code>{r[2]}</code></td><td className={r[3] === '—' ? 'v22-muted' : 'v22-old'}>{r[3]}</td></tr>)}</tbody>
            </table>
          </div>
          <p className="v22-note">Éléments système non supprimables : MAG0000, CIS0000, CLN0000, FOR0000, CATE0000, SC0000.</p>
        </div>
      </div>
    </Section>
  );
}

/* ============================================================ Conformité */
const NOTE_L = { C: 'Conforme', P: 'Partiel', D: 'Divergent', A: 'Absent' };
function Conformity() {
  const [dom, setDom] = React.useState('all');
  const [only, setOnly] = React.useState(true);
  const rows = GRID.rows.filter((r) => (dom === 'all' || r.d === dom) && (!only || r.v21 !== 'C'));
  return (
    <Section id="conformite" kicker="07 · Conformité" title="Grille re-notée" lead={`${GRID.n} exigences de la spécification 06, pondérées de 1 à 3 (poids total ${GRID.poids}) ; conforme = 1, partiel ou divergent = 0,5, absent = 0. La note mesure la couverture des maquettes, pas l’application développée.`}>
      <div className="v22-domains">
        {GRID.domains.map(([k, name, a, b, n]) => (
          <button key={k} className={'v22-domain' + (dom === k ? ' on' : '')} onClick={() => setDom(dom === k ? 'all' : k)} title={name}>
            <span className="k">{k}</span><span className="name">{name}</span>
            <span className="bars"><i style={{ width: a + '%' }} className="a" /><i style={{ insetInlineStart: a + '%', width: Math.max(0, b - a) + '%' }} className="b" /></span>
            <span className="v"><s>{Math.round(a)}</s> {Math.round(b)} %</span>
          </button>
        ))}
      </div>
      <div className="v22-toolbar">
        <div className="v22-chips"><button className={only ? 'on' : ''} onClick={() => setOnly(true)}>Corrigées en v2.2</button><button className={!only ? 'on' : ''} onClick={() => setOnly(false)}>Toutes</button>{dom !== 'all' && <button onClick={() => setDom('all')}>Domaine {dom} ✕</button>}</div>
        <span className="v22-note" style={{ margin: 0 }}><i className="v22-key a" /> v2.1 · <i className="v22-key b" /> gain v2.2 · {rows.length} lignes</span>
      </div>
      <div className="v22-table-wrap">
        <table className="v22-table v22-grid-table">
          <thead><tr><th>ID</th><th>Exigence</th><th>Poids</th><th>v2.1</th><th>v2.2</th><th>Correction</th><th /></tr></thead>
          <tbody>{rows.map((r) => (
            <tr key={r.id}>
              <td><code>{r.id}</code></td>
              <td><div>{r.req}</div><small className="v22-muted">{r.ref}{r.v21 !== 'C' ? ' · ' + r.com : ''}</small></td>
              <td className="num">{r.w}</td>
              <td><span className={'v22-st st-' + r.v21}>{NOTE_L[r.v21]}</span></td>
              <td><span className={'v22-st st-' + r.v22}>{NOTE_L[r.v22]}</span></td>
              <td>{r.fix || <span className="v22-muted">{r.com}</span>}{r.mode === 'decision' && <span className="v22-tag v22-tag-fix" style={{ marginInlineStart: 6 }}>décision</span>}</td>
              <td>{r.at && <Where a={r.at} />}</td>
            </tr>
          ))}</tbody>
        </table>
      </div>
    </Section>
  );
}

/* ============================================================ Page */
function App() {
  const [theme, setThemeS] = React.useState(() => document.documentElement.getAttribute('data-theme') || 'system');
  const [lang, setLang] = React.useState('fr');
  const setTheme = (t) => {
    setThemeS(t);
    if (t === 'system') document.documentElement.removeAttribute('data-theme'); else document.documentElement.setAttribute('data-theme', t);
    try { if (t === 'system') localStorage.removeItem('cdz-theme'); else localStorage.setItem('cdz-theme', t); } catch (e) {}
  };
  React.useEffect(() => {
    const mo = new MutationObserver(() => setThemeS(document.documentElement.getAttribute('data-theme') || 'system'));
    mo.observe(document.documentElement, { attributes: true, attributeFilter: ['data-theme'] });
    const h = (location.hash || '').slice(1);
    if (/^[a-z0-9-]+$/.test(h)) setTimeout(() => (h.startsWith('scr-') || h.startsWith('n-') ? show(h) : go(h)), 300);
    return () => mo.disconnect();
  }, []);
  return (
    <LangCtx.Provider value={lang}>
      <TopNav theme={theme} setTheme={setTheme} lang={lang} setLang={setLang} />
      <main className="v22-page">
        <Hero />
        <Foundations theme={theme} />
        <Components />
        <Screens />
        <Flows />
        <Plan />
        <Referentiels />
        <Conformity />
        <footer className="v22-foot">CaisseDZ Design System v2.2 · construit sur la v2.1 (Claude Design) · spécification de référence : 06_specification_reconstruction.md · 13/10/2026</footer>
      </main>
    </LangCtx.Provider>
  );
}
ReactDOM.createRoot(document.getElementById('root')).render(<App />);
