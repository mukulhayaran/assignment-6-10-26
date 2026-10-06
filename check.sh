#!/usr/bin/env bash
# Builds each question, makes a few structural checks, and runs a set of cases.
# Usage: ./check.sh

cd "$(dirname "$0")" || exit 1

CXX="${CXX:-g++}"
FLAGS="-std=c++17 -Wall -Wextra -pedantic"

pass=0
fail=0
Q=""

if command -v timeout >/dev/null 2>&1; then
  TO="timeout 5"
else
  TO=""
fi

strip_trailing() { sed 's/[[:space:]]*$//'; }

ok() {
  echo "  PASS  $1"
  pass=$((pass + 1))
}

bad() {
  echo "  FAIL  $1"
  fail=$((fail + 1))
}

# build <q>: compile <q>.cpp into ./<q>; returns non-zero on failure
build() {
  Q="$1"
  rm -f "$Q"
  if ! $CXX $FLAGS "$Q.cpp" -o "$Q" 2> "$Q.build.log"; then
    echo "  BUILD FAILED"
    sed 's/^/    /' "$Q.build.log"
    rm -f "$Q.build.log"
    return 1
  fi
  rm -f "$Q.build.log"
  return 0
}

# code <file>: the file with // comments removed, so comments never satisfy a check
code() { sed 's://.*::' "$1"; }

# require <file> <regex> <description>
require() {
  if code "$1" | grep -Eq "$2"; then ok "$3"; else bad "$3"; fi
}

# forbid <file> <regex> <description>
forbid() {
  if code "$1" | grep -Eq "$2"; then bad "$3"; else ok "$3"; fi
}

# run_case <label> <input> <expected output>
run_case() {
  local label="$1" input="$2" want got
  want=$(printf '%s' "$3" | strip_trailing)
  got=$(printf '%s' "$input" | $TO "./$Q" 2>&1 | strip_trailing)
  if [ "$got" == "$want" ]; then
    ok "$label"
  else
    bad "$label"
    echo "    input:"
    printf '%s\n' "$input" | sed 's/^/      /'
    echo "    expected:"
    printf '%s\n' "$want" | sed 's/^/      /'
    echo "    your program printed:"
    printf '%s\n' "$got" | sed 's/^/      /'
  fi
}

# skip_cases <count>: a question that did not build fails all of its cases
skip_cases() {
  fail=$((fail + $1))
}

# ---------------------------------------------------------------- q1
echo "q1 - people records"
require q1.cpp 'struct[[:space:]]+Person' "defines struct Person"
require q1.cpp '\[[[:space:]]*100[[:space:]]*\]' "uses an array of 100"
require q1.cpp 'update[[:space:]]*\([^)]*&[^)]*\)' "update() takes the array by reference"
if build q1; then
  run_case "one update" \
$'1\n0 Alice 30 F Engineer\n' \
$'0 Alice 30 F Engineer'

  run_case "several updates, printed in index order" \
$'3\n5 Bob 41 M Teacher\n2 Carol 28 F Doctor\n99 Dan 19 M Student\n' \
$'2 Carol 28 F Doctor\n5 Bob 41 M Teacher\n99 Dan 19 M Student'

  run_case "same index updated twice" \
$'2\n7 Eve 22 F Pilot\n7 Eve 23 F Captain\n' \
$'7 Eve 23 F Captain'

  run_case "indexes out of range" \
$'2\n100 Zed 50 M Chef\n-1 Yan 60 M Cook\n' \
$'INVALID INDEX\nINVALID INDEX'

  run_case "valid and invalid updates mixed" \
$'3\n3 Fay 33 F Nurse\n150 Gus 44 M Judge\n0 Hal 55 O Writer\n' \
$'INVALID INDEX\n0 Hal 55 O Writer\n3 Fay 33 F Nurse'

  run_case "first and last slot" \
$'2\n99 Ivy 61 F Chemist\n0 Jon 18 M Student\n' \
$'0 Jon 18 M Student\n99 Ivy 61 F Chemist'
else
  skip_cases 6
fi
echo

# ---------------------------------------------------------------- q2
echo "q2 - vowels and consonants"
require q2.cpp 'char' "uses a char array"
forbid q2.cpp 'std::string|#include[[:space:]]*<string>' "does not use std::string"
if build q2; then
  run_case "hello" \
$'hello\n' \
$'Vowels (2): e o\nConsonants (3): h l l'

  run_case "no vowels (y is a consonant)" \
$'Rhythm\n' \
$'Vowels (0):\nConsonants (6): R h y t h m'

  run_case "capital letters keep their case" \
$'Education\n' \
$'Vowels (5): E u a i o\nConsonants (4): d c t n'

  run_case "a single vowel" \
$'a\n' \
$'Vowels (1): a\nConsonants (0):'

  run_case "all vowels" \
$'AEIOU\n' \
$'Vowels (5): A E I O U\nConsonants (0):'

  run_case "digit in the word" \
$'sky2\n' \
$'INVALID'

  run_case "apostrophe in the word" \
$"it's"$'\n' \
$'INVALID'

  run_case "no word at all" \
$'' \
$'INVALID'
else
  skip_cases 8
fi
echo

# ---------------------------------------------------------------- q3
echo "q3 - complex numbers"
require q3.cpp 'struct[[:space:]]+ComplexNumber' "defines struct ComplexNumber"
if build q3; then
  run_case "whole numbers" \
$'1 2 3 4\n' \
$'Sum: 4 + 6i\nDifference: -2 - 2i'

  run_case "decimals and a negative part" \
$'1.5 2.5 0.5 -1\n' \
$'Sum: 2 + 1.5i\nDifference: 1 + 3.5i'

  run_case "all zero" \
$'0 0 0 0\n' \
$'Sum: 0 + 0i\nDifference: 0 + 0i'

  run_case "all negative" \
$'-3 -4 -5 -6\n' \
$'Sum: -8 - 10i\nDifference: 2 + 2i'

  run_case "identical numbers" \
$'5 7 5 7\n' \
$'Sum: 10 + 14i\nDifference: 0 + 0i'

  run_case "purely real" \
$'4 0 1 0\n' \
$'Sum: 5 + 0i\nDifference: 3 + 0i'
else
  skip_cases 6
fi
echo

total=$((pass + fail))
echo "$pass of $total checks passed"
[ "$fail" -eq 0 ]
