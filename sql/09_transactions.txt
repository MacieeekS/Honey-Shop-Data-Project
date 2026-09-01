--Transakcja zamowienie

begin;
update magazyn set ilosc_sztuk = ilosc_sztuk - 2
where produkt_id = 1;

insert into zamowienia (klient_id, adres_id, data_zamowienia, status, calkowita_kwota)
values (1, 1, current_date, 'Nowe', 90);

insert into szczegoly_zamowienia (zamowienie_id, produkt_id, ilosc, cena_w_momencie_zakupu)
values (lastval(), 1, 2, 45);
commit;

--Symulacja błędu
BEGIN;
UPDATE magazyn SET ilosc_sztuk = ilosc_sztuk - 2 WHERE produkt_id = 1;

INSERT INTO zamowienia (klient_id, adres_id, data_zamowienia, status, calkowita_kwota)
VALUES (1, 1, CURRENT_DATE, 'Nowe', 45);

ROLLBACK;


select * from zamowienia order by id desc;