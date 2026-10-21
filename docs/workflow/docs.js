// CaisseDZ documentation (docs/workflow/*.html): the EN | FR pill, Mermaid diagrams drawn for the language
// shown (Mermaid can't measure hidden ones), the choice remembered for every page.
(function () {
  var racine = document.documentElement;
  var titres = { en: racine.dataset.titleEn || document.title, fr: racine.dataset.titleFr || document.title };
  var sombre = racine.dataset.theme === 'dark' ||
    (racine.dataset.theme !== 'light' && window.matchMedia('(prefers-color-scheme: dark)').matches);
  var pret = !!window.mermaid;
  if (pret) {
    mermaid.initialize({
      startOnLoad: false,
      securityLevel: 'strict',
      theme: 'base',
      fontFamily: 'Poppins, system-ui, sans-serif',
      themeVariables: sombre ? {
        primaryColor: '#2d2950', primaryTextColor: '#ecebf5', primaryBorderColor: '#8f7cf0', lineColor: '#a9a6c0',
        secondaryColor: '#262338', tertiaryColor: '#1c1a2b', noteBkgColor: '#3a3160', noteTextColor: '#ecebf5',
        actorBkg: '#2d2950', actorTextColor: '#ecebf5', signalColor: '#c9b8ff', signalTextColor: '#ecebf5',
        labelBoxBkgColor: '#2d2950', labelTextColor: '#ecebf5', clusterBkg: '#1c1a2b', clusterBorder: '#353149'
      } : {
        primaryColor: '#ece8ff', primaryTextColor: '#1b1830', primaryBorderColor: '#6c5ce7', lineColor: '#6b6880',
        secondaryColor: '#fff3f5', tertiaryColor: '#ffffff', noteBkgColor: '#fff6dc', noteTextColor: '#1b1830',
        actorBkg: '#ece8ff', actorTextColor: '#1b1830', signalColor: '#4b2f63', signalTextColor: '#1b1830',
        clusterBkg: '#ffffff', clusterBorder: '#e6e2f3'
      },
      flowchart: { curve: 'basis', htmlLabels: true },
      sequence: { mirrorActors: false, wrap: true }
    });
  } else {
    document.querySelectorAll('.hors-ligne-msg').forEach(function (e) { e.style.display = 'inline'; });
  }

  function afficher(langue) {
    racine.lang = langue;
    document.title = titres[langue];
    document.querySelectorAll('.langue button').forEach(function (b) {
      b.setAttribute('aria-pressed', String(b.dataset.lang === langue));
    });
    try { localStorage.setItem('caissedz-docs-langue', langue); } catch (e) {}
    if (pret) {
      var aDessiner = document.querySelectorAll('.l-' + langue + ' pre.mermaid:not([data-processed])');
      if (aDessiner.length) mermaid.run({ nodes: aDessiner });
    }
  }

  document.querySelectorAll('.langue button').forEach(function (b) {
    b.addEventListener('click', function () { afficher(b.dataset.lang); });
  });
  var choix = null;
  try { choix = localStorage.getItem('caissedz-docs-langue') || localStorage.getItem('tendance-langue'); } catch (e) {}
  afficher(choix === 'fr' || choix === 'en' ? choix : 'en');
})();
