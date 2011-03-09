#include <gtest/gtest.h>

const void* %kata_file%() {
	return "fixme";
}

TEST(%Kata_file%Test, %Kata_file%) {
  EXPECT_EQ("foo", %kata_file%());
}

