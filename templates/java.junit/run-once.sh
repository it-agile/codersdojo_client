rm bin/#{kata_file}Test.class
javac -cp lib/junit.jar -d bin src/#{kata_file}Test.java
java -cp lib/junit.jar:bin #{kata_file}Test
