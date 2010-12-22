rm bin/PrimeTest.class
javac -cp lib/junit.jar -d bin src/PrimeTest.java
java -cp lib/junit.jar:bin PrimeTest