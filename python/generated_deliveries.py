import random
from faker import Faker

fake = Faker('pl_PL')

zapytania = []

statusy_dostawy = ['Przygotowana', 'Wysłana', 'W doręczeniu', 'Dostarczona', 'Zwrócona']
wagi_dostaw = [5, 10, 10, 70, 5]
koszty_wysylki = [9.99, 12.99, 14.99, 18.99, 24.99]

for zamowienie_id in range(1, 1001):
    firma_kurierska_id = random.randint(1, 5)
    numer_paczki = fake.bothify(text='PL-#########')
    status_dos = random.choices(statusy_dostawy, weights=wagi_dostaw)[0]
    koszt = random.choice(koszty_wysylki)
    
    zapytania.append(f"({zamowienie_id}, {firma_kurierska_id}, '{numer_paczki}', '{status_dos}', {koszt})")

print("INSERT INTO dostawy (zamowienie_id, firma_kurierska_id, numer_paczki, status_dostawy, koszt_wysylki) VALUES")
print(",\n".join(zapytania) + ";")
