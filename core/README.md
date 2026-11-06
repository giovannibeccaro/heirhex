# core/ — il motore delle regole

Classi GDScript pure (`extends RefCounted`): **nessun nodo, scena o grafica**.
Combattimento, mattoncini degli effetti, stati, modificatori, memoria della stirpe, testamento.

Deve poter girare senza grafica (`godot --headless`) per i test e le simulazioni.
Il codice conosce solo i *tipi* (mattoncini, stati, proprietà), mai i contenuti: nessun nome di carta o nemico qui.
