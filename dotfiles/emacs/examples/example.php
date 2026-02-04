<?php
// Example PHP file

declare(strict_types=1);

class Person
{
    public function __construct(
        private string $name,
        private int $age
    ) {}

    public function greet(): string
    {
        return "Hello, my name is {$this->name}";
    }
}

function processItems(array $items): array
{
    return array_map(
        fn($item) => strtoupper($item),
        array_filter($items, fn($item) => strlen($item) > 3)
    );
}

$person = new Person("Alice", 30);
echo $person->greet() . "\n";

$items = ["foo", "bar", "hello", "world"];
print_r(processItems($items));
