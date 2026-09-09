// Pool (Public for users who want to re-use it as-is for other resources).
// ----------------------------------------------------------------------------
// The pool is a simple resource management system.
//
// The pool work like this, there is a fixed number of slots (defined at pool
// creation) that can be acquired and released. Each slot has an incrementing
// generation counter, which is used to generate unique ids for each slot.
//
// When a slot is released, its generation counter is incremented, so that any
// ids generated from that slot will be invalid until the slot is acquired
// again.
package sdl_gp

POOL_INVALID_SLOT :: 0
POOL_SLOT_SHIFT   :: 16
POOL_SLOT_MASK    :: ((1<<POOL_SLOT_SHIFT)-1)

Pool :: struct {
	size:           i32,  // total number of slots in the pool (counting the invalid slot)
	counters:       ^u32, // incrementing generation counters for each slot
	free_stack:     ^i32, // stack of free slots
	free_stack_top: i32,  // index of the top of the free queue
}

@(default_calling_convention="c", link_prefix="SDL_GP", require_results)
foreign lib {
	// Create a pool with the specified number of slots (not counting the invalid
	// slot).
	CreatePool :: proc (number_of_slots: i32) -> ^Pool ---

	// Destroy a pool and free its resources.
	DestroyPool :: proc (resource: ^Pool) ---

	// Acquire a slot from the pool and return its index. Returns
	// POOL_INVALID_SLOT if no more slots are available.
	AcquirePoolSlot :: proc (resource: ^Pool) -> i32 ---

	// Release a slot back to the pool, making it available for future
	// acquisitions.
	ReleasePoolSlot :: proc (resource: ^Pool, slot_index: i32) ---

	// Generate a unique id for a slot in the pool using its index and generation
	// counter.
	GeneratePoolId :: proc (resource: ^Pool, slot_index: i32) -> u32 ---

	// Extract the slot index from a generated id.
	PoolIdToSlot :: proc (id: u32) -> i32 ---
}
