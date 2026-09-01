--View
--Karta produktu widok
create or replace view v_karta_produktu as(
with statystyki_ulubione as (
select produkt_id, count(produkt_id) as ilosc_ulubionych from ulubione
group by produkt_id),
statystyki_opinie as 
(select produkt_id, round(avg(ocena), 2) as srednia_ocen from opinie
group by produkt_id),
statystyki_sprzedazy as (
select produkt_id, sum(ilosc) as liczba_sprzedazy from szczegoly_zamowienia
group by produkt_id)
select p.nazwa, so.srednia_ocen, su.ilosc_ulubionych, ss.liczba_sprzedazy from produkty as p
left join statystyki_ulubione as su on p.id = su.produkt_id 
left join statystyki_opinie as so on p.id = so.produkt_id 
left join statystyki_sprzedazy as ss on p.id = ss.produkt_id 
order by ss.liczba_sprzedazy desc);

select * from v_karta_produktu order by liczba_sprzedazy desc;

--Zarobki sklepu w poszczegolnych miesiacach

create or replace view v_raport_miesieczny as(
select to_char(z.data_zamowienia, 'YYYY-MM') as miesiac, sum(z.calkowita_kwota) as calkowita_kwota
from zamowienia as z
inner join platnosci as p on z.id = p.zamowienie_id
where p.status = 'Zakończona'
group by miesiac);

select * from v_raport_miesieczny order by miesiac desc;

--Widok klienci
create or replace view v_klienci as(
with zamowienie_klienta as(
select klient_id, count(id) as liczba_zamowien, 
round(avg(calkowita_kwota), 2) as srednia_wartosc_zamowienia, 
sum(calkowita_kwota) as suma_wydatkow,
min(data_zamowienia) as data_pierwszego_zamowienia,
max(data_zamowienia) as data_ostatniego_zamowienia
from zamowienia
group by klient_id)
select zk.klient_id, k.imie, k.nazwisko, zk.liczba_zamowien, zk.srednia_wartosc_zamowienia,
zk.suma_wydatkow, zk.data_pierwszego_zamowienia, zk.data_ostatniego_zamowienia
from zamowienie_klienta as zk inner join klienci as k on zk.klient_id = k.id
order by liczba_zamowien desc);

select * from v_klienci;

--Widok produkty
create or replace view v_produkty as (
with sprzedaze as (
select sz.produkt_id, sum(sz.ilosc) as liczba_sprzedanych_sztuk, 
sum(sz.ilosc * sz.cena_w_momencie_zakupu) as przychod from szczegoly_zamowienia as sz
group by sz.produkt_id),
opinia as (
select o.produkt_id, count(o.id) as liczba_opinii, avg(o.ocena) as srednia_ocena from opinie as o
group by o.produkt_id),
ulub as (
select produkt_id, count(u.produkt_id) as liczba_dodan_ulubione from ulubione as u
group by u.produkt_id),
mag as (
select m.produkt_id, sum(ilosc_sztuk) as liczba_sztuk_magazyn from magazyn as m
group by m.produkt_id)
select p.nazwa, s.produkt_id, s.liczba_sprzedanych_sztuk, s.przychod, o.liczba_opinii, o.srednia_ocena,
u.liczba_dodan_ulubione, m.liczba_sztuk_magazyn 
from produkty as p
left join sprzedaze as s on p.id = s.produkt_id 
left join opinia as o on p.id = o.produkt_id
left join ulub as u on p.id = u.produkt_id 
left join mag as m on p.id = m.produkt_id);

select * from v_produkty;

--Widok sprzedaz miesieczna
create or replace view v_sprzedaz_miesieczna as (
with sprzedaz_miesieczna as (
select to_char(z.data_zamowienia, 'yyyy-mm') as miesiac, 
count(z.id) as liczba_zamowien, round(avg(z.calkowita_kwota), 2) as srednia_wartosc_zamowienia,
sum(z.calkowita_kwota) as przychod
from zamowienia as z
group by miesiac)
select miesiac, liczba_zamowien, srednia_wartosc_zamowienia, przychod,
przychod - lag(przychod) over(order by miesiac) as roznica
from sprzedaz_miesieczna);

select * from v_sprzedaz_miesieczna;

--Widok stan magazynowy
create or replace view v_stan_magazynowy as (
with stan_magazynu as(
select produkt_id, sum(ilosc_sztuk) as stan, minimalny_stan as minimum from magazyn
group by produkt_id, minimum)
select p.nazwa, sm.stan, sm.minimum, sm.stan * p.cena as wartosc_magazynu,
case 
	when sm.stan = 0 then 'BRAK'
	when sm.stan < sm.minimum then 'NISKI STAN'
	else 'OK'
end as status
from produkty as p 
inner join stan_magazynu as sm on p.id = sm.produkt_id);

select * from v_stan_magazynowy;

--Widok sprzedaz regiony
create or replace view v_sprzedaz_regiony as (
with sprzedaz_woj as (
select count(z.id) as liczba_zamowien, w.nazwa, sum(z.calkowita_kwota) as przychod, 
avg(z.calkowita_kwota) as srednia_wartosc_zamowien
from zamowienia as z
inner join adresy as a on z.adres_id = a.id 
inner join wojewodztwa as w on a.wojewodztwo_id = w.id
group by a.wojewodztwo_id, w.nazwa)
select nazwa, sw.liczba_zamowien, sw.przychod, sw.srednia_wartosc_zamowien,
round((przychod / SUM(przychod) over()) * 100, 2) as udzial_procentowy
from sprzedaz_woj as sw);

select * from v_sprzedaz_regiony;

--Widok dostawy kurierow
create or replace view v_statystyki_przewoznikow as (
with kurier_stat as (
select fk.id, fk.nazwa, count(d.id) as liczba_wyslanych_paczek, 
round(avg(d.koszt_wysylki), 2) as sredni_koszt_wysylki,
sum(case when d.status_dostawy = 'Zwrócona' then 1 else 0 end) as liczba_zwrotow
from firmy_kurierskie as fk
inner join dostawy as d on fk.id = d.firma_kurierska_id
group by fk.id, fk.nazwa)
select ks.nazwa, ks.sredni_koszt_wysylki, ks.liczba_wyslanych_paczek, ks.liczba_zwrotow,
round(((ks.liczba_zwrotow ) / ks.liczba_wyslanych_paczek) * 100, 2) as procent_zwrotow
from kurier_stat as ks);
select * from v_statystyki_przewoznikow;

--Widok klasyfikacja klientow
create or replace view v_klasyfikacja_klientow as(
with klasyfikacja as (
select k.id, concat(k.imie, ' ', k.nazwisko) as klient, count(z.id) as liczba_zamowien,
current_date - max(z.data_zamowienia) as dni_od_ostatniego_zakupu
from klienci as k 
inner join zamowienia as z on k.id = z.klient_id
group by k.id)
select k.klient, k.liczba_zamowien, k.dni_od_ostatniego_zakupu,
case 
	when k.liczba_zamowien > 5 and k.dni_od_ostatniego_zakupu < 30 then 'Stały klient'
	when k.liczba_zamowien >=2 and k.dni_od_ostatniego_zakupu < 90 then 'Aktywny'
	when k.dni_od_ostatniego_zakupu > 180 then 'Nieaktywny'
	else 'Standard'
end as segment
from klasyfikacja as k);

select * from v_klasyfikacja_klientow;