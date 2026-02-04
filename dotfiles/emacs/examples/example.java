// Example Java file

package com.example;

import java.util.List;
import java.util.stream.Collectors;

public class Example {
    private String name;
    private int age;

    public Example(String name, int age) {
        this.name = name;
        this.age = age;
    }

    public String greet() {
        return String.format("Hello, my name is %s", name);
    }

    public static List<String> processItems(List<String> items) {
        return items.stream()
            .filter(item -> item.length() > 3)
            .map(String::toUpperCase)
            .collect(Collectors.toList());
    }

    public static void main(String[] args) {
        Example person = new Example("Alice", 30);
        System.out.println(person.greet());

        List<String> items = List.of("foo", "bar", "hello", "world");
        System.out.println(processItems(items));
    }
}
