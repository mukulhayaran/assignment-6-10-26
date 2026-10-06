#  Structs, C strings and complex numbers

Three questions, one file each. Each one reads its input, works out the answer, and
prints it. You need only what has been covered so far: structs, arrays, C-style
strings (`char` arrays), functions, and references.

This course uses **C++17**. Build any question with:

```
g++ -std=c++17 -Wall -Wextra -pedantic q1.cpp -o q1
./q1
```

All three questions read from the keyboard (standard input) and print to the screen.

---

## q1 — people records

Create a `struct Person` with the fields `name`, `age`, `gender` and `profession`.
Create an array that holds **100** people. Write a function called **`update`** that
takes a **reference to the array** as its parameter and updates the information based
on user input.

Input:

```
k
index name age gender profession      (this line is repeated k times)
```

| Part         | Meaning                                                     |
| ------------ | ----------------------------------------------------------- |
| `k`          | how many updates follow                                     |
| `index`      | which of the 100 slots to update, from `0` to `99`          |
| `name`       | a single word, no spaces, at most 49 characters             |
| `age`        | a whole number                                              |
| `gender`     | a single character, such as `M`, `F` or `O`                 |
| `profession` | a single word, no spaces, at most 49 characters             |

Output:

| Condition                          | Print                                                              |
| ---------------------------------- | ------------------------------------------------------------------ |
| an update has an index outside 0–99 | `INVALID INDEX` (right away, and that update is ignored)           |
| after all updates are read         | one line per filled slot, in increasing index order, as `index name age gender profession` |

Slots that were never updated print nothing. Updating the same index twice replaces
the earlier record.

**How to do it.** Declare the array once in `main` (`Person people[100] = {};` starts
every slot empty) and pass it to `update`. The parameter has to be a *reference to the
array*, so that the function changes the caller's array rather than a copy:

```
void update(Person (&people)[100]);
```

The brackets and parentheses are easy to get wrong, so type it exactly. Read the index
first, check it, and only then store the record. You need some way to know which slots
have been filled; a `bool` field in the struct is one option, an empty name is another.

Worked examples:

```
2
5 Bob 41 M Teacher
2 Carol 28 F Doctor
```
```
2 Carol 28 F Doctor
5 Bob 41 M Teacher
```

```
2
7 Eve 22 F Pilot
100 Zed 50 M Chef
```
```
INVALID INDEX
7 Eve 22 F Pilot
```

## q2 — vowels and consonants

Input: `word`, one English word.

Save the word as a **C-style string** (a `char` array ending in `'\0'`), then identify
which letters are vowels and which are consonants. Do not use `std::string` for this
question.

| Condition                                      | Print                                                         |
| ---------------------------------------------- | ------------------------------------------------------------- |
| the word has any character that is not a letter, or there is no word | `INVALID`                               |
| anything else                                  | two lines: the vowels, then the consonants, in the order they appear |

The two lines look like this, with the count in brackets and then the letters
separated by single spaces:

```
Vowels (2): e o
Consonants (3): h l l
```

**How to do it.** The vowels are `a e i o u`, in either case; every other letter is a
consonant, including `y`. Walk along the array with a `for` or `while` loop until you
reach the `'\0'`. First check that every character is a letter (`std::isalpha` from
`<cctype>`), and only then sort the letters out. Letters are printed exactly as typed,
so `E` stays `E`, but `E` still counts as a vowel. The word is at most 100 letters, so
a `char` array of 101 holds it with room for the `'\0'`.

Worked examples:

```
hello        -> Vowels (2): e o
                Consonants (3): h l l
Rhythm       -> Vowels (0):
                Consonants (6): R h y t h m
sky2         -> INVALID
```

## q3 — complex numbers

Input: `a b c d`, four numbers, meaning the two complex numbers `a + bi` and `c + di`.

Create a `struct ComplexNumber` that holds a complex number. Write **one function to
add** two complex numbers and **another to subtract** one from the other. Both take
`ComplexNumber` values and return a `ComplexNumber`.

| Condition | Print                                              |
| --------- | -------------------------------------------------- |
| always    | two lines: `Sum: ...` and `Difference: ...`        |

Each result is printed as `real + imag i` when the imaginary part is zero or positive,
and as `real - imag i` when it is negative. Print the size of the imaginary part
without its sign, and write the `i` straight after it.

**How to do it.** Use `double` for the two parts so that inputs like `1.5` work. The
arithmetic is done part by part:

```
(a + bi) + (c + di)  =  (a + c)  +  (b + d)i
(a + bi) - (c + di)  =  (a - c)  +  (b - d)i
```

Choose the `+` or `-` by looking at the sign of the imaginary part, and print its
absolute value (`std::fabs` from `<cmath>`) so that you never get `+ -2i`. Plain
`std::cout` formatting is enough: `2` prints as `2` and `1.5` as `1.5`.

Worked examples:

```
1 2 3 4        -> Sum: 4 + 6i
                  Difference: -2 - 2i
1.5 2.5 0.5 -1 -> Sum: 2 + 1.5i
                  Difference: 1 + 3.5i
```

---

## Check your work

```
chmod +x check.sh
./check.sh
```

`chmod` is only needed once — unzipping a download removes the executable bit.

The check builds each question, makes a few structural checks on your code (for
example, that `q1.cpp` really defines a `Person` struct and an `update` function that
takes the array by reference), and then runs a set of cases against it. It prints
`PASS` or shows you the input, what was expected, and what your program printed. The
untouched template fails nearly every check; that is expected until you write the code.

Trailing spaces at the end of a line and blank lines at the end of the output are
ignored; everything else must match exactly.

## Submitting

Commit and push to `main`. The last commit on `main` at the deadline is what gets
graded. Editing a file only on your own machine does not submit anything.
