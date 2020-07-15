module Language.Haskell.Stylish.Printer.ModuleHeader.Tests
  ( tests
  ) where

--------------------------------------------------------------------------------
import Test.Framework                 (Test, testGroup)
import Test.Framework.Providers.HUnit (testCase)
import Test.HUnit                     (Assertion, (@=?))
import GHC.Stack                      (HasCallStack, withFrozenCallStack)
import Prelude hiding                 (lines)


--------------------------------------------------------------------------------
import Language.Haskell.Stylish.Module
import Language.Haskell.Stylish.Config (defaultConfig')
import Language.Haskell.Stylish.Parse (parseModule)
import Language.Haskell.Stylish.Printer.ModuleHeader (printModuleHeader)



--------------------------------------------------------------------------------
tests :: Test
tests = testGroup "Language.Haskell.Stylish.Printer.ModuleHeader"
  [ testCase "Hello world" ex0
  , testCase "Empty exports list" ex1
  , testCase "Single exported variable" ex2
  , testCase "Multiple exported variables" ex3
  , testCase "Only reformats module header" ex4
  , testCase "Leaving pragmas in place" ex5
  , testCase "Leaving pragmas in place variant" ex6
  , testCase "Leaving comments in place" ex7
  , testCase "Exports all" ex8
  , testCase "Exports module" ex9
  , testCase "Exports symbol" ex10
  , testCase "Respects groups" ex11
  ]

--------------------------------------------------------------------------------
ex0 :: Assertion
ex0 = input `assertFormatted` output
  where
    input =
      [ "module Foo where"
      ]
    output =
      [ "module Foo"
      , "  where"
      ]

ex1 :: Assertion
ex1 = input `assertFormatted` output
  where
    input =
      [ "module Foo () where"
      ]
    output =
      [ "module Foo"
      , "  ("
      , "  ) where"
      ]

ex2 :: Assertion
ex2 = input `assertFormatted` output
  where
    input =
      [ "module Foo (tests) where"
      ]
    output =
      [ "module Foo"
      , "  ( tests"
      , "  ) where"
      ]

ex3 :: Assertion
ex3 = input `assertFormatted` output
  where
    input =
      [ "module Foo (t1, t2, t3) where"
      ]
    output =
      [ "module Foo"
      , "  ( t1"
      , "  , t2"
      , "  , t3"
      , "  ) where"
      ]

ex4 :: Assertion
ex4 = input `assertFormatted` output
  where
    input =
      [ "module Foo ("
      , "  t1,"
      , "  t3,"
      , "  t2"
      , ") where"
      , ""
      , ""
      , "-- | Docstring"
      , "foo :: Int"
      , "foo = 1"
      ]
    output =
      [ "module Foo"
      , "  ( t1"
      , "  , t2"
      , "  , t3"
      , "  ) where"
      , ""
      , ""
      , "-- | Docstring"
      , "foo :: Int"
      , "foo = 1"
      ]

ex5 :: Assertion
ex5 = input `assertFormatted` output
  where
    input =
      [ "{-# LANGUAGE DerivingVia #-}"
      , "-- | This module docs"
      , "module Foo ("
      , "  t1,"
      , "  t3,"
      , "  t2"
      , ") where"
      ]
    output =
      [ "{-# LANGUAGE DerivingVia #-}"
      , "-- | This module docs"
      , "module Foo"
      , "  ( t1"
      , "  , t2"
      , "  , t3"
      , "  ) where"
      ]
ex6 :: Assertion
ex6 = input `assertFormatted` output
  where
    input =
      [ "-- | This module docs"
      , "{-# LANGUAGE DerivingVia #-}"
      , "module Foo ("
      , "  t1,"
      , "  t3,"
      , "  t2"
      , ") where"
      ]
    output =
      [ "-- | This module docs"
      , "{-# LANGUAGE DerivingVia #-}"
      , "module Foo"
      , "  ( t1"
      , "  , t2"
      , "  , t3"
      , "  ) where"
      ]

ex7 :: Assertion
ex7 = input `assertFormatted` output
  where
    input =
      [ "module Foo -- Foo"
      , "("
      , " -- * t1 something"
      , "  t3,"
      , "  t1,"
      , " -- * t2 something"
      , "  t2"
      , ") where -- x"
      , "-- y"
      ]
    output =
      [ "module Foo -- Foo"
      , "  ( -- * t1 something"
      , "    t1"
      , "  , t3"
      , "    -- * t2 something"
      , "  , t2"
      , "  ) where -- x"
      , "-- y"
      ]


ex8 :: Assertion
ex8 = input `assertFormatted` output
  where
    input =
      [ "module Foo ("
      , " -- * t1 something"
      , "  t3,"
      , "  A(..),"
      , " -- * t2 something"
      , "  t2,"
      , "  t1"
      , ") where -- x"
      , "-- y"
      ]
    output =
      [ "module Foo"
      , "  ( -- * t1 something"
      , "    A (..)"
      , "  , t3"
      , "    -- * t2 something"
      , "  , t1"
      , "  , t2"
      , "  ) where -- x"
      , "-- y"
      ]

ex9 :: Assertion
ex9 = input `assertFormatted` output
  where
    input =
      [ "module Foo ("
      , " -- * t1 something"
      , "  module A,"
      , "  t3,"
      , " -- * t2 something"
      , "  t2"
      , ") where -- x"
      , "-- y"
      ]
    output =
      [ "module Foo"
      , "  ( -- * t1 something"
      , "    module A"
      , "  , t3"
      , "    -- * t2 something"
      , "  , t2"
      , "  ) where -- x"
      , "-- y"
      ]

ex10 :: Assertion
ex10 = input `assertFormatted` output
  where
    input =
      [ "module Foo ("
      , "  (<&>)"
      , ") where -- x"
      , "-- y"
      ]
    output =
      [ "module Foo"
      , "  ( (<&>)"
      , "  ) where -- x"
      , "-- y"
      ]

ex11 :: Assertion
ex11 = input `assertFormatted` output
  where
    input =
      [ "module Foo ("
      , "  -- group 1"
      , " g1_1,"
      , " g1_0,"
      , "  -- group 2"
      , " g0_1,"
      , " g0_0"
      , ") where"
      ]
    output =
      [ "module Foo"
      , "  ( -- group 1"
      , "    g1_0"
      , "  , g1_1"
      , "    -- group 2"
      , "  , g0_0"
      , "  , g0_1"
      , "  ) where"
      ]

--------------------------------------------------------------------------------
assertFormatted :: HasCallStack => Lines -> Lines -> Assertion
assertFormatted input expected = withFrozenCallStack $ expected @=? parseAndFormat input
  where
    parseAndFormat lines =
      case parseModule [] Nothing (unlines lines) of
        Right parsedModule ->
          printModuleHeader defaultConfig' lines parsedModule
        Left err ->
          error $ "parseAndFormat: Should've been able to parse input - " <> err
