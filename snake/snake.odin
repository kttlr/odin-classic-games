package snake

import fmt "core:fmt"
import "core:time"
import rl "vendor:raylib"

WINDOW_SIZE :: 500
GRID_WIDTH :: 20
CELL_SIZE :: 16
CANVAS_SIZE :: GRID_WIDTH * CELL_SIZE
MAX_SNAKE_LENGTH :: GRID_WIDTH * GRID_WIDTH

TICK_RATE :: 0.15

Vec2i :: [2]int

snake_shader: rl.Shader
food_shader: rl.Shader
iTime_loc_snake: i32
iTime_loc_food: i32
target: rl.RenderTexture2D

snake: [MAX_SNAKE_LENGTH]Vec2i
snake_length: int
tick_timer: f32 = TICK_RATE
move_direction: Vec2i
game_over: bool
food_pos: Vec2i

place_food :: proc() {
    occupied: [GRID_WIDTH][GRID_WIDTH]bool

    for i in 0 ..< snake_length {
        occupied[snake[i].x][snake[i].y] = true
    }

    free_cells := make([dynamic]Vec2i, context.temp_allocator)

    for x in 0 ..< GRID_WIDTH {
        for y in 0 ..< GRID_WIDTH {
            if !occupied[x][y] {
                append(&free_cells, Vec2i{x, y})
            }
        }
    }

    if len(free_cells) > 0 {
        random_cell_idx := rl.GetRandomValue(0, i32(len(free_cells)) - 1)
        food_pos = free_cells[random_cell_idx]
    }
}

restart :: proc() {
    start_head_pos := Vec2i{GRID_WIDTH / 2, GRID_WIDTH / 2}
    snake[0] = start_head_pos
    snake[1] = start_head_pos - Vec2i{0, 1}
    snake[2] = start_head_pos - Vec2i{0, 2}
    snake_length = 3
    move_direction = {0, 1}
    game_over = false
    place_food()
}

main :: proc() {
    rl.SetConfigFlags({.VSYNC_HINT})
    rl.InitWindow(WINDOW_SIZE, WINDOW_SIZE, "Classsic Snake")
    defer rl.CloseWindow()

    // Load shaders
    snake_shader = rl.LoadShader("shaders/simple_vertex.vert", "shaders/snake_wave.frag")
    defer rl.UnloadShader(snake_shader)

    food_shader = rl.LoadShader("shaders/simple_vertex.vert", "shaders/food_glow.frag")
    defer rl.UnloadShader(food_shader)

    // Get shader uniform locations
    iTime_loc_snake = rl.GetShaderLocation(snake_shader, "iTime")
    iTime_loc_food = rl.GetShaderLocation(food_shader, "iTime")

    // Create render texture for separate rendering
    target = rl.LoadRenderTexture(CANVAS_SIZE, CANVAS_SIZE)
    defer rl.UnloadRenderTexture(target)

    // Enable texture blending
    rl.SetTextureFilter(target.texture, .BILINEAR)

    start_time := time.now()

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

                if cur_pos == head_pos {
                    game_over = true
                }

                snake[i] = next_part_pos
                next_part_pos = cur_pos
            }

            if head_pos == food_pos {
                snake_length += 1
                snake[snake_length - 1] = next_part_pos
                place_food()
            }

            tick_timer = TICK_RATE + tick_timer
        }

        rl.BeginDrawing()
        rl.ClearBackground({20, 20, 20, 255})

        cam := rl.Camera2D {
            zoom = f32(WINDOW_SIZE) / CANVAS_SIZE,
        }

        // Calculate time for shaders
        elapsed := time.diff(start_time, time.now())
        seconds := f32(time.duration_seconds(elapsed))
        rl.SetShaderValue(snake_shader, iTime_loc_snake, &seconds, .FLOAT)
        rl.SetShaderValue(food_shader, iTime_loc_food, &seconds, .FLOAT)

        // First render the snake to the render texture
        rl.BeginTextureMode(target)
        rl.ClearBackground(rl.BLANK) // Clear with transparent background

        for i in 0 ..< snake_length {
            part_rect := rl.Rectangle {
                f32(snake[i].x) * CELL_SIZE + 1,
                f32(snake[i].y) * CELL_SIZE + 1,
                CELL_SIZE - 2,
                CELL_SIZE - 2,
            }

            // Just use white color, the shader will handle coloring
            rl.DrawRectangleRounded(part_rect, 0.5, 6, rl.WHITE)
        }
        rl.EndTextureMode()

        // Begin drawing to screen
        rl.BeginMode2D(cam)

        // Draw food with food shader
        food_rect := rl.Rectangle {
            f32(food_pos.x) * CELL_SIZE + 2,
            f32(food_pos.y) * CELL_SIZE + 2,
            CELL_SIZE - 4,
            CELL_SIZE - 4,
        }

        rl.BeginShaderMode(food_shader)
        rl.DrawRectangleRounded(food_rect, 0.5, 8, rl.RED)
        rl.EndShaderMode()

        // Draw snake with snake shader
        rl.BeginShaderMode(snake_shader)
        source_rec := rl.Rectangle{0, 0, f32(target.texture.width), -f32(target.texture.height)}
        dest_rec := rl.Rectangle{0, 0, f32(CANVAS_SIZE), f32(CANVAS_SIZE)}
        rl.DrawTexturePro(target.texture, source_rec, dest_rec, {0, 0}, 0, rl.WHITE)
        rl.EndShaderMode()
        if game_over {
            rl.DrawText("Game Over", GRID_WIDTH / 2, GRID_WIDTH / 2, 18, rl.WHITE)
            rl.DrawText("Press Enter to Restart", GRID_WIDTH / 2, GRID_WIDTH / 2 + 30, 12, rl.WHITE)
        }

        score := snake_length - 3
        score_str := fmt.ctprintf("Score: %v", score)
        rl.DrawText(score_str, 4, CANVAS_SIZE - 14, 10, rl.GRAY)
        rl.DrawFPS(10, 10)

        rl.EndMode2D()

        rl.EndDrawing()

        free_all(context.temp_allocator)
    }
}
