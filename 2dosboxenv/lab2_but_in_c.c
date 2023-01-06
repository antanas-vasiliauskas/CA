#include <stdio.h>
#include <string.h>

#define MAX_LEN 256

int decimal_sum = 0;
int floating_sum = 0;

int main(void){
    FILE* fp = fopen("failas.csv", "rb");
    if (fp == NULL) {
      perror("Failed: ");
      return 1;
    }

    char buffer[MAX_LEN];
    int sum = 0;
    int cursor = 0;
    char first = 1;
    while (fread(buffer, 1, MAX_LEN, fp) != 0){
        for(int i = 0; i < MAX_LEN; i++)
            if(buffer[i] == '\n'){
                cursor += i+1;
                fseek(fp, cursor, SEEK_SET);
                break;
            }
        if(first)
            {first = 0; continue;}

        sum += five_digit_numbers_in_line(buffer);
        add_float_number_in_line(buffer);
    }



    fclose(fp);
    printf("%d\n", sum);
    printf("%d, %d\n", decimal_sum, floating_sum);
    return 0;
}


int five_digit_numbers_in_line(char *line){
    // memory
    char is_number = 1;
    char cell = 1;
    int number_count = 0;
    int digit_count = 0;
    int non_zero_reached = 0;

    // register
    int cx = -1;

    Loop:
        cx++;
        if(*(line+cx) != ';') goto Mark2;
        cell++;
        goto Mark3;
        Mark2:
        if(*(line+cx) != ' ') goto Mark4;
        Mark3:
        if(!is_number) goto Mark5;
        if(digit_count != 5) goto Mark5;
        number_count++;
        Mark5:

        is_number = 1;
        digit_count = 0;
        if(cell > 2) return number_count;
        goto Loop;
        Mark4:
        if(!is_number) goto Loop;
        if(*(line+cx) < 0x31) goto Mark10;
        if(*(line+cx) > 0x39) goto Mark10;
        digit_count++;
        non_zero_reached = 1;
        goto Loop;
        Mark10:
        if(*(line+cx) != 0x30) goto Mark6;
        if(non_zero_reached == 0) goto Loop;
        digit_count++;
        goto Loop;
        Mark6:
        if(digit_count != 0) goto Mark8;
        if(*(line+cx) == 0x2B) goto Mark7;
        if(*(line+cx) != 0x2D) goto Mark8;
        Mark7:
        goto Loop;
        Mark8:
        is_number = 0;
    goto Loop;
}





void add_float_number_in_line(char *line){
    int cell = 1;
    int bx = -1;
    char is_positive = 1;
    int which_number = 1;

    Loop2:
        printf("dec: %d, float: %d\n", decimal_sum, floating_sum);
        bx++;
        if(line[bx] == '\n') goto OutLoop2;
        if(line[bx] != ';') goto L1;
        cell++;
        goto Loop2;
        L1:
        if(cell < 6) goto Loop2;
        if(line[bx] == '+') goto Loop2;
        if(line[bx] != '-') goto L2;
        is_positive = 0;
        goto Loop2;
        L2:
        printf("char: %c\n", line[bx]);
        printf("cell: %d\n", cell);
        // Case numbers:
        if(which_number != 1) goto L3;
        which_number++;
        if(is_positive == 0) goto L4;
        decimal_sum += line[bx] - '0';
        goto L5;
        L4:
        decimal_sum -= line[bx] - '0';
        L5:
        bx++;
        goto Loop2;

        L3:
        if(which_number != 2) goto L6;
        which_number++;
        if(is_positive == 0) goto L7;
        floating_sum += (line[bx]-'0')*10;
        goto L8;
        L7:
        floating_sum -= (line[bx]-'0')*10;
        L8:
        goto Loop2;
        L6:
        if(is_positive == 0) goto L10;
        floating_sum += line[bx] - '0';
        goto OutLoop2;
        L10:
        floating_sum -= line[bx] - '0';
    OutLoop2:

    // Pop registers
    if(floating_sum >= 99) goto L12;
    if(floating_sum <= -99) goto L13;
    return;
    L12:
    floating_sum -= 100;
    decimal_sum++;
    return;
    L13:
    floating_sum += 100;
    decimal_sum--;
    return;
}
/**
cell = 1
bx = -1
is_positive = 1
which_number = 1
#global memory dw
decimal_sum = 0
floating_sum = 0

while(true)
    bx++
    if [bx + line] == '\n'
        break
    if [bx + line] == ';'
        cell++
        continue
    if cell < 6
        continue
    if [bx + line] == '+'
        continue
    if [bx + line] == '-'
        is_positive = 0
        continue
    ; case numbers
    if which_number == 1
        which_number ++
        if positive
            decimal_sum += [bx + line] - '0'
        else
            decimal_sum -= [bx + line] - '0'
        bx++ // jump dot
        continue
    if which_number == 2
        which_number++
        if positive
            floating_sum += ([bx + line] - '0')*10
        else
            floating_sum -= ([bx + line] - '0')*10
        continue
    if which_number == 3
        if positive
            floating_sum += [bx + line] - '0'
        else
            floating_sum -= [bx + line] - '0'
        break;

if floating_sum > 99
    floating_sum -= 100
    decimal_sum++







*/




/**
is_number = true
cell = 1
number_count = 0
digit_count = 0
while true
    if " " or ";"
        if is_number and digit_count == 5
            number_count++
        is_number = true
        digit_count = 0
        if ";"
            cell++
            if cell > 2
                return number_count
    else
        if not is_number
            continue
        else if is_digit_without_zero
            digit_count++
        else if is_zero and non_zero_reached
            digit_count++
        else if digit_count == 0 and (+ or -)
            continue
        else
            is_number = 0
*/
