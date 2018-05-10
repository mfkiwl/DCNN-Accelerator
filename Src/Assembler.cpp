#include <bits/stdc++.h>

using namespace std;
string dataPath = "ram.mem";
int maxi = 256 * 256;
vector<string> vec;
string decToHexa(int i) {
	string ans = "";
	while (i) {
		if (i % 16 < 10)
			ans += (i % 16) + '0';
		else
			ans += (i % 16 - 10) + 'a';
		i/=16;
	}
	reverse(ans.begin(), ans.end());
	if (ans.empty())
		ans = "0";
	return ans;
}
void gen() {

	int k = 0;
	for (int i = 0; i < maxi / 2; ++i)
		vec.push_back("00000000"), k++;
	for (int i = 0; i < maxi / 2; ++i)
		vec.push_back("01111111"), k++;

	for (int i = 0; i < 5; ++i)
		for (int j = 0; j < 5; ++j)
			vec.push_back("00000001"), k++;
	for (; k <= 262143; ++k)
		vec.push_back("00000000");

	freopen(dataPath.c_str(), "w", stdout);
	cout<< "// memory data file (do not edit the following line - required for mem load use)\n";
	cout<< "// instance=/pu/RAM_LAB/MEMORY\n";
	cout<< "// format=bin addressradix=h dataradix=b version=1.0 wordsperline=1";
	cout<< "wordsperline=1" << endl;
	for (int i = 0; i < vec.size(); ++i) {
		if (i <= 0xf) {
			cout << "  @";
		} else if (i <= 0xff) {
			cout << " @";
		} else {
			cout << "@";
		}
		string s = decToHexa(i);
		cout << s << " " << vec[i] << endl;
	}
}
int main() {
	gen();
	return 0;
}
