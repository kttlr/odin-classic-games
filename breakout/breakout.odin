package breakout

import "core:fmt"
import "core:math"
import "core:math/linalg"
import rl "vendor:raylib"

SCREEN_SIZE :: 320
PADDLE_WIDTH :: 50
PADDLE_HEIGTH :: 6
PADDLE_POS_Y :: 260
PADDLE_SPEED :: 200

BALL_SPEED :: 260
BALL_RADIUS :: 4
BALL_START_Y :: 160

NUM_BLOCX_X :: 10
NUM_BLOCX_Y :: 8
BLOCK_WIDTH :: 28
BLOCK_HEIGHT :: 10

Block_Color :: enum {
    Yellow,
    Green,
    Orange,
    Red,
}

row_colors := [NUM_BLOCX_Y]Block_Color {
    .Red,
    .Red,
    .Orange,
    .Orange,
    .Green,
    .Green,
    .Yellow,
    .Yellow,
}

block_color_values := [Block_Color]rl.Color {
    .Yellow = {253, 249, 150, 255},
    .Green  = {180, 245, 190, 255},
    .Orange = {170, 120, 250, 255},
    .Red    = {250, 90, 85, 255},
}

block_color_score := [Block_Color]int {
    .Yellow = 2,
    .Green  = 4,
    .Orange = 6,
    .Red    = 8,
}

blocks: [NUM_BLOCX_X][NUM_BLOCX_Y]bool

paddle_pos_x: f32

ball_pos: rl.Vector2
ball_dir: rl.Vector2

started: bool
game_over: bool

score: int


restart :: proc() {
    paddle_pos_x = SCREEN_SIZE / 2 - PADDLE_WIDTH / 2
    ball_pos = {SCREEN_SIZE / 2, BALL_START_Y}
    started = false
    score = 0

    for x in 0 ..< NUM_BLOCX_X {
        for y in 0 ..< NUM_BLOCX_Y {
            blocks[x][y] = true
        }
    }
}

reflect :: proc(dir, normal: rl.Vector2) -> rl.Vector2 {
    new_dir := linalg.reflect(dir, linalg.normalize(normal))
    return linalg.normalize(new_dir)
}

calc_block_rect :: proc(x, y: int) -> rl.Rectangle {
    return {
        f32(20 + x * BLOCK_WIDTH),
        f32(40 + y * BLOCK_HEIGHT),
        BLOCK_WIDTH,
        BLOCK_HEIGHT,
    }
}

block_exists :: proc(x, y: int) -> bool {
    if x < 0 || y < 0 || x >= NUM_BLOCX_X || y >= NUM_BLOCX_Y {
        return false
    }
    return blocks[x][y]
}

main :: proc() {
    rl.SetConfigFlags({.VSYNC_HINT})
    rl.InitWindow(1280, 1280, "Breakout")
    rl.SetTargetFPS(500)

    restart()

    for !rl.WindowShouldClose() {
        dt: f32

        if !started {
            ball_pos = {
                SCREEN_SIZE / 2 +
                f32(math.cos(rl.GetTime()) * SCREEN_SIZE / 2.5),
                BALL_START_Y,
            }
            if rl.IsKeyPressed(.SPACE) {
                paddle_middle := rl.Vector2 {
                    paddle_pos_x + PADDLE_WIDTH / 2,
                    PADDLE_POS_Y,
                }
                ball_to_paddle := paddle_middle - ball_pos
                ball_dir = linalg.normalize0(ball_to_paddle)
                started = true
            }
        } else if game_over {
            if rl.IsKeyPressed(.SPACE) {
                restart()
                game_over = false
            }
        } else {
            dt = rl.GetFrameTime()
        }

        prev_ball_pos := ball_pos
        ball_pos += ball_dir * BALL_SPEED * dt

        if ball_pos.x + BALL_RADIUS > SCREEN_SIZE {
            ball_pos.x = SCREEN_SIZE - BALL_RADIUS
            ball_dir = reflect(ball_dir, {-1, 0})
        }

        if ball_pos.x - BALL_RADIUS < 0 {
            ball_pos.x = BALL_RADIUS
            ball_dir = reflect(ball_dir, {1, 0})
        }

        if ball_pos.y - BALL_RADIUS < 0 {
            ball_pos.y = BALL_RADIUS
            ball_dir = reflect(ball_dir, {0, 1})
        }

        if !game_over && ball_pos.y > SCREEN_SIZE + BALL_RADIUS * 6 {
            game_over = true
        }

        paddle_move_velocity: f32

        if rl.IsKeyDown(.LEFT) {
            paddle_move_velocity -= PADDLE_SPEED
        }

        if rl.IsKeyDown(.RIGHT) {
            paddle_move_velocity += PADDLE_SPEED
        }

        paddle_pos_x += paddle_move_velocity * dt
        paddle_pos_x = clamp(
            paddle_pos_x,
            0,
            SCREEN_SIZE - PADDLE_WIDTH,
        )

        paddle_rect := rl.Rectangle {
            paddle_pos_x,
            PADDLE_POS_Y,
            PADDLE_WIDTH,
            PADDLE_HEIGTH,
        }

        if rl.CheckCollisionCircleRec(
            ball_pos,
            BALL_RADIUS,
            paddle_rect,
        ) {
            collision_normal: rl.Vector2

            if prev_ball_pos.y < paddle_rect.y + paddle_rect.height {
                collision_normal += {0, -1}
                ball_pos.y = paddle_rect.y - BALL_RADIUS
            }

            if prev_ball_pos.y > paddle_rect.y + paddle_rect.height {
                collision_normal += {0, 1}
                ball_pos.y =
                    paddle_rect.y + paddle_rect.height + BALL_RADIUS
            }

            if prev_ball_pos.x < paddle_rect.x {
                collision_normal += {-1, 0}
            }

            if prev_ball_pos.x > paddle_rect.x + paddle_rect.width {
                collision_normal += {1, 0}
            }

            if collision_normal != 0 {
                ball_dir = reflect(ball_dir, collision_normal)
            }
        }

        block_x_loop: for x in 0 ..< NUM_BLOCX_X {
            for y in 0 ..< NUM_BLOCX_Y {
                if blocks[x][y] == false {
                    continue
                }

                block_rect := calc_block_rect(x, y)

                if rl.CheckCollisionCircleRec(
                    ball_pos,
                    BALL_RADIUS,
                    block_rect,
                ) {
                    collision_normal: rl.Vector2
                    if prev_ball_pos.y < block_rect.y {
                        collision_normal += {0, -1}
                    }

                    if prev_ball_pos.y >
                       block_rect.y + block_rect.height {
                        collision_normal += {0, 1}
                    }

                    if prev_ball_pos.x < block_rect.x {
                        collision_normal += {-1, 0}
                    }

                    if prev_ball_pos.x >
                       block_rect.x + block_rect.width {
                        collision_normal += {1, 0}
                    }

                    if block_exists(x + int(collision_normal.x), y) {
                        collision_normal.x = 0
                    }

                    if block_exists(x, y + int(collision_normal.y)) {
                        collision_normal.y = 0
                    }

                    if collision_normal != 0 {
                        ball_dir = reflect(ball_dir, collision_normal)
                    }

                    blocks[x][y] = false
                    row_color := row_colors[y]
                    score += block_color_score[row_color]
                    break block_x_loop
                }
            }
        }

        rl.BeginDrawing()
        rl.ClearBackground({150, 190, 220, 255})

        cam := rl.Camera2D {
            zoom = f32(rl.GetScreenHeight() / SCREEN_SIZE),
        }

        rl.BeginMode2D(cam)

        rl.DrawRectangleRec(paddle_rect, {50, 150, 90, 255})
        rl.DrawCircleV(ball_pos, BALL_RADIUS, {200, 90, 20, 255})

        for x in 0 ..< NUM_BLOCX_X {
            for y in 0 ..< NUM_BLOCX_Y {
                if blocks[x][y] == false {
                    continue
                }
                block_rect := calc_block_rect(x, y)


                top_left := rl.Vector2{block_rect.x, block_rect.y}
                top_right := rl.Vector2 {
                    block_rect.x + block_rect.width,
                    block_rect.y,
                }
                bottom_left := rl.Vector2 {
                    block_rect.x,
                    block_rect.y + block_rect.height,
                }
                bottom_right := rl.Vector2 {
                    block_rect.x + block_rect.width,
                    block_rect.y + block_rect.height,
                }

                rl.DrawLineEx(
                    top_left,
                    top_right,
                    1,
                    {255, 255, 150, 100},
                )
                rl.DrawLineEx(
                    top_left,
                    bottom_left,
                    1,
                    {255, 255, 150, 100},
                )
                rl.DrawLineEx(
                    top_right,
                    bottom_right,
                    1,
                    {0, 0, 50, 100},
                )
                rl.DrawLineEx(
                    bottom_left,
                    bottom_right,
                    1,
                    {0, 0, 50, 100},
                )


                rl.DrawRectangleRec(
                    block_rect,
                    block_color_values[row_colors[y]],
                )
            }
        }
        score_text := fmt.ctprint(score)
        rl.DrawText(score_text, 5, 5, 10, rl.WHITE)

        if !started {
            start_text := fmt.ctprint("Press SPACE to start")
            text_width := rl.MeasureText(start_text, 15)
            rl.DrawText(
                start_text,
                SCREEN_SIZE / 2 - text_width / 2,
                SCREEN_SIZE / 2 - 15,
                15,
                rl.WHITE,
            )

        }

        if game_over {
            game_over_text := fmt.ctprintf(
                "Score: %d. Press SPACE to restart",
                score,
            )
            text_width := rl.MeasureText(game_over_text, 15)
            rl.DrawText(
                game_over_text,
                SCREEN_SIZE / 2 - text_width / 2,
                SCREEN_SIZE / 2 - 15,
                15,
                rl.WHITE,
            )
        }

        rl.EndMode2D()
        rl.EndDrawing()

        free_all(context.temp_allocator)
    }
    rl.CloseWindow()
}
