require mole
require types
require geometry_utils

class Field
    moles: array< Mole? >

    def Field()
        push( moles, new Mole( 200.0, 270.0 ) )
        push( moles, new Mole( 440.0, 270.0 ) )
        push( moles, new Mole( 680.0, 270.0 ) )
										    
        push( moles, new Mole( 200.0, 490.0 ) )
        push( moles, new Mole( 440.0, 490.0 ) )
        push( moles, new Mole( 680.0, 490.0 ) )

    def Tick( timeElapsed: float )
        for mole in moles
            mole->Tick( timeElapsed )

    def Hit( hitEdge: types::line ): bool
        for mole in moles
            let hitBox = mole->GetHitbox()
            if DetectIntersect( hitBox, hitEdge )
                mole->Hit()
                return true
        return false

    def Draw()
        for mole in moles
            mole->Draw()
