module Main

import Data.List
import Data.Strings

%default total

-- 此程序用于验证助词语法的无歧义性
-- 对任意深度 <= 4、宽度 <= 3 的语法树已验证通过

data Tree = Node (List Tree)
data Crumb = L | M | R | S

covering
Eq Tree where
  Node xs == Node ys = xs == ys

unsnoc : (l : List t) -> {auto p : NonEmpty l} -> (List t, t)
unsnoc (l :: []) = ([], l)
unsnoc (x :: xs@(_ :: _)) = let (xs', l) = unsnoc xs in (x :: xs', l)

covering
walk : List Tree -> List Crumb
walk [] = []
walk [Node le] = walk le ++ [S]
walk (Node lle :: xs@(_ :: _)) =
  let (m, Node rle) = unsnoc xs
   in walk lle ++ L ::
      join (map (\(Node mle) => walk mle ++ [M]) m) ++
      walk rle ++ [R]

rebuild : List Crumb -> List Tree
rebuild xs =
  case foldl rebuild' [[]] xs of
    [] => []
    xs@(_ :: _) => last xs
  where rebuild' : List (List Tree) -> Crumb -> List (List Tree)
        rebuild' (c :: ts) S = [Node c] :: ts
        rebuild' (c :: ts) L = [] :: [Node c] :: ts
        rebuild' (c :: l :: ts) M = [] :: (l `snoc` Node c) :: ts
        rebuild' (c :: l :: ts) R = (l `snoc` Node c) :: ts
        rebuild' _ _ = []

-- width = 宽度 - 1
genTrees : (depth : Nat) -> (width : Nat) -> List Tree
genTrees Z _ = pure $ Node []
genTrees (S n) m =
  let subTrees : List Tree
      subTrees = genTrees n m
      gen' : Nat -> List Tree
      gen' Z = map (Node . (:: [])) subTrees
      gen' (S n) =
        let prev = gen' n
         in prev ++ [Node (x :: xs) | Node xs <- prev, x <- subTrees]
   in gen' m

covering
tests : List (Bool, Tree)
tests = filter (not . fst)
      $ map (\(Node xs) => (rebuild (walk xs) == xs, Node xs))
      $ concatMap (flip genTrees 2) [1, 2, 3]

interface ShowLines a where
  showLines : a -> List String

ShowLines a => ShowLines (List a) where
  showLines [] = ["[]"]
  showLines xs = "[" :: concatMap (map ("  " ++) . showElem) xs `snoc` "]"
    where showElem : a -> List String
          showElem x = case showLines x of
            [] => [","]
            xs@(_ :: _) => let (i, l) = unsnoc xs in i `snoc` (l ++ ",")

mutual
  covering
  showTreeHelper : String -> String -> Tree -> List String
  showTreeHelper h1 hs x = case showLines x of
    [] => ["!"]
    l1 :: ls => (h1 ++ l1) :: map (hs ++) ls

  covering
  ShowLines Tree where
    showLines (Node []) = ["o"]
    showLines (Node [x]) = showTreeHelper "o─" "  " x
    showLines (Node (h :: xs@(_ :: _))) =
      let (m, l) = unsnoc xs
       in showTreeHelper "o┬" " │" h ++
          concatMap (showTreeHelper " ├" " │") m ++
          showTreeHelper " └" "  " l

(Show a, ShowLines b) => ShowLines (a, b) where
  showLines (x, y) = 
    ("(" ++ show x ++ ",") ::
    map ("  " ++) (showLines y) `snoc`
    ")"

[lines] ShowLines a => Show a where
  show = unlines . showLines

covering
main : IO ()
main = putStr $ show @{lines} tests
