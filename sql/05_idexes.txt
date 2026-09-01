--Optymalizacja

--Optymalizacja na statusie zamowien
explain analyze select * from zamowienia where status = 'Anulowane';
--Execution Time: 0.215 ms
create index idx_zamowienia_status on zamowienia(status);
explain analyze select * from zamowienia where status = 'Anulowane';
--Execution Time: 0.117 ms

--Optymalizacja na datach zamowien
explain analyze select * from zamowienia where data_zamowienia >= '2024-01-01';
--Execution Time: 0.334 ms
create index idx_zamowienia_data on zamowienia(data_zamowienia);
explain analyze select * from zamowienia where data_zamowienia >= '2024-01-01';
--Execution Time: 0.171 ms


--Optymalizacja na klientach
explain analyze select * from klienci where email = 'oliwier59@example.net';
--Execution Time: 1.688 ms
create index idx_klienci_email on klienci(email);
explain analyze select * from klienci where email = 'oliwier59@example.net';
--Execution Time: 0.093 ms

--Optymalizacja na kluczu obcym - produkt_id
explain analyze select * from szczegoly_zamowienia where produkt_id = 45;
--Execution Time: 0.572 ms
create index idx_szczegoly_zamowienia_produkt_id on szczegoly_zamowienia(produkt_id);
explain analyze select * from szczegoly_zamowienia where produkt_id = 45;
--Execution Time: 0.087 ms