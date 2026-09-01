--Joiny

--10 Najnowszych zamówień
select z.id, z.data_zamowienia, k.imie, k.nazwisko from zamowienia as z
inner join klienci as k on z.klient_id = k.id
order by data_zamowienia desc limit 10;

--Najlepiej sprzedające się produkty
select p.nazwa, coalesce(sum(sz.ilosc), 0) as suma_sprzedanych_sztuk from produkty as p 
left join szczegoly_zamowienia as sz on p.id = sz.produkt_id
group by p.nazwa order by suma_sprzedanych_sztuk desc;

--Opłacone zamówienia, które nie opuściły magazynu
select z.id, z.data_zamowienia, p.status, d.status_dostawy from zamowienia as z
inner join platnosci as p on z.id = p.zamowienie_id
inner join dostawy as d on z.id = d.zamowienie_id
where d.status_dostawy = 'Przygotowana' and p.status = 'Zakończona';

--Zamówienia z kodem 'PASIEKA15'
select k.imie, k.nazwisko, p.nazwa, z.id as numer_zamowienia, sz.ilosc, kr.kod from klienci as k
inner join zamowienia as z on k.id = z.klient_id
inner join szczegoly_zamowienia as sz on z.id = sz.zamowienie_id 
inner join produkty as p on sz.produkt_id = p.id 
inner join kody_rabatowe as kr on z.kod_rabatowy_id = kr.id
where kr.kod = 'PASIEKA15';

--Pracownik z największą ilością zamówień
select p.imie, p.nazwisko, count(z.id) as liczba_obsluzonych_zamowien from pracownicy as p
inner join zamowienia as z on p.id = z.pracownik_id
inner join platnosci as pl on z.id = pl.zamowienie_id 
where pl.status = 'Zakończona' 
group by p.imie, p.nazwisko order by liczba_obsluzonych_zamowien desc;

--Osoby które nie złożyły żadnego zamówienia
select k.imie, k.nazwisko, k.email from klienci as k
left join zamowienia as z on k.id = z.klient_id
where z.id is null;

--Gdzie wysylamy najwiecej miodu
select a.wojewodztwo_id, w.nazwa, sum(z.calkowita_kwota) as calkowita_kwota from adresy as a
inner join zamowienia as z on a.id = z.adres_id
inner join wojewodztwa as w on a.wojewodztwo_id = w.id
group by a.wojewodztwo_id, w.nazwa 
order by calkowita_kwota desc;

--Paczki zwrocone do nadawcy
select d.numer_paczki, fk.id, fk.nazwa, k.imie, k.nazwisko, k.telefon from dostawy as d
inner join firmy_kurierskie as fk on d.firma_kurierska_id = fk.id 
inner join zamowienia as z on d.zamowienie_id = z.id 
inner join klienci as k on z.klient_id = k.id 
where d.status_dostawy = 'Zwrócona';