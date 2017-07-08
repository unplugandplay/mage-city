module Object exposing
    ( Object
    , Category
    , Category(..)
    , Crate
    , Npc
    , colliding
    )

import Math.Vector2 as Vector2 exposing (Vec2)
import Math.Vector3 as Vector3 exposing (Vec3)
import WebGL.Texture as Texture exposing (Texture)
import Collision exposing (Rectangle)


{-| The main game object type. See individual file (e.g. Crate.elm)
for actual implementation -}
type Category
    = TriggerCategory
    | ObstacleCategory
    | CrateCategory Crate
    | NpcCategory Npc


type alias Crate = TexturedObject
    { isOpen : Bool
    }


type alias Npc = TexturedObject
    { velocity : Vec2
    , targetPosition : Vec2
    -- direction : Direction
    }


{-| A generic object in the level
-}
type alias Object =
    { category : Category
    , id : Int
    , name : String
    , position : Vec2
    , collisionSize: Vec2
    }


{-| Object with an associated texture atlas with
potentially multiple appearance -}
type alias TexturedObject a =
    { a | atlas: Texture }


{- Object with a simple looping animation -}
-- type alias AnimatedObject a =
--     { a | atlas: Texture, frameCount: Int, duration : Float }


-- MISC


{-| Figure out the colliding objects with given target rectangle
-}
colliding : Rectangle -> List Object -> List Object
colliding targetRect objects =
    let
        isColliding : Object -> Bool
        isColliding { position, collisionSize }  =
            let
                rect = Collision.rectangle position collisionSize
            in
                Collision.axisAlignedBoundingBox rect targetRect
    in
        List.filter isColliding objects
