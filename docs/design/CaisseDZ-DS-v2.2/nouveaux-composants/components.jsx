// v2.2 · Phase 1 — composants manquants
// ContextMenu (B8b) · Calculator (B16b) · Code128 / QRCode / BarcodeCard QR (I7, V1) · CodeBarrePickerDialog (B13b)
// NombreField, CartLineQN, QuantiteNombreDialog (F5, J5) · AccessDenied + colonnes masquées (E6)
import JsBarcode from 'jsbarcode';
import qrcode from 'qrcode-generator';
import { ds, da, f2 } from './charts.jsx';

/* ------------------------------------------------------------------ ContextMenu */
export function ContextMenu({ x, y, items = [], title, onClose }) {
  const { Icon } = ds();
  const ref = React.useRef(null);
  const [pos, setPos] = React.useState({ left: x, top: y });
  React.useLayoutEffect(() => {
    const r = ref.current.getBoundingClientRect();
    setPos({ left: Math.max(8, Math.min(x, window.innerWidth - r.width - 8)), top: Math.max(8, Math.min(y, window.innerHeight - r.height - 8)) });
  }, [x, y]);
  React.useEffect(() => {
    const close = (e) => { if (!ref.current || !ref.current.contains(e.target)) onClose(); };
    const key = (e) => { if (e.key === 'Escape') onClose(); };
    window.addEventListener('mousedown', close); window.addEventListener('keydown', key); window.addEventListener('scroll', onClose, true); window.addEventListener('resize', onClose);
    return () => { window.removeEventListener('mousedown', close); window.removeEventListener('keydown', key); window.removeEventListener('scroll', onClose, true); window.removeEventListener('resize', onClose); };
  }, []);
  return ReactDOM.createPortal(
    <div ref={ref} role="menu" style={{ position: 'fixed', ...pos, zIndex: 400, minWidth: 220, padding: 6, borderRadius: 10, background: 'var(--surface-raised)', border: '1px solid var(--border-default)', boxShadow: 'var(--shadow-lg)', animation: 'cdz-scale-in var(--dur-fast) var(--ease-emphasized)' }}>
      {title && <div style={{ padding: '6px 10px 8px', font: '600 11px var(--font-sans)', letterSpacing: '.04em', textTransform: 'uppercase', color: 'var(--text-muted)' }}>{title}</div>}
      {items.map((it, i) => it.divider ? <div key={i} style={{ height: 1, margin: '5px 4px', background: 'var(--border-subtle)' }} /> : (
        <button key={i} role="menuitem" disabled={it.disabled} onClick={() => { onClose(); it.onClick && it.onClick(); }}
          style={{ width: '100%', display: 'flex', alignItems: 'center', gap: 10, height: 34, padding: '0 10px', border: 0, borderRadius: 7, background: 'transparent', cursor: it.disabled ? 'not-allowed' : 'pointer', opacity: it.disabled ? 0.45 : 1, color: it.danger ? 'var(--danger-fg)' : 'var(--text-primary)', font: '500 13px var(--font-sans)', textAlign: 'start' }}
          onMouseEnter={(e) => (e.currentTarget.style.background = it.danger ? 'var(--danger-tint)' : 'var(--surface-hover)')} onMouseLeave={(e) => (e.currentTarget.style.background = 'transparent')}>
          <Icon name={it.icon || 'dot'} size={16} color={it.danger ? 'var(--danger-fg)' : 'var(--icon-default)'} />
          <span style={{ flex: 1 }}>{it.label}</span>
          {it.kbd && <kbd style={{ font: '500 11px var(--font-sans)', color: 'var(--text-muted)' }}>{it.kbd}</kbd>}
        </button>
      ))}
    </div>, document.body
  );
}

/** Menu standard des tableaux de module : mêmes actions que la barre, accessibles au clic droit. */
export const rowMenu = (r, { onDetail, onEdit, onCancel, onPrint, onExport, onCopy } = {}) => [
  { label: 'Afficher le détail', icon: 'eye', kbd: 'Entrée', onClick: onDetail },
  { label: 'Modifier', icon: 'pencil', kbd: 'F2', onClick: onEdit },
  { label: 'Copier le code', icon: 'copy', kbd: 'Ctrl C', onClick: onCopy },
  { divider: true },
  { label: 'Imprimer', icon: 'printer', kbd: 'Ctrl P', onClick: onPrint },
  { label: 'Exporter la ligne', icon: 'file-spreadsheet', onClick: onExport },
  { divider: true },
  { label: 'Annuler…', icon: 'ban', kbd: 'Suppr', danger: true, onClick: onCancel, disabled: r && r.statut === 'annule' },
];

/* ------------------------------------------------------------------ Calculator */
export function Calculator({ onUse, useLabel = 'Utiliser le résultat' }) {
  const { Button, Icon } = ds();
  const [expr, setExpr] = React.useState('');
  const [hist, setHist] = React.useState([]);
  const evalExpr = (s) => {
    const clean = s.replace(/×/g, '*').replace(/÷/g, '/').replace(/,/g, '.').replace(/−/g, '-');
    if (!/^[\d.+\-*/()% ]*$/.test(clean) || !clean.trim()) return null;
    try { const v = Function('"use strict";return (' + clean.replace(/(\d+(?:\.\d+)?)%/g, '($1/100)') + ')')(); return isFinite(v) ? Math.round(v * 100) / 100 : null; } catch (e) { return null; }
  };
  const result = evalExpr(expr);
  const press = (k) => {
    if (k === 'C') return setExpr('');
    if (k === '⌫') return setExpr((e) => e.slice(0, -1));
    if (k === '=') { if (result != null) { setHist((h) => [[expr, result]].concat(h).slice(0, 4)); setExpr(String(result).replace('.', ',')); } return; }
    setExpr((e) => e + k);
  };
  React.useEffect(() => {
    const h = (e) => {
      const map = { '*': '×', '/': '÷', '-': '−', Enter: '=', Backspace: '⌫', Escape: 'C', '.': ',' };
      const k = map[e.key] || e.key;
      if (/^[\d+%(),]$/.test(k) || ['×', '÷', '−', '=', '⌫', 'C'].includes(k)) { e.preventDefault(); press(k); }
    };
    window.addEventListener('keydown', h); return () => window.removeEventListener('keydown', h);
  }, [expr, result]);
  const keys = ['C', '(', ')', '÷', '7', '8', '9', '×', '4', '5', '6', '−', '1', '2', '3', '+', '%', '0', ',', '='];
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
      <div style={{ padding: '12px 14px', borderRadius: 12, background: 'var(--surface-sunken)', border: '1px solid var(--border-subtle)', display: 'flex', flexDirection: 'column', alignItems: 'flex-end', gap: 4, minHeight: 92, direction: 'ltr' }}>
        {hist.slice(0, 2).map(([e, r], i) => <span key={i} style={{ font: '500 12px var(--font-sans)', color: 'var(--text-muted)', fontVariantNumeric: 'tabular-nums' }}>{e} = {String(r).replace('.', ',')}</span>)}
        <span style={{ font: '500 15px var(--font-sans)', color: 'var(--text-secondary)', minHeight: 20, wordBreak: 'break-all', fontVariantNumeric: 'tabular-nums' }}>{expr || '0'}</span>
        <span style={{ font: '700 28px/1.1 var(--font-sans)', color: 'var(--text-primary)', fontVariantNumeric: 'tabular-nums' }}>{result != null ? f2(result) : '—'}</span>
      </div>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 8, direction: 'ltr' }}>
        {keys.map((k) => {
          const op = '÷×−+%()'.includes(k), eq = k === '=', clr = k === 'C';
          return <button key={k} onClick={() => press(k)} style={{ height: 48, borderRadius: 10, cursor: 'pointer', border: eq ? 0 : '1px solid var(--border-default)', background: eq ? 'var(--primary)' : op ? 'var(--primary-tint)' : clr ? 'var(--danger-tint)' : 'var(--surface-card)', color: eq ? 'var(--primary-fg)' : op ? 'var(--primary-tint-fg)' : clr ? 'var(--danger-fg)' : 'var(--text-primary)', font: '600 18px var(--font-sans)', boxShadow: eq ? 'none' : 'var(--shadow-xs)' }}>{k}</button>;
        })}
      </div>
      <div style={{ display: 'flex', gap: 8 }}>
        <Button variant="secondary" icon="delete" onClick={() => press('⌫')}>Effacer</Button>
        {onUse && <Button icon="check" fullWidth disabled={result == null} onClick={() => onUse(result)}>{useLabel}</Button>}
      </div>
    </div>
  );
}
export function CalculatorDialog({ onClose, onUse, inline }) {
  const { Dialog } = ds();
  return <Dialog inline={inline} open width={inline ? '100%' : 380} icon="calculator" title="Calculatrice" description="Clavier : chiffres, + − × ÷, Entrée = résultat, Échap = effacer." onClose={onClose}><Calculator onUse={onUse && ((v) => { onUse(v); onClose && onClose(); })} useLabel="Reporter dans le champ" /></Dialog>;
}

/* ------------------------------------------------------------------ Codes-barres */
export function Code128({ value, height = 40, width = 1.4, color = '#111' }) {
  const ref = React.useRef(null);
  React.useEffect(() => { try { JsBarcode(ref.current, value, { format: 'CODE128', displayValue: false, height, width, margin: 0, lineColor: color, background: 'transparent' }); } catch (e) {} }, [value, height, width]);
  return <svg ref={ref} aria-label={'Code-barres ' + value} style={{ maxWidth: '100%', display: 'block' }} />;
}
export function QRCode({ value, size = 120, color = '#111', bg = '#fff' }) {
  const { n, d } = React.useMemo(() => {
    const q = qrcode(0, 'M'); q.addData(value); q.make();
    const n = q.getModuleCount(); let d = '';
    for (let r = 0; r < n; r++) for (let c = 0; c < n; c++) if (q.isDark(r, c)) d += `M${c} ${r}h1v1h-1z`;
    return { n, d };
  }, [value]);
  return <svg width={size} height={size} viewBox={`-2 -2 ${n + 4} ${n + 4}`} shapeRendering="crispEdges" role="img" aria-label={'QR ' + value} style={{ display: 'block', background: bg, borderRadius: 6 }}><path d={d} fill={color} /></svg>;
}
/** Code automatique §8.10 : CAISSEDZ + date + séquence (produits sans code fabricant). */
export const autoCode = (seq = 17, date = '20261010') => 'CAISSEDZ' + date + String(seq).padStart(4, '0');

/** BarcodeCard v2.2 — EAN-13 (DS) + formats CODE128 (code auto) et QR. */
export function BarcodeCardV22({ product, initial = 'ean' }) {
  const { BarcodeCard, SegmentedControl, Button } = ds();
  const [fmt, setFmt] = React.useState(initial);
  const p = product || { nom: 'Lait Candia 1 L', vente: 100, ean: '6130234000126' };
  const auto = autoCode(17);
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
      <SegmentedControl size="sm" value={fmt} onChange={setFmt} options={[{ value: 'ean', label: 'EAN-13' }, { value: 'auto', label: 'Code auto' }, { value: 'qr', label: 'QR' }]} />
      {fmt === 'ean' && <BarcodeCard value={p.ean} name={p.nom} price={p.vente} compact />}
      {fmt !== 'ean' && (
        <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8, padding: 14, borderRadius: 12, border: '1px solid var(--border-default)', background: '#fff', color: '#111' }}>
          <span style={{ font: '600 13px var(--font-sans)' }}>{p.nom}</span>
          {fmt === 'auto' ? <Code128 value={auto} height={56} width={1.3} /> : <QRCode value={auto + '|' + p.nom + '|' + p.vente} size={112} />}
          <span style={{ font: '500 11.5px var(--font-mono)', letterSpacing: '.04em' }}>{auto}</span>
          <span style={{ font: '700 15px var(--font-sans)' }}>{da(p.vente)}</span>
        </div>
      )}
      <div style={{ display: 'flex', gap: 8 }}><Button size="sm" variant="secondary" icon="printer">Imprimer l’étiquette</Button><Button size="sm" variant="ghost" icon="copy">Copier</Button></div>
    </div>
  );
}

/** Sélection « code-barres » (preset de lookup) : choisir un code existant ou en générer un. */
export function CodeBarrePickerDialog({ onClose, onPick, inline }) {
  const { PickerDialog } = ds();
  const rows = [
    { id: 1, code: '6130234000126', type: 'EAN-13', produit: 'Lait Candia 1 L', colis: 'Unité' },
    { id: 2, code: '6130234000171', type: 'EAN-13', produit: 'Lait Candia 1 L', colis: 'Carton ×12' },
    { id: 3, code: '5449000000996', type: 'EAN-13', produit: 'Coca-Cola 1,5 L', colis: 'Unité' },
    { id: 4, code: '6133002000034', type: 'EAN-13', produit: 'Huile Elio 1 L', colis: 'Unité' },
    { id: 5, code: autoCode(16), type: 'Code auto', produit: 'Pain de mie maison', colis: 'Unité' },
    { id: 6, code: autoCode(17), type: 'Code auto', produit: 'Olives vertes vrac', colis: 'Unité' },
  ];
  return <PickerDialog inline={inline} width={inline ? '100%' : 760} title="Choisir un code-barres" description="Scannez, tapez ou choisissez ; « Nouveau » génère un code CAISSEDZ + date." icon="barcode" multiple={false} confirmLabel="Choisir" createLabel="Générer un code" onCreate={() => {}}
    columns={[{ key: 'code', label: 'Code-barres', strong: true, mono: true }, { key: 'type', label: 'Type', muted: true }, { key: 'produit', label: 'Produit' }, { key: 'colis', label: 'Colis', muted: true }]}
    rows={rows} searchKeys={['code', 'produit']} searchPlaceholder="Scanner ou rechercher un code…" onClose={onClose} onConfirm={(r) => { onPick && onPick(r[0]); onClose && onClose(); }} />;
}

/* ------------------------------------------------------------------ 2ᵉ stock « nombre » */
/** NombreField — saisie du 2ᵉ stock (pièces comptées à part : sachets, bouteilles, mètres…). Obligatoire si le produit l’active. */
export function NombreField({ value, onChange, unit = 'nombre', required = true, available, error }) {
  const { TextField } = ds();
  return <TextField numeric icon="hash" suffix={unit} value={value} onChange={onChange} placeholder={required ? 'Obligatoire' : 'Optionnel'} error={error || (available != null && Number(value) > available ? 'Nombre disponible : ' + available : undefined)} />;
}

/** CartLineQN — ligne de panier « quantité + nombre » (le nombre se saisit en plus de la quantité). */
export function CartLineQN({ name, code, price, qty = 1, nombre, nombreUnit = 'nb', pack = 'Unité', onInc, onDec, onNombre, onRemove, reserved }) {
  const { Icon, IconButton } = ds();
  return (
    <div style={{ display: 'grid', gridTemplateColumns: 'minmax(0,1fr) 92px 82px 96px 28px', alignItems: 'center', gap: 10, padding: '10px 12px', borderBottom: '1px solid var(--border-subtle)' }}>
      <div style={{ minWidth: 0 }}>
        <div style={{ font: '600 13.5px var(--font-sans)', color: 'var(--text-primary)', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{name}</div>
        <div style={{ font: '500 11.5px var(--font-sans)', color: 'var(--text-muted)', display: 'flex', gap: 6, alignItems: 'center' }}>{code} · {pack}{reserved ? <span style={{ color: 'var(--warning-fg)', display: 'inline-flex', alignItems: 'center', gap: 3 }}><Icon name="lock" size={11} />{reserved} réservé(s)</span> : null}</div>
      </div>
      <div style={{ display: 'flex', alignItems: 'center', gap: 2, border: '1px solid var(--border-default)', borderRadius: 8, height: 32 }}>
        <IconButton icon="minus" size="sm" onClick={onDec} title="Diminuer (−)" /><span style={{ flex: 1, textAlign: 'center', font: '700 13px var(--font-sans)', fontVariantNumeric: 'tabular-nums' }}>{qty}</span><IconButton icon="plus" size="sm" onClick={onInc} title="Augmenter (+)" />
      </div>
      <label style={{ display: 'flex', alignItems: 'center', gap: 4, height: 32, padding: '0 8px', borderRadius: 8, border: '1px solid ' + (nombre === '' ? 'var(--danger)' : 'var(--border-default)'), background: 'var(--surface-card)' }}>
        <Icon name="hash" size={13} color="var(--icon-muted)" />
        <input value={nombre} onChange={(e) => onNombre && onNombre(e.target.value.replace(/\D/g, ''))} inputMode="numeric" aria-label="Nombre" style={{ width: '100%', minWidth: 0, border: 0, outline: 0, background: 'transparent', font: '700 13px var(--font-sans)', color: 'var(--text-primary)', fontVariantNumeric: 'tabular-nums' }} />
        <span style={{ font: '500 11px var(--font-sans)', color: 'var(--text-muted)' }}>{nombreUnit}</span>
      </label>
      <div style={{ textAlign: 'end', font: '700 13.5px var(--font-sans)', color: 'var(--text-primary)', fontVariantNumeric: 'tabular-nums' }}>{da(qty * price)}</div>
      <IconButton icon="trash-2" size="sm" onClick={onRemove} title="Retirer (Suppr)" />
    </div>
  );
}

/** Dialog « Quantité et colis » — variante avec nombre (F5). */
export function QuantiteNombreDialog({ onClose, onAdd, inline }) {
  const { Dialog, ChoiceCards, Numpad, Button, FormRow, Icon } = ds();
  const p = { nom: 'Viande hachée (barquette)', code: 'PRD000014', vente: 1450, stock: 18, nombre: 42 };
  const [mode, setMode] = React.useState('u');
  const [q, setQ] = React.useState('2');
  const [nb, setNb] = React.useState('');
  const qn = parseInt(q || '0', 10), nbn = parseInt(nb || '0', 10);
  const err = !nb ? 'Le nombre est obligatoire pour ce produit' : nbn > p.nombre ? 'Nombre disponible : ' + p.nombre : null;
  return (
    <Dialog inline={inline} open width={inline ? '100%' : 720} icon="package" title="Quantité, colis et nombre" description={p.code + ' · 2ᵉ stock « nombre » actif sur ce produit'} onClose={onClose}
      footer={<><Button variant="secondary" onClick={onClose}>Annuler</Button><Button icon="plus" kbd="Entrée" disabled={!qn || !!err} onClick={() => onAdd && onAdd({ q: qn, nb: nbn })}>Ajouter · {da(qn * p.vente)}</Button></>}>
      <div style={{ display: 'grid', gridTemplateColumns: 'minmax(0,1fr) 232px', gap: 20 }}>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 12, minWidth: 0 }}>
          <div style={{ font: '700 15px var(--font-sans)', color: 'var(--text-primary)' }}>{p.nom}</div>
          <ChoiceCards columns={1} size="sm" value={mode} onChange={setMode} options={[{ value: 'u', label: "À l'unité", meta: da(p.vente) + ' / kg' }]} />
          <FormRow label="Nombre" required labelWidth={80} hint={'Stock : ' + p.stock + ' kg · ' + p.nombre + ' barquettes'} error={err || undefined}><NombreField value={nb} onChange={setNb} unit="barquettes" available={p.nombre} /></FormRow>
          <div style={{ display: 'flex', gap: 8, alignItems: 'flex-start', padding: '10px 12px', borderRadius: 10, background: 'var(--info-tint)', color: 'var(--info-fg)', font: '500 12.5px/1.45 var(--font-sans)' }}><Icon name="info" size={15} style={{ marginTop: 1 }} />Le nombre se compte à part de la quantité : 2 kg peuvent faire 3 barquettes. Il est décompté du 2ᵉ stock et imprimé sur le ticket.</div>
        </div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
          <div style={{ font: '500 13px var(--font-sans)', color: 'var(--text-secondary)' }}>Quantité (kg)</div>
          <div style={{ height: 52, display: 'flex', alignItems: 'center', justifyContent: 'center', borderRadius: 10, border: '1px solid var(--border-focus)', boxShadow: 'var(--ring-focus)', font: '700 26px var(--font-sans)', color: 'var(--text-primary)' }}>{q || '0'}</div>
          <Numpad size="sm" decimals value={q} onChange={setQ} />
        </div>
      </div>
    </Dialog>
  );
}

/* ------------------------------------------------------------------ Permissions */
/** AccessDenied — écran affiché quand le rôle n’a pas la permission du module (E6). */
export function AccessDenied({ module = 'Gestion caisse', onBack, compact }) {
  const { LicenseGate } = ds();
  return <LicenseGate kind="refuse" compact={compact} description={`Votre rôle n’a pas accès au module « ${module} ». Demandez à l’administrateur de l’ajouter à votre rôle.`} onAction={onBack} />;
}
/** Colonnes masquées selon voirPrixAchat / voirMarge (E6). */
export const hiddenByPerm = (perm) => [].concat(perm.voirPrixAchat ? [] : ['achat'], perm.voirMarge ? [] : ['marge', 'taux']);
