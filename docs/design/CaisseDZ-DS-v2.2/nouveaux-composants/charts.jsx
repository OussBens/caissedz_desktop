// v2.2 · Phase 1 — graphiques manquants (B18) : courbe et barres horizontales classées
export const ds = () => window.CaisseDZDesignSystem_9ce617;
export const f0 = (n) => Math.round(n || 0).toLocaleString('fr-FR');
export const f2 = (n) => (n || 0).toLocaleString('fr-FR', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
export const da = (n) => f2(n) + ' DA';
export const kda = (n) => (Math.abs(n) >= 1000 ? (n / 1000).toLocaleString('fr-FR', { maximumFractionDigits: 1 }) + ' k' : f0(n));

// Échelle « ronde » : 4 graduations sur des valeurs lisibles
function niceMax(v) {
  if (v <= 0) return 1;
  const p = Math.pow(10, Math.floor(Math.log10(v)));
  const m = [1, 1.5, 2, 2.5, 3, 4, 5, 6, 8, 10].find((x) => x * p >= v);
  return m * p;
}

/**
 * LineChart — une ou plusieurs séries sur des catégories (jours, heures…).
 * series = [{ name, color, values: [] }], labels = []
 */
export function LineChart({ labels = [], series = [], height = 220, formatValue = kda, area = true, showDots = true }) {
  const ref = React.useRef(null);
  const [w, setW] = React.useState(560);
  const [hover, setHover] = React.useState(null);
  React.useEffect(() => {
    if (!ref.current || typeof ResizeObserver === 'undefined') return;
    const ro = new ResizeObserver(([e]) => setW(Math.max(240, e.contentRect.width)));
    ro.observe(ref.current);
    return () => ro.disconnect();
  }, []);
  const padL = 44, padR = 12, padT = 12, padB = 26;
  const max = niceMax(Math.max(1, ...series.flatMap((s) => s.values)));
  const n = labels.length;
  const x = (i) => padL + (n <= 1 ? 0 : (i * (w - padL - padR)) / (n - 1));
  const y = (v) => padT + (1 - v / max) * (height - padT - padB);
  const ticks = [0, 0.25, 0.5, 0.75, 1].map((t) => t * max);
  const every = Math.ceil(n / Math.max(2, Math.floor((w - padL) / 64)));
  const onMove = (e) => {
    const r = e.currentTarget.getBoundingClientRect();
    const px = ((e.clientX - r.left) / r.width) * w;
    const i = Math.round(((px - padL) / (w - padL - padR)) * (n - 1));
    setHover(i >= 0 && i < n ? i : null);
  };
  return (
    <div ref={ref} style={{ position: 'relative', width: '100%' }}>
      <svg width="100%" height={height} viewBox={`0 0 ${w} ${height}`} onMouseMove={onMove} onMouseLeave={() => setHover(null)} role="img" aria-label="Graphique en courbe" style={{ display: 'block', overflow: 'visible' }}>
        {ticks.map((t, k) => (
          <g key={k}>
            <line x1={padL} x2={w - padR} y1={y(t)} y2={y(t)} stroke="var(--border-subtle)" strokeDasharray={k ? '3 4' : '0'} />
            <text x={padL - 8} y={y(t) + 4} textAnchor="end" style={{ font: '500 10.5px var(--font-sans)', fill: 'var(--text-muted)', fontVariantNumeric: 'tabular-nums' }}>{formatValue(t)}</text>
          </g>
        ))}
        {labels.map((l, i) => (i % every === 0 || i === n - 1) && (
          <text key={i} x={x(i)} y={height - 6} textAnchor={i === 0 ? 'start' : i === n - 1 ? 'end' : 'middle'} style={{ font: '500 10.5px var(--font-sans)', fill: 'var(--text-muted)' }}>{l}</text>
        ))}
        {series.map((s, si) => {
          const pts = s.values.map((v, i) => [x(i), y(v)]);
          const d = pts.map((p, i) => (i ? 'L' : 'M') + p[0].toFixed(1) + ' ' + p[1].toFixed(1)).join(' ');
          const c = s.color || `var(--chart-${si + 1})`;
          return (
            <g key={si}>
              {area && si === 0 && <path d={d + ` L ${x(n - 1)} ${y(0)} L ${x(0)} ${y(0)} Z`} fill={c} opacity=".10" />}
              <path d={d} fill="none" stroke={c} strokeWidth={si === 0 ? 2.5 : 2} strokeDasharray={s.dashed ? '5 5' : undefined} strokeLinejoin="round" strokeLinecap="round" />
              {showDots && pts.map((p, i) => (hover === i || n <= 12) && <circle key={i} cx={p[0]} cy={p[1]} r={hover === i ? 4.5 : 3} fill="var(--surface-card)" stroke={c} strokeWidth="2" />)}
            </g>
          );
        })}
        {hover != null && <line x1={x(hover)} x2={x(hover)} y1={padT} y2={height - padB} stroke="var(--border-strong)" strokeDasharray="2 3" />}
      </svg>
      {hover != null && (
        <div style={{ position: 'absolute', top: 4, left: Math.min(Math.max(0, x(hover) - 70), w - 150), width: 150, padding: '8px 10px', borderRadius: 8, background: 'var(--surface-raised)', border: '1px solid var(--border-default)', boxShadow: 'var(--shadow-md)', pointerEvents: 'none', display: 'flex', flexDirection: 'column', gap: 4 }}>
          <span style={{ font: '600 11.5px var(--font-sans)', color: 'var(--text-secondary)' }}>{labels[hover]}</span>
          {series.map((s, si) => (
            <span key={si} style={{ display: 'flex', alignItems: 'center', gap: 6, font: '600 12px var(--font-sans)', color: 'var(--text-primary)', fontVariantNumeric: 'tabular-nums' }}>
              <i style={{ width: 8, height: 8, borderRadius: 2, background: s.color || `var(--chart-${si + 1})` }} />
              <span style={{ flex: 1, fontWeight: 500, color: 'var(--text-secondary)' }}>{s.name}</span>{formatValue(s.values[hover])}
            </span>
          ))}
        </div>
      )}
      {series.length > 1 && (
        <div style={{ display: 'flex', gap: 14, flexWrap: 'wrap', marginTop: 6 }}>
          {series.map((s, si) => (
            <span key={si} style={{ display: 'inline-flex', alignItems: 'center', gap: 6, font: '500 12px var(--font-sans)', color: 'var(--text-secondary)' }}>
              <i style={{ width: 14, height: 0, borderTop: `2.5px ${s.dashed ? 'dashed' : 'solid'} ${s.color || `var(--chart-${si + 1})`}` }} />{s.name}
            </span>
          ))}
        </div>
      )}
    </div>
  );
}

/** RankedBars — classement horizontal (top produits, ventes par caissier). data = [{ label, value, caption }] */
export function RankedBars({ data = [], formatValue = da, max: maxProp, color = 'var(--primary)', showRank = true, onRowClick }) {
  const max = maxProp || Math.max(1, ...data.map((d) => d.value));
  return (
    <ol style={{ listStyle: 'none', margin: 0, padding: 0, display: 'flex', flexDirection: 'column', gap: 10 }}>
      {data.map((d, i) => (
        <li key={d.label} onClick={onRowClick ? () => onRowClick(d) : undefined} style={{ display: 'grid', gridTemplateColumns: (showRank ? '22px ' : '') + 'minmax(0,1fr) auto', alignItems: 'center', columnGap: 10, rowGap: 5, cursor: onRowClick ? 'pointer' : 'default' }}>
          {showRank && <span style={{ gridRow: 'span 2', width: 22, height: 22, borderRadius: 6, display: 'inline-flex', alignItems: 'center', justifyContent: 'center', font: '700 11px var(--font-sans)', background: i < 3 ? 'var(--primary-tint)' : 'var(--surface-sunken)', color: i < 3 ? 'var(--primary-tint-fg)' : 'var(--text-muted)' }}>{i + 1}</span>}
          <span style={{ minWidth: 0, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap', font: '500 13px var(--font-sans)', color: 'var(--text-primary)' }}>
            {d.label}{d.caption && <span style={{ color: 'var(--text-muted)', fontWeight: 400 }}> · {d.caption}</span>}
          </span>
          <span style={{ font: '600 12.5px var(--font-sans)', color: 'var(--text-primary)', fontVariantNumeric: 'tabular-nums' }}>{formatValue(d.value)}</span>
          <span style={{ gridColumn: showRank ? '2 / 4' : '1 / 3', height: 6, borderRadius: 3, background: 'var(--chart-track)', overflow: 'hidden' }}>
            <span style={{ display: 'block', height: '100%', width: (d.value / max) * 100 + '%', borderRadius: 3, background: d.color || color, transformOrigin: 'left', animation: 'cdz-grow-x var(--dur-slower) var(--ease-emphasized)' }} />
          </span>
        </li>
      ))}
    </ol>
  );
}
