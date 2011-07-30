; Adapt the code to your code kata %kata_file%.

(ns %kata_file%
  (:use [midje.sweet]))

(use 'clojure.test)

(defn %kata_file% []
  "fixme")

(fact (%kata_file%) => "foo")

(run-tests)
