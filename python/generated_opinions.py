import random
from faker import Faker

fake = Faker('pl_PL')

zapytania = []
oceny = [1, 2, 3, 4, 5]
wagi_ocen = [5, 5, 10, 30, 50] # Najwięcej 5-tek i 4-rek

komentarze_pozytywne = ['Super jakość!', 'Szybka wysyłka, polecam.', 'Pyszny miód, dzieciaki uwielbiają.', 'Najlepsza pasieka w sieci.', 'Konsystencja idealna.', 'Kupię ponownie.']
komentarze_negatywne = ['Przesyłka szła za długo.', 'Słoik był lekko nieszczelny.', 'Smak mi nie podszedł.', 'Zbyt szybko skrystalizował.', 'Za słodki jak dla mnie.']

for i in range(300):
    klient_id = random.randint(1, 400)
    produkt_id = random.randint(1, 100)
    ocena = random.choices(oceny, weights=wagi_ocen)[0]
    
    if ocena >= 4:
        komentarz = random.choice(komentarze_pozytywne)
    else:
        komentarz = random.choice(komentarze_negatywne)
        
    zapytania.append(f"({klient_id}, {produkt_id}, {ocena}, '{komentarz}')")

print("INSERT INTO opinie (klient_id, produkt_id, ocena, komentarz) VALUES")
print(",\n".join(zapytania) + ";")
