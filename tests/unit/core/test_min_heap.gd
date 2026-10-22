extends GdUnitTestSuite
## Hàng đợi ưu tiên của flow field (S2.T03).


func test_pops_in_priority_order() -> void:
	var heap := MinHeap.new()
	for priority in [5.0, 1.0, 4.0, 2.0, 3.0, 0.5]:
		heap.push(priority, int(priority * 10))
	var order: Array = []
	while not heap.is_empty():
		heap.pop()
		order.append(heap.last_priority)
	assert_array(order).is_equal([0.5, 1.0, 2.0, 3.0, 4.0, 5.0])


func test_pop_returns_the_value_of_the_smallest_priority() -> void:
	var heap := MinHeap.new()
	heap.push(2.0, 20)
	heap.push(1.0, 10)
	assert_int(heap.pop()).is_equal(10)
	assert_int(heap.size()).is_equal(1)


func test_random_load_stays_sorted() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	var heap := MinHeap.new()
	for i in 500:
		heap.push(rng.randf() * 100.0, i)
	var previous := -1.0
	while not heap.is_empty():
		heap.pop()
		assert_bool(heap.last_priority >= previous).is_true()
		previous = heap.last_priority
