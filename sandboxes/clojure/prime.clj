(use 'clojure.test)

(defn divider? [number divider]
	(zero? (rem number divider)))

(defn prime-fac [number] 
	(loop [prime 2]
		(cond (divider? number prime) (concat [prime] (prime-fac (/ number prime)))
					(< prime number) (recur (inc prime))
					(> number 1) [number]
					:else [])))

(deftest computes-prime-factors[]
	(is (= (prime-fac 1) []))
	(is (= (prime-fac 2) [2]))
	(is (= (prime-fac 3) [3]))
	(is (= (prime-fac 4) [2 2]))
	(is (= (prime-fac 5) [5]))
	(is (= (prime-fac 6) [2 3]))
	(is (= (prime-fac 7) [7]))
	(is (= (prime-fac 8) [2 2 2]))
	(is (= (prime-fac 9) [3 3]))
	(is (= (prime-fac 10) [2 5]))
)

(deftest foo []
	(are [x y] (= (prime-fac x) y)
		1 []
		2 [2]
		3 [3]
		4 [2 2]
		5 [5]
		6 [2 3]
		7 [7]
		8 [2 2 2]
		9 [3 3]
		10 [2 5]
))

(run-tests)
