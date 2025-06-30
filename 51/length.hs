import System.Environment (getArgs)

main :: IO ()
main = do
  a <- getArgs
  print $ length $ head a