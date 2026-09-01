import random

zapytania = []

# Mamy 1000 zamówień (ID 1-1000)
for zamowienie_id in range(1, 1001):
    
    # Losujemy, ile różnych produktów klient ma w koszyku (od 1 do 4)
    ilosc_roznych_produktow = random.randint(1, 4)
    
    # Losujemy unikalne ID produktów (od 1 do 100)
    wylosowane_produkty = random.sample(range(1, 101), ilosc_roznych_produktow)
    
    for produkt_id in wylosowane_produkty:
        ilosc_sztuk = random.randint(1, 3) # Od 1 do 3 słoików/sztuk
        cena_w_momencie = 0.00 # Cena tymczasowa
        
        zapytania.append(f"({zamowienie_id}, {produkt_id}, {ilosc_sztuk}, {cena_w_momencie})")

print("INSERT INTO szczegoly_zamowienia (zamowienie_id, produkt_id, ilosc, cena_w_momencie_zakupu) VALUES")
print(",\n".join(zapytania) + ";")
