require daslib/media
require game_utils
require mouse
require field
require types

options debugger
require daslib/debug

var field: Field?
var mouse: Mouse?

let private background: Image <- create_image( "content/background.png" )
let private whack_img: Image <- create_image( "content/whack.png" )
let private whack_size = float2( 600., 600. )

enum States
    Wait
    Countdown
    Play
    Over

var game_state: States
var hit_count: int

var countdown_time: float
var game_time: float
var whack_time: float

def hit_callback( hitEdge: types::line ) : void
    if game_state != States Play
        return

    let hit = field->Hit( hitEdge )
    if hit
        hit_count++
        //play sound
        return

def countdown()
    countdown_time = 3.
 
def start()
    mouse->Activate( true )
    game_state = States Play
    hit_count = 0
    game_time = 15.

def finish()
    mouse->Activate( false )
    game_state = States Over
    whack_time = 3.

[export]
def initialize()
    set_window_title( "Whack-a-mole" )
    set_resolution( display_resolution.x, display_resolution.y )
    set_antialiasing( 4 )
    set_font_name("content/PressStart2P-vaV7.ttf")
 
    game_state = States Wait

    field = new Field()
    mouse = new Mouse()
    mouse->SetHitCallback( @@hit_callback )
 
[export]
def act( dt: float )
    if get_key( VK_ESCAPE )
        schedule_quit_game()

    if game_state == States Wait
        if countdown_time == 0.0 && get_key_down( VK_SPACE ) 
            countdown_time = 3.
            game_state = States Countdown
    elif game_state == States Countdown
        countdown_time -= dt
        if countdown_time <= 0.
            countdown_time = 0.
            start()
    elif game_state == States Play
        let prev_game_time = game_time
        game_time -= dt
        if game_time <= 0. && prev_game_time > 0.
            finish()
    elif game_state == States Over
        whack_time -= dt
        if whack_time <= 0.
            game_state = States Wait

    field->Tick( dt )
    mouse->Tick( dt )

[export]
def draw
    draw_image( background, 0., 0. )
    //fill_rect( 0, 0, display_resolution.x, display_resolution.y, 0xFF0C6918 )
    enable_alpha_blend()

    field->Draw()
    mouse->Draw()
    
    set_font_size( 15. )
    text_out( 10., 10., "score: {hit_count * 100}", 0xEAFFFFFF )

    if game_state == States Wait
        set_font_size( 60. )
        text_out( float( display_resolution.x ) / 2. - 330., float( display_resolution.y ) / 2. - 40., "PRESS SPACE", 0xEAFFFFFF )
    elif game_state == States Countdown
        let count: int = int( countdown_time + 0.99 )
        set_font_size( 200. )
        text_out( float( display_resolution.x ) / 2. - 100., float( display_resolution.y ) / 2. - 100., "{count}", 0xEAFFFFFF )
    elif game_state == States Play
        let seconds: int = int( game_time )
        let miliseconds: int = int( ( game_time - float(seconds) ) * 100. ) 
        let str = "{seconds}:{miliseconds}"
        set_font_size( 15. )
        text_out( 10., 35., str, 0xEAFFFFFF )
    elif game_state == States Over
        let pos_x = ( float( display_resolution.x ) - whack_size.x ) / 2.
        let pos_y = ( float( display_resolution.y ) - whack_size.y ) / 2.
        draw_image( whack_img, pos_x, pos_y )
