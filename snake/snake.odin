package snake

import rl "vendor:raylib"

WINDOW_SIZE :: 1000
GRID_WIDTH :: 20
CELL_SIZE :: 16
CANVAS_WIDTH :: GRID_WIDTH * CELL_SIZE

TICK_RATE :: 0.13

Vec2i :: [2]int

tick_timer: f32 = TICK_RATE
snake_head_pos: Vec2i

main :: proc() {
	rl.SetConfigFlags({.VSYNC_HINT})
	rl.InitWindow(WINDOW_SIZE, WINDOW_SIZE, "Classsic Snake")
	defer rl.CloseWindow()

	snake_head_pos = {GRID_WIDTH / 2, GRID_WIDTH / 2}

	for !rl.WindowShouldClose() {
		tick_timer -= rl.GetFrameTime()

		if tick_timer <= 0 {
			snake_head_pos += {0, 1}
			tick_timer = TICK_RATE + tick_timer
		}

		rl.BeginDrawing()
		rl.ClearBackground({20, 20, 20, 255})

		cam := rl.Camera2D {
			zoom = f32(WINDOW_SIZE) / CANVAS_WIDTH,
		}

		rl.BeginMode2D(cam)

		head_rect := rl.Rectangle {
			f32(snake_head_pos.x) * CELL_SIZE,
			f32(snake_head_pos.y) * CELL_SIZE,
			CELL_SIZE,
			CELL_SIZE,
		}

		rl.DrawRectangleRounded(head_rect, 0.5, 6, rl.GREEN)

		rl.EndMode2D()
		rl.EndDrawing()
	}
}
