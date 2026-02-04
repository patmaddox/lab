// Example C++ file

#include <iostream>
#include <string>
#include <vector>
#include <algorithm>

class Person {
public:
	Person(const std::string& name, int age)
	    : name_(name), age_(age) {}

	std::string greet() const {
		return "Hello, my name is " + name_;
	}

private:
	std::string name_;
	int age_;
};

std::vector<std::string> processItems(const std::vector<std::string>& items) {
	std::vector<std::string> result;
	for (const auto& item : items) {
		if (item.length() > 3) {
			std::string upper = item;
			std::transform(upper.begin(), upper.end(), upper.begin(), ::toupper);
			result.push_back(upper);
		}
	}
	return result;
}

int main() {
	Person person("Alice", 30);
	std::cout << person.greet() << std::endl;

	std::vector<std::string> items = {"foo", "bar", "hello", "world"};
	for (const auto& item : processItems(items)) {
		std::cout << item << std::endl;
	}

	return 0;
}
