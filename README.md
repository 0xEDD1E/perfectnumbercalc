# perfectnumbercalc
Calculate Perfect numbers in a range

### Description
`perfectnum` is a assembly written program to find perfect numbers in a user given range.<br />
The program asks the user to input a maximum number which is the upper bound of the range stated above. And the program finds (prints) perfect numbers between 1 and maximum. I think the algorithm used in this program is very slow (and I couldn't implement a fast one yet!) because biggest number I could found with this program is 8128 (next one is 8 digit number, It can be found in wikipedia). And beause this is written in Assembly(NASM)(and of course because my little experiences :baby:) source file(`perfectnum.asm`) may look like a noodles cup! :pensive: :warning:

### Usage Samples
*Normal Case:*
```
$ ./perfectnum
Input the maximum number (< 4294967295): 9000
Perfect number found in the given range:
6
28
496
8128
$
```

*If no perfect numbers in the range:*
```
$ ./perfectnum
Input the maximum number (< 4294967295): 5
Perfect number found in the given range:
$
```
*If user input an invalid number:*
```
$ ./perfectnum
Input the maximum number (< 4294967295): nan
Perfect number found in the given range: 
ERROR: Input is Not A Number
$
```

### Limitations
Because I assembled this program in a 32-bit environment, Maximum number this program can handle in `4294967295`.
This is caused because I heavily depends on the x86 GP registers (`EAX, EBX, ECX, EDX, EDI, ESI, EBP`).
This means If I used x86-64 GP Registers that `perfectnum` can handle is ![2^{64} - 1](http://www.sciweavers.org/upload/Tex2Img_1454580303/render.png)

### Conculsion
Yes, This Program is not very useful.
However, this program implements several homemade techniques, namely `Str2Num`, `Num2Str`. These techniques(by "techniques" I mean something similar to a function :thought_balloon:) can be found in C as `atoi` and `%d`
