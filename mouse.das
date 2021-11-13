require daslib/media
require game_utils
require types

let private hammer_hit_time = 0.08
let private hammer_down_angle = -1.5
let private hammer_size = float2( 96.0, 255.0 )

let private img: Image <- create_image( "content/hammer.png" )


enum private States
    Hitting
    Down
    Releasing
    Up

class Mouse
    active: bool
    pos: float2
    state: States
    downCount: int
    angle: float
    animationState: float
    hitCallback : function < ( hitEdge: types::line ) : void >

    def Mouse()
        Activate( false )

    def SetHitCallback( var hitCallback_ : function < ( hitEdge: types::line ) : void > )
        hitCallback <- hitCallback_

    def Tick( timeElapsed: float )
        let pos_ = get_mouse_position()

        let mouseOverField: bool = pos_.x >= 0.0 && pos_.x <= float( get_screen_width() ) && pos_.y >= 0.0 && pos_.y <= float( get_screen_height() )
        if mouseOverField
            hide_mouse_cursor()
        else
            show_mouse_cursor()

        if !active
            return

        if mouseOverField
            pos = pos_

        let nextDownState = clamp( animationState + timeElapsed, 0.0, hammer_hit_time )
        let nextUpState = clamp( animationState - timeElapsed, 0.0, hammer_hit_time )

        if ( state == States Releasing || state == States Up ) && get_mouse_button_down( MB_LEFT )
            state = States Hitting
        elif state == States Hitting && nextDownState >= hammer_hit_time
            state = States Down
            var edge: types::line
            edge.a = float2( pos.x - 205.0, pos.y + 32.0 )
            edge.b = float2( edge.a.x + 127.0, edge.a.y + 10.0 )
            invoke( hitCallback, edge )
        elif state == States Down && !get_mouse_button( MB_LEFT ) && downCount++ > 4
            state = States Releasing
            downCount = 0
        elif state == States Releasing && nextDownState == 0.0
            state = States Up

        if state == States Hitting || state == States Down
            animationState = nextDownState
        else
            animationState = nextUpState

        angle = lerp( 0.0, hammer_down_angle, animationState / hammer_hit_time )

    def Draw()
        draw_image_transformed( img, pos.x, pos.y, float4( 0.0, 0.0, hammer_size.x, hammer_size.y ), 0xFFFFFFFF, hammer_size, angle, 0.5, 0.8 )

        if debug_mode
            fill_circle( pos.x, pos.y, 3., 0xFF1900FF )
            var edge: types::line
            edge.a = float2( pos.x - 205.0, pos.y + 32.0 )
            edge.b = float2( edge.a.x + 127.0, edge.a.y + 10.0 )
            line( edge.a.x, edge.a.y, edge.b.x, edge.b.y, 0xFF1900FF )

    def Activate( active_: bool )
        if !active_
            pos = float2( float( display_resolution.x ) * 0.9, float( display_resolution.y ) * 0.7 )
            state = States Up
        active = active_
