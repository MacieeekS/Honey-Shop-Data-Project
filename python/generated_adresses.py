from faker import Faker
import random

fake = Faker('pl_PL')

# Słownik miast
miasta_wojewodztw = {
    1: ['Wrocław', 'Legnica', 'Wałbrzych', 'Jelenia Góra'],
    2: ['Bydgoszcz', 'Toruń', 'Włocławek', 'Grudziądz'],
    3: ['Lublin', 'Zamość', 'Chełm', 'Biała Podlaska'],
    4: ['Zielona Góra', 'Gorzów Wielkopolski', 'Nowa Sól'],
    5: ['Łódź', 'Piotrków Trybunalski', 'Skierniewice'],
    6: ['Kraków', 'Tarnów', 'Nowy Sącz', 'Zakopane'],
    7: ['Warszawa', 'Radom', 'Płock', 'Siedlce'],
    8: ['Opole', 'Nysa', 'Brzeg', 'Kędzierzyn-Koźle'],
    9: ['Rzeszów', 'Przemyśl', 'Krosno', 'Sanok'],
    10: ['Białystok', 'Suwałki', 'Łomża', 'Augustów'],
    11: ['Gdańsk', 'Gdynia', 'Sopot', 'Słupsk'],
    12: ['Katowice', 'Częstochowa', 'Gliwice', 'Bielsko-Biała'],
    13: ['Kielce', 'Ostrowiec Świętokrzyski', 'Sandomierz'],
    14: ['Olsztyn', 'Elbląg', 'Ełk', 'Mrągowo'],
    15: ['Poznań', 'Kalisz', 'Konin', 'Piła'],
    16: ['Szczecin', 'Koszalin', 'Świnoujście', 'Kołobrzeg']
}

# Słownik prefiksów kodów pocztowych (pierwsze 2 cyfry)
kody_miast = {
    'Wrocław': ['50', '51', '52', '53', '54'], 'Legnica': ['59'], 'Wałbrzych': ['58'], 'Jelenia Góra': ['58'],
    'Bydgoszcz': ['85'], 'Toruń': ['87'], 'Włocławek': ['87'], 'Grudziądz': ['86'],
    'Lublin': ['20'], 'Zamość': ['22'], 'Chełm': ['22'], 'Biała Podlaska': ['21'],
    'Zielona Góra': ['65'], 'Gorzów Wielkopolski': ['66'], 'Nowa Sól': ['67'],
    'Łódź': ['90', '91', '92', '93', '94'], 'Piotrków Trybunalski': ['97'], 'Skierniewice': ['96'],
    'Kraków': ['30', '31'], 'Tarnów': ['33'], 'Nowy Sącz': ['33'], 'Zakopane': ['34'],
    'Warszawa': ['00', '01', '02', '03', '04'], 'Radom': ['26'], 'Płock': ['09'], 'Siedlce': ['08'],
    'Opole': ['45', '46'], 'Nysa': ['48'], 'Brzeg': ['49'], 'Kędzierzyn-Koźle': ['47'],
    'Rzeszów': ['35'], 'Przemyśl': ['37'], 'Krosno': ['38'], 'Sanok': ['38'],
    'Białystok': ['15'], 'Suwałki': ['16'], 'Łomża': ['18'], 'Augustów': ['16'],
    'Gdańsk': ['80'], 'Gdynia': ['81'], 'Sopot': ['81'], 'Słupsk': ['76'],
    'Katowice': ['40'], 'Częstochowa': ['42'], 'Gliwice': ['44'], 'Bielsko-Biała': ['43'],
    'Kielce': ['25'], 'Ostrowiec Świętokrzyski': ['27'], 'Sandomierz': ['27'],
    'Olsztyn': ['10'], 'Elbląg': ['82'], 'Ełk': ['19'], 'Mrągowo': ['11'],
    'Poznań': ['60', '61'], 'Kalisz': ['62'], 'Konin': ['62'], 'Piła': ['64'],
    'Szczecin': ['70', '71'], 'Koszalin': ['75'], 'Świnoujście': ['72'], 'Kołobrzeg': ['78']
}

zapytania = []

for klient_id in range(1, 401):
    wojewodztwo_id = random.randint(1, 16)
    miasto = random.choice(miasta_wojewodztw[wojewodztwo_id])
    ulica = fake.street_name()
    
    # --- NOWA LOGIKA KODÓW POCZTOWYCH ---
    # Losujemy jeden z przypisanych prefiksów
    prefiks = random.choice(kody_miast[miasto])
    # Doklejamy myślnik i 3 losowe cyfry, formatując je tak, by zawsze miały 3 znaki (np. 012)
    kod_pocztowy = f"{prefiks}-{random.randint(1, 999):03d}"
    
    zapytania.append(f"({klient_id}, '{miasto}', '{ulica}', '{kod_pocztowy}', {wojewodztwo_id})")

print("INSERT INTO adresy (klient_id, miasto, ulica, kod_pocztowy, wojewodztwo_id) VALUES")
print(",\n".join(zapytania) + ";")
