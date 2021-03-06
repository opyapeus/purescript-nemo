module Data.Enemy where

import Prelude
import Class.Object (class ObjectDraw, class Object, position, size)
import Constants (canvasSize, emoSize, speed)
import Data.EnemyBullet (EnemyBullet(..))
import Data.Player (Player(..))
import Emo8.Data.Emoji as E
import Emo8.Game.Draw (emo)
import Types (Pos)

data Enemy
  = Invader { pos :: Pos }
  | Bee { pos :: Pos }
  | Rex { pos :: Pos, cnt :: Int }
  | Moi { pos :: Pos, cnt :: Int }
  | Oct { pos :: Pos }

instance objectEnemy :: Object Enemy where
  size _ = emoSize
  position (Invader s) = s.pos
  position (Moi s) = s.pos
  position (Bee s) = s.pos
  position (Rex s) = s.pos
  position (Oct s) = s.pos

instance objectDrawEnemy :: ObjectDraw Enemy where
  draw o@(Invader _) = emo E.alienMonster (size o) (position o).x (position o).y
  draw o@(Moi _) = emo E.moai (size o) (position o).x (position o).y
  draw o@(Bee _) = emo E.honeybee (size o) (position o).x (position o).y
  draw o@(Rex _) = emo E.tRex (size o) (position o).x (position o).y
  draw o@(Oct _) = emo E.octopus (size o) (position o).x (position o).y

updateEnemy :: Player -> Enemy -> Enemy
updateEnemy p@(Player _) e@(Invader s) = switch
  where
  switch
    | v.y > 0 = Invader $ s { pos { x = s.pos.x - 3, y = s.pos.y - 1 } }
    | v.y < 0 = Invader $ s { pos { x = s.pos.x - 3, y = s.pos.y + 1 } }
    | otherwise = Invader $ s { pos { x = s.pos.x - 3 } }

  v = diffVec e p

updateEnemy _ (Moi s)
  | mod s.cnt 32 < 16 = Moi $ s { pos { x = s.pos.x - 2, y = s.pos.y - 2 }, cnt = s.cnt + 1 }
  | otherwise = Moi $ s { pos { x = s.pos.x - 4, y = s.pos.y + 2 }, cnt = s.cnt + 1 }

updateEnemy _ (Bee s) = Bee $ s { pos { x = s.pos.x - 6 } }

updateEnemy (Player p) (Rex s)
  | mod s.cnt 32 < 16 = Rex $ s { pos { x = s.pos.x - speed, y = s.pos.y + 4 }, cnt = s.cnt + 1 }
  | otherwise = Rex $ s { pos { x = s.pos.x - speed, y = s.pos.y - 4 }, cnt = s.cnt + 1 }

updateEnemy _ o@(Oct s)
  | s.pos.x > canvasSize.width / 2 = Oct $ s { pos { x = s.pos.x - speed } }
  | otherwise = o

addEnemyBullet :: Player -> Enemy -> Array EnemyBullet
addEnemyBullet _ (Moi s)
  | mod s.cnt 16 == 0 = [ NormalBull { pos: s.pos } ]
  | otherwise = []

addEnemyBullet p e@(Rex s)
  | mod s.cnt 32 == 16 = [ ParseBull { pos: s.pos, vec: v', t: 0 } ]
    where
    v = diffVec p e

    v' = { x: v.x / 128, y: v.y / 128 }
  | otherwise = []

addEnemyBullet _ _ = []

diffVec :: forall a b. Object a => Object b => a -> b -> Pos
diffVec a b = { x: (position a).x - (position b).x, y: (position a).y - (position b).y }

emergeTable :: Int -> Array Enemy
emergeTable = case _ of
  200 -> [ Invader { pos: { x: canvasSize.width, y: 250 } } ]
  250 ->
    [ Invader { pos: { x: canvasSize.width, y: 400 } }
    , Invader { pos: { x: canvasSize.width, y: 150 } }
    ]
  700 -> [ Invader { pos: { x: canvasSize.width, y: 250 } } ]
  750 ->
    [ Invader { pos: { x: canvasSize.width, y: 400 } }
    , Invader { pos: { x: canvasSize.width, y: 150 } }
    ]
  1250 ->
    [ Invader { pos: { x: canvasSize.width, y: 250 } }
    , Invader { pos: { x: canvasSize.width, y: 350 } }
    , Invader { pos: { x: canvasSize.width, y: 450 } }
    , Invader { pos: { x: canvasSize.width, y: 150 } }
    , Invader { pos: { x: canvasSize.width, y: 50 } }
    ]
  -- second: 2048
  2000 -> [ Bee { pos: { x: canvasSize.width, y: 400 } } ]
  2250 -> [ Bee { pos: { x: canvasSize.width, y: 250 } } ]
  2500 -> [ Bee { pos: { x: canvasSize.width, y: 100 } } ]
  3000 ->
    [ Bee { pos: { x: canvasSize.width, y: 400 } }
    , Bee { pos: { x: canvasSize.width, y: 250 } }
    , Bee { pos: { x: canvasSize.width, y: 100 } }
    ]
  3250 ->
    [ Bee { pos: { x: canvasSize.width, y: 450 } }
    , Bee { pos: { x: canvasSize.width, y: 300 } }
    , Bee { pos: { x: canvasSize.width, y: 150 } }
    ]
  -- third: 4096
  4000 -> [ Rex { pos: { x: canvasSize.width, y: emoSize }, cnt: 0 } ]
  4250 -> [ Rex { pos: { x: canvasSize.width, y: emoSize }, cnt: 0 } ]
  5000 -> [ Rex { pos: { x: canvasSize.width, y: emoSize }, cnt: 0 } ]
  5250 -> [ Rex { pos: { x: canvasSize.width, y: emoSize }, cnt: 0 } ]
  -- forth: 6144
  6000 -> [ Moi { pos: { x: canvasSize.width, y: 250 }, cnt: 0 } ]
  6250 -> [ Moi { pos: { x: canvasSize.width, y: 400 }, cnt: 0 } ]
  6500 -> [ Moi { pos: { x: canvasSize.width, y: 100 }, cnt: 0 } ]
  7000 ->
    [ Moi { pos: { x: canvasSize.width, y: 250 }, cnt: 0 }
    , Moi { pos: { x: canvasSize.width, y: 400 }, cnt: 0 }
    , Moi { pos: { x: canvasSize.width, y: 100 }, cnt: 0 }
    ]
  -- fifth: 8192
  8000 -> [ Oct { pos: { x: canvasSize.width, y: 250 } } ]
  _ -> []
