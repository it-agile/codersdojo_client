; Adapt the code to your code kata %kata_file%.
; Important: Test and production code has to be
;            completely in this file.

(use 'clojure.test)

(defn %kata_file% []
  "fixme")

(deftest %kata_file%-test []
	(is (= "foo" (%kata_file%))))

(run-tests)
