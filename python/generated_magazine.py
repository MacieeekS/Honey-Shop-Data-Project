import random

zapytania = []

# Mamy 100 produktów (ID od 1 do 100)
for produkt_id in range(1, 101):
    wojewodztwo_id = random.randint(1, 16)
    ilosc_sztuk = random.randint(50, 200)
    
    # Ta linijka wywalała błąd, upewnij się, że tu jest!
    minimalny_stan = random.randint(10, 30) 
    
    zapytania.append(f"({produkt_id}, {wojewodztwo_id}, {ilosc_sztuk}, {minimalny_stan})")

print("INSERT INTO magazyn (produkt_id, wojewodztwo_id, ilosc_sztuk, minimalny_stan) VALUES")
print(",\n".join(zapytania) + ";")
