require daslib/media
require game_utils
require random_utils
require types

let private animation_time = 0.2
let private min_waiting_time = 1.0
let private max_waiting_time = 4.0

let private hit_frame_lenght = 15
let private hit_offset = float2( -32., -54. )

let private mole_size = float2( 128., 161. )
let private mole_deadzone = 16. // The unused pixel size around the mole in mole.png
let private hole_size = float2( 128., 61. )

let private mole: Image <- create_image( "content/mole.png" )
let private hole: Image <- create_image( "content/hole.png" )
let private hole_mask: Image <- create_image( "content/hole_mask.png" )
let private hit: Image <- create_image( "content/hit.png" )

enum private States
    Emerging
    Visible
    Struck
    Hiding
    Hidden

class Mole
    pos: float2
    view_pos: float2
    state: States
    animationState: float
    fixedAnimationState: float
    freezeCount: int

    def Mole( x, y: float )
        pos = float2( x, y )
        view_pos= pos - float2( hole_size.x / 2., hole_size.y / 2. )
        state = States Hidden
        animationState = random( min_waiting_time, max_waiting_time )

    def Tick( timeElapsed: float )
        if state == States Struck
            if freezeCount++ > hit_frame_lenght
                freezeCount = 0
                state = States Hiding
                animationState = fixedAnimationState
        else
            animationState -= timeElapsed
            if animationState <= 0.
                if state == States Emerging
                    state = States Visible
                    animationState = random( min_waiting_time, max_waiting_time )
                elif state == States Visible
                    state = States Hiding
                    animationState = animation_time
                elif state == States Hiding
                    state = States Hidden
                    animationState = random( min_waiting_time, max_waiting_time )
                elif state == States Hidden
                    state = States Emerging
                    animationState = animation_time

    def Draw()
        draw_image( hole, view_pos.x, view_pos.y )

        let visibleHeight: float = GetVisibleHeight()
        draw_image_region( mole, view_pos.x,  pos.y - visibleHeight + hole_size.y / 2., float4( 0., 0., mole_size.x, visibleHeight - mole_deadzone ), 0xFFFFFFFF )

        if freezeCount > 0
            let opacity = uint( ( float( hit_frame_lenght - freezeCount + 1 ) / float( hit_frame_lenght ) ) * 255. ) << uint(24) | 0x00FFFFFF
            draw_image( hit, view_pos.x + hit_offset.x , pos.y - visibleHeight + hole_size.y / 2. + hit_offset.y, opacity )

        draw_image( hole_mask, view_pos.x, view_pos.y )

        if debug_mode
            let hitBox = GetHitbox2()
            rect( hitBox.x, hitBox.y, hitBox.width, hitBox.height, 0xFFFF0000 )
            fill_rect( hitBox.x, hitBox.y, 5., 5., 0xFFFFD900 )

    def private GetVisibleHeight(): float
        var visibilityPercent: float
        if state == States Emerging
            visibilityPercent = ( animation_time - animationState ) / animation_time
        elif state == States Struck
            visibilityPercent = fixedAnimationState / animation_time
        elif state == States Hiding
            visibilityPercent = animationState / animation_time
        elif state == States Visible
            visibilityPercent = 1.
        else
            visibilityPercent = 0.

        return lerp( 0., mole_size.y, visibilityPercent )

    def GetHitbox(): types::rect
        var hitBox: types::rect
        let hitBox2 = GetHitbox2()
        hitBox.left = hitBox2.x
        hitBox.top = hitBox2.y
        hitBox.right = hitBox2.x + hitBox2.width
        hitBox.bottom = hitBox2.y + hitBox2.height
        return hitBox

    def GetHitbox2(): types::rect2
        var hitBox: types::rect2
        let visibleHeight = GetVisibleHeight()
        hitBox.x = view_pos.x + mole_deadzone
        hitBox.y = pos.y - visibleHeight + hole_size.y / 2.
        hitBox.width = max( mole_size.x - mole_deadzone * 2., 0. )
        hitBox.height = max( visibleHeight - mole_deadzone, 0. )
        return hitBox

    def Hit()
        if state == States Visible
            fixedAnimationState = animation_time
        elif state == States Hiding
            fixedAnimationState = animationState
        elif state == States Emerging
            fixedAnimationState = animation_time - animationState
        animationState = 0.
        state = States Struck
