-- Testy funkcjonalności i aktualizacji dashboardów w PowerBi

--1 Cykl życia zamówienia
select * from magazyn m order by ilosc_sztuk asc; --ilosc 51
select * from produkty where id = 31; --Miod lipowy id 31

call zamowienie(31, 6, 401, 401, null); -- zamówienie na 6 sztuk miodu lipowego
-- zamówienie nr. 1009

select * from zamowienia where id = 1009; --status nowe, brak pracownika

select * from magazyn where produkt_id = 31; 
-- sprawdzenie stanu magazynowego, stan 45 sztuk

call przypisz_pracownika(1009, 1);
select * from zamowienia where id = 1009; --przypisany pracownik nr.1

call zmiana_statusu(1009, 'Wysłane'); --zmiana statusu na 'Wysłane';
call zmiana_statusu(1009, 'Anulowane'); --SQL Error [P0001]: BŁĄD: Paczka numer 1009 została już wysłana
call zmiana_statusu(1009, 'Dostarczone');

select * from zamowienia where id = 1009;
-- zamówienie dostarczone

--2 Próba zamówienia większej ilości sztuk niż mamy na magazynie
--Dodanie klienta i adresu
call dodaj_klienta('Janusz', 'Przykładowy', 'janusz.przyklad@onet.pl', '712345678');
select * from klienci where id = 402;
call dodaj_adres(402, 'Poznań', 'Matejki 3', '60-782', 15);
select * from adresy where klient_id = 402;

--Sprawdzenie stanu magazynu
select * from magazyn order by ilosc_sztuk asc; -- id->56, sztuk: 53

--Zamowienie
call zamowienie(56, 60, 402, 402, 2);
--BŁĄD: Brak produktu w magazynie

select * from zamowienia order by id desc; --Brak nowego zamowienia
select * from magazyn where produkt_id = 56; -- Dalej 53 sztuki

--3 Zwrot większej ilości sztuk
call zamowienie(44, 4, 367, 367, null);
call zmiana_statusu(1012, 'Wysłane');
call czesciowy_zwrot(1012, 44, 5);
--Błąd: zwracana ilość jest większa niż liczba produktów w zamówieniu
call czesciowy_zwrot(1012, 44, 1);

--4 Anulowanie anulowanego zamówienia
call zamowienie(10, 1, 10, 10, null);
call anuluj_zamowienie(1013);
call zmiana_statusu(1013, 'Nowe');
--BŁĄD: Zamówienie numer 1013 jest już zamknięte, brak możliwości zmiany statusu
call anuluj_zamowienie(1013);
--BŁĄD: Błąd: zamówienie nr 1013 zostało już wcześniej anulowane!

--5 Zła dostawa
call przyjmij_dostawe(18, -10, 3);
--BŁĄD: Błąd: Ilość sztuk w dostawie musi być większa od zera!