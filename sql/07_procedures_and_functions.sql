--Procedury i funkcje

--Dodaj zamowienie
create or replace procedure zamowienie(
p_produkt_id int, p_ilosc int, p_klient_id int, p_adres_id int, p_kod_rabatowy_id int default null)
language plpgsql as $$
declare 
v_ilosc_sztuk int;
v_cena numeric;
v_kwota_do_zaplaty numeric;
v_nowe_zamowienie_id int;
v_procent_rabatu int;
begin
if p_ilosc <= 0 then
        raise exception 'BŁĄD: Zamawiana ilość musi być większa od zera!';
end if;

	select m.ilosc_sztuk, p.cena into v_ilosc_sztuk, v_cena from magazyn as m 
	inner join produkty as p on m.produkt_id = p.id
	where p.id = p_produkt_id;

if v_ilosc_sztuk < p_ilosc then
raise exception 'Brak produktu w magazynie';
end if;
v_kwota_do_zaplaty := p_ilosc * v_cena;

if p_kod_rabatowy_id is not null then
select procent_znizki into v_procent_rabatu from kody_rabatowe
where id = p_kod_rabatowy_id;

v_kwota_do_zaplaty := v_kwota_do_zaplaty - (v_kwota_do_zaplaty * v_procent_rabatu / 100.0);
end if;

update magazyn
set ilosc_sztuk = ilosc_sztuk - p_ilosc
where produkt_id = p_produkt_id;

insert into 
zamowienia (klient_id, adres_id, kod_rabatowy_id, data_zamowienia, status, calkowita_kwota)
values
(p_klient_id, p_adres_id, p_kod_rabatowy_id, current_date, 'Nowe', v_kwota_do_zaplaty)
returning id into v_nowe_zamowienie_id;

insert into 
szczegoly_zamowienia (zamowienie_id, produkt_id, ilosc, cena_w_momencie_zakupu)
VALUES
(v_nowe_zamowienie_id, p_produkt_id, p_ilosc, v_cena);

raise notice 'Pomyslnie dokonano zakupu';

end;
$$;

--Anuluj zamowienie
create or replace procedure anuluj_zamowienie(
p_zamowienie_id int)
language plpgsql as $$
declare
v_obecny_status varchar;
begin
select status into v_obecny_status from zamowienia
where id = p_zamowienie_id;

if v_obecny_status = 'Anulowane' then
	raise exception 'Błąd: zamówienie nr % zostało już wcześniej anulowane!', p_zamowienie_id;
elsif v_obecny_status = 'Dostarczone' then
	raise exception 'Błąd: nie można anulować zamówienia %, zamówienie zostało już dostarczone', p_zamowienie_id;
end if;

update zamowienia
set status = 'Anulowane'
where id = p_zamowienie_id;

update magazyn as m
set ilosc_sztuk = m.ilosc_sztuk + sz.ilosc
from szczegoly_zamowienia as sz
where m.produkt_id = sz.produkt_id
and sz.zamowienie_id = p_zamowienie_id;

raise notice 'Pomyślnie anulowano zamówienie nr % i przywrócono produkty na magazyn', p_zamowienie_id;
end;
$$;

--Dodawanie adresu
create or replace procedure dodaj_adres(
p_klient_id int, p_miasto varchar, p_ulica varchar, p_kod_pocztowy varchar, p_wojewodztwo_id int)
language plpgsql as $$
begin
	insert into adresy (klient_id, miasto, ulica, kod_pocztowy, wojewodztwo_id) values
	(p_klient_id, p_miasto, p_ulica, p_kod_pocztowy, p_wojewodztwo_id);

raise notice 'Pomyślnie dodano nowy adres do puli';
end;
$$;

call dodaj_klienta ('Patrycja', 'Nowak', 'patrycjanowa@onet.pl', '987654321');
select * from klienci where id = 401;

call dodaj_adres(401, 'Kunów', 'Fabryczna 1', '27-415', 13);
select * from adresy where id = 401;


--Przypis pracownika do zamówienia
create or replace procedure przypisz_pracownika(
p_zamowienie_id int, p_pracownik_id int)
language plpgsql as $$
begin
	update zamowienia set pracownik_id = p_pracownik_id
	where id = p_zamowienie_id;

raise notice 'Zamówienie zostało przypisane do pracownika o id %', p_pracownik_id;
end;
$$;

select * from zamowienia where id in (1003);

call przypisz_pracownika (1003, 1);


--Aktualizacja statusu zamówienia
create or replace procedure zmiana_statusu(
p_zamowienie_id int, p_status varchar)
language plpgsql as $$
declare
v_obecny_stan varchar;
begin 
select status into v_obecny_stan from zamowienia
where id = p_zamowienie_id;

if v_obecny_stan IN ('Dostarczone', 'Anulowane') 
then raise exception 'Zamówienie numer % jest już zamknięte, brak możliwości zmiany statusu', p_zamowienie_id;
elsif v_obecny_stan = 'Wysłane' and p_status != 'Dostarczone'
then raise exception 'Paczka numer % została już wysłana', p_zamowienie_id;
end if;

	update zamowienia set status = p_status
	where id = p_zamowienie_id;

raise notice 'Pomyślnie zmieniono status zamówienia numer % na: %', p_zamowienie_id, p_status;

end;
$$;

--Przyjmowanie dostawy
create or replace procedure przyjmij_dostawe(
p_produkt_id int, p_ilosc int, p_wojewodztwo_id int)
language plpgsql as $$
declare
v_czy_istnieje int;
begin
if p_ilosc <= 0 then
	raise exception 'Błąd: Ilość sztuk w dostawie musi być większa od zera!';
end if;

	select count(*) into v_czy_istnieje from magazyn
	where produkt_id = p_produkt_id and wojewodztwo_id = p_wojewodztwo_id;
	
if v_czy_istnieje > 0 then
update magazyn set ilosc_sztuk = ilosc_sztuk + p_ilosc
where produkt_id = p_produkt_id and wojewodztwo_id = p_wojewodztwo_id;
else
insert into magazyn (produkt_id, wojewodztwo_id, ilosc_sztuk)
values (p_produkt_id, p_wojewodztwo_id, p_ilosc);
end if;

raise notice 'Dostawa została przyjęta w magazynie';
end;
$$;

--czesciowy zwrot
create or replace procedure czesciowy_zwrot(
p_zamowienie_id int, p_produkt_id int, p_zwracana_ilosc int)
language plpgsql as $$
declare
v_zwracana_kwota numeric;
v_cena numeric;
v_kupiona_ilosc int;
begin
if p_zwracana_ilosc <= 0 then
	raise exception 'Błąd: zwracana ilość musi być większa od zera';
end if;

select cena_w_momencie_zakupu, ilosc into v_cena, v_kupiona_ilosc from szczegoly_zamowienia
where zamowienie_id = p_zamowienie_id and produkt_id = p_produkt_id;

if p_zwracana_ilosc > v_kupiona_ilosc then
	raise exception 'Błąd: zwracana ilość jest większa niż liczba produktów w zamówieniu';
end if;

v_zwracana_kwota := p_zwracana_ilosc * v_cena;

update szczegoly_zamowienia set 
ilosc = ilosc - p_zwracana_ilosc
where produkt_id = p_produkt_id and zamowienie_id = p_zamowienie_id;

update magazyn set
ilosc_sztuk = ilosc_sztuk + p_zwracana_ilosc
where produkt_id = p_produkt_id;

update zamowienia set
calkowita_kwota = calkowita_kwota - v_zwracana_kwota
where id = p_zamowienie_id;

raise notice 'Pomyślnie dokonano zwrotu produktu % w ilości %', p_produkt_id, p_zwracana_ilosc;
end;
$$;

select * from zamowienia where id = 758; -- 400zl rachunek
select * from szczegoly_zamowienia where zamowienie_id = 758; --produkt - 62 - Miód Wrzosowy 3 sztuki
select * from produkty where id = 62;

call czesciowy_zwrot(758, 62, 1);

--system_lojalnosciowy
create or replace procedure system_lojalnosciowy(
p_klient_id int)
language plpgsql as $$
declare
v_suma_wydatkow numeric;
v_kod_rabatowy varchar;

begin

select coalesce(sum(calkowita_kwota), 0) into v_suma_wydatkow from zamowienia
where klient_id = p_klient_id;

v_kod_rabatowy := 'RABATKLIENT' || p_klient_id;

if v_suma_wydatkow > 4000 then
	insert into kody_rabatowe (kod, procent_znizki, data_waznosci, czy_aktywny) values
	(v_kod_rabatowy, 10, current_date + interval '1 year', true);
raise notice 'Gratulacje! Otrzymałeś nowy kod rabatowy: % na nastepne zakupy', v_kod_rabatowy;
	else raise notice 'Brak wystarczającej kwoty w programie lojalnościowym
						Wydano: %, brakuje: %', v_suma_wydatkow, (4000 - v_suma_wydatkow);
end if;

end;
$$;

select k.id, sum(z.calkowita_kwota) as suma from klienci as k
inner join zamowienia as z on k.id = z.klient_id
group by  k.id order by suma desc;
--id: 22, id: 78

call system_lojalnosciowy(22);
select * from kody_rabatowe;
call system_lojalnosciowy(78);