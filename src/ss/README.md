# ss

A couple differences from redo:

- build files not tightly coupled to output files
- stdout does not get captured by default - you always have to write
  something to ${target}

## hello world

``` shell
target hello
needs hello.c

hello() {
  cc -o hello hello.c
}
```

## hello world: vars

``` shell
target hello
needs hello.c

hello() {
  cc -o ${target} ${deps}
}
```

## hello world: named build function

``` shell
target hello.out build_hello
needs hello.c

build_hello() {
  cc -o ${target} ${deps}
}
```

## hello world: implicit deps

``` shell
target hello
needs hello.c : hello.h

hello() {
  cc -o ${target} ${deps}
}
```

## hello world: produces

``` shell
target hello
needs hello.c
produces bin/hello lib/libhello.so

hello() {
  cc -shared -o lib/libhello.so hello.c
  cc -o bin/hello hello.c
}
```

## hello world: named needs and produces

``` shell
target hello
needs src=hello.c
produces bin=bin/hello lib=lib/libhello.so

hello() {
  cc -shared -o ${lib} ${src}
  cc -o ${bin} ${src}
}
```

## hello world: named transitive deps

``` shell
target libhello
needs hello.c : hello.h
produces lib=libhello.so

target hello
needs src=main.c libhello

libhello() {
  cc -shared -o ${lib} ${deps}
}

hello() {
  cc -o ${target} ${src} ${libhello__lib}
}
```

## hello world: transitive deps

``` shell
target libhello
needs hello.c : hello.h
produces libhello.so

target hello
needs main.c libhello

libhello() {
  cc -shared -o ${target}.so ${deps}
}

hello() {
  cc -o ${target} ${deps}
}
```

## hello world: dynamic needs

``` shell
target libhello
needs hello.c
produces so=libhello.so

target hello
needs hello.c

libhello() {
  cc -shared -o ${so} ${deps}
}

hello() {
  needs : lib=lib${target}
  cc -o ${target} ${deps} ${lib__so}
}
```

## hello world: dynamic produces

``` shell
target libhello
needs hello.c

target hello
needs hello.c : libhello

libhello() {
  produces so=${target}.so
  cc -shared -o ${so} ${deps}
}

hello() {
  cc -o ${target} ${deps} ${libhello__so}
}
```
