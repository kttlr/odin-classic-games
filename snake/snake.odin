package snake

import fmt "core:fmt"
import "core:time"
import rl "vendor:raylib"

WINDOW_SIZE :: 800
GRID_WIDTH :: 20
CELL_SIZE :: 16
CANVAS_SIZE :: GRID_WIDTH * CELL_SIZE
MAX_SNAKE_LENGTH :: GRID_WIDTH * GRID_WIDTH

TICK_RATE :: 0.13

Vec2i :: [2]int

crt_shader: rl.Shader
iTime_loc: i32
screen_size_loc: i32
target: rl.RenderTexture2D

snake: [MAX_SNAKE_LENGTH]Vec2i
snake_length: int
snake_direction: string
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

    rl.InitAudioDevice()
    defer rl.CloseAudioDevice()

    score_sound := rl.LoadSound("assets/audio/twoTone1.ogg")
    rl.SetSoundVolume(score_sound, 0.2)
    defer rl.UnloadSound(score_sound)

    crash_sound := rl.LoadSound("assets/audio/lowDown.ogg")
    defer rl.UnloadSound(crash_sound)

    music := rl.LoadMusicStream("assets/audio/music.mp3")
    rl.PlayMusicStream(music) // Start playing music once at the beginning
    defer rl.UnloadMusicStream(music)

    // Load CRT shader
    crt_shader = rl.LoadShader("shaders/simple_vertex.vert", "shaders/crt_shader.frag")
    defer rl.UnloadShader(crt_shader)

    // Get shader uniform locations
    iTime_loc = rl.GetShaderLocation(crt_shader, "iTime")
    screen_size_loc = rl.GetShaderLocation(crt_shader, "screen_size")

    // Create render texture for game rendering (before CRT effect)
    target = rl.LoadRenderTexture(CANVAS_SIZE, CANVAS_SIZE)
    defer rl.UnloadRenderTexture(target)

    // Enable texture filtering
    rl.SetTextureFilter(target.texture, .BILINEAR)

    start_time := time.now()

    restart()

    for !rl.WindowShouldClose() {
        // Update music buffer and restart if it stopped
        rl.UpdateMusicStream(music)
        if !rl.IsMusicStreamPlaying(music) {
            rl.PlayMusicStream(music)
        }

        if (rl.IsKeyDown(.UP) || rl.IsKeyDown(.K)) && snake_direction != "DOWN" {
            move_direction = {0, -1}
            snake_direction = "UP"
        }

        if (rl.IsKeyDown(.DOWN) || rl.IsKeyDown(.J)) && snake_direction != "UP" {
            move_direction = {0, 1}
            snake_direction = "DOWN"
        }

        if (rl.IsKeyDown(.LEFT) || rl.IsKeyDown(.H)) && snake_direction != "RIGHT" {
            move_direction = {-1, 0}
            snake_direction = "LEFT"
        }

        if (rl.IsKeyDown(.RIGHT) || rl.IsKeyDown(.L)) && snake_direction != "LEFT" {
            move_direction = {1, 0}
            snake_direction = "RIGHT"
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
                rl.PlaySound(crash_sound)
            }

            for i in 1 ..< snake_length {
                cur_pos := snake[i]

                if cur_pos == head_pos {
                    game_over = true
                    rl.PlaySound(crash_sound)
                }

                snake[i] = next_part_pos
                next_part_pos = cur_pos
            }

            if head_pos == food_pos {
                snake_length += 1
                snake[snake_length - 1] = next_part_pos
                place_food()
                rl.PlaySound(score_sound)
            }

            tick_timer = TICK_RATE + tick_timer
        }

        cam := rl.Camera2D {
            zoom = 1.0,
        }

        // Update shader uniforms
        elapsed := time.diff(start_time, time.now())
        seconds := f32(time.duration_seconds(elapsed))
        rl.SetShaderValue(crt_shader, iTime_loc, &seconds, .FLOAT)

        screen_size := [2]f32{f32(CANVAS_SIZE), f32(CANVAS_SIZE)}
        rl.SetShaderValue(crt_shader, screen_size_loc, &screen_size, .VEC2)

        // Render the game to the render texture
        rl.BeginTextureMode(target)
        rl.ClearBackground({20, 20, 20, 255})

        // Draw food
        food_rect := rl.Rectangle {
            f32(food_pos.x) * CELL_SIZE + 2,
            f32(food_pos.y) * CELL_SIZE + 2,
            CELL_SIZE - 4,
            CELL_SIZE - 4,
        }
        rl.DrawRectangleRec(food_rect, rl.RED)

        // Draw snake
        for i in 0 ..< snake_length {
            part_rect := rl.Rectangle {
                f32(snake[i].x) * CELL_SIZE + 1,
                f32(snake[i].y) * CELL_SIZE + 1,
                CELL_SIZE - 2,
                CELL_SIZE - 2,
            }
            rl.DrawRectangleRounded(part_rect, 0.5, 6, rl.GREEN)
        }
        if game_over {
            rl.DrawText("Game Over", GRID_WIDTH / 2, GRID_WIDTH / 2, 18, rl.WHITE)
            rl.DrawText("Press Enter to Restart", GRID_WIDTH / 2, GRID_WIDTH / 2 + 30, 12, rl.WHITE)
        }

        score := snake_length - 3
        score_str := fmt.ctprintf("Score: %v", score)
        direction_str := fmt.ctprintf("Direction: %v", snake_direction)
        rl.DrawText(score_str, 4, CANVAS_SIZE - 14, 10, rl.GRAY)
        rl.DrawText(direction_str, 4, CANVAS_SIZE - 30, 10, rl.GRAY)
        // rl.DrawFPS(2, 2)

        rl.EndTextureMode()

        // Draw the render texture to the screen with CRT shader applied
        rl.BeginDrawing()
        rl.ClearBackground(rl.BLACK)

        rl.BeginShaderMode(crt_shader)
        source_rec := rl.Rectangle{0, 0, f32(target.texture.width), -f32(target.texture.height)}
        dest_rec := rl.Rectangle{0, 0, f32(WINDOW_SIZE), f32(WINDOW_SIZE)}
        rl.DrawTexturePro(target.texture, source_rec, dest_rec, {0, 0}, 0, rl.WHITE)
        rl.EndShaderMode()

        rl.EndDrawing()

        free_all(context.temp_allocator)
    }
}
