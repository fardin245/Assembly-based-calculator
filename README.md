# Assembly-Based-Calculator

The input numbers are taken as separate digits rather than whole numbers in order to obtain the ASCII values easily. The operation is performed only after ‘=‘ is pressed and the output is directly shown. For all the operations, the calculations are done individually for each digit of the numbers since the output is to be saved in ASCII format. So, the operation of ones place digits are done first and then the next set of digits. 

Loops are used to make this repetitive process simpler and extra loops are considered for some special cases such as when both numbers are 0 or there are uneven number of significant digits. Moreover, multiplication is substituted with successive addition to ensure the proper decimal value is obtained. Using the direct MUL instruction would give a hexadecimal value which would require complicated coding for adjusting to corresponding decimal and ASCII value.

The ON/C button resets the entire program at any time.
