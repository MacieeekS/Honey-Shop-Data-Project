import random
from faker import Faker

fake = Faker('pl_PL')

zapytania = []
unikalne_pary = set()

# Pętla działa, dopóki nie zbierzemy 250 unikalnych par
while len(unikalne_pary) < 250:
    klient_id = random.randint(1, 400)
    produkt_id = random.randint(1, 100)
    unikalne_pary.add((klient_id, produkt_id))

for para in unikalne_pary:
    klient_id, produkt_id = para
    data_dodania = fake.date_between(start_date='-1y', end_date='today')
    zapytania.append(f"({klient_id}, {produkt_id}, '{data_dodania}')")

print("INSERT INTO ulubione (klient_id, produkt_id, data_dodania) VALUES")
print(",\n".join(zapytania) + ";")
