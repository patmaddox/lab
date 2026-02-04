#!/usr/bin/env python3
"""Example Python module."""

from dataclasses import dataclass
from typing import List


@dataclass
class Person:
    name: str
    age: int

    def greet(self) -> str:
        return f"Hello, my name is {self.name}"


def process_items(items: List[str]) -> List[str]:
    return [item.upper() for item in items if len(item) > 3]


def main():
    person = Person(name="Alice", age=30)
    print(person.greet())

    items = ["foo", "bar", "hello", "world"]
    result = process_items(items)
    print(result)


if __name__ == "__main__":
    main()
