// Example JavaScript file

class Person {
  constructor(name, age) {
    this.name = name;
    this.age = age;
  }

  greet() {
    return `Hello, my name is ${this.name}`;
  }
}

function processItems(items) {
  return items
    .filter(item => item.length > 3)
    .map(item => item.toUpperCase());
}

const person = new Person("Alice", 30);
console.log(person.greet());

const items = ["foo", "bar", "hello", "world"];
console.log(processItems(items));
