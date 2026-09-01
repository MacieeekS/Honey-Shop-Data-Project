from faker import Faker

fake = Faker('pl_PL')

zapytania = []

for i in range(400):
    imie = fake.first_name()
    nazwisko = fake.last_name()
    email = fake.unique.email()
    telefon_surowy = fake.phone_number()
    telefon = ''.join(znak for znak in telefon_surowy if znak.isdigit() or znak == '+')[:15]
    data = fake.date_between(start_date='-3y', end_date='today')
    
    zapytania.append(f"('{imie}', '{nazwisko}', '{email}', '{telefon}', '{data}')")

print("INSERT INTO klienci (imie, nazwisko, email, telefon, data_rejestracji) VALUES")
print(",\n".join(zapytania) + ";")
