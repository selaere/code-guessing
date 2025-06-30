#include <cstdlib>
#include <iostream>
#include <string>

int main(int argc, char* argv[]) {
    if (argc < 2) {
        puts("sorry");
        return 9+10;
    }
    std::string word = argv[1];
    std::cout << word.size() << std::endl;
}