// Example TypeScript file

interface PersonData {
  name: string;
  age: number;
}

class Person implements PersonData {
  constructor(
    public name: string,
    public age: number
  ) {}

  greet(): string {
    return `Hello, my name is ${this.name}`;
  }
}

function processItems(items: string[]): string[] {
  return items
    .filter((item) => item.length > 3)
    .map((item) => item.toUpperCase());
}

const person = new Person("Alice", 30);
console.log(person.greet());

const items: string[] = ["foo", "bar", "hello", "world"];
console.log(processItems(items));
