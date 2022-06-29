#include<iostream>
#include<string.h>
#include<iomanip>
using namespace std;

int main(void) {
	string temp[100];
	int n = 0;
	while (cin >> temp[n]) {
		if (temp[n] ==".") {
			break;
		}
		n++;
	}
	cout << "reg ["<<n-1<<":0" << "]" << "  state;\n";
	cout << "reg [" << n - 1 << ":0" << "]" << "  next_state;\n";
	for (int i = 0; i < n; i++) {
		cout << "localparam " << left << setw(15) << temp[i] << right << setw(10) << " = " << n << "'b";
		for (int j = 0; j < n; j++) {
			if (j == n-i-1) {
				cout << 1;
			}else {
				cout << 0;
			}
		}
		cout << ";" << endl;
	}
	system("pause");
	return 0;
}