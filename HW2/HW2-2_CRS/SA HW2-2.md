# SA HW2-2

## Goal

## Crul NCTU CS's timetable

```shell
curl 'https://timetable.nctu.edu.tw/?r=main/get_cos_list' --data 'm_acy=107&m_sem=1&m_degree=3&m_dep_id=17&m_group=**&m_grade=**&m_class=**&m_option=**&m_crsname=**&m_teaname=**&m_cos_id=**&m_cos_code=**&m_crstime=**&m_crsoutline=**&m_costype=**' > nctucsClass.json
```



## Dialog

### --buildlist to build 2 unselected/selected list

```shell
  # input
  dialog --buildlist "Select a directory" 20 50 5 \
  f1 "Directory One" off \
  f2 "Directory Two" on \
  f3 "Directory Three" on
  
  # output
     ┌────────────────────────────────────────────────┐
     │ Select a directory                             │
     │ ┌─────────────────────┐ ┌────^(-)─────────────┐│
     │ │Directory One        │ │Directory Two        ││
     │ │                     │ │Directory Three      ││
     │ │                     │ │                     ││
     │ │                     │ │                     ││
     │ │                     │ │                     ││
     │ └─────────────────────┘ └─────────────100%────┘│
     │                                                │
     │                                                │
     │                                                │
     │                                                │
     │                                                │
     │                                                │
     │                                                │
     │                                                │
     ├────────────────────────────────────────────────┤
     │           <OK>          <Cancel>               │
     └────────────────────────────────────────────────┘
```

#### How to control

The controls:

- `^` selects the left column
- `$` selects the right column
- Move up and down the selected column with the arrow keys
- Move the selected item to the other column with the space bar
- Toggle between OK and Cancel with the tab key. If you use the `--visit-items` option, the tab key lets you cycle through the lists as well as the buttons.
- Hit enter to select OK or cancel.

If you select OK, the tags (`f1`, `f2`, etc) associated with each item in the right column is printed to standard output.

### Detail of return value

There are several environment variable: 

| environment variable | return value |
| -------------------- | ------------ |
| DIALOG_CANCEL        | 1            |
| DIALOG_ERROR         | -1           |
| DIALOG_ESC           | 255          |
| DIALOG_EXTRA         | 3            |
| DIALOG_HELP          | 2            |
| DIALOG_OK            | 0            |

### Grep (group in the match)

GNU grep has the `-P` option for perl-style regexes, and the `-o` option to print only what matches the pattern. 

The `\K` is the short-form (and more efficient form) of `(?<=pattern)` which you use as a zero-width look-behind assertion before the text you want to output. `(?=pattern)` can be used as a zero-width look-ahead assertion after the text you want to output.

```shell
# match the word between foo and bar
$ grep -oP 'foo \K\w+(?= bar)' test.txt
$ grep -oP '(?<=foo )\w+(?= bar)' test.txt
```

### Xargs

By default `xargs` reads items from standard input as separated by blanks and executes a command once for each argument.

```shell
echo 'one two three' | xargs mkdir
ls
one two three
```

### Sed(replace single quote)

```shell
sed 's/\x27/\\\x27/g'
sed "s/'/\\\'/"
sed 's/'\''/ /g'
```

### Replace a string

To replace the *first* occurrence of a pattern with a given string, use `${parameter/pattern/string}`:

```sh
#!/bin/bash
firstString="I love Suzi and Marry"
secondString="Sara"
echo "${firstString/Suzi/$secondString}"    # prints 'I love Sara and Marry'
```

To replace *all* occurrences, use `${parameter//pattern/string*}`:

```sh
message='The secret code is 12345'
echo "${message//[0-9]/X}"           # prints 'The secret code is XXXXX'
```

### Source another shell script(Bourne shell)

```sh
. ./library.sh
```



