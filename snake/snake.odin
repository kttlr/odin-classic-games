package snake

import rl "vendor:raylib"

WINDOW_SIZE :: 1000
GRID_WIDTH :: 20
CELL_SIZE :: 16
CANVAS_WIDTH :: GRID_WIDTH * CELL_SIZE
MAX_SNAKE_LENGTH :: GRID_WIDTH * GRID_WIDTH

TICK_RATE :: 0.15

Vec2i :: [2]int

snake: [MAX_SNAKE_LENGTH]Vec2i
snake_length: int
tick_timer: f32 = TICK_RATE
move_direction: Vec2i
game_over: bool
food_pos: Vec2i

restart :: proc() {
    start_head_pos := Vec2i{GRID_WIDTH / 2, GRID_WIDTH / 2}
    snake[0] = start_head_pos
    snake[1] = start_head_pos - Vec2i{0, 1}
    snake[2] = start_head_pos - Vec2i{0, 2}
    snake_length = 3
    move_direction = {0, 1}
    game_over = false
}

main :: proc() {
    rl.SetConfigFlags({.VSYNC_HINT})
    rl.InitWindow(WINDOW_SIZE, WINDOW_SIZE, "Classsic Snake")
    defer rl.CloseWindow()

    restart()

    for !rl.WindowShouldClose() {
        if rl.IsKeyDown(.UP) {
            move_direction = {0, -1}
        }

        if rl.IsKeyDown(.DOWN) {
            move_direction = {0, 1}
        }

        if rl.IsKeyDown(.LEFT) {
            move_direction = {-1, 0}
        }

        if rl.IsKeyDown(.RIGHT) {
            move_direction = {1, 0}
        }

        if game_over {
            if rl.IsKeyPressed(.ENTER) {
                restart()
            }
        } else {
            tick_timer -= rl.GetFrameTime()
        }

        if tick_timer <= 0 {
            next_part_pos := snake[0]
            snake[0] += move_direction
            head_pos := snake[0]

            if head_pos.x < 0 || head_pos.y < 0 || head_pos.x >= GRID_WIDTH || head_pos.y >= GRID_WIDTH {
                game_over = true
            }

            for i in 1 ..< snake_length {
                cur_pos := snake[i]
                snake[i] = next_part_pos
                next_part_pos = cur_pos
            }

            tick_timer = TICK_RATE + tick_timer
        }

        rl.BeginDrawing()
        rl.ClearBackground({20, 20, 20, 255})

        cam := rl.Camera2D {
            zoom = f32(WINDOW_SIZE) / CANVAS_WIDTH,
        }

        rl.BeginMode2D(cam)

        food_rect := rl.Rectangle {
            f32(food_pos.x) * CELL_SIZE,
            f32(food_pos.y) * CELL_SIZE,
            CELL_SIZE,
            CELL_SIZE,
        }

        rl.DrawRectangleRec(food_rect, rl.RED)

        for i in 0 ..< snake_length {
            part_rect := rl.Rectangle {
                f32(snake[i].x) * CELL_SIZE,
                f32(snake[i].y) * CELL_SIZE,
                CELL_SIZE,
                CELL_SIZE,
            }

            rl.DrawRectangleRounded(part_rect, 0.5, 6, rl.GREEN)
        }
        if game_over {
            rl.DrawText("Game Over", GRID_WIDTH / 2, GRID_WIDTH / 2, 18, rl.WHITE)
            rl.DrawText("Press Enter to Restart", GRID_WIDTH / 2, GRID_WIDTH / 2 + 30, 12, rl.WHITE)
        }

        rl.EndMode2D()
        rl.EndDrawing()
    }
}
