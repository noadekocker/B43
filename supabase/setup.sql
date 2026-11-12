-- B43 – Lekker tuinen: database voor Supabase
-- Plak dit in Supabase > SQL Editor > New query en klik op Run.

-- 1. Wie mag erin
create table if not exists public.members (
  email text primary key,
  name  text not null
);

-- 2. Taken en planten (elke rij = één taak of plant, als JSON)
create table if not exists public.tasks (
  id text primary key,
  data jsonb not null,
  updated_at timestamptz not null default now()
);
create table if not exists public.plants (
  id text primary key,
  data jsonb not null,
  updated_at timestamptz not null default now()
);

-- 3. Beveiliging: alleen leden mogen lezen en schrijven
-- De controle staat in een apart schema "private", zodat ze niet via de API aan te roepen is.
create schema if not exists private;
grant usage on schema private to authenticated;
create or replace function private.is_member() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.members m where lower(m.email) = lower(auth.jwt() ->> 'email'));
$$;
revoke all on function private.is_member() from public, anon;
grant execute on function private.is_member() to authenticated;

alter table public.members enable row level security;
alter table public.tasks   enable row level security;
alter table public.plants  enable row level security;

drop policy if exists "leden lezen leden" on public.members;
create policy "leden lezen leden" on public.members for select to authenticated using (private.is_member());

drop policy if exists "leden beheren taken" on public.tasks;
create policy "leden beheren taken" on public.tasks for all to authenticated using (private.is_member()) with check (private.is_member());

drop policy if exists "leden beheren planten" on public.plants;
create policy "leden beheren planten" on public.plants for all to authenticated using (private.is_member()) with check (private.is_member());

-- 4. Live bijwerken op beide gsm's
do $$ begin
  begin alter publication supabase_realtime add table public.tasks;  exception when duplicate_object then null; end;
  begin alter publication supabase_realtime add table public.plants; exception when duplicate_object then null; end;
end $$;

-- 5. De leden
-- De mailadressen staan bewust NIET in deze repository.
-- Voeg ze apart toe in de SQL Editor van Supabase:
--   insert into public.members (email, name) values ('MAILADRES', 'NAAM');

-- 6. De huidige taken (plan van aanpak winter 2026–2027)
insert into public.tasks (id, data) values
  ('bakken-bouwen', '{"blockedBy": ["moestuin-egaal"], "createdAt": "2026-11-11T21:15:00Z", "createdBy": null, "deadline": null, "from": "2027-02", "materials": "Planken (onbehandeld lariks of douglas)\nHoeksteunen en schroeven\nHoutsnippers", "notes": "4 bakken van 1,5 × 2,8 m en 5 bakken van 1,5 × 1,5 m, met open bodem. Houtsnipperpad in het midden.\nHergebruik de 4 bewaarde oude bakken waar het past.", "status": "open", "title": "Moestuinbakken bouwen en houtsnipperpad leggen", "to": "2027-03", "who": null, "zone": "moestuin"}'::jsonb),
  ('bloemen-kiezen', '{"blockedBy": [], "createdAt": "2026-11-11T21:15:00Z", "createdBy": null, "deadline": null, "from": "2026-11", "materials": "", "notes": "Maak per bloemenzone een keuze: zon of schaduw, en wat er wanneer bloeit (bloeiboog van vroege lente tot late herfst). Gebruik de bloemenlijst uit het plan Liefdestuin. Noteer ook welke planten uit het oude perk (bloemenperk naast de moestuin) waar naartoe gaan. Plant in groepjes van 3–5 per soort.", "status": "open", "title": "Bepalen welke bloemen waar komen", "to": "2027-02", "who": null, "zone": "bloemen"}'::jsonb),
  ('bloemenperk-weg', '{"blockedBy": [], "createdAt": "2026-11-11T21:15:00Z", "createdBy": null, "deadline": null, "from": "2026-11", "materials": "Spade\nPotten", "notes": "Planten die je wil houden: uitgraven in de winterrust en verhuizen naar het nieuwe perk rechts vooraan, of tijdelijk in een pot zetten.", "status": "open", "title": "Bloemenperk naast de moestuin weghalen", "to": "2027-02", "who": null, "zone": "moestuin"}'::jsonb),
  ('boompje-weg', '{"blockedBy": [], "createdAt": "2026-11-11T21:15:00Z", "createdBy": null, "deadline": null, "from": "2026-11", "materials": "Spade\nHouweel\nSnoeizaag", "notes": "Graaf de wortelkluit mee uit, anders loopt het opnieuw uit. Is de stam dik? Vraag dan eerst aan Stad Waregem of je een vergunning nodig hebt (milieuzorg@waregem.be, 056 62 12 80). Doe het vóór half maart.", "status": "open", "title": "Klein raar boompje in de moestuin weghalen", "to": "2027-02", "who": null, "zone": "moestuin"}'::jsonb),
  ('compostplek', '{"blockedBy": [], "createdAt": "2026-11-11T21:15:00Z", "createdBy": null, "deadline": null, "from": "2026-11", "materials": "Paletten of planken voor 2 bakken", "notes": "Twee hopen, zoals in het grondplan. Doe dit eerst: dan kunnen zoden, blad en snoeiafval van alle werken er meteen naartoe.", "status": "open", "title": "Compostplek achteraan links aanleggen", "to": "2026-12", "who": null, "zone": "compost"}'::jsonb),
  ('haag-weg', '{"blockedBy": [], "createdAt": "2026-11-11T21:15:00Z", "createdBy": null, "deadline": null, "from": "2026-11", "materials": "Spade en houweel\nSnoeischaar", "notes": "Buiten het broedseizoen (vóór half maart) doen. Wortels zo goed mogelijk uitgraven.", "status": "open", "title": "Haag achteraan weghalen (vóór de plek van het waterreservoir)", "to": "2027-02", "who": null, "zone": "water"}'::jsonb),
  ('hakselaar', '{"blockedBy": ["haag-weg", "struiken-rooien", "opkronen"], "createdAt": "2026-11-11T21:15:00Z", "createdBy": null, "deadline": null, "from": "2027-01", "materials": "", "notes": "Plan dit op één dag, als de haag, de hazelaars, het boompje en de takken van het opkronen weg zijn. Zo heb je in één keer houtsnippers voor het moestuinpad en de kippenren.", "status": "open", "title": "Hakselaar huren of lenen", "to": "2027-02", "who": null, "zone": "algemeen"}'::jsonb),
  ('kabels', '{"blockedBy": [], "createdAt": "2026-11-11T21:15:00Z", "createdBy": null, "deadline": null, "from": "2026-11", "materials": "", "notes": "Vóór het graafwerk. Vooral naar het bureau en de koten, en later naar de buitendouche. Zo graaf je niet per ongeluk door een kabel bij de haag, de moestuin of de palen van de ren.", "status": "open", "title": "Nagaan waar kabels en leidingen lopen", "to": "2026-12", "who": null, "zone": "algemeen"}'::jsonb),
  ('moestuin-egaal', '{"blockedBy": ["oude-bakken-weg", "stammen-moestuin", "boompje-weg", "bloemenperk-weg", "kabels"], "createdAt": "2026-11-11T21:15:00Z", "createdBy": null, "deadline": null, "from": "2026-12", "materials": "Piketten\nTouw\nHark\nKarton (zonder plakband of print)\nCompost", "notes": "Zet de nieuwe vorm uit met piketten en touw (± 110 m² volgens het grondplan). Spit niet diep, dan spaar je het bodemleven en de wortels van de grote bomen. Vul kuilen met compost en hark bulten weg. Dek het gras op het nieuwe stuk af met karton en ± 10 cm blad of compost: tegen maart is het gras weg.", "status": "open", "title": "Moestuin egaal maken en uitbreiden", "to": "2027-02", "who": null, "zone": "moestuin"}'::jsonb),
  ('opkronen', '{"blockedBy": ["struiken-rooien"], "createdAt": "2026-11-11T21:15:00Z", "createdBy": null, "deadline": null, "from": "2026-11", "materials": "Snoeizaag op steel\nLadder\nHandschoenen", "notes": "De onderste takken weg, zodat je eronder kan lopen. Liefst in de winterrust, niet bij vorst. Grote takken in stukken afzagen en net buiten de takkraag zagen (niet tegen de stam).", "status": "open", "title": "Mispel en wilde kastanje opkronen", "to": "2027-02", "who": null, "zone": "bomen"}'::jsonb),
  ('oude-bakken-weg', '{"blockedBy": [], "createdAt": "2026-11-11T21:15:00Z", "createdBy": null, "deadline": null, "from": "2026-11", "materials": "Kruiwagen\nSchop\nBalken of pallets", "notes": "Schep de aarde eruit en verdeel ze over de moestuin. Bewaar de bakken droog en niet op de grond. Ze kunnen terug in het nieuwe plan (4 bakken van 1,5 × 2,8 m).", "status": "open", "title": "4 moestuinbakken weghalen en bewaren", "to": "2026-12", "who": null, "zone": "moestuin"}'::jsonb),
  ('perk-rechts', '{"blockedBy": ["bloemen-kiezen"], "createdAt": "2026-11-11T21:15:00Z", "createdBy": null, "deadline": null, "from": "2026-11", "materials": "Tuinslang\nKarton\nBlad of compost\nPlanten", "notes": "Leg nu de nieuwe vorm met een tuinslang. Dek het gras af met karton en ± 10 cm blad of compost. Plant er in maart–april in, door het karton heen, volgens het bloemenplan. Zet ook de verhuisde planten uit het oude perk erin.\nHet afdekken kan al nu; alleen het planten wacht op het bloemenplan.", "status": "open", "title": "Bloemenperk rechts vooraan uitbreiden (gras weg)", "to": "2027-04", "who": null, "zone": "bloemen"}'::jsonb),
  ('stammen-moestuin', '{"blockedBy": [], "createdAt": "2026-11-11T21:15:00Z", "createdBy": null, "deadline": null, "from": "2026-11", "materials": "Kruiwagen\nHandschoenen", "notes": "Niet weggooien. Leg een paar stammen op een stapel in een schaduwrijk hoekje (bv. bij de compost) voor kevers, egels en padden. Dunne stukken gaan door de hakselaar, voor het houtsnipperpad.", "status": "open", "title": "Stammen in de moestuin opruimen", "to": "2027-01", "who": null, "zone": "moestuin"}'::jsonb),
  ('struiken-rooien', '{"blockedBy": [], "createdAt": "2026-11-11T21:15:00Z", "createdBy": null, "deadline": null, "from": "2026-11", "materials": "Spade en houweel\nSnoeizaag\nKruiwagen", "notes": "Hazelaar loopt makkelijk opnieuw uit: graaf de wortelstronk mee uit. Doe het vóór half maart (broedseizoen).\nDe struiken gaan weg, zodat er een speelplek onder de bomen kan komen. Takken kunnen naar een takkenhoop of de hakselaar (houtsnippers voor de paden).", "status": "open", "title": "Hazelaars en struiken vooraan links uitgraven (onder mispel en kastanje)", "to": "2027-02", "who": null, "zone": "bomen"}'::jsonb),
  ('vlinderstruik-snoeien', '{"blockedBy": [], "createdAt": "2026-11-11T21:15:00Z", "createdBy": null, "deadline": null, "from": "2027-03", "materials": "Snoeischaar\nTakkenschaar", "notes": "Snoei pas na de strengste vorst. Snoei flink terug tot ± 30–50 cm boven de grond. Hij bloeit op nieuw hout, dus in de zomer bloeit hij gewoon. Knip in de zomer de uitgebloeide pluimen weg, zodat hij zich niet uitzaait.", "status": "open", "title": "Vlinderstruik snoeien", "to": "2027-03", "who": null, "zone": "kippen"}'::jsonb),
  ('waslijn-weg', '{"blockedBy": [], "createdAt": "2026-11-11T21:15:00Z", "createdBy": null, "deadline": null, "from": "2026-11", "materials": "Spade\nKoevoet", "notes": "Paal en betonvoet mee uitgraven. Denk na waar de was voortaan droogt (bv. onder het overdekte terras).", "status": "open", "title": "Waslijn weghalen", "to": "2026-12", "who": null, "zone": "algemeen"}'::jsonb)
on conflict (id) do nothing;
