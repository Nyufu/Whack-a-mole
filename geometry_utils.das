require types

def private IsWithinRectangle( r: types::rect const&; p: float2 const& ): bool
    return p.x >= r.left && p.x <= r.right && p.y >= r.top && p.y <= r.bottom;

def DetectIntersect( r: types::rect const&; l: types::line const& ): bool
    if IsWithinRectangle(r, l.a) || IsWithinRectangle(r, l.b)
        return true
    if l.a.x < r.left && l.b.x > r.right && ( ( l.a.y >= r.top && l.a.y <= r. bottom) || ( l.b.y >= r.top && l.b.y <= r.bottom ) )
        return true
    return false
