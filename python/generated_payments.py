import random
from faker import Faker

fake = Faker('pl_PL')

zapytania = []

statusy_platnosci = ['Oczekująca', 'Zakończona', 'Odrzucona']
wagi_platnosci = [10, 85, 5]

for zamowienie_id in range(1, 1001):
    metoda_platnosci_id = random.randint(1, 5)
    status_plat = random.choices(statusy_platnosci, weights=wagi_platnosci)[0]
    data_platnosci = fake.date_between(start_date='-2y', end_date='today')
    
    zapytania.append(f"({zamowienie_id}, {metoda_platnosci_id}, '{status_plat}', '{data_platnosci}')")

print("INSERT INTO platnosci (zamowienie_id, metoda_platnosci_id, status, data_platnosci) VALUES")
print(",\n".join(zapytania) + ";")
