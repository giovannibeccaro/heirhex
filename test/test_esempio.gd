extends GutTest
## Test di esempio: verifica che GUT sia installato e funzionante.

func test_la_somma_funziona() -> void:
	assert_eq(1 + 1, 2, "GUT esegue i test")
