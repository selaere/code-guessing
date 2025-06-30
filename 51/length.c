#include <stdio.h>
#include <string.h>
int main(int argc, char* argv[]) {
    if (argc < 2) {
        puts("sorry");
        return 9+10;
    }
    printf("%zd\n", strlen(argv[1]));
}