package snake

import "core:encoding/json"
import fmt "core:fmt"
import "core:os"
import "core:strings"
import "core:time"
import rl "vendor:raylib"

SCORE_SOUND_DATA :: #load("assets/audio/twoTone1.ogg")
CRASH_SOUND_DATA :: #load("assets/audio/lowDown.ogg")
MUSIC_DATA :: #load("assets/audio/music.mp3")
VERTEX_SHADER_DATA :: #load("assets/shaders/simple_vertex.vert")
FRAGMENT_SHADER_DATA :: #load("assets/shaders/crt_shader.frag")

WINDOW_SIZE :: 800
GRID_WIDTH :: 20
CELL_SIZE :: 16
CANVAS_SIZE :: GRID_WIDTH * CELL_SIZE
MAX_SNAKE_LENGTH :: GRID_WIDTH * GRID_WIDTH

TICK_RATE :: 0.13
HIGH_SCORE_FILE :: "highscore.json"

Vec2i :: [2]int

High_Score :: struct {
    score: int,
}

crt_shader: rl.Shader
iTime_loc: i32
screen_size_loc: i32
target: rl.RenderTexture2D

snake: [MAX_SNAKE_LENGTH]Vec2i
snake_length: int = 0
tick_timer: f32 = TICK_RATE
move_direction: Vec2i
food_pos: Vec2i
high_score: int = 0
game_state: i8 = 1



load_high_score :: proc() -> int {
    data, ok := os.read_entire_file_from_filename(HIGH_SCORE_FILE)
    if !ok {
        return 0
    }
    defer delete(data)

    score_data: High_Score
    unmarshal_err := json.unmarshal(data, &score_data)
    if unmarshal_err != nil {
        fmt.eprintln("Failed to load high score file!")
        return 0
    }

    return score_data.score
}

save_high_score :: proc(score: int) {
    score_data := High_Score {
        score = score,
    }

    json_data, err := json.marshal(score_data, {pretty = true})
    if err != nil {
        fmt.eprintfln("Unable to marshal high score JSON: %v", err)
        return
    }
    defer delete(json_data)

    werr := os.write_entire_file_or_err(HIGH_SCORE_FILE, json_data)
    if werr != nil {
        fmt.eprintfln("Unable to write high score file: %v", werr)
    }
}

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
    game_state = 1
    place_food()
}

main :: proc() {
    rl.SetConfigFlags({.VSYNC_HINT})
    rl.InitWindow(WINDOW_SIZE, WINDOW_SIZE, "Snake")
    defer rl.CloseWindow()

    rl.InitAudioDevice()
    defer rl.CloseAudioDevice()

    score_sound := rl.LoadSoundFromWave(
        rl.LoadWaveFromMemory(".ogg", raw_data(SCORE_SOUND_DATA), i32(len(SCORE_SOUND_DATA))),
    )
    rl.SetSoundVolume(score_sound, 0.2)
    defer rl.UnloadSound(score_sound)

    crash_sound := rl.LoadSoundFromWave(
        rl.LoadWaveFromMemory(".ogg", raw_data(CRASH_SOUND_DATA), i32(len(CRASH_SOUND_DATA))),
    )
    defer rl.UnloadSound(crash_sound)

    music := rl.LoadMusicStreamFromMemory(".mp3", raw_data(MUSIC_DATA), i32(len(MUSIC_DATA)))
    rl.SetMusicVolume(music, 0.4)
    rl.PlayMusicStream(music)
    defer rl.UnloadMusicStream(music)

    // Load shader from memory
    vertex_shader_cstr := strings.clone_to_cstring(string(VERTEX_SHADER_DATA), context.temp_allocator)
    fragment_shader_cstr := strings.clone_to_cstring(string(FRAGMENT_SHADER_DATA), context.temp_allocator)
    crt_shader = rl.LoadShaderFromMemory(vertex_shader_cstr, fragment_shader_cstr)
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

    // Load high score at startup
    high_score = load_high_score()

    restart()

    for !rl.WindowShouldClose() {
        rl.UpdateMusicStream(music)
        if !rl.IsMusicStreamPlaying(music) {
            rl.PlayMusicStream(music)
        }

        if (rl.IsKeyDown(.UP) || rl.IsKeyDown(.K)) && move_direction != {0, 1} {
            move_direction = {0, -1}
        }

        if (rl.IsKeyDown(.DOWN) || rl.IsKeyDown(.J)) && move_direction != {0, -1} {
            move_direction = {0, 1}
        }

        if (rl.IsKeyDown(.LEFT) || rl.IsKeyDown(.H)) && move_direction != {1, 0} {
            move_direction = {-1, 0}
        }

        if (rl.IsKeyDown(.RIGHT) || rl.IsKeyDown(.L)) && move_direction != {-1, 0} {
            move_direction = {1, 0}
        }

        if game_state == 0 {
            if rl.IsKeyPressed(.ENTER) {
                restart()
            }
        }
        if game_state == 1 {
            if rl.IsKeyPressed(.ENTER) {
                game_state = 2
            }
        }
        if game_state == 2 {
            tick_timer -= rl.GetFrameTime()
        }


        if tick_timer <= 0 {
            next_part_pos := snake[0]
            snake[0] += move_direction
            head_pos := snake[0]

            if head_pos.x < 0 || head_pos.y < 0 || head_pos.x >= GRID_WIDTH || head_pos.y >= GRID_WIDTH {
                game_state = 0
                rl.PlaySound(crash_sound)

                // Check and save high score when game ends
                current_score := snake_length - 3
                if current_score > high_score {
                    high_score = current_score
                    save_high_score(high_score)
                }
            }

            for i in 1 ..< snake_length {
                cur_pos := snake[i]

                if cur_pos == head_pos {
                    game_state = 0
                    rl.PlaySound(crash_sound)

                    // Check and save high score when game ends
                    current_score := snake_length - 3
                    if current_score > high_score {
                        high_score = current_score
                        save_high_score(high_score)
                    }
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

        // Update shader uniforms
        elapsed := time.diff(start_time, time.now())
        seconds := f32(time.duration_seconds(elapsed))
        rl.SetShaderValue(crt_shader, iTime_loc, &seconds, .FLOAT)

        screen_size := [2]f32{f32(CANVAS_SIZE), f32(CANVAS_SIZE)}
        rl.SetShaderValue(crt_shader, screen_size_loc, &screen_size, .VEC2)

        rl.BeginTextureMode(target)
        rl.ClearBackground({20, 20, 20, 255})

        if game_state == 2 || game_state == 0 {
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
        }

        if game_state == 1 {
            text1Width := rl.MeasureText("SNAKE", 24)
            text2Width := rl.MeasureText("Press Enter to start", 12)

            rl.DrawRectangle(0, 0, CANVAS_SIZE, CANVAS_SIZE, {0, 0, 0, 172})
            rl.DrawText("SNAKE", CANVAS_SIZE / 2 - (text1Width / 2), CANVAS_SIZE / 2 - 60, 24, rl.WHITE)
            rl.DrawText(
                "Press Enter to Start",
                CANVAS_SIZE / 2 - (text2Width / 2),
                CANVAS_SIZE / 2 - 30,
                12,
                rl.WHITE,
            )
        }

        score := snake_length - 3
        score_str := fmt.ctprintf("Score: %v", score)
        high_score_str := fmt.ctprintf("High Score: %v", high_score)

        if game_state == 2 {
            rl.DrawText(score_str, 4, CANVAS_SIZE - 14, 10, rl.GRAY)
            if high_score > 0 {
                rl.DrawText(high_score_str, 4, CANVAS_SIZE - 26, 10, rl.GRAY)
            }
        }

        if game_state == 0 {
            text1Width := rl.MeasureText("Game Over", 18)
            text2Width := rl.MeasureText("Press Enter to Restart", 12)
            text3Width := rl.MeasureText(score_str, 10)
            text4Width := rl.MeasureText(high_score_str, 10)

            rl.DrawRectangle(0, 0, CANVAS_SIZE, CANVAS_SIZE, {0, 0, 0, 172})
            rl.DrawText("Game Over", CANVAS_SIZE / 2 - (text1Width / 2), CANVAS_SIZE / 2 - 60, 18, rl.WHITE)
            rl.DrawText(
                "Press Enter to Restart",
                CANVAS_SIZE / 2 - (text2Width / 2),
                CANVAS_SIZE / 2 - 30,
                12,
                rl.WHITE,
            )
            rl.DrawText(score_str, CANVAS_SIZE / 2 - (text3Width / 2), CANVAS_SIZE / 2 - 10, 10, rl.WHITE)
            rl.DrawText(
                high_score_str,
                CANVAS_SIZE / 2 - (text4Width / 2 + 2),
                CANVAS_SIZE / 2 + 5,
                10,
                rl.WHITE,
            )
        }

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
