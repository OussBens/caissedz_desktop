"""Génère docs/workflow/workflow.html : présentation fonctionnelle module par module (modèle « Workflow &
Fonctionnement » de l'ancienne version), avec les captures de docs/workflow/captures/.

Usage : python3 tool/workflow_html.py
Captures : CAPTURES=1 flutter test test/outils/captures_workflow_test.dart
"""
import html
import os

SORTIE = 'docs/workflow/workflow.html'
E = html.escape

# ———————————————————————————— Contenu ————————————————————————————

NOUVEAUTES = [
    ('🧾', 'TVA HT / TVA / TTC partout', "Taux 19 %, 9 % ou exonéré figé sur chaque ligne ; ticket, facture, clôture Z, "
     "détail des ventes et des entrées, analyse « TVA par taux » ; TVA déductible sur les entrées ; aide G50 ; "
     "régime Réel ou IFU."),
    ('🔢', 'Factures et avoirs numérotés', "Numérotation continue FAC / AVO distincte du ticket VTE, identités "
     "fiscales du vendeur (NIF, NIS, RC, article d'imposition) et du client figées, montant en lettres, avoir "
     "automatique sur retour ou annulation."),
    ('📄', 'Devis, proforma, commande, BL', "Devis DEV et proforma PRO transformables en bon de commande BCC, "
     "livré en une ou plusieurs fois par des bons de livraison LIV distincts du ticket."),
    ('🚚', 'Commandes fournisseurs', "Bon de commande BCF réceptionné en une ou plusieurs entrées ; quantités "
     "reçues calculées, reliquat soldé à la main."),
    ('☎️', 'Téléphone sur 10 chiffres', "Saisie limitée à 10 chiffres pour les clients et les fournisseurs."),
    ('⚖️', 'Solde initial des tiers', "Dette ou avance de reprise saisie à la création d'un client ou d'un "
     "fournisseur ; comptée dans le solde, le relevé et imputée en premier."),
    ('🔎', 'Filtre tiers des versements', "Les versements se filtrent par client ou fournisseur."),
]

GENERALES = [
    ('🖥️', 'Point de vente complet', 'Multi-paniers, scan code-barres, remises, plusieurs modes de paiement, raccourcis F1 à F12.'),
    ('📦', 'Stock en temps réel', 'Quantité toujours recalculée depuis le journal des mouvements, jamais saisie à la main.'),
    ('🏬', 'Multi-magasins', 'Stock séparé par magasin, transferts tracés, colonne Total sur tous les magasins.'),
    ('👥', 'Multi-utilisateurs', 'Comptes individuels, rôles et permissions personnalisables, caisse attachée par utilisateur.'),
    ('💳', 'Comptant ou à crédit', 'Vente payée, partielle ou à crédit, plafond de crédit par client, versements imputés.'),
    ('🏷️', 'Remises flexibles', 'Par produit ou par montant de panier, actives seulement entre leurs dates.'),
    ('🧮', 'Vente par colis', "Prix à l'unité ou par colis (boîte, carton) ; 2ᵉ stock « nombre » de pièces si besoin."),
    ('🧩', 'Packs produits', 'Vente groupée à prix dédié, éclatée en lignes au prorata du prix.'),
    ('↩️', 'Retours & annulations', 'Retour client ou fournisseur par ligne, annulation avec motif, stock rétabli.'),
    ('🧾', 'TVA & factures', 'HT / TVA / TTC, factures et avoirs numérotés, droit de timbre, aide G50.'),
    ('📄', 'Devis & commandes', 'Devis, proforma, commandes clients livrées par bons de livraison.'),
    ('🌙', 'Calcul de la Zakat', 'Capital commercial (stock, liquidités, créances, dettes) et nissab.'),
    ('📜', 'Audit complet', 'Créé / modifié le, par qui, sur chaque fiche ; journal Historique immuable.'),
    ('📊', 'Tableau de bord & analyses', 'KPI de la période, 11 analyses de situation dont la TVA par taux.'),
    ('🖨️', 'Export & impression', 'Excel et PDF sur tous les tableaux, tickets 58 / 80 mm, documents A4.'),
    ('🌐', 'Multilingue', 'Français, anglais et arabe avec interface de droite à gauche.'),
]

MODULES = [
    dict(
        cat='Pilotage', nom='Tableau de bord', icone='📊',
        desc="Vue d'ensemble de l'activité sur la période choisie, comparée à la période précédente ; l'onglet "
             "Situation regroupe les analyses détaillées.",
        captures=[('tableau_bord.png', 'Tableau de bord'), ('situation.png', 'Situation : 11 analyses')],
        sous=['Tableau de bord', 'Situation (11 analyses)'],
        champs=['Période (jour, semaine, mois, période)', 'Ventes', 'Achats', 'Net', 'Dette fournisseurs',
                'Crédit clients', 'Top produits', 'Ventes par caissier'],
        actions=['Changer de période', 'Exporter', 'Ouvrir une analyse', 'Analyse TVA par taux', 'Excel / PDF'],
        scenarios=[
            "Fin de mois : choix « Mois » puis comparaison des ventes, achats et du net avec le mois précédent.",
            "Préparation de la G50 : Situation → « TVA par taux » donne la base HT, la TVA collectée, la TVA "
            "déductible et la TVA nette par taux.",
            "Réassort : le Top 5 produits indique les articles à recommander en priorité.",
        ],
    ),
    dict(
        cat='Ventes', nom='Caisse', icone='🛒',
        desc="L'écran de vente au comptoir : le caissier scanne ou choisit les produits, applique les remises, "
             "choisit le client et encaisse. Une session de caisse ouverte est obligatoire.",
        captures=[('caisse.png', 'Panier en cours, produits du catalogue')],
        sous=['Multi-paniers (Ctrl+N)', 'Ventes du jour (F12)', 'Recette produit', 'Mouvement de caisse',
              'Clôture'],
        champs=['Client', 'Produits (code-barres, recherche)', "Mode d'achat (unité / colis)", 'Pièces',
                'Remise', 'Mode de paiement', 'Total à payer'],
        actions=['Scanner (F2)', 'Recherche (F3)', 'Encaisser (F4)', 'Enregistrer (F6)', 'Client (F7)',
                 'Remise (F8)', 'Calculatrice (F9)', 'Vider (F10)', 'Entrée rapide (E)', '+200 / +500 / +1000',
                 'Imprimer la facture'],
        scenarios=[
            "Client avec articles : scan du code-barres, un 2ᵉ scan du même produit passe la quantité à 2, "
            "encaissement F4, ticket imprimé avec HT et TVA par taux.",
            "Client professionnel à crédit : choix du client (F7), paiement partiel, le reste s'ajoute à son "
            "solde dans la limite de son plafond.",
            "Article non codifié : touche +200 / +500 ou « Autre montant » pour vendre au montant.",
        ],
    ),
    dict(
        cat='Ventes', nom='Ventes', icone='🧾',
        desc="L'historique des paniers encaissés et, dans un onglet dédié, les factures et factures d'avoir "
             "émises avec leur numérotation continue.",
        captures=[('ventes.png', 'Paniers'), ('factures.png', 'Factures & avoirs')],
        sous=['Paniers', 'Factures & avoirs'],
        champs=['Code VTE', 'Date', 'Client', 'Caissier', 'Montant TTC', 'HT / TVA', 'Versé', 'Reste',
                'N° FAC / AVO', 'Timbre', 'Net à payer'],
        actions=['Détail', 'Liste des produits', 'Imprimer la facture', 'Bon de livraison', 'Modifier',
                 'Annuler (motif)', 'Vérifier le scellement', 'Vérifier la chaîne des factures', 'Excel / PDF'],
        scenarios=[
            "Un client demande une facture : FAC numérotée, NIF / NIS / RC / AI des deux parties, montant en "
            "lettres, droit de timbre sur la part payée en espèces.",
            "Retour sur une vente facturée : une facture d'avoir AVO est émise automatiquement et apparaît "
            "dans l'onglet Factures & avoirs.",
            "Contrôle : « Vérifier la chaîne » recalcule l'empreinte SHA-256 de chaque facture.",
        ],
    ),
    dict(
        cat='Ventes', nom='Devis & commandes', icone='📄', nouveau=True,
        desc="Le circuit commercial avant la vente : devis et factures proforma, bons de commande clients livrés "
             "en une ou plusieurs fois, et bons de livraison.",
        captures=[('documents.png', 'Devis'), ('livraison_dialog.png', "Livraison partielle d'une commande"),
                  ('commandes_clients.png', 'Commandes clients'), ('livraisons.png', 'Bons de livraison')],
        sous=['Devis (DEV)', 'Proformas (PRO)', 'Commandes clients (BCC)', 'Bons de livraison (LIV)'],
        champs=['Client', 'Validité', 'P.U. TTC', 'Taux TVA', 'HT / TVA / TTC', 'Livré', 'Reste à livrer',
                'Statut'],
        actions=['Nouveau devis', 'Nouvelle proforma', 'Nouvelle commande', 'Imprimer (A4)', 'Modifier',
                 'Accepter', 'Refuser', 'Transformer en commande', 'Livrer', 'Annuler'],
        scenarios=[
            "Devis accepté : « Transformer en commande » crée le BCC avec les mêmes lignes et prix ; le devis "
            "passe « Transformé ».",
            "Livraison partielle : 10 sur 20 livrés, la vente et le bon de livraison sont créés ensemble, le "
            "stock sort, le reste est dû par le client ; la commande passe « Partiellement livrée ».",
            "Dossier administratif : la proforma A4 porte la mention « ne vaut pas facture » ; un BL peut aussi "
            "être imprimé pour une vente de caisse depuis Ventes.",
        ],
    ),
    dict(
        cat='Ventes', nom='Retours', icone='↩️',
        desc="Retours clients et fournisseurs, par ligne de la pièce d'origine, avec remise en stock ou non et "
             "règlement en avoir ou en espèces.",
        captures=[('retours.png', 'Retours clients')],
        sous=['Retours clients', 'Retours fournisseurs'],
        champs=["Client / fournisseur", "Pièce d'origine (ses seules ventes ou entrées)", 'Ligne', 'Quantité',
                'Remise en stock', 'Règlement (avoir / espèces)', 'Observation'],
        actions=['Nouveau retour client', 'Nouveau retour fournisseur', 'Détail', 'Modifier', 'Annuler'],
        scenarios=[
            "Client qui rapporte un article : choix du client, la liste ne propose que ses ventes ; avoir "
            "imputé sur son solde.",
            "Produit cassé : retour non remis en stock, une sortie « Casse » liée est créée automatiquement.",
            "Retour fournisseur : la dette envers le fournisseur diminue du montant retourné.",
        ],
    ),
    dict(
        cat='Stock', nom='Produits', icone='🏷️',
        desc="Le catalogue : fiches produits, catégories, sous-catégories, remises et packs.",
        captures=[('produits.png', 'Produits')],
        sous=['Produits', 'Catégories', 'Sous-catégories', 'Remises', 'Packs'],
        champs=['Code PRD', 'Désignation', 'Code-barres', "Prix d'achat", 'Prix de vente', 'TVA (19 / 9 / 0 %)',
                'Seuil', 'Colis', 'Pièces par unité', 'Expiration'],
        actions=['Nouveau produit', 'Mode IA (fiche pré-remplie)', 'Import Excel', 'Modifier', 'Désactiver',
                 'Nouvelle remise', 'Nouveau pack', 'Excel / PDF'],
        scenarios=[
            "Création assistée : le code-barres scanné interroge le catalogue CaisseDZ, Mantouj puis Open Food "
            "Facts pour pré-remplir la fiche.",
            "Remise « Par montant » : déclenchée en caisse au-delà d'un seuil de panier, entre deux dates.",
            "Reprise d'un ancien logiciel : import d'un classeur Excel avec correspondance des colonnes.",
        ],
    ),
    dict(
        cat='Stock', nom='Stock', icone='📦',
        desc="Le niveau de stock par magasin, calculé depuis le journal des mouvements, et ce journal lui-même.",
        captures=[('stock.png', 'Stock par magasin')],
        sous=['Stock', 'Mouvements'],
        champs=['Produit', 'Stock par magasin', 'Total', 'Pièces', 'Valeur', 'État (rupture / sous le seuil)',
                'Type de mouvement', 'Référence'],
        actions=['Détail', 'Distribution', 'Voir les mouvements', 'Excel / PDF'],
        scenarios=[
            "Vérifier un écart : le journal des mouvements d'un produit montre chaque entrée, vente, retour et "
            "sortie avec sa référence.",
            "Filtre magasin : la colonne Total reste calculée sur tous les magasins consultables.",
            "Préparer un réassort : filtre « sous le seuil » puis envoi vers une liste de besoins.",
        ],
    ),
    dict(
        cat='Stock', nom='Entrées / Achats', icone='📥',
        desc="Réceptions fournisseurs : saisie avec scan, lecture IA des bons, entrée rapide, paiement immédiat "
             "ou à crédit, TVA déductible figée par ligne.",
        captures=[('entrees.png', 'Entrées')],
        sous=['Smart Scan', 'Mode IA'],
        champs=['Fournisseur', 'N° facture', 'Magasin', 'Quantité', "Prix d'achat", 'TVA déductible',
                'Versé / reste', 'Caisse de paiement'],
        actions=['Nouvelle entrée', 'Entrée rapide', 'Liste des produits', 'Modifier', 'Annuler',
                 'Réceptionner une commande fournisseur'],
        scenarios=[
            "Facture fournisseur reçue en photo : le Smart Scan IA extrait les lignes, l'utilisateur valide.",
            "Réception d'une commande BCF : l'entrée s'ouvre pré-remplie avec les quantités restant à recevoir.",
            "Achat payé en partie : le reste s'ajoute à la dette fournisseur, réglée plus tard par versement.",
        ],
    ),
    dict(
        cat='Stock', nom='Commandes fournisseurs', icone='🚚', nouveau=True,
        desc="Les bons de commande envoyés aux fournisseurs, réceptionnés en une ou plusieurs entrées.",
        captures=[('commandes_fournisseurs.png', 'Commandes fournisseurs')],
        sous=['Écran unique (tableau + filtres)'],
        champs=['N° BCF', 'Fournisseur', 'Magasin de réception', 'Livraison prévue', 'Commandé',
                'Reçu', 'Reste à recevoir', "Prix d'achat", 'Statut'],
        actions=['Nouvelle commande fournisseur', 'Imprimer (A4)', 'Modifier', 'Réceptionner', 'Solder',
                 'Annuler'],
        scenarios=[
            "Depuis une liste de besoins : « Créer une commande fournisseur », puis impression A4 à envoyer.",
            "Livraison partielle : 48 cartons reçus sur 96, la commande passe « Partiellement reçue ».",
            "Reliquat jamais livré : « Solder » arrête l'attente ; une entrée annulée remet sa quantité en "
            "attente.",
        ],
    ),
    dict(
        cat='Stock', nom='Sorties', icone='📤',
        desc="Sorties de stock hors vente : casse, péremption, consommation interne.",
        captures=[('sorties.png', 'Sorties')],
        sous=['Écran unique (tableau + filtres)'],
        champs=['Code SRT', 'Magasin', 'Motif', 'Produits', 'Quantité', 'Pièces', "Valeur au prix d'achat"],
        actions=['Nouvelle sortie', 'Détail', 'Liste des produits', 'Modifier', 'Annuler'],
        scenarios=[
            "Produits périmés : sortie motif « Péremption », le stock et la valeur baissent.",
            "Quantité plafonnée : impossible de sortir plus que le stock du magasin.",
            "Erreur de saisie : annulation avec motif, le stock est rétabli.",
        ],
    ),
    dict(
        cat='Stock', nom='Magasins', icone='🏬',
        desc="Les points de stock et les transferts entre eux (palier Avancé).",
        captures=[('magasins.png', 'Magasins')],
        sous=['Magasins', 'Transferts'],
        champs=['Code MAG', 'Nom', 'Adresse', 'Responsable', 'Valeur du stock', 'Transfert (origine → destination)'],
        actions=['Nouveau magasin', 'Nouveau transfert', 'Modifier', 'Désactiver', 'Détail'],
        scenarios=[
            "Dépôt et boutique : réassort de la boutique par un transfert depuis le dépôt.",
            "Utilisateur rattaché : chaque utilisateur voit son magasin principal par défaut.",
            "Fermeture d'un point : désactivation, l'historique reste consultable.",
        ],
    ),
    dict(
        cat='Stock', nom='Besoins', icone='⚠️',
        desc="Listes de besoins par fournisseur, ruptures et seuils, produits expirés ou proches de l'expiration.",
        captures=[('besoins.png', 'Listes de besoins')],
        sous=['Listes', 'Ruptures & seuils', 'Expirés'],
        champs=['Fournisseur', 'Produits', 'À commander', 'Prix estimé', 'Livraison souhaitée', 'Statut'],
        actions=['Nouvelle liste', 'Ajouter sous le seuil', 'Ajouter les ruptures', 'PDF fournisseur',
                 'Créer une entrée', 'Créer une commande fournisseur', 'Annuler'],
        scenarios=[
            "Inventaire du matin : « Ajouter les ruptures » remplit la liste avec les quantités suggérées.",
            "Commande formelle : la liste devient un bon de commande fournisseur BCF.",
            "Produits à date courte : l'onglet Expirés liste ceux qui expirent sous 30 jours.",
        ],
    ),
    dict(
        cat='Tiers', nom='Clients', icone='👤',
        desc="Fiches clients, solde, relevé, fidélité et versements.",
        captures=[('clients.png', 'Clients'), ('versements.png', 'Versements (filtre par tiers)')],
        sous=['Clients', 'Versements'],
        champs=['Code CLN', 'Nom', 'Téléphone (10 chiffres)', 'Adresse', 'NIF / NIS / RC / AI',
                'Plafond de crédit', 'Solde initial', 'Points', 'Solde'],
        actions=['Nouveau client', 'Situation (relevé)', 'Versement', 'Modifier', 'Désactiver',
                 'Filtrer les versements par tiers', 'Excel / PDF'],
        scenarios=[
            "Reprise d'un client existant : son ancienne dette est saisie en solde initial, réglée en premier "
            "par les versements.",
            "Client professionnel : NIF, NIS, RC et article d'imposition apparaissent sur ses factures.",
            "Encaissement d'une dette : versement imputé sur les plus anciens paniers non soldés.",
        ],
    ),
    dict(
        cat='Tiers', nom='Fournisseurs', icone='🏭',
        desc="Fiches fournisseurs, dettes, relevé et versements.",
        captures=[('fournisseurs.png', 'Fournisseurs')],
        sous=['Fournisseurs', 'Versements'],
        champs=['Code FOR', 'Nom', 'Téléphone (10 chiffres)', 'NIF / NIS / RC / AI', 'Solde initial',
                'Achats', 'Versé', 'Dette'],
        actions=['Nouveau fournisseur', 'Situation (relevé)', 'Versement', 'Modifier', 'Désactiver'],
        scenarios=[
            "Avance versée avant livraison : solde initial négatif, imputé sur les prochaines entrées.",
            "Relevé à envoyer : situation du fournisseur exportée en PDF.",
            "Règlement partiel : versement imputé sur les entrées les plus anciennes.",
        ],
    ),
    dict(
        cat='Gestion', nom='Gestion caisse', icone='💰',
        desc="Les caisses, leurs sessions, mouvements, transferts et clôtures Z scellées.",
        captures=[('gestion_caisse.png', 'Caisses')],
        sous=['Caisses', 'Transferts', 'Clôtures Z', 'Mouvements', 'Sessions'],
        champs=['Caisse', 'Fond initial', 'Solde courant', 'Espèces attendues / comptées', 'Écart',
                'Récapitulatif TVA', 'Empreinte'],
        actions=['Ouvrir la caisse', 'Mouvement', 'Clôturer (Z)', 'Transfert vers le coffre', 'Détail',
                 'Nouvelle caisse'],
        scenarios=[
            "Fin de journée : comptage, écart calculé, clôture Z figée avec la TVA par taux de la session.",
            "Dépôt au coffre : transfert d'espèces de la caisse vers le coffre CIS0001.",
            "Contrôle : le journal des mouvements de caisse n'accepte que des ajouts (contre-passation).",
        ],
    ),
    dict(
        cat='Gestion', nom='Utilisateurs', icone='🔐',
        desc="Comptes, rôles et permissions.",
        captures=[('utilisateurs.png', 'Utilisateurs')],
        sous=['Utilisateurs', 'Rôles'],
        champs=['Identifiant', 'Nom', 'Rôle', 'Caisse attachée', 'Magasin principal', 'Permissions'],
        actions=['Nouvel utilisateur', 'Nouveau rôle', 'Modifier', 'Réinitialiser le mot de passe',
                 'Désactiver'],
        scenarios=[
            "Caissier : accès Caisse et Ventes, caisse verrouillée sur son poste.",
            "Magasinier : Stock, Entrées, Sorties, Besoins, sans les prix d'achat s'il le faut.",
            "Dépassement de plafond : réservé aux rôles qui ont la permission correspondante.",
        ],
    ),
    dict(
        cat='Gestion', nom='Zakat', icone='🌙',
        desc="Calcul annuel de la Zakat sur le capital commercial.",
        captures=[('zakat.png', 'Zakat')],
        sous=['Écran unique (tableau + calcul)'],
        champs=['Année', 'Capital (stock, liquidités, créances, dettes)', 'Nissab', 'Zakat due', 'Échéance',
                'Payée le'],
        actions=['Nouveau calcul', 'Modifier', 'Marquer payée', 'Annuler', 'Excel / PDF'],
        scenarios=[
            "Échéance annuelle : le capital est proposé depuis le stock, la caisse et les soldes.",
            "Capital sous le nissab : aucune zakat due.",
            "Suivi : la zakat marquée payée garde sa date de paiement.",
        ],
    ),
    dict(
        cat='Gestion', nom='Historique', icone='📜',
        desc="Le journal de toutes les actions, consultable selon le rôle et impossible à modifier.",
        captures=[('historique.png', 'Historique')],
        sous=['Écran unique (tableau + filtres)'],
        champs=['Date', 'Utilisateur', 'Module', 'Action', 'Référence', 'Description', 'Poste'],
        actions=['Filtrer (période, module, action, utilisateur, poste)', 'Détail', 'Excel / PDF'],
        scenarios=[
            "Qui a annulé ce panier ? Filtre module Ventes, action Annulation.",
            "Traçabilité commerciale : création, transformation et livraison des devis et commandes.",
            "Export : chaque export Excel / PDF est lui-même journalisé.",
        ],
    ),
    dict(
        cat='Gestion', nom='Paramètres', icone='⚙️',
        desc="Préférences du poste, de la boutique et de l'application.",
        captures=[('parametres.png', 'Paramètres')],
        sous=['Système', 'Boutique', 'Caisse et ventes', 'Impression', 'Alertes', 'Sauvegarde', 'Licence'],
        champs=['Thème', 'Langue', 'Devise', 'Régime fiscal (Réel / IFU)', 'Droit de timbre',
                'NIF / NIS / RC / article', 'Imprimante (58 / 80 mm)'],
        actions=['Changer de régime', 'Activer le timbre', 'Sauvegarder', 'Restaurer', 'Activer la licence'],
        scenarios=[
            "Commerçant à l'IFU : régime IFU, les ventes sortent sans TVA.",
            "Identité fiscale : NIF, NIS, RC et article d'imposition saisis une fois, repris sur chaque facture.",
            "Sécurité : sauvegarde chiffrée par mot de passe, restaurable sur un autre poste.",
        ],
    ),
]

# ———————————————————————————— Rendu ————————————————————————————


def chips(items, classe=''):
    return ''.join(f'<span class="chip {classe}">{E(i)}</span>' for i in items)


def entete(eyebrow, titre, desc):
    return (f'<p class="eyebrow">{E(eyebrow)}</p><h2>{E(titre)}</h2>'
            f'<p class="lead">{E(desc)}</p>')


def page(contenu, pied, id_=''):
    ident = f' id="{id_}"' if id_ else ''
    return (f'<section class="page"{ident}>{contenu}'
            f'<footer class="pied"><span>CaisseDZ · Workflow détaillé</span><span>{E(pied)}</span></footer>'
            '</section>')


def module_html(m, n):
    def figure(f, l):
        return f'<figure><img src="captures/{f}" alt="{E(l)}" loading="lazy"><figcaption>{E(l)}</figcaption></figure>'

    # Première capture à côté de la fiche, les suivantes en grille sous le bloc (pas de vide à droite).
    figures = figure(*m['captures'][0])
    autres = ''.join(figure(f, l) for f, l in m['captures'][1:])
    autres = f'<div class="captures-sup">{autres}</div>' if autres else ''
    nouveau = '<span class="nouveau">Nouveau</span>' if m.get('nouveau') else ''
    scen = ''.join(f'<div class="scenario"><span class="num">{i}</span><p>{E(s)}</p></div>'
                   for i, s in enumerate(m['scenarios'], 1))
    sid = 'm-' + m['nom'].lower().replace(' ', '-').replace('&', 'et').replace('/', '-')
    contenu = f'''
      <header class="tete-module">
        <div class="tuile">{m['icone']}</div>
        <div><p class="eyebrow cat">{E(m['cat'])}{nouveau}</p><h2>{E(m['nom'])}</h2>
        <p class="lead">{E(m['desc'])}</p></div>
      </header>
      <div class="module">
        <div class="captures">{figures}</div>
        <div class="fiche">
          <h4>Sous-modules</h4><div class="chips">{chips(m['sous'], 'sombre')}</div>
          <h4>Champs clés</h4><div class="chips">{chips(m['champs'])}</div>
          <h4>Actions disponibles</h4><div class="chips">{chips(m['actions'], 'action')}</div>
        </div>
      </div>
      {autres}
      <h3 class="filet">Scénarios d'usage</h3>
      <div class="scenarios">{scen}</div>'''
    return page(contenu, f"{m['cat']} — {m['nom']}", sid)


def cycle():
    etapes = [
        ('📥', '1. Approvisionnement', 'Besoins → commande fournisseur → entrée (Smart Scan IA), réception partielle'),
        ('🏷️', '2. Catalogue', 'Produits, TVA, colis, remises et packs, fiche pré-remplie par IA'),
        ('🛒', '3. Vente', 'Devis → commande → livraison, ou caisse ; facture et avoir numérotés'),
        ('👥', '4. Tiers', 'Clients et fournisseurs : solde initial, versements, relevés'),
        ('📊', '5. Pilotage', 'Tableau de bord, Situation (TVA par taux), clôtures Z, Historique'),
    ]
    cartes = '<span class="fleche">→</span>'.join(
        f'<div class="etape"><div class="ico">{i}</div><h5>{E(t)}</h5><p>{E(d)}</p></div>' for i, t, d in etapes)
    return f'<div class="cycle">{cartes}</div>'


def flux(titre, etapes):
    pas = '<span class="fl">→</span>'.join(f'<span class="pas">{E(e)}</span>' for e in etapes)
    return f'<div class="flux"><h5>{E(titre)}</h5><div class="pas-liste">{pas}</div></div>'


CSS = '''
:root{
  /* Mise en page : pages A4 empilées, captures à gauche, fiche du module à droite (modèle CaisseDZ). */
  --violet:#6c5ce7; --violet-2:#8f7cf0; --violet-fonce:#4b2f63; --rose:#ff6b81; --rose-fond:#ffe9ec;
  --fond:#f4f2fb; --page:#ffffff; --carte:#f6f4ff; --texte:#1b1830; --doux:#6b6880; --trait:#e6e2f3;
  --ombre:0 10px 30px rgba(76,56,160,.10);
  --titre:'Poppins',system-ui,-apple-system,'Segoe UI',sans-serif;
  --corps:'Poppins',system-ui,-apple-system,'Segoe UI',sans-serif;
}
@media (prefers-color-scheme:dark){:root:not([data-theme="light"]){
  --fond:#14121f; --page:#1c1a2b; --carte:#262338; --texte:#ecebf5; --doux:#a9a6c0; --trait:#353149;
  --violet-fonce:#c9b8ff; --rose-fond:#3a2230; --ombre:0 10px 30px rgba(0,0,0,.35); color-scheme:dark}}
:root[data-theme="dark"]{--fond:#14121f; --page:#1c1a2b; --carte:#262338; --texte:#ecebf5; --doux:#a9a6c0;
  --trait:#353149; --violet-fonce:#c9b8ff; --rose-fond:#3a2230; --ombre:0 10px 30px rgba(0,0,0,.35); color-scheme:dark}
*{box-sizing:border-box}
body{background:var(--fond);color:var(--texte);font-family:var(--corps);font-size:14px;line-height:1.55;
  padding-left:max(16px,env(safe-area-inset-left,0px));padding-right:max(16px,env(safe-area-inset-right,0px));
  padding-block:24px}
.doc{max-width:1120px;margin:0 auto;display:flex;flex-direction:column;gap:28px}
.page{background:var(--page);border-radius:18px;box-shadow:var(--ombre);padding:44px 52px 22px;display:flex;
  flex-direction:column;gap:14px;min-width:0}
h1,h2,h3,h4,h5{font-family:var(--titre);margin:0;text-wrap:balance}
h2{font-size:28px;font-weight:700;letter-spacing:-.01em}
.eyebrow{font-size:10.5px;letter-spacing:.22em;text-transform:uppercase;color:var(--violet);font-weight:700;margin:0}
.eyebrow.cat{color:var(--rose);display:flex;gap:10px;align-items:center}
.nouveau{background:var(--violet);color:#fff;border-radius:999px;padding:2px 9px;letter-spacing:.08em;font-size:9.5px}
.lead{color:var(--doux);margin:0;max-width:78ch}
.couverture{background:linear-gradient(135deg,#6a5ad8 0%,#8a76e8 55%,#9d86f0 100%);color:#fff;text-align:center;
  padding:110px 40px 60px;gap:18px;align-items:center}
.logo{display:inline-flex;flex-direction:column;align-items:center;background:rgba(60,36,120,.45);border-radius:18px;
  padding:16px 26px;font-family:var(--titre);font-weight:700;font-size:38px;line-height:1;box-shadow:0 12px 30px rgba(40,20,90,.35)}
.logo small{font-size:38px}
.couverture .eyebrow{color:rgba(255,255,255,.8)}
.couverture h1{font-size:40px;font-weight:700}
.couverture p{max-width:62ch;color:rgba(255,255,255,.88);margin:0}
.couverture .version{font-size:11px;opacity:.7;margin-top:40px}
.sommaire{display:grid;grid-template-columns:repeat(auto-fill,minmax(210px,1fr));gap:8px}
.sommaire a{display:flex;gap:10px;align-items:center;padding:9px 12px;border-radius:10px;background:var(--carte);
  color:var(--texte);text-decoration:none;font-weight:500}
.sommaire a:hover,.sommaire a:focus-visible{outline:2px solid var(--violet);outline-offset:1px}
.grille{display:grid;grid-template-columns:repeat(4,minmax(0,1fr));gap:14px}
.carte{border:1px solid var(--trait);border-radius:14px;padding:16px;display:flex;flex-direction:column;gap:6px;min-width:0}
.carte.pleine{background:var(--carte);border:none}
.carte .ico{font-size:22px}
.carte h5{font-size:13px;color:var(--violet-fonce)}
.carte p{margin:0;color:var(--doux);font-size:12px}
.cycle{display:flex;align-items:stretch;gap:8px;flex-wrap:wrap;justify-content:center}
.etape{flex:1 1 150px;max-width:190px;background:var(--page);border-radius:16px;box-shadow:var(--ombre);padding:16px;
  text-align:center;display:flex;flex-direction:column;gap:6px;align-items:center}
.etape .ico{width:44px;height:44px;border-radius:12px;background:var(--carte);display:grid;place-items:center;font-size:22px}
.etape h5{font-size:13px}.etape p{margin:0;font-size:11px;color:var(--doux)}
.fleche{align-self:center;color:var(--violet);font-size:20px}
.pastilles{display:flex;gap:8px;flex-wrap:wrap;justify-content:center}
.pastille{background:var(--violet-fonce);color:var(--page);border-radius:999px;padding:6px 12px;font-size:11px;font-weight:600}
.satellite{border:1px dashed var(--trait);border-radius:999px;padding:5px 12px;font-size:11px;color:var(--doux)}
.satellite b{color:var(--rose)}
.note{font-size:11px;color:var(--doux);text-align:center;font-style:italic}
.flux{background:var(--carte);border-radius:14px;padding:16px 18px;display:flex;flex-direction:column;gap:10px}
.flux h5{font-size:13px;color:var(--violet-fonce)}
.pas-liste{display:flex;flex-wrap:wrap;gap:8px;align-items:center}
.pas{background:var(--page);border-radius:10px;padding:7px 12px;font-size:11.5px;font-weight:600;box-shadow:0 2px 6px rgba(76,56,160,.08)}
.fl{color:var(--doux)}
.intel{border:1px solid var(--trait);border-radius:16px;padding:18px 20px;display:flex;flex-direction:column;gap:10px}
.intel h5{font-size:15px;display:flex;gap:10px;align-items:center}
.intel .n{width:26px;height:26px;border-radius:50%;background:var(--violet);color:#fff;display:grid;place-items:center;font-size:12px}
.intel p{margin:0;color:var(--doux);font-size:12.5px;max-width:95ch}
.tete-module{display:flex;gap:16px;align-items:flex-start}
.tuile{width:54px;height:54px;flex:none;border-radius:14px;background:var(--carte);display:grid;place-items:center;font-size:26px}
.module{display:grid;grid-template-columns:minmax(0,1.15fr) minmax(0,1fr);gap:24px;align-items:start}
.captures{display:flex;flex-direction:column;gap:14px;min-width:0}
.captures-sup{display:grid;grid-template-columns:repeat(auto-fit,minmax(min(100%,320px),1fr));gap:18px;margin-top:22px}
figure{margin:0;display:flex;flex-direction:column;gap:6px}
figure img{width:100%;height:auto;border-radius:10px;border:1px solid var(--trait);box-shadow:0 8px 22px rgba(40,30,90,.14);display:block}
figcaption{font-size:11px;color:var(--doux);text-align:center}
.fiche{display:flex;flex-direction:column;gap:8px;min-width:0}
.fiche h4{font-size:10.5px;letter-spacing:.16em;text-transform:uppercase;color:var(--violet);margin-top:6px}
.chips{display:flex;flex-wrap:wrap;gap:7px}
.chip{border:1px solid var(--trait);background:var(--page);border-radius:999px;padding:5px 11px;font-size:11.5px}
.chip.sombre{background:var(--violet-fonce);color:var(--page);border-color:transparent;font-weight:600}
.chip.action{background:var(--rose-fond);color:var(--rose);border-color:transparent;font-weight:600}
h3.filet{font-size:14px;color:var(--violet-fonce);padding-bottom:8px;border-bottom:1px solid var(--trait);margin-top:6px}
.scenarios{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:14px}
.scenario{background:var(--carte);border-left:3px solid var(--violet);border-radius:12px;padding:14px 16px;display:flex;gap:10px;align-items:flex-start}
.scenario .num{width:22px;height:22px;flex:none;border-radius:50%;background:var(--violet);color:#fff;display:grid;place-items:center;font-size:11px;font-weight:600}
.scenario p{margin:0;font-size:12px}
.deux{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:22px}
.deux h4{font-size:13px;color:var(--violet-fonce);padding-bottom:8px;border-bottom:1px solid var(--trait);margin-bottom:10px}
.pile{display:flex;flex-direction:column;gap:12px}
.connexion{display:grid;grid-template-columns:minmax(0,1.3fr) minmax(0,1fr);gap:22px;align-items:start}
table.taux{border-collapse:collapse;width:100%;font-size:12px;font-variant-numeric:tabular-nums}
table.taux th,table.taux td{border-bottom:1px solid var(--trait);padding:7px 8px;text-align:left}
table.taux th{font-size:10.5px;letter-spacing:.1em;text-transform:uppercase;color:var(--violet)}
.table-defile{overflow-x:auto}
.pied{display:flex;justify-content:space-between;border-top:1px solid var(--trait);padding-top:10px;margin-top:auto;
  font-size:10px;color:var(--doux)}
.couverture .pied{display:none}
@media (max-width:900px){
  .page{padding:28px 20px 16px}
  .module,.connexion,.deux{grid-template-columns:minmax(0,1fr)}
  .grille{grid-template-columns:repeat(2,minmax(0,1fr))}
  .scenarios{grid-template-columns:minmax(0,1fr)}
  .fleche{display:none}
}
@media (max-width:480px){.grille{grid-template-columns:minmax(0,1fr)}h2{font-size:23px}.couverture h1{font-size:30px}}
@media print{
  body{background:#fff;padding:0}
  .doc{gap:0;max-width:none}
  .page{box-shadow:none;border-radius:0;break-after:page;min-height:auto}
}
@media (prefers-reduced-motion:reduce){*{scroll-behavior:auto}}
'''


def main():
    sommaire = ''.join(
        f'<a href="#{"m-" + m["nom"].lower().replace(" ", "-").replace("&", "et").replace("/", "-")}">'
        f'<span>{m["icone"]}</span>{E(m["nom"])}</a>' for m in MODULES)
    pages = []
    pages.append(f'''<section class="page couverture">
      <div class="logo">Caisse<small>DZ</small></div>
      <p class="eyebrow">Présentation fonctionnelle détaillée</p>
      <h1>Workflow &amp; Fonctionnement</h1>
      <p>Module par module : à quoi il sert, ses champs et actions, ses scénarios d'usage réels, avec une capture
      d'écran de l'application pour chacun ; le circuit commercial (devis, commande, livraison, facture, avoir),
      la TVA et les fonctions intelligentes.</p>
      <p class="version">CaisseDZ Desktop (Windows) · document de présentation · octobre 2026</p>
    </section>''')
    pages.append(page(
        entete('Sommaire', 'Les modules de CaisseDZ', "Cliquez sur un module pour aller à sa page.")
        + f'<div class="sommaire">{sommaire}</div>', 'Sommaire'))
    nouveautes = ''.join(f'<div class="carte"><div class="ico">{i}</div><h5>{E(t)}</h5><p>{E(d)}</p></div>'
                         for i, t, d in NOUVEAUTES)
    pages.append(page(
        entete('Cette version', 'Nouveautés', "Les fonctionnalités ajoutées dans cette version, détaillées dans les "
               "pages des modules concernés.")
        + f'<div class="grille">{nouveautes}</div>', 'Nouveautés', 'nouveautes'))
    structure = ''.join(f'<div class="carte pleine"><div class="ico">{i}</div><h5>{E(t)}</h5><p>{E(d)}</p></div>'
                        for i, t, d in [
                            ('🛒', 'Général', 'Tableau de bord, Caisse, Ventes, Devis & commandes, Retours'),
                            ('📦', 'Stock', 'Produits, Stock, Entrées, Commandes fournisseurs, Sorties, Magasins, Besoins'),
                            ('👥', 'Tiers', 'Clients et Fournisseurs (avec leurs versements)'),
                            ('⚙️', 'Gestion', 'Gestion caisse, Utilisateurs, Zakat, Historique, Paramètres'),
                        ])
    pages.append(page(
        entete("Vue d'ensemble", 'Un cycle complet, du fournisseur au client',
               "CaisseDZ couvre tout le parcours d'un commerce de détail ou de gros : l'approvisionnement, le "
               "catalogue, la vente au comptoir ou sur devis, le suivi des tiers et le pilotage, sur un seul poste "
               "et sans connexion Internet obligatoire.")
        + '<div class="pastilles"><span class="pastille">🔎 Reconnaissance produit (code-barres)</span>'
          '<span class="pastille">📄 Smart Scan IA (factures fournisseurs)</span>'
          '<span class="pastille">⚡ Scan en rafale en caisse</span></div>'
        + '<p class="note">↓ alimentent le cycle principal ↓</p>' + cycle()
        + '<p class="note">↓ modules satellites, déclenchés depuis le cycle principal ↓</p>'
        + '<div class="pastilles">'
          '<span class="satellite"><b>●</b> Besoin (déclenché par une rupture de stock)</span>'
          '<span class="satellite"><b>●</b> Retour (depuis une vente ou une entrée)</span>'
          '<span class="satellite"><b>●</b> Versement (règlement client / fournisseur)</span>'
          '<span class="satellite"><b>●</b> Facture &amp; avoir (depuis une vente)</span>'
          '<span class="satellite"><b>●</b> Gestion caisse (session et clôture Z encadrant toute vente)</span></div>'
        + '<h3 class="filet">Structure des modules</h3>'
        + f'<div class="grille">{structure}</div>', "01 — Vue d'ensemble", 'vue'))
    pages.append(page(
        entete('Circuits', 'Le circuit commercial pas à pas',
               "Chaque document garde le lien avec celui dont il est issu ; le stock et les soldes ne bougent "
               "qu'au moment de la livraison ou de la réception.")
        + flux('Vente sur devis (client professionnel)',
               ['Devis DEV', 'Accepté', 'Commande BCC', 'Livraison partielle → BL LIV + vente VTE',
                'Livraison du reste', 'Facture FAC', 'Retour → avoir AVO'])
        + flux('Vente au comptoir',
               ['Session de caisse ouverte', 'Scan des produits', 'Encaissement (F4)', 'Ticket avec TVA',
                'Facture FAC sur demande', 'Clôture Z avec TVA par taux'])
        + flux('Approvisionnement',
               ['Rupture / seuil', 'Liste de besoins', 'Commande fournisseur BCF',
                'Entrée ENT (réception partielle)', 'Reste reçu ou soldé', 'Versement fournisseur'])
        + flux('Règlement des tiers',
               ['Solde initial', '+ ventes / entrées à crédit', '− retours (avoirs)', '− versements imputés',
                '= solde du tiers'])
        + '<h3 class="filet">Numérotation des pièces</h3><div class="table-defile"><table class="taux"><thead><tr>'
          '<th>Pièce</th><th>Préfixe</th><th>Effet</th></tr></thead><tbody>'
          '<tr><td>Ticket de vente</td><td>VTE</td><td>Stock, caisse, solde client</td></tr>'
          '<tr><td>Facture / facture d\'avoir</td><td>FAC / AVO</td><td>Numérotation continue, scellée SHA-256</td></tr>'
          '<tr><td>Devis / proforma</td><td>DEV / PRO</td><td>Aucun effet sur le stock ni le solde</td></tr>'
          '<tr><td>Bon de commande client</td><td>BCC</td><td>Quantités à livrer</td></tr>'
          '<tr><td>Bon de livraison</td><td>LIV</td><td>Lié à la vente qui sort le stock</td></tr>'
          '<tr><td>Commande fournisseur</td><td>BCF</td><td>Quantités attendues</td></tr>'
          '<tr><td>Entrée / retour / sortie</td><td>ENT / RET / SRT</td><td>Stock et solde fournisseur</td></tr>'
          '<tr><td>Versement / clôture</td><td>VER / CLT</td><td>Soldes, caisse, Z</td></tr>'
          '</tbody></table></div>', '02 — Circuits', 'circuits'))
    generales = ''.join(f'<div class="carte"><div class="ico">{i}</div><h5>{E(t)}</h5><p>{E(d)}</p></div>'
                        for i, t, d in GENERALES)
    pages.append(page(
        entete('Avant de commencer', 'Fonctions générales',
               'Les capacités transversales de CaisseDZ, présentes dans tous les modules détaillés ensuite.')
        + f'<div class="grille">{generales}</div>', '03 — Fonctions générales'))
    intel = [
        ('Reconnaissance de produit par code-barres',
         "À la création d'un produit en mode IA, le code-barres scanné ou saisi déclenche une recherche en "
         "cascade jusqu'à trouver une fiche (nom, marque, catégorie, photo) à valider.",
         ['Base locale', 'Catalogue CaisseDZ', 'Mantouj (GS1 Maghreb)', 'Open Food Facts', 'Open Beauty Facts']),
        ('Smart Scan IA des factures fournisseurs',
         "Dans Entrées : la photo ou le PDF d'une facture fournisseur est analysé ; chaque ligne ressort avec "
         "sa quantité et son prix, rapprochée du catalogue ; l'utilisateur n'a plus qu'à valider.",
         ['Photo / PDF du bon', 'Lecture IA', 'Extraction des lignes', 'Rapprochement catalogue',
          "Validation de l'entrée"]),
        ('Scan en caisse et dans les listes',
         "La douchette est détectée par la vitesse de frappe : un produit déjà au panier passe à +1, une "
         "rafale dans une liste de sélection ajoute le produit sans fermer la fenêtre.",
         ['Scan (F2)', 'Produit trouvé', 'Déjà au panier : +1', 'Nouvelle ligne sinon', 'Encaisser (F4)']),
    ]
    intel_html = ''.join(
        f'<div class="intel"><h5><span class="n">{i}</span>{E(t)}</h5><p>{E(d)}</p>'
        + '<div class="pas-liste">' + '<span class="fl">→</span>'.join(f'<span class="pas">{E(p)}</span>' for p in ps)
        + '</div></div>' for i, (t, d, ps) in enumerate(intel, 1))
    pages.append(page(
        entete('Avant de commencer', 'Fonctions intelligentes',
               "Trois fonctions qui font gagner du temps à la saisie et s'intègrent aux modules Produits, Entrées "
               "et Caisse.")
        + f'<div class="pile">{intel_html}</div>', '04 — Fonctions intelligentes'))
    pages.append(page(
        entete('Étape 0', 'Mise en route',
               "Connexion sécurisée, puis ouverture directe sur la Caisse ; le menu des modules et les favoris "
               "donnent accès à tout le reste.")
        + '<div class="connexion"><figure><img src="captures/connexion.png" alt="Écran de connexion" loading="lazy">'
          '<figcaption>Écran de connexion</figcaption></figure><div class="pile">'
          '<div class="carte pleine"><h5>Rôles &amp; permissions</h5><p>Chaque utilisateur a un rôle (Admin, '
          'Caissier, Magasinier…) qui détermine les modules visibles et les actions autorisées. Un utilisateur '
          'non-admin peut être verrouillé sur une caisse et un magasin.</p></div>'
          '<div class="carte pleine"><h5>Première configuration</h5><p>Activation de la licence (Basic ou '
          'Avancé), identité de la boutique (NIF, NIS, RC, article d\'imposition), caisse et magasin principal, '
          'compte administrateur.</p></div>'
          '<div class="carte pleine"><h5>Barre latérale</h5><p>Quatre groupes repliables : Général, Stock, '
          'Tiers, Gestion ; jusqu\'à 7 favoris ; mode réduit avec info-bulles.</p></div>'
          '</div></div>', '05 — Mise en route'))
    for n, m in enumerate(MODULES, 1):
        pages.append(module_html(m, n))
    pages.append(page(
        entete('Fiscalité', 'TVA, factures et déclarations',
               "La fiscalité algérienne intégrée au cycle de vente et d'achat, selon le régime choisi dans "
               "Paramètres.")
        + '<div class="deux"><div><h4>TVA collectée et déductible</h4><div class="table-defile"><table class="taux">'
          '<thead><tr><th>Taux</th><th>Exemples</th><th>Où il apparaît</th></tr></thead><tbody>'
          '<tr><td>19 %</td><td>Taux normal</td><td rowspan="3">Ligne de vente (figé), ticket, facture, clôture Z, '
          'détail des ventes, entrées (TVA déductible), analyse TVA par taux, export G50</td></tr>'
          '<tr><td>9 %</td><td>Taux réduit</td></tr><tr><td>0 %</td><td>Exonéré</td></tr></tbody></table></div>'
          '<p class="lead">Les prix saisis sont TTC ; le HT et la TVA sont ventilés au centime et la somme reste '
          'exacte.</p></div>'
          '<div><h4>Régime et documents</h4><div class="pile">'
          '<div class="carte pleine"><h5>Réel ou IFU</h5><p>Réel : TVA collectée et déductible. IFU : ventes '
          'sans TVA.</p></div>'
          '<div class="carte pleine"><h5>Facture et avoir</h5><p>FAC et AVO numérotés sans trou, identités '
          'fiscales figées, montant en lettres, droit de timbre sur la part en espèces, chaîne SHA-256.</p></div>'
          '<div class="carte pleine"><h5>Aide à la G50</h5><p>Export Excel de la TVA collectée, déductible et '
          'nette par taux sur la période, avec le droit de timbre.</p></div>'
          '</div></div></div>', 'Fiscalité', 'fiscalite'))
    secu = [
        ('🗃️', 'Registre fiscal inviolable', "Ventes, lignes, paiements, mouvements de stock, factures et journal "
         "fiscal sont protégés par des déclencheurs : aucune modification après coup."),
        ('🔒', 'Clôtures Z scellées', "Chaque Z est figé à sa création avec son empreinte ; une période clôturée "
         "n'accepte plus d'écriture sur sa caisse."),
        ('📜', "Journal d'audit complet", "Création, modification, annulation et export tracés avec l'utilisateur, "
         "le poste et l'horodatage."),
    ]
    quotidien = [
        ('🔌', 'Sans connexion Internet obligatoire', "Tout fonctionne en local ; seuls le Smart Scan IA et la "
         "recherche de fiches en ligne demandent une connexion."),
        ('🖥️', 'Un poste, plusieurs rôles', 'Comptes et permissions séparent ce que chacun peut faire.'),
        ('💾', 'Base chiffrée et sauvegardes', "Base SQLCipher chiffrée avec la clé du poste, sauvegarde "
         "automatique au démarrage (30 archives), sauvegarde manuelle protégée par mot de passe."),
    ]

    def colonne(items):
        return ''.join(f'<div class="carte pleine"><div class="ico">{i}</div><h5>{E(t)}</h5><p>{E(d)}</p></div>'
                       for i, t, d in items)
    pages.append(page(
        entete('Pour conclure', 'Sécurité, conformité & fonctionnement hors ligne',
               "Un socle pensé pour un commerce réel : résister à un contrôle, fonctionner sans connexion et rester "
               "simple au quotidien.")
        + f'<div class="deux"><div><h4>Sécurité &amp; traçabilité</h4><div class="pile">{colonne(secu)}</div></div>'
          f'<div><h4>Fonctionnement au quotidien</h4><div class="pile">{colonne(quotidien)}</div></div></div>',
        'Sécurité & conformité'))

    document = f'''<title>CaisseDZ Workflow</title>
<meta name="claude:viewport-fit-sides" content="cover">
<meta name="description" content="CaisseDZ : workflow détaillé et fonctionnement, module par module">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap">
<style>{CSS}</style>
<main class="doc">
{''.join(pages)}
</main>
'''
    os.makedirs(os.path.dirname(SORTIE), exist_ok=True)
    with open(SORTIE, 'w', encoding='utf-8') as f:
        f.write(document)
    print(f'{SORTIE} : {len(pages)} pages')


if __name__ == '__main__':
    main()
