import random
from faker import Faker

fake = Faker('pl_PL')

zapytania = []

for i in range(150):
    produkt_id = random.randint(1, 100)
    # Losujemy starą cenę i nową cenę (żeby pokazać, że była zmiana)
    stara_cena = round(random.uniform(20.0, 90.0), 2)
    nowa_cena = round(random.uniform(25.0, 100.0), 2)
    data_zmiany = fake.date_between(start_date='-2y', end_date='-1m')
    
    zapytania.append(f"({produkt_id}, {stara_cena}, {nowa_cena}, '{data_zmiany}')")

print("INSERT INTO historia_cen (produkt_id, stara_cena, nowa_cena, data_zmiany) VALUES")
print(",\n".join(zapytania) + ";")
