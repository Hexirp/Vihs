import Text.Parsec

ed :: IO [String]
ed = do
  cmd <- getLine
  ed' cmd [] True
    where
      ed' :: String -> [String] -> Bool -> IO [String]
      ed' cmd buff saved
        | cmd == "q" && saved = return buff
        | cmd == "q" && not saved = do
          putStrLn "?"
          newCmd <- getLine
          if newCmd == "q"
            then ed' newCmd buff True
            else ed' newCmd buff False
        | cmd == "a" = do
          newBuff <- insert
          newCmd <- getLine
          ed' newCmd newBuff False
        | (last cmd) == 'i' = do
          buff2 <- insert
          let newBuff = iCmd buff buff2 (read $ init cmd)
          newCmd <- getLine
          ed' newCmd newBuff False
        | (last cmd) == 'd' = do
          newCmd <- getLine
          ed' newCmd (deleteLine buff $ read $ init cmd) False
        | cmd == "l" = do
          putStr $ unlines (map (++"$") buff)
          newCmd <- getLine
          ed' newCmd buff saved
        | (head cmd) == 'w' = do
          buffToFile ((words cmd) !! 1) buff
          print $ length (unlines buff)
          newCmd <- getLine
          ed' newCmd buff True
        | otherwise = do
          putStrLn "?"
          newCmd <- getLine
          ed' newCmd buff saved

buffToFile :: String -> [String] -> IO ()
buffToFile path str = writeFile path $ unlines str

iCmd :: [String] -> [String] -> Int -> [String]
iCmd buff buff2 line = (take (line - 1) buff) ++ buff2 ++ (reverse (take ((length buff) - line + 1) (reverse buff)))

insert :: IO [String]
insert = insert' [] False
  where
    insert' :: [String] -> Bool -> IO [String]
    insert' buff done
      | done = return buff
      | otherwise = do
        str <- getLine
        if str == "."
          then insert' buff True
          else insert' (buff ++ [str]) False

deleteLine :: [String] -> Int ->[String]
deleteLine str line | line <= length str && line >= 0 && line - 1 <= length str = (take (line - 1) str) ++ (reverse . take ((length str) - line) $ reverse str)

main = ed
