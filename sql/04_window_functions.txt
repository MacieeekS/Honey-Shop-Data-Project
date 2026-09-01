--Window Function

--Najdroższe produkty w danej kategorii
select p.nazwa, p.kategoria_id, p.cena, 
DENSE_RANK() over(partition by p.kategoria_id order by p.cena desc) as ranking
from produkty as p;

--Wykres przychodów
select id, data_zamowienia, calkowita_kwota,
SUM(calkowita_kwota) over(order by data_zamowienia) as cala_kwota
from zamowienia as z;

--Przychod z dzisiaj vs z wczoraj
with dzienne_utargi as (
select data_zamowienia, SUM(calkowita_kwota) as utarg_dzienny from zamowienia
group by data_zamowienia)
select du.data_zamowienia, du.utarg_dzienny, lag(du.utarg_dzienny) over (order by du.data_zamowienia)
as utarg_z_poprzedniego_dnia
from dzienne_utargi as du;

--Najlepiej sprzedajacy sie produkt w danym Wojewodztwie
with sprzedaz_regiony as (
select sum(sz.ilosc) as zsumowana_ilosc, sz.produkt_id, a.wojewodztwo_id 
from szczegoly_zamowienia as sz
inner join zamowienia as z on sz.zamowienie_id = z.id 
inner join adresy as a on z.adres_id = a.id
group by wojewodztwo_id, produkt_id),
ranking_regionow as (
select produkt_id, wojewodztwo_id, zsumowana_ilosc,
row_number() over (partition by wojewodztwo_id order by zsumowana_ilosc desc) as pozycja
from sprzedaz_regiony)
select p.nazwa as produkt, w.nazwa as wojewodztwo, rr.zsumowana_ilosc from ranking_regionow as rr
inner join produkty as p on rr.produkt_id = p.id
inner join wojewodztwa as w on rr.wojewodztwo_id = w.id 
where rr.pozycja = 1;

--3 najdrozsze produkty z kazdej kategorii
with ranking_produktow as (
select nazwa, kategoria_id, cena,
dense_rank() over(partition by kategoria_id order by cena desc) as ranking
from produkty)
select rp.nazwa as nazwa_produktu, rp.kategoria_id, k.nazwa as nazwa_kategorii, rp.cena, rp.ranking 
from ranking_produktow as rp
inner join kategorie as k on rp.kategoria_id = k.id
where rp.ranking in (1, 2, 3)
order by k.nazwa, rp.cena desc;

--Produkty drozsze od sredniej w kategorii
with srednie_kategorii as (
select nazwa, cena, kategoria_id,
AVG(cena) over(partition by kategoria_id) as srednia_w_kategorii
from produkty)
select sk.kategoria_id, k.nazwa, sk.nazwa, sk.cena, sk.srednia_w_kategorii from srednie_kategorii as sk
inner join kategorie as k on sk.kategoria_id = k.id
where sk.cena > sk.srednia_w_kategorii;

--Ile dni mija miedzy kolejnymi zamowieniami
with historia_zakupow as (
select klient_id, id as numer_zamowienia, data_zamowienia, 
lag(data_zamowienia) over(partition by klient_id order by data_zamowienia) as poprzednie_zamowienie
from zamowienia)
select hz.klient_id, hz.numer_zamowienia, hz.data_zamowienia, hz.poprzednie_zamowienie, 
hz.data_zamowienia - hz.poprzednie_zamowienie as dni_miedzy_zakupami
from historia_zakupow as hz;

--Procent udzialu klienta w utargu
with utarg_calkowity as (
select id, calkowita_kwota, SUM(calkowita_kwota) over() as suma
from zamowienia)
select uc.id, uc.calkowita_kwota, round((uc.calkowita_kwota / uc.suma) * 100, 4) as procent_utargu
from utarg_calkowity as uc
order by procent_utargu desc;

--Jak długo klienci z nami zostają
with pierwsze_zamowienie as (
select klient_id, id as numer_zamowienia, data_zamowienia,
min(data_zamowienia) over(partition by klient_id) as data_pierwszego_zamowienia
from zamowienia)
select pz.klient_id, pz.numer_zamowienia, pz.data_zamowienia,
pz.data_zamowienia  - pz.data_pierwszego_zamowienia as dni_od_debiutu
from pierwsze_zamowienie as pz
order by pz.klient_id, pz.data_zamowienia desc;

--Portfel klienta
with zamowienia_klienta as (
select id as numer_zamowienia, klient_id, data_zamowienia, calkowita_kwota,
sum(calkowita_kwota) over(partition by klient_id order by data_zamowienia) as dotychczasowe_wydatki
from zamowienia)
select zk.klient_id, zk.numer_zamowienia, zk.data_zamowienia, zk.calkowita_kwota, zk.dotychczasowe_wydatki 
from zamowienia_klienta as zk
order by zk.klient_id, zk.data_zamowienia;