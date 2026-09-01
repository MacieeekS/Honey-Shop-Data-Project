--Zadania na pojedynczych tabelach

--Aktywne kody rabatowe ze zniżką większą niż 10%
select kod, procent_znizki, czy_aktywny from kody_rabatowe
where procent_znizki > 10 and czy_aktywny = true;

--Najdroższe dostępne produkty w sklepie
select nazwa, cena, czy_dostepny from produkty 
where czy_dostepny = true order by cena desc limit 5;

--Opinie które zawierają słowo 'Polecam'
select ocena, komentarz from opinie
where komentarz ilike '%polecam%';

--Ilu pracowników zatrudniamy na stanowisku 'Sprzedawca'
select count(id) as liczba_pracownikow from pracownicy
where stanowisko = 'Sprzedawca';

--Suma przychodów z dostarczonych zamówień
select sum(calkowita_kwota) as suma_przychodow from zamowienia
where status = 'Dostarczone';

--Średnia cena naszych produktów
select round(avg(cena), 2) as srednia_cena from produkty;

--Liczba zamówień w poszczególnych statusach
select status, count(id) as liczba_zamowien from zamowienia
group by status order by liczba_zamowien desc;

--Najwyższa i najniższa cena produktu w każdej kategorii
select kategoria_id, max(cena) as najwyzsza_cena, min(cena) as najmniejsza_cena from produkty
group by kategoria_id;

--Alert magazynowy
select produkt_id, sum(ilosc_sztuk) as laczna_ilosc from magazyn
group by produkt_id
having sum(ilosc_sztuk) < 150;

--Produkty z ocena wyższą niż 4 oraz liczbą opinii większa niż 3
select produkt_id, avg(ocena) as srednia_ocen from opinie
group by produkt_id 
having avg(ocena) >= 4 and count(id) >= 3
order by srednia_ocen desc;