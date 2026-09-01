import random
from faker import Faker

fake = Faker('pl_PL')

zapytania = []

# Statusy muszą dokładnie pasować do Twojego ograniczenia CHECK w bazie
statusy = ['Nowe', 'Opłacone', 'Wysłane', 'Dostarczone', 'Anulowane']
# Ustawiamy wagi - większość będzie dostarczona, mało anulowanych
wagi_statusow = [5, 10, 15, 65, 5] 

for i in range(1000):
    # ZASADA PARETO: 80% szans, że kupi stały klient (np. ID 1-80)
    # 20% szans, że kupi ktoś z pozostałych 320 klientów (ID 81-400)
    if random.random() < 0.8:
        klient_id = random.randint(1, 80)
    else:
        klient_id = random.randint(81, 400)
        
    # Każdy klient dostał jeden adres, więc ID się pokrywają
    adres_id = klient_id
    
    # Obsługuje go losowy pracownik (ID 1 do 5)
    pracownik_id = random.randint(1, 5)
    
    # 20% szans na użycie kodu rabatowego (mamy 4 kody w bazie)
    if random.random() < 0.2:
        kod_rabatowy_id = random.randint(1, 4)
        kod_sql = str(kod_rabatowy_id)
    else:
        kod_sql = "NULL"
        
    data_zam = fake.date_between(start_date='-2y', end_date='today')
    status = random.choices(statusy, weights=wagi_statusow)[0]
    
    # Kwota zastępcza (przeliczymy ją w bazie później)
    calkowita_kwota = round(random.uniform(50.0, 500.0), 2)
    
    # Budujemy wiersz SQL (zwróć uwagę na NULL bez apostrofów dla kod_sql)
    zapytania.append(f"({klient_id}, {adres_id}, {pracownik_id}, {kod_sql}, '{data_zam}', '{status}', {calkowita_kwota})")

print("INSERT INTO zamowienia (klient_id, adres_id, pracownik_id, kod_rabatowy_id, data_zamowienia, status, calkowita_kwota) VALUES")
print(",\n".join(zapytania) + ";")
