// v2.2 · Phase 2 — écrans et flux manquants
import { ds, da, f0, f2, kda, LineChart, RankedBars } from './charts.jsx';
import { NombreField, CartLineQN, ContextMenu, rowMenu, CodeBarrePickerDialog, autoCode, hiddenByPerm, AccessDenied, QRCode } from './components.jsx';
import { PreviewDialog } from './previews.jsx';

const Note = ({ icon = 'info', tone = 'info', children }) => {
  const { Icon } = ds();
  return <div style={{ display: 'flex', gap: 8, alignItems: 'flex-start', padding: '10px 12px', borderRadius: 10, background: `var(--${tone}-tint)`, color: `var(--${tone}-fg)`, font: '500 12.5px/1.45 var(--font-sans)' }}><Icon name={icon} size={15} style={{ marginTop: 1, flex: 'none' }} /><span>{children}</span></div>;
};
const Row = ({ title, desc, children, last }) => (
  <div style={{ display: 'flex', alignItems: 'center', gap: 16, flexWrap: 'wrap', padding: '12px 0', borderBottom: last ? 0 : '1px solid var(--border-subtle)' }}>
    <div style={{ flex: '1 1 220px', minWidth: 0 }}><div style={{ font: '600 13.5px var(--font-sans)', color: 'var(--text-primary)' }}>{title}</div>{desc && <div style={{ font: '400 12.5px/1.45 var(--font-sans)', color: 'var(--text-secondary)', marginTop: 2 }}>{desc}</div>}</div>
    <div style={{ flex: 'none', display: 'flex', gap: 8, alignItems: 'center', flexWrap: 'wrap' }}>{children}</div>
  </div>
);

/* ================================================================== Tableau de bord v2.2 (R1, R2) */
const DAYS = ['01/10', '02/10', '03/10', '04/10', '05/10', '06/10', '07/10', '08/10', '09/10', '10/10'];
const CUR = [61200, 74800, 58300, 64200, 81500, 118400, 52800, 97300, 70100, 104600];
const PREV = [55400, 66100, 61800, 59000, 72400, 98100, 57600, 83900, 66500, 89700];
export function DashboardV22({ onNavigate }) {
  const { PageHeader, SegmentedControl, Button, Tabs, StatCard, Card, BarChart, DonutChart, DataTable, StatusBadge, Badge } = ds();
  const [menu, setMenu] = React.useState(null);
  const [prev, setPrev] = React.useState(null);
  const ventes = CUR.reduce((a, b) => a + b, 0), avant = PREV.reduce((a, b) => a + b, 0), achats = 512400;
  const trend = Math.round(((ventes - avant) / avant) * 1000) / 10;
  const pay = [{ label: 'Espèces', value: 498300 }, { label: 'Carte CIB', value: 186900 }, { label: 'Chèque', value: 58400 }, { label: 'Virement', value: 31200 }, { label: 'Points fidélité', value: 8400 }];
  const recent = window.CDZ.sales.slice(0, 5).map((s) => ({ ...s, statut: s.statut === 'Payé' ? 'paye' : s.statut === 'Crédit' ? 'credit' : 'annule' }));
  return (<>
    <PageHeader title="Tableau de bord" description="Magasin Central · du 01/10 au 10/10/2026, comparé aux 10 jours précédents."
      actions={<><SegmentedControl options={['Jour', 'Semaine', 'Mois', 'Période']} defaultValue="Période" /><Button variant="secondary" icon="calendar">01 – 10 oct.</Button><Button variant="secondary" icon="eye" onClick={() => setPrev('excel')}>Exporter</Button></>} />
    <Tabs value="dash" onChange={(t) => t === 'sit' && onNavigate && onNavigate('situation')} tabs={[{ key: 'dash', label: 'Tableau de bord' }, { key: 'sit', label: 'Situation', count: 10 }]} />
    <div className="v22-kpis">
      <StatCard icon="banknote" title="Ventes" value={ventes} suffix="DA" trend={trend} info="Total des paniers encaissés sur la période" caption="vs période précédente" />
      <StatCard icon="history" title="Période précédente" value={avant} suffix="DA" info="Mêmes jours, période d’avant" caption="21/09 – 30/09" animate={false} />
      <StatCard icon="shopping-cart" title="Achats" value={achats} suffix="DA" trend={4.2} trendInvert info="Entrées validées (bons d’achat)" />
      <StatCard icon="scale" title="Net" value={ventes - achats} suffix="DA" trend={18.6} info="Ventes − achats de la période" />
      <StatCard icon="truck" title="Dette fournisseurs" value={128600} suffix="DA" trend={-6.3} trendInvert info="Restes à payer sur les entrées" onClick={() => onNavigate && onNavigate('fournisseurs')} />
      <StatCard icon="hand-coins" title="Crédit clients" value={46300} suffix="DA" trend={2.1} trendInvert info="Restes dus sur les paniers" onClick={() => onNavigate && onNavigate('clients')} />
    </div>
    <div className="v22-grid-2-1">
      <Card title="Courbe des ventes" icon="chart-line" actions={<Badge tone="success" icon="trending-up">+{String(trend).replace('.', ',')} %</Badge>}>
        <LineChart labels={DAYS} series={[{ name: 'Période', values: CUR }, { name: 'Période précédente', values: PREV, dashed: true, color: 'var(--text-muted)' }]} height={230} />
      </Card>
      <Card title="Modes de paiement" icon="wallet">
        <div style={{ display: 'flex', justifyContent: 'center' }}><DonutChart size={180} centerLabel="Total" centerValue={kda(pay.reduce((s, p) => s + p.value, 0))} data={pay} /></div>
      </Card>
    </div>
    <div className="v22-grid-3">
      <Card title="Chiffre d’affaires par jour" icon="chart-column"><BarChart height={190} highlight={5} data={DAYS.map((l, i) => ({ label: l.slice(0, 2), value: CUR[i] }))} formatValue={kda} /></Card>
      <Card title="Ventes par caissier" icon="users"><RankedBars formatValue={(v) => kda(v) + ' DA'} data={[{ label: 'Yacine Benali', caption: '212 tickets', value: 389400 }, { label: 'Amina Kaci', caption: '168 tickets', value: 276100 }, { label: 'Riad Ouali', caption: '74 tickets', value: 117700 }]} /></Card>
      <Card title="Top produits" icon="trophy"><RankedBars color="var(--accent)" formatValue={(v) => kda(v) + ' DA'} data={[{ label: 'Huile Elio 1 L', caption: '312 u.', value: 131040 }, { label: 'Coca-Cola 1,5 L', caption: '804 u.', value: 96480 }, { label: 'Café moulu 250 g', caption: '196 u.', value: 62720 }, { label: 'Lait Candia 1 L', caption: '588 u.', value: 58800 }, { label: 'Farine 1 kg', caption: '402 u.', value: 32160 }]} /></Card>
    </div>
    <Card title="Dernières ventes" icon="receipt-text" padding={0} info="Clic droit sur une ligne : menu contextuel">
      <DataTable rows={recent} rowKey="id" onRowContextMenu={(r, e) => setMenu({ x: e.clientX, y: e.clientY, r })}
        columns={[{ key: 'id', label: 'N° panier', muted: true }, { key: 'heure', label: 'Heure', muted: true }, { key: 'client', label: 'Client', strong: true }, { key: 'mode', label: 'Paiement' }, { key: 'total', label: 'Montant', align: 'right', render: (v) => da(v) }, { key: 'statut', label: 'Statut', render: (v) => <StatusBadge status={v} /> }]} />
    </Card>
    {menu && <ContextMenu x={menu.x} y={menu.y} title={menu.r.id} items={rowMenu(menu.r, { onPrint: () => setPrev('ticket') })} onClose={() => setMenu(null)} />}
    {prev && <PreviewDialog kind={prev} onClose={() => setPrev(null)} />}
  </>);
}

/* ================================================================== Paramètres — compléments (T2, T3, T6-T9, F5/J5) */
export function ParametresV22() {
  const { Card, SegmentedControl, TextField, Switch, ChoiceCards, Button, Badge, Select } = ds();
  const [mType, setMType] = React.useState('%');
  const [bonus, setBonus] = React.useState(true);
  const [nb, setNb] = React.useState(true);
  const [pt, setPt] = React.useState('reseau');
  const [prev, setPrev] = React.useState(false);
  const [test, setTest] = React.useState(null);
  const w = (n) => ({ width: n });
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
      <div className="v22-grid-2">
        <Card title="Marge par défaut" icon="percent" info="Appliquée aux nouveaux produits et proposée dans l’entrée">
          <Row title="Type de marge" desc="En montant fixe ou en pourcentage du prix d’achat."><SegmentedControl value={mType} onChange={setMType} options={[{ value: 'DA', label: 'Montant' }, { value: '%', label: 'Pourcentage' }]} /></Row>
          <Row title="Marge détail" desc="Prix de vente = achat + marge."><div style={w(140)}><TextField numeric suffix={mType} defaultValue={mType === '%' ? '25' : '50'} /></div></Row>
          <Row title="Marge gros (carton)" desc="Utilisée pour le prix du colis." last><div style={w(140)}><TextField numeric suffix={mType} defaultValue={mType === '%' ? '15' : '30'} /></div></Row>
        </Card>
        <Card title="Seuils de stock globaux" icon="gauge" info="Valeurs par défaut, modifiables produit par produit">
          <Row title="Seuil minimum (rupture)" desc="Alerte quand le stock passe sous ce seuil."><div style={w(140)}><TextField numeric suffix="pcs" defaultValue="10" /></div></Row>
          <Row title="Seuil maximum" desc="Signale un sur-stock ; sert au calcul des besoins."><div style={w(140)}><TextField numeric suffix="pcs" defaultValue="200" /></div></Row>
          <Row title="Garde de stock" desc="Toujours active : le stock ne devient jamais négatif." last><Badge tone="success" icon="shield-check">Non désactivable</Badge></Row>
        </Card>
        <Card title="Fidélité" icon="star">
          <Row title="Bonus fidélité" desc="Les clients identifiés gagnent des points à chaque encaissement."><Switch checked={bonus} onChange={setBonus} /></Row>
          <Row title="Taux de gain" desc="Points gagnés par tranche d’achat."><div style={{ display: 'flex', gap: 8, alignItems: 'center' }}><div style={w(80)}><TextField numeric disabled={!bonus} defaultValue="1" /></div><span style={{ font: '500 13px var(--font-sans)', color: 'var(--text-secondary)' }}>point / </span><div style={w(120)}><TextField numeric disabled={!bonus} suffix="DA" defaultValue="100" /></div></div></Row>
          <Row title="Valeur d’un point" desc="Utilisée par le mode de paiement « Points fidélité »." last><div style={w(140)}><TextField numeric disabled={!bonus} suffix="DA" defaultValue="1" /></div></Row>
        </Card>
        <Card title="Zakat" icon="hand-coins">
          <Row title="Nissab" desc="Valeur de 85 g d’or ; proposée à chaque calcul."><div style={w(180)}><TextField numeric suffix="DA" defaultValue="1 615 000" /></div></Row>
          <Row title="Taux" desc="Taux appliqué à l’assiette." last><div style={w(120)}><TextField numeric suffix="%" defaultValue="2,5" /></div></Row>
        </Card>
        <Card title="2ᵉ stock « nombre »" icon="hash" info="Compte à part : barquettes, sachets, bouteilles…">
          <Row title="Activer le 2ᵉ stock" desc="Ajoute la saisie du nombre en caisse, entrées, retours, sorties et transferts."><Switch checked={nb} onChange={setNb} /></Row>
          <Row title="Libellé par défaut" desc="Affiché à côté du nombre." last><div style={w(160)}><TextField disabled={!nb} defaultValue="nombre" /></div></Row>
        </Card>
        <Card title="Boutique — mentions légales" icon="store">
          <Row title="Registre du commerce (RC)"><div style={w(220)}><TextField defaultValue="16/00-1234567 B 21" /></div></Row>
          <Row title="E-mail"><div style={w(220)}><TextField icon="mail" defaultValue="contact@elbaraka.dz" /></div></Row>
          <Row title="NIF · NIS · Article" desc="Imprimés sur le ticket et la facture A4." last><Badge tone="neutral">Renseignés</Badge></Row>
        </Card>
      </div>
      <Card title="Imprimante ticket" icon="printer" actions={<><Button size="sm" variant="secondary" icon="eye" onClick={() => setPrev(true)}>Aperçu du ticket</Button><Button size="sm" variant="soft" icon="printer" onClick={() => new Promise((r) => setTimeout(() => { setTest('ok'); r(); }, 900))}>Imprimer un test</Button></>}>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
          <ChoiceCards size="sm" columns={4} value={pt} onChange={setPt} options={[{ value: 'bluetooth', label: 'Bluetooth', icon: 'bluetooth', description: 'Appairée par adresse MAC' }, { value: 'usb', label: 'USB', icon: 'usb', description: 'Port COM / pilote ESC/POS' }, { value: 'reseau', label: 'Réseau', icon: 'network', description: 'Adresse IP et port' }, { value: 'normale', label: 'Normale', icon: 'printer', description: 'Imprimante Windows' }]} />
          <div className="v22-fields">
            {pt === 'reseau' && <><TextField label="Adresse IP" defaultValue="192.168.1.50" /><TextField label="Port" numeric defaultValue="9100" /></>}
            {pt === 'bluetooth' && <><TextField label="Adresse MAC" defaultValue="66:12:4F:A0:3C:19" /><Select label="Appareil" options={['XP-P323B', 'MTP-II']} defaultValue="XP-P323B" /></>}
            {pt === 'usb' && <Select label="Port" options={['COM3', 'COM4', 'USB001']} defaultValue="USB001" />}
            {pt === 'normale' && <Select label="Imprimante Windows" options={['EPSON TM-T20III', 'Microsoft Print to PDF']} defaultValue="EPSON TM-T20III" />}
            <Select label="Largeur" options={['58 mm', '80 mm']} defaultValue="80 mm" />
          </div>
          {test && <Note icon="circle-check" tone="success">Test envoyé : la page de test est sortie sur l’imprimante {pt === 'reseau' ? '192.168.1.50:9100' : pt}.</Note>}
        </div>
      </Card>
      {prev && <PreviewDialog kind="ticket" onClose={() => setPrev(false)} />}
    </div>
  );
}

/* ================================================================== Configuration initiale — étape Marge (C4) */
export function InitialSetupMargeDialog({ onClose, inline }) {
  const { Dialog, Stepper, Button, SegmentedControl, TextField, FormRow } = ds();
  const [t, setT] = React.useState('%');
  return (
    <Dialog inline={inline} open width={inline ? '100%' : 640} icon="settings-2" title="Configuration initiale" description="Étape 4 sur 4 — vous pourrez tout modifier dans Paramètres." onClose={onClose}
      footer={<><Button variant="secondary" icon="arrow-left">Précédent</Button><Button icon="check">Terminer</Button></>}>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
        <Stepper active={4} steps={['Langue et devise', 'Boutique', 'Paiements', 'Marge']} size="sm" />
        <FormRow label="Type de marge"><SegmentedControl value={t} onChange={setT} options={[{ value: 'DA', label: 'Montant' }, { value: '%', label: 'Pourcentage' }]} /></FormRow>
        <FormRow label="Marge détail" hint="Prix de vente proposé = achat + marge"><TextField numeric suffix={t} defaultValue={t === '%' ? '25' : '50'} /></FormRow>
        <FormRow label="Marge gros"><TextField numeric suffix={t} defaultValue={t === '%' ? '15' : '30'} /></FormRow>
        <Note>Exemple : un produit acheté 100,00 DA sera proposé à {t === '%' ? '125,00' : '150,00'} DA.</Note>
      </div>
    </Dialog>
  );
}

/* ================================================================== Mode démo (C2) & Mon compte (D5) */
export function DemoNotice() {
  const { Icon } = ds();
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 10, padding: '10px 12px', borderRadius: 10, border: '1px dashed var(--border-strong)', background: 'var(--surface-sunken)', font: '500 12.5px/1.4 var(--font-sans)', color: 'var(--text-secondary)' }}>
      <Icon name="flask-conical" size={16} color="var(--primary)" />
      <span style={{ flex: 1 }}>Application non activée ? Essayez le <b style={{ color: 'var(--text-primary)' }}>mode démo</b> : identifiant <code>demo</code>, mot de passe <code>demo</code>.</span>
    </div>
  );
}
export function DemoBanner() {
  const { Icon, Button } = ds();
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 10, flexWrap: 'wrap', padding: '8px 14px', borderRadius: 10, background: 'var(--warning-tint)', color: 'var(--warning-fg)', font: '600 12.5px var(--font-sans)' }}>
      <Icon name="flask-conical" size={16} /><span style={{ flex: 1 }}>Mode démo — données fictives, réinitialisées à la fermeture. Rien n’est imprimé ni exporté.</span><Button size="sm" variant="secondary" icon="key-round">Activer l’application</Button>
    </div>
  );
}
export function ChangerIdentifiantDialog({ onClose, inline }) {
  const { Dialog, Button, FormRow, TextField, KeyValueGrid } = ds();
  const [id, setId] = React.useState('yacine.b');
  const taken = id.trim().toLowerCase() === 'amina';
  return (
    <Dialog inline={inline} open width={inline ? '100%' : 600} icon="at-sign" title="Changer d’identifiant" description="Mon compte — l’identifiant sert à la connexion ; il doit être unique." onClose={onClose}
      footer={<><Button variant="secondary" onClick={onClose}>Annuler</Button><Button icon="check" disabled={taken || !id.trim()} onClick={() => new Promise((r) => setTimeout(r, 700))}>Enregistrer</Button></>}>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
        <KeyValueGrid columns={3} dense items={[{ label: 'Code', value: 'USR000002', mono: true }, { label: 'Dernier accès', value: '10/10/2026 08:02' }, { label: 'Rôle', value: 'Admin' }]} />
        <FormRow label="Identifiant actuel"><TextField disabled value="yacine" /></FormRow>
        <FormRow label="Nouvel identifiant" required error={taken ? 'Identifiant déjà utilisé' : undefined}><TextField icon="at-sign" value={id} onChange={setId} /></FormRow>
        <FormRow label="Mot de passe" required hint="Confirmez avec votre mot de passe actuel"><TextField type="password" icon="key-round" defaultValue="••••••" /></FormRow>
      </div>
    </Dialog>
  );
}

/* ================================================================== États métier (G5, O6, F16, K4) */
export function AnnulationClotureDialog({ onClose, inline }) {
  const { ConfirmDialog } = ds();
  return <ConfirmDialog inline={inline} kind="refuse" title="Annulation impossible" message="Le panier PN0000212 appartient à une période clôturée (CLT000041 du 09/10/2026). Les clôtures sont immuables : faites un retour à la place." confirmLabel="Créer un retour" cancelLabel="Fermer" onCancel={onClose} onConfirm={onClose} />;
}
export function VersementVerrouilleDialog({ onClose, inline }) {
  const { ConfirmDialog } = ds();
  return <ConfirmDialog inline={inline} kind="refuse" icon="lock" title="Versement verrouillé" message="Ce versement de 2 380,00 DA a été créé par le retour du panier PN0000229. Il ne se modifie et ne s’annule qu’en annulant le retour." confirmLabel="Ouvrir le retour" cancelLabel="Fermer" onCancel={onClose} onConfirm={onClose} />;
}
export function StockReserveDialog({ onClose, inline }) {
  const { Dialog, Button, KeyValueGrid } = ds();
  return (
    <Dialog inline={inline} open width={inline ? '100%' : 560} tone="warning" icon="lock" title="Stock réservé par un autre panier" description="Huile Elio 1 L · PRD000003" onClose={onClose}
      footer={<><Button variant="secondary" onClick={onClose}>Annuler</Button><Button variant="secondary" icon="external-link">Ouvrir la vente 2</Button><Button icon="plus" onClick={onClose}>Ajouter 2</Button></>}>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
        <KeyValueGrid columns={3} items={[{ label: 'Stock', value: '6 pcs' }, { label: 'Réservé (vente 2)', value: '4 pcs' }, { label: 'Disponible', value: '2 pcs' }]} />
        <Note tone="warning" icon="triangle-alert">Vous demandez 3 pièces. Les paniers ouverts réservent leur stock jusqu’à l’encaissement ou la fermeture du panier.</Note>
      </div>
    </Dialog>
  );
}
export function QuotaIADialog({ onClose, inline }) {
  const { Dialog, Button, QuotaCard, FormRow, Select, TextField, ResultDialog } = ds();
  const [sent, setSent] = React.useState(false);
  if (sent) return <ResultDialog inline={inline} status="success" title="Demande envoyée" message="Votre revendeur vous contactera sous 24 h. Le quota se renouvelle aussi le 01/11/2026." onClose={onClose} />;
  return (
    <Dialog inline={inline} open width={inline ? '100%' : 620} icon="sparkles" title="Quota Smart Scan IA atteint" description="Les scans IA reprendront au renouvellement, ou dès qu’une offre plus large est activée." onClose={onClose}
      footer={<><Button variant="secondary" onClick={onClose}>Plus tard</Button><Button icon="send" onClick={() => new Promise((r) => setTimeout(() => { setSent(true); r(); }, 800))}>Demander une offre</Button></>}>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
        <QuotaCard plan="Standard" used={60} limit={60} renewal="01/11/2026" />
        <FormRow label="Offre souhaitée"><Select options={['Pro · 300 scans / mois', 'Illimité']} defaultValue="Pro · 300 scans / mois" /></FormRow>
        <FormRow label="Téléphone" required><TextField icon="phone" defaultValue="0550 12 34 56" /></FormRow>
        <FormRow label="Message" align="start"><TextField multiline rows={2} placeholder="Précisez votre besoin (optionnel)" /></FormRow>
      </div>
    </Dialog>
  );
}

/* ================================================================== Raccourcis caisse (F7) */
export const SHORTCUTS = [
  ['Vente', [['F2', 'Rechercher un produit'], ['F3', 'Recherche avancée'], ['N', 'Nouvelle vente (onglet)'], ['C', 'Choisir le client'], ['E', 'Entrée rapide de stock'], ['R', 'Remise sur le ticket'], ['P', 'Modifier le prix de la ligne']]],
  ['Lignes', [['+', 'Augmenter la quantité'], ['−', 'Diminuer la quantité'], ['Suppr', 'Retirer la ligne'], ['F10', 'Vider le panier']]],
  ['Encaissement', [['F4', 'Encaisser BL / SC'], ['F5', 'Enregistrer le ticket (reste en crédit)'], ['F6', 'Encaisser le ticket'], ['F9', 'Ventes du jour'], ['Ctrl P', 'Réimprimer le dernier ticket'], ['Ctrl R', 'Recette du jour']]],
];
export function ShortcutsDialog({ onClose, inline }) {
  const { Dialog, Button } = ds();
  return (
    <Dialog inline={inline} open width={inline ? '100%' : 760} icon="keyboard" title="Raccourcis clavier de la caisse" description="Touche ? ou F1 pour afficher cette aide. Les lettres seules agissent hors d’un champ de saisie." onClose={onClose} footer={<Button onClick={onClose}>Compris</Button>}>
      <div className="v22-grid-3" style={{ alignItems: 'start' }}>
        {SHORTCUTS.map(([g, list]) => (
          <div key={g} style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
            <div style={{ font: '700 11px var(--font-sans)', letterSpacing: '.06em', textTransform: 'uppercase', color: 'var(--text-muted)', marginBottom: 2 }}>{g}</div>
            {list.map(([k, l]) => <div key={k} style={{ display: 'flex', alignItems: 'center', gap: 10, font: '500 13px var(--font-sans)', color: 'var(--text-primary)' }}><kbd className="v22-kbd">{k}</kbd><span>{l}</span></div>)}
          </div>
        ))}
      </div>
    </Dialog>
  );
}

/* ================================================================== Encaissement avec points gagnés (F13) */
export function PointsGagnesResult({ onClose, inline }) {
  const { ResultDialog, KeyValueGrid } = ds();
  return (
    <ResultDialog inline={inline} status="success" title="Ticket encaissé" message="PN0000233 · rendu 1 295,00 DA" actionLabel="Nouvelle vente" onClose={onClose}>
      <KeyValueGrid columns={2} dense items={[{ label: 'Client', value: 'Yacine Benali' }, { label: 'Points gagnés', value: '+30 (imprimés sur le ticket)' }, { label: 'Ancien solde', value: '382 points' }, { label: 'Nouveau solde', value: '412 points' }]} />
    </ResultDialog>
  );
}

/* ================================================================== Nouveau produit — mode IA (I4) + synchro catalogue (I5) */
const SOURCES = [['CaisseDZ', 'Catalogue partagé des commerces CaisseDZ', 'database'], ['Mantouj', 'Base algérienne des produits', 'flag'], ['Open Food Facts', 'Alimentaire, mondial', 'apple'], ['Open Beauty Facts', 'Hygiène et beauté', 'sparkle']];
export function ProduitIADialog({ onClose, inline, startStep = 1 }) {
  const { Dialog, Button, Stepper, TextField, FormRow, Select, Icon, Badge, Spinner } = ds();
  const [step, setStep] = React.useState(startStep);
  const [code, setCode] = React.useState('6130234000126');
  const [k, setK] = React.useState(startStep > 1 ? 4 : 0);
  React.useEffect(() => {
    if (step !== 2) return;
    setK(0); let i = 0;
    const id = setInterval(() => { i += 1; setK(i); if (i >= 2) { clearInterval(id); setTimeout(() => setStep(3), 500); } }, 650);
    return () => clearInterval(id);
  }, [step]);
  const state = (i) => (step === 1 ? 'idle' : i < k ? (i === 1 ? 'found' : 'none') : i === k && step === 2 ? 'busy' : i > 1 && step >= 3 ? 'skip' : 'idle');
  const st = { idle: ['circle', 'var(--icon-muted)', 'En attente'], busy: ['loader', 'var(--primary)', 'Recherche…'], none: ['circle-x', 'var(--text-muted)', 'Introuvable'], found: ['circle-check', 'var(--success-fg)', 'Trouvé'], skip: ['circle-minus', 'var(--icon-muted)', 'Non consulté'] };
  return (
    <Dialog inline={inline} open width={inline ? '100%' : 860} icon="sparkles" title="Nouveau produit — mode IA" description="Scannez le code-barres : CaisseDZ interroge les catalogues dans l’ordre et pré-remplit la fiche." onClose={onClose}
      footer={step === 3 ? <><Button variant="secondary" onClick={() => setStep(1)} icon="scan-barcode">Autre code</Button><Button variant="secondary">Mode détaillé</Button><Button icon="check" onClick={() => new Promise((r) => setTimeout(r, 800))}>Créer le produit</Button></> : <><Button variant="secondary" onClick={onClose}>Annuler</Button><Button icon="search" disabled={step === 2 || code.length < 8} onClick={() => setStep(2)}>Rechercher</Button></>}>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
        <Stepper size="sm" active={step} steps={['Scanner', 'Catalogues', 'Vérifier et compléter']} />
        <div className="v22-grid-ia">
          <div style={{ display: 'flex', flexDirection: 'column', gap: 10, minWidth: 0 }}>
            <TextField label="Code-barres" icon="scan-barcode" value={code} onChange={setCode} disabled={step === 2} />
            <div style={{ font: '600 12px var(--font-sans)', color: 'var(--text-muted)', marginTop: 4 }}>Cascade des sources</div>
            {SOURCES.map(([n, d, ic], i) => { const s = st[state(i)]; return (
              <div key={n} style={{ display: 'flex', alignItems: 'center', gap: 10, padding: '9px 10px', borderRadius: 10, border: '1px solid ' + (state(i) === 'found' ? 'var(--success)' : 'var(--border-subtle)'), background: state(i) === 'found' ? 'var(--success-tint)' : 'var(--surface-card)' }}>
                <span style={{ width: 22, font: '700 11px var(--font-sans)', color: 'var(--text-muted)' }}>{i + 1}</span>
                <Icon name={ic} size={16} color="var(--icon-default)" />
                <div style={{ flex: 1, minWidth: 0 }}><div style={{ font: '600 13px var(--font-sans)', color: 'var(--text-primary)' }}>{n}</div><div style={{ font: '400 11.5px var(--font-sans)', color: 'var(--text-muted)' }}>{d}</div></div>
                <span style={{ display: 'inline-flex', alignItems: 'center', gap: 5, font: '600 11.5px var(--font-sans)', color: s[1] }}><Icon name={s[0]} size={14} className={state(i) === 'busy' ? 'v22-spin' : ''} />{s[2]}</span>
              </div>); })}
          </div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 10, minWidth: 0, opacity: step === 3 ? 1 : 0.45, pointerEvents: step === 3 ? 'auto' : 'none', transition: 'opacity var(--dur-base)' }}>
            <div style={{ display: 'flex', gap: 12, alignItems: 'center' }}>
              <div style={{ width: 84, height: 84, borderRadius: 12, flex: 'none', background: 'linear-gradient(160deg, #e8f1ff, #cfe0fb)', border: '1px solid var(--border-subtle)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}><Icon name="milk" size={40} color="#2b5fb3" /></div>
              <div style={{ minWidth: 0 }}><div style={{ font: '700 15px var(--font-sans)', color: 'var(--text-primary)' }}>Lait Candia 1 L</div><div style={{ display: 'flex', gap: 6, marginTop: 6, flexWrap: 'wrap' }}><Badge tone="success" icon="sparkles">Trouvé sur Mantouj</Badge><Badge tone="neutral">Photo importée</Badge></div></div>
            </div>
            <FormRow label="Nom" labelWidth={110}><TextField defaultValue="Lait Candia 1 L" /></FormRow>
            <FormRow label="Marque" labelWidth={110}><TextField defaultValue="Candia" /></FormRow>
            <FormRow label="Catégorie" labelWidth={110}><Select options={['Crèmerie', 'Épicerie', 'Boissons']} defaultValue="Crèmerie" /></FormRow>
            <FormRow label="Prix d’achat" required labelWidth={110}><TextField numeric suffix="DA" defaultValue="80" /></FormRow>
            <FormRow label="Prix de vente" required labelWidth={110} hint="Marge par défaut 25 % appliquée"><TextField numeric suffix="DA" defaultValue="100" /></FormRow>
          </div>
        </div>
        {step === 3 && <Note icon="cloud-upload">À l’enregistrement, la fiche est proposée au catalogue partagé CaisseDZ (sans prix ni stock). Statut visible dans la liste des produits.</Note>}
      </div>
    </Dialog>
  );
}
export const SYNC = { synchro: ['success', 'cloud', 'Synchronisé'], attente: ['warning', 'cloud-upload', 'En attente d’envoi'], refuse: ['danger', 'cloud-alert', 'Refusé par la modération'], local: ['neutral', 'hard-drive', 'Local uniquement'] };
export function SyncBadge({ s }) { const { Badge } = ds(); const x = SYNC[s]; return <Badge tone={x[0]} icon={x[1]}>{x[2]}</Badge>; }
export function CatalogueSyncCard() {
  const { Card, DataTable, Button } = ds();
  const rows = [{ id: 1, code: 'PRD000001', nom: 'Lait Candia 1 L', src: 'Mantouj', s: 'synchro', d: '10/10 09:12' }, { id: 2, code: 'PRD000014', nom: 'Viande hachée (barquette)', src: 'Saisie', s: 'local', d: '—' }, { id: 3, code: 'PRD000016', nom: 'Biscuits Bimo 200 g', src: 'Open Food Facts', s: 'attente', d: '10/10 11:40' }, { id: 4, code: 'PRD000017', nom: 'Savon Mira 125 g', src: 'Open Beauty Facts', s: 'refuse', d: '09/10 16:05' }];
  return (
    <Card title="Catalogue partagé — statut de synchro" icon="cloud" padding={0} actions={<Button size="sm" variant="secondary" icon="refresh-cw" onClick={() => new Promise((r) => setTimeout(r, 900))}>Synchroniser</Button>}>
      <DataTable rows={rows} columns={[{ key: 'code', label: 'Code', muted: true }, { key: 'nom', label: 'Produit', strong: true }, { key: 'src', label: 'Source' }, { key: 's', label: 'Statut', render: (v) => <SyncBadge s={v} /> }, { key: 'd', label: 'Dernier envoi', muted: true }]} />
    </Card>
  );
}

/* ================================================================== Formulaire produit détaillé (I3) */
export function ProduitDetailleDialog({ onClose, inline }) {
  const { Dialog, Button, FormRow, TextField, Select, Switch, PhotoUploader, DateField } = ds();
  const [nb, setNb] = React.useState(true);
  const [pick, setPick] = React.useState(false);
  const [cb, setCb] = React.useState('6130234000126');
  const lw = 150;
  return (<>
    <Dialog inline={inline} open width={inline ? '100%' : 900} icon="package-plus" title="Nouveau produit — mode détaillé" description="Tous les champs de la fiche ; * obligatoires." onClose={onClose}
      footer={<><Button variant="secondary" onClick={onClose}>Annuler</Button><Button variant="secondary" icon="sparkles">Mode IA</Button><Button icon="check" onClick={() => new Promise((r) => setTimeout(r, 700))}>Enregistrer</Button></>}>
      <div className="v22-grid-2" style={{ alignItems: 'start' }}>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 10, minWidth: 0 }}>
          <FormRow label="Code-barres" labelWidth={lw} onLookup={() => setPick(true)} lookupTitle="Choisir un code-barres"><TextField icon="barcode" value={cb} onChange={setCb} trailing={<Button size="sm" variant="ghost" onClick={() => setCb(autoCode(18))}>Générer</Button>} /></FormRow>
          <FormRow label="Nom" required labelWidth={lw}><TextField defaultValue="Viande hachée (barquette)" /></FormRow>
          <FormRow label="Catégorie" required labelWidth={lw}><Select lookup="categorie" options={['Boucherie', 'Crèmerie', 'Épicerie']} defaultValue="Boucherie" /></FormRow>
          <FormRow label="Marque" labelWidth={lw}><TextField placeholder="Optionnel" /></FormRow>
          <FormRow label="Fournisseur par défaut" labelWidth={lw}><Select lookup="fournisseur" options={['Boucherie Ouled Fayet', 'Sarl Djurdjura Distribution']} defaultValue="Boucherie Ouled Fayet" /></FormRow>
          <FormRow label="Description" align="start" labelWidth={lw}><TextField multiline rows={3} defaultValue="Bœuf haché frais, barquette ±600 g, à conserver entre 0 et 4 °C." /></FormRow>
          <FormRow label="Photos" align="start" labelWidth={lw}><PhotoUploader photos={[]} max={4} size={72} /></FormRow>
        </div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 10, minWidth: 0 }}>
          <FormRow label="Prix d’achat" required labelWidth={lw}><TextField numeric suffix="DA" defaultValue="1 160" /></FormRow>
          <FormRow label="Prix de vente" required labelWidth={lw} hint="Marge : 290,00 DA (25 %)"><TextField numeric suffix="DA" defaultValue="1 450" /></FormRow>
          <FormRow label="Unité" labelWidth={lw}><Select options={['Pièce', 'kg', 'Litre', 'Mètre']} defaultValue="kg" /></FormRow>
          <FormRow label="Seuil d’alerte" labelWidth={lw} hint="Par défaut : seuil global (10)"><TextField numeric suffix="kg" defaultValue="10" /></FormRow>
          <FormRow label="Date d’expiration" labelWidth={lw}><DateField defaultValue="2026-10-14" /></FormRow>
          <FormRow label="2ᵉ stock « nombre »" labelWidth={lw}><Switch checked={nb} onChange={setNb} label={nb ? 'Actif — saisie obligatoire' : 'Inactif'} /></FormRow>
          <FormRow label="Libellé du nombre" labelWidth={lw}><TextField disabled={!nb} defaultValue="barquettes" /></FormRow>
          <FormRow label="Statut" labelWidth={lw}><Switch defaultChecked label="Actif à la vente" /></FormRow>
        </div>
      </div>
    </Dialog>
    {pick && <CodeBarrePickerDialog onClose={() => setPick(false)} onPick={(r) => setCb(r.code)} />}
  </>);
}

/* ================================================================== Sorties — onglet Ventes (L3) */
export function SortiesVentesTab() {
  const { Card, DataTable, Badge } = ds();
  const rows = [['PN0000232', '10/10 11:42', 'Huile Elio 1 L', 2, '—', 'Magasin Central', 'Yacine'], ['PN0000232', '10/10 11:42', 'Coca-Cola 1,5 L', 3, '—', 'Magasin Central', 'Yacine'], ['PN0000231', '10/10 11:30', 'Viande hachée', 1.25, 2, 'Magasin Central', 'Yacine'], ['PN0000230', '10/10 11:12', 'Café moulu 250 g', 2, '—', 'Boutique Hydra', 'Amina'], ['PN0000227', '10/10 10:02', 'Lait Candia 1 L', 12, '—', 'Magasin Central', 'Yacine']]
    .map(([panier, date, produit, qte, nombre, mag, caissier], i) => ({ id: i, panier, date, produit, qte, nombre, mag, caissier }));
  return (
    <Card title="Sorties · onglet Ventes" icon="receipt-text" padding={0} info="Les ventes sont des sorties automatiques ; consultation seule" actions={<Badge tone="info" icon="lock">Lecture seule</Badge>}>
      <DataTable rows={rows} columns={[{ key: 'panier', label: 'N° panier', muted: true }, { key: 'date', label: 'Date', muted: true }, { key: 'produit', label: 'Produit', strong: true }, { key: 'qte', label: 'Qté', align: 'right' }, { key: 'nombre', label: 'Nombre', align: 'right' }, { key: 'mag', label: 'Magasin' }, { key: 'caissier', label: 'Caissier' }]} />
    </Card>
  );
}

/* ================================================================== Versement imputé aux documents (O4) */
const DOCS = [{ id: 'PN0000198', date: '18/09/2026', montant: 12400, reste: 6400 }, { id: 'PN0000225', date: '10/10/2026', montant: 26900, reste: 26900 }, { id: 'PN0000231', date: '10/10/2026', montant: 18400, reste: 8400 }];
export function VersementImputationDialog({ onClose, inline }) {
  const { Dialog, Button, FormRow, TextField, Select, Icon } = ds();
  const [m, setM] = React.useState('15000');
  const total = Number(String(m).replace(/\s/g, '').replace(',', '.')) || 0;
  const auto = (t) => { let r = t; return DOCS.map((d) => { const a = Math.min(d.reste, r); r -= a; return String(a); }); };
  const [alloc, setAlloc] = React.useState(auto(15000));
  React.useEffect(() => setAlloc(auto(total)), [total]);
  const used = alloc.reduce((s, a) => s + (Number(a) || 0), 0);
  const over = DOCS.some((d, i) => Number(alloc[i]) > d.reste);
  return (
    <Dialog inline={inline} open width={inline ? '100%' : 780} icon="hand-coins" title="Nouveau versement client" description="Hôtel Safir · crédit total 41 700,00 DA — le versement est imputé aux documents ouverts." onClose={onClose}
      footer={<><Button variant="secondary" onClick={onClose}>Annuler</Button><Button icon="check" disabled={over || used !== total || !total} onClick={() => new Promise((r) => setTimeout(r, 700))}>Enregistrer le versement</Button></>}>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
        <div className="v22-fields">
          <TextField label="Montant" numeric suffix="DA" value={m} onChange={setM} />
          <Select label="Mode" options={['Espèces', 'Carte CIB', 'Chèque', 'Virement']} defaultValue="Espèces" />
          <Select label="Caisse" options={['Caisse 1', 'Caisse 2']} defaultValue="Caisse 1" />
        </div>
        <div style={{ border: '1px solid var(--border-default)', borderRadius: 12, overflow: 'hidden' }}>
          <div className="v22-imp v22-imp-h"><span>Document</span><span>Date</span><span style={{ textAlign: 'end' }}>Reste</span><span style={{ textAlign: 'end' }}>Imputé</span></div>
          {DOCS.map((d, i) => (
            <div key={d.id} className="v22-imp">
              <span style={{ fontWeight: 600, color: 'var(--text-primary)' }}>{d.id}</span><span>{d.date}</span><span style={{ textAlign: 'end' }}>{da(d.reste)}</span>
              <span><TextField size="sm" numeric suffix="DA" value={alloc[i]} error={Number(alloc[i]) > d.reste ? 'Supérieur au reste' : undefined} onChange={(v) => setAlloc(alloc.map((a, j) => (j === i ? v.replace(/\D/g, '') : a)))} /></span>
            </div>
          ))}
          <div className="v22-imp v22-imp-h"><span>Total imputé</span><span /><span /><span style={{ textAlign: 'end', color: used === total ? 'var(--success-fg)' : 'var(--danger-fg)' }}>{da(used)} / {da(total)}</span></div>
        </div>
        <Note icon="arrow-down-wide-narrow">Imputation automatique du plus ancien au plus récent ; modifiable ligne par ligne. Chaque document garde son propre versé / reste.</Note>
      </div>
    </Dialog>
  );
}

/* ================================================================== 2ᵉ stock « nombre » partout (F5, J5) */
export function NombreShowcase() {
  const { Tabs, Card, LineItemsEditor, DataTable, Badge } = ds();
  const [tab, setTab] = React.useState('caisse');
  const [lines, setLines] = React.useState([{ id: 1, name: 'Viande hachée (barquette)', code: 'PRD000014', price: 1450, qty: 2, nombre: '3', unit: 'barq.' }, { id: 2, name: 'Poulet entier', code: 'PRD000015', price: 520, qty: 3, nombre: '', unit: 'pièces', reserved: 1 }, { id: 3, name: 'Lait Candia 1 L', code: 'PRD000001', price: 100, qty: 6, nombre: null }]);
  const up = (id, k, v) => setLines(lines.map((l) => (l.id === id ? { ...l, [k]: v } : l)));
  const [rows, setRows] = React.useState([{ id: 1, code: 'PRD000014', nom: 'Viande hachée (barquette)', qte: '12', nombre: '20', prix: '1160' }, { id: 2, code: 'PRD000015', nom: 'Poulet entier', qte: '18', nombre: '', prix: '410' }]);
  const cols = [{ key: 'code', label: 'Code', muted: true, width: 110 }, { key: 'nom', label: 'Produit', strong: true }, { key: 'qte', label: 'Qté', editable: true, align: 'right', width: 90 }, { key: 'nombre', label: 'Nombre', editable: true, align: 'right', width: 96 }, { key: 'prix', label: 'Prix', editable: true, align: 'right', width: 110 }];
  const errors = Object.fromEntries(rows.filter((r) => !r.nombre).map((r) => [r.id, { nombre: 'Obligatoire' }]));
  const label = { entrees: 'Entrée SS000233', retours: 'Retour sur PN0000229', sorties: 'Sortie SRT000045 · Casse', transferts: 'Transfert TRM000012 · Central → Hydra' };
  return (
    <Card title="2ᵉ stock « nombre » dans chaque flux" icon="hash" padding={0}>
      <div style={{ padding: '0 16px' }}><Tabs value={tab} onChange={setTab} tabs={[{ key: 'caisse', label: 'Caisse' }, { key: 'entrees', label: 'Entrées' }, { key: 'retours', label: 'Retours' }, { key: 'sorties', label: 'Sorties' }, { key: 'transferts', label: 'Transferts' }, { key: 'stock', label: 'Stock' }]} /></div>
      <div style={{ padding: 16, display: 'flex', flexDirection: 'column', gap: 12 }}>
        {tab === 'caisse' && <div style={{ border: '1px solid var(--border-default)', borderRadius: 12, overflow: 'hidden', overflowX: 'auto' }}><div style={{ minWidth: 560 }}>{lines.map((l) => l.nombre == null
          ? <div key={l.id} style={{ display: 'flex', justifyContent: 'space-between', padding: '12px', borderBottom: '1px solid var(--border-subtle)', font: '500 13px var(--font-sans)', color: 'var(--text-secondary)' }}><span><b style={{ color: 'var(--text-primary)' }}>{l.name}</b> · {l.qty} pcs — nombre inactif sur ce produit</span><b style={{ color: 'var(--text-primary)' }}>{da(l.qty * l.price)}</b></div>
          : <CartLineQN key={l.id} {...l} nombreUnit={l.unit} onInc={() => up(l.id, 'qty', l.qty + 1)} onDec={() => up(l.id, 'qty', Math.max(1, l.qty - 1))} onNombre={(v) => up(l.id, 'nombre', v)} onRemove={() => setLines(lines.filter((x) => x.id !== l.id))} />)}</div></div>}
        {['entrees', 'retours', 'sorties', 'transferts'].includes(tab) && <><div style={{ font: '600 13px var(--font-sans)', color: 'var(--text-secondary)' }}>{label[tab]}</div><LineItemsEditor rows={rows} onChange={setRows} columns={tab === 'sorties' || tab === 'transferts' ? cols.filter((c) => c.key !== 'prix') : cols} lineTotal={tab === 'sorties' || tab === 'transferts' ? (r) => 0 : undefined} showTotals={!(tab === 'sorties' || tab === 'transferts')} errors={errors} /></>}
        {tab === 'stock' && <DataTable rows={[{ id: 1, code: 'PRD000014', nom: 'Viande hachée (barquette)', stock: '18 kg', nombre: '42 barq.', mag: 'Magasin Central' }, { id: 2, code: 'PRD000015', nom: 'Poulet entier', stock: '64 kg', nombre: '31 pièces', mag: 'Magasin Central' }, { id: 3, code: 'PRD000001', nom: 'Lait Candia 1 L', stock: '72 pcs', nombre: '—', mag: 'Magasin Central' }]} columns={[{ key: 'code', label: 'Code', muted: true }, { key: 'nom', label: 'Produit', strong: true }, { key: 'stock', label: 'Stock', align: 'right' }, { key: 'nombre', label: 'Nombre', align: 'right', render: (v) => (v === '—' ? v : <Badge tone="primary">{v}</Badge>) }, { key: 'mag', label: 'Magasin' }]} />}
        <Note>Le nombre ne s’affiche que pour les produits qui l’activent ; il est alors obligatoire et contrôlé contre le 2ᵉ stock.</Note>
      </div>
    </Card>
  );
}

/* ================================================================== Permissions : colonnes masquées et accès refusé (E3, E6) */
export function PermissionsDemo() {
  const { Card, DataTable, Switch, PermissionGrid } = ds();
  const [perm, setPerm] = React.useState({ voirPrixAchat: false, voirMarge: false });
  const rows = window.CDZ.products.slice(0, 5).map((p) => ({ ...p, marge: p.vente - p.achat, taux: Math.round(((p.vente - p.achat) / p.achat) * 100) + ' %' }));
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
      <Card title="Permissions d’action (7)" icon="shield-check"><PermissionGrid items={PermissionGrid.SPECIAL} value={{ voirPrixAchat: perm.voirPrixAchat, voirMarge: perm.voirMarge, modifierPrixVente: false, annulerOperations: true }} onChange={(v) => setPerm({ voirPrixAchat: !!v.voirPrixAchat, voirMarge: !!v.voirMarge })} columns={2} /></Card>
      <Card title="Effet sur les tableaux" icon="eye-off" padding={0} actions={<div style={{ display: 'flex', gap: 14, flexWrap: 'wrap' }}><Switch size="sm" checked={perm.voirPrixAchat} onChange={(v) => setPerm({ ...perm, voirPrixAchat: v })} label="voirPrixAchat" /><Switch size="sm" checked={perm.voirMarge} onChange={(v) => setPerm({ ...perm, voirMarge: v })} label="voirMarge" /></div>}>
        <DataTable rows={rows} hiddenColumns={hiddenByPerm(perm)} columns={[{ key: 'code', label: 'Code', muted: true }, { key: 'nom', label: 'Produit', strong: true }, { key: 'achat', label: 'Prix d’achat', align: 'right', render: (v) => da(v) }, { key: 'vente', label: 'Prix de vente', align: 'right', render: (v) => da(v) }, { key: 'marge', label: 'Marge', align: 'right', render: (v) => da(v) }, { key: 'taux', label: 'Taux', align: 'right' }, { key: 'stock', label: 'Stock', align: 'right' }]} />
      </Card>
      <AccessDenied module="Gestion caisse" onBack={() => {}} />
    </div>
  );
}
