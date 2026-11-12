# B43 – Lekker tuinen

Tuin-app voor Ballingstraat 43. Noa en Jacob gebruiken ze samen op de gsm om de tuinwerken te begeleiden en een logboek van de planten bij te houden.

Live: **https://noadekocker.github.io/B43/**

## Wat zit erin

- **Vandaag**: één kaart met de eerstvolgende uiterlijke datum (of de tip van de maand) en maximaal 5 taken die nu aan de beurt zijn.
- **Tuin**: plattegrond van de tuin volgens het grondplan in Figma. Tik op een zone om de werken op die plek te zien.
- **Werken**: alle taken, per maand en per zone. Tik op een taak om ze te bewerken, tik op het vinkje als ze klaar is.
- **Planten**: lijst van de planten in de tuin, met een logboek per plant.
- **Plusknop**: nieuwe taak (of nieuwe plant op het scherm Planten).

## Bestanden

| Bestand | Wat |
|---|---|
| `index.html` | De volledige app: HTML, CSS en JavaScript in één bestand. Logo en iconen zitten erin. |
| `manifest.webmanifest`, `icon-*.png` | App-naam "B43" en het app-icoon (bloem, room op klaproos), om de app op het beginscherm te zetten |
| `supabase/setup.sql` | Het script dat de database aanmaakt: tabellen, beveiliging, de twee leden en de startlijst met taken |
| `assets/logo-b43.svg` | Het handgeschreven B43-logo |
| `assets/bloem-app-icoon.svg` | De handgetekende bloem van het app-icoon |
| `assets/iconen/` | De 15 handgetekende iconen, met hun plek in de app in de bestandsnaam |

## Hoe het werkt

- De app staat op **GitHub Pages**.
- De gegevens (taken en planten) staan in **Supabase** (gratis database, regio EU). Beide gsm's zien wijzigingen meteen.
- **Aanmelden** gebeurt met je mailadres: je krijgt een code van 6 cijfers per mail. Alleen de mailadressen in de tabel `members` krijgen toegang.
- De Supabase-sleutel in `index.html` is de publieke ("publishable") sleutel. Die mag in de code staan: de beveiliging (row level security) laat alleen leden toe.

## Installeren op de gsm

1. Open **https://noadekocker.github.io/B43/** in Safari (iPhone) of Chrome (Android).
2. iPhone: **Deel → Zet op beginscherm**. Android: **⋮ → Toevoegen aan startscherm**.
3. Open de app via de bloem en meld je aan met je mailadres en de code.

## Stijl

- Lettertype: [Inter](https://fonts.google.com/specimen/Inter)
- Kleuren (alleen deze, plus wit voor kaarten): Room `#FFF9EF`, Woudgroen `#212C02`, Olijf `#838E2C`, Lucht `#7BADC9`, Roest `#592A24`, Klaproos `#ED412F`
- Licht afgeronde hoeken: kaarten 12 px, knoppen 10 px, iconvlakjes 8 px.

## Nog te doen

- Iconen voor **compost** en **waterreservoir** (nu nog tijdelijke lijntekeningen).
- Wekelijkse mail op maandag met de taken van de week (uitgewerkt, nog niet ingesteld).
