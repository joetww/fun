/*
https://www.facebook.com/groups/1403852566495675/permalink/2814688275412090/
我不想直接算出BMI
我只想列出計算式，再送給bash去找bc來算

$ ./main | bash
Input Your Height: 182
Input Your Weight: 110
33.23

*/

#include <stdio.h>

int main()
{
    float Hight;
    float Weight;
    float HightKG;
    float BMI;
    fprintf(stderr, "Input Your Height: ");
    scanf("%f",&Hight);
    fprintf(stderr, "Input Your Weight: ");
    scanf("%f",&Weight);
    HightKG=(Hight * 0.01);
    BMI=(Weight/(HightKG*HightKG));
    printf("#Your BMI Size is %f\n",BMI);
    printf("echo \"scale = 2; %f / ( %f / 100 )^2\" | $(which bc)\n", Weight, Hight);
    return 0;
}
