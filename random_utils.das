require daslib/media
require random

var private seed: int4 = random_seed( int( get_time_after_start() * 1000.0 ) )

def randomize()
    seed = random_seed( int( get_time_after_start() * 1000.0 ) )

def random()
    return random_float( seed )

def random( min, max: float )
    if min >= max
        return min
    return min + random_float( seed ) * ( max - min )

def random( min, max: int )
    if min >= max
        return min
    return min + random_int( seed ) % ( max - min + 1 )