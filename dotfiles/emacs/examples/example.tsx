// Example TSX file

import React, { useState } from 'react';

interface Person {
  name: string;
  age: number;
}

interface Props {
  initialPerson: Person;
}

const PersonCard: React.FC<Props> = ({ initialPerson }) => {
  const [person, setPerson] = useState<Person>(initialPerson);
  const [items, setItems] = useState<string[]>(['foo', 'bar', 'hello', 'world']);

  const greet = (): string => {
    return `Hello, my name is ${person.name}`;
  };

  const processItems = (items: string[]): string[] => {
    return items
      .filter((item) => item.length > 3)
      .map((item) => item.toUpperCase());
  };

  return (
    <div className="person-card">
      <h1>{greet()}</h1>
      <p>Age: {person.age}</p>
      <ul>
        {processItems(items).map((item, index) => (
          <li key={index}>{item}</li>
        ))}
      </ul>
      <button onClick={() => setPerson({ ...person, age: person.age + 1 })}>Birthday!</button>
    </div>
  );
};

export default PersonCard;
