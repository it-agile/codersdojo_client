(defn divider? [number divider] (= 0 (mod number divider)))

(defn factor-count [number factor]
	(cond	(= number factor) 1
			(zero? (mod number factor)) (inc (factor-count (/ number factor) factor))
	 		:else 0))

(defn factor-rest [number factor]
	(let [count (factor-count number factor)]
		(cond	(zero? count) number
				(= number factor) 0
				:else (/ number (eval (cons '* (repeat count factor)))))))

(defn prime-fac
	([number] (prime-fac number 2))
	([number prime]
		(let 	[count (factor-count number prime)
				 rest  (factor-rest number prime)]
			(flatten	(cond 	(= number 1) '()
								(<= number prime) [number]
								(> count 0) (cons (repeat count prime) (prime-fac rest (inc prime)))
								:else (prime-fac number (inc prime)))))))
	
(use 'clojure.test)

(deftest checks-divider[]
	(is (divider? 1 1))
	(is (divider? 2 2))
	(is (divider? 6 3))
	(is (not (divider? 2 4)))
	(is (not (divider? 3 2)))
)

(deftest computes-factor-count[]
    (is (= 1 (factor-count 2 2)))
	(is (= 2 (factor-count 4 2)))
	(is (= 3 (factor-count 27 3)))
	(is (= 0 (factor-count 2 3)))
	(is (= 1 (factor-count 12 3)))
	(is (= 2 (factor-count 12 2)))
)

(deftest computes-factor-rest[]
	(is (= 0 (factor-rest 2 2)))
	(is (= 2 (factor-rest 2 3)))
	(is (= 4 (factor-rest 12 3)))
	(is (= 3 (factor-rest 12 2)))
)

(deftest computes-prime-factors[]
  (is (= (prime-fac 1) '()))
  (is (= (prime-fac 2) '(2)))
  (is (= (prime-fac 3) '(3)))
  (is (= (prime-fac 4) '(2 2)))
  (is (= (prime-fac 5) '(5)))
  (is (= (prime-fac 6) '(2 3)))
  (is (= (prime-fac 7) '(7)))
  (is (= (prime-fac 8) '(2 2 2)))
  (is (= (prime-fac 9) '(3 3)))
  (is (= (prime-fac 10) '(2 5)))
  (is (= (prime-fac 11) '(11)))
  (is (= (prime-fac 12) '(2 2 3)))
)

(run-tests)

