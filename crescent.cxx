#include <iostream>

#include "CrescentConfig.h"
#include "MathFunctions.h"
using namespace std;
int main(int argc, char *argv[])
{
    const double inputValue = stod(argv[1]);
    cout << mathfunctions::sqrt(inputValue) << endl;
    cout << argv[0] << " Version " << Crescent_VERSION_MAJOR << "." << Crescent_VERSION_MINOR << endl;
    cout << "Usage: " << argv[0] << " number" << endl;
    return 0;
}
