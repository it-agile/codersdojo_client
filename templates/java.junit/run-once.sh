rm bin/%Kata_file%Test.class
javac -cp lib/junit.jar -d bin src/%Kata_file%Test.java
java -cp lib/junit.jar:bin %Kata_file%Test
