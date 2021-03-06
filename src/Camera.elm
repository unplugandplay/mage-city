module Camera exposing (Camera, makeCamera, view, moveBy, moveTo, follow)

{-| This provides a basic camera
-}

import Math.Vector2 as Vector2 exposing (Vec2, vec2)
import Math.Matrix4 as Matrix4 exposing (Mat4)
import Vector2Extra as Vector2

{-|
A camera represents how to render the virtual world. It's essentially a
transformation from virtual game coordinates to pixel coordinates on the screen
-}
type alias Camera =
    { area : Float
    , position : Vec2
    }


{-|
A camera that always shows the same viewport area. This is useful in a top down game.
This means that you probably want to specify the area property like this:

    fixedArea (16, 10) (x, y)

This would show 16 by 10 units _if_ the game is displayed in a 16:10 viewport. However,
in a 4:3 viewport it would show sqrt(16*10*4/3)=14.6 by sqrt(16*10*3/4)=10.95 units
-}
makeCamera : Vec2 -> Vec2 -> Camera
makeCamera size position =
    let
        ( w, h ) =
            Vector2.toTuple size
    in
        { area = w * h
        , position = position
        }


{-| Calculate the matrix transformation that represents how to transform the
camera back to the origin. The result of this is used in the vertex shader.
-}
view : Vec2 -> Camera -> Mat4
view viewportSize camera =
    let
        ( w, h ) =
            Vector2.toTuple viewportSize

        -- Snap camera position to nearest pixel, since passing unrounded
        --   values will cause artifacts on the final scene
        ( x, y ) =
            camera.position
                |> Vector2.snap
                |> Vector2.toTuple

        -- Calculate the viewport size in game units and halve it
        ( w_, h_ ) =
            ( sqrt ( camera.area * w / h ) / 2
            , sqrt ( camera.area * h / w ) / 2 )

        ( l, r, d, u ) =
            ( x - w_, x + w_, y - h_, y + h_ )
    in
        Matrix4.makeOrtho2D l r d u


{-| Move a camera by the given vector *relative* to the camera.
-}
moveBy : Vec2 -> Camera -> Camera
moveBy offset camera =
    { camera | position = Vector2.add camera.position offset }


{-| Move a camera to the given location. In *absolute* coordinates.
-}
moveTo : Vec2 -> Camera -> Camera
moveTo position camera =
    { camera | position = position }


{-| Smoothly follow the given target. Use this in your tick function.

    follow 1.5 dt target camera
-}
follow : Float -> Float -> Vec2 -> Camera -> Camera
follow speed dt targetPosition ({ position } as camera) =
    let
        targetVector =
            Vector2.sub targetPosition position

        newPosition =
            Vector2.add position (Vector2.scale (speed * dt) targetVector)
    in
        { camera | position = newPosition }
