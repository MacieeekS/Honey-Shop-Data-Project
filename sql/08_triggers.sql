--Trigger - zmiana dostepnosci produktów
create or replace function zmiana_dostepnosci()
returns trigger as $$
begin
	if new.ilosc_sztuk <= 0 then update produkty set czy_dostepny = false where
	id = new.produkt_id;
	else update produkty set czy_dostepny = true where id = new.produkt_id;
end if;
return new;
end;
$$ language plpgsql;

create trigger trg_zmiana_dostepnosci
after update of ilosc_sztuk on magazyn
for each row
execute function zmiana_dostepnosci();

select p.id, m.ilosc_sztuk, p.czy_dostepny  from produkty as p 
inner join magazyn as m on p.id = m.produkt_id
where m.ilosc_sztuk <= 20;

call zamowienie(1, 20, 2, 2, 1);
call anuluj_zamowienie(1005);

create or replace function podsumowanie_zamowienia(p_zamowienie_id int)
returns table (
numer_zamowienia int, status_zamowienia varchar, calkowita_kwota numeric, numer_produktu int, 
nazwa_produktu varchar,  ilosc_sztuk int, imie_klienta varchar, nazwisko_klienta varchar, 
miasto varchar, ulica varchar, kod_pocztowy varchar)
language plpgsql as $$
begin
	return query 
with dane_z as (
	select z.id, z.status, z.calkowita_kwota, z.klient_id, z.adres_id, sz.produkt_id, p.nazwa, sz.ilosc 
	from zamowienia as z
	inner join szczegoly_zamowienia as sz on z.id = sz.zamowienie_id
	inner join produkty as p on sz.produkt_id = p.id
	where z.id = p_zamowienie_id),
dane_k as (select k.id as k_id, a.id as a_id, k.imie, k.nazwisko, 
	a.miasto, a.ulica, a.kod_pocztowy from klienci as k
	inner join adresy as a on k.id = a.klient_id)
select dz.id, dz.status, dz.calkowita_kwota, dz.produkt_id, dz.nazwa, dz.ilosc, dk.imie, dk.nazwisko, 
dk.miasto, dk.ulica, dk.kod_pocztowy
from dane_z as dz inner join dane_k as dk on dz.klient_id = dk.k_id and dz.adres_id = dk.a_id;
end;
$$;

select * from podsumowanie_zamowienia(1005);
