#include "utilities.h"
#include "input.h"
#include "jajankenImg.h"
#include "output.h"
#include "aspireOCR.h"
#include <vector>
#include <algorithm>
using namespace cv;
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
		i /= 16;
	}
	reverse(ans.begin(), ans.end());
	if (ans.empty())
		ans = "0";
	return ans;
}
string toBin(int x)
{
	string ans = "";
	while (x)
	{
		ans += (x % 2) + '0';
		x /= 2;
	}
	reverse(ans.begin(), ans.end());
	while (ans.size() < 8) ans = "0" + ans;
	return ans;
}
int arr[10][10];
void gen(Mat img , int ws , int fact , int stride , int algo) {

	int k = 0;
	for (int i = 0; i < 256; ++i)
		for (int j = 0; j < 256; ++j)
		{
			vec.push_back(toBin(img.at < uchar >(i, j) /25));
			k++;
		}
	for (int i = 0; i < ws; ++i)
		for (int j = 0; j < ws; ++j)
			vec.push_back(toBin(arr[i][j]/fact)), k++;

	
	for (; k <= 262143; ++k)
		vec.push_back("00000000");

	freopen(dataPath.c_str(), "w", stdout);
	cout << "// memory data file (do not edit the following line - required for mem load use)\n";
	cout << "// instance=/pu/RAM_LAB/MEMORY\n";
	cout << "// format=bin addressradix=h dataradix=b version=1.0 wordsperline=1";
	cout << "wordsperline=1" << endl;
	for (int i = 0; i < vec.size(); ++i) {
		if (i <= 0xf) {
			cout << "  @";
		}
		else if (i <= 0xff) {
			cout << " @";
		}
		else {
			cout << "@";
		}
		string s = decToHexa(i);
		cout << s << " " << vec[i] << endl;
	}
	
	fclose(stdout);
	freopen("doFile.do", "w", stdout);
	cout<<"vsim work.main"<<endl;
	cout<<"mem load -i {D:\Projects\Image Processing\ya rab sotor\ya rab sotor/ram.mem} /main/dma/ram/ram"<<endl;
	cout<<"add wave -r /*"<<endl;
	cout<<"force -freeze sim:/main/clk 1 0, 0 {50 ns} -r 100"<<endl;
	cout<<"force -freeze sim:/main/algo "<<algo <<" 0"<<endl;
	cout<<"force -freeze sim:/main/ws "<<ws <<" 0"<<endl;
	cout<<"force -freeze sim:/main/start 0 0"<<endl;
	cout<<"force -freeze sim:/main/stride "<<stride-1 <<" 0"<<endl;
	cout<<"run 100 ns"<<endl;
	cout<<"force -freeze sim:/main/start 1 0"<<endl;
	cout<<"run 45161900 ns"<<endl;
}
int toInt(string s)
{
	int ret = 0;
	int b = 1;
	reverse(s.begin(), s.end());
	for (int i = 0; i < s.size(); ++i) {
		ret += (s[i] - '0') * b; b *= 2;
	}
	return ret;
}

pair<int,int> generateDO()
{
	cout<<"Enter Image Path: "<<endl;
	string imagePath;
	cin>>imagePath;
	Mat img = imread(imagePath.c_str(), CV_LOAD_IMAGE_COLOR);
	Mat gray;
	cvtColor(img, gray, cv::COLOR_RGB2GRAY);
	imshow("in", gray);
	cout<<"Enter Stride : 1 for 1 step or 2 for 2 steps"<<endl;
	int stride;
	cin>>stride;

	
	cout<<"Enter window Size : 0 for 3*3 window or 1 for 5*5 window"<<endl;
	int ws;
	cin>>ws;

	cout<<"Enter Algorithm : 0 for convolution or 1 for pooling"<<endl;
	int algo;
	cin>>algo;


	if(algo == 1)
	{
		gen(gray , ws*2+3 , 1,stride , algo);
		return {ws*2+3 , stride};
	}

	
	cout<<"Choose to enter filter : 0 to enter manualy or 1 for ones filter"<<endl;
	int ch;
	cin>>ch;
	if(ch == 1)
	{
		cout<<"enter the filter"<<endl;
		for(int i = 0 ; i<ws*2+3 ; i++)
			for(int j = 0 ; j<ws*2+3 ; j++) cin>>arr[i][j];
			
	}
	else
	{
		for(int i = 0 ; i<ws*2+3; i++)
			for(int j = 0 ; j<ws*2+3 ; j++) arr[i][j] = 1;
	}
	
	cout<<"Enter a factor to divide each cell by"<<endl;
	int fact;
	cin>>fact;
	
	gen(gray,ws*2+3,fact,stride , algo);
	return {ws*2+3 +  , stride};
}
int main() {
	
	pair<int,int> imageData = generateDO();
	cout<<"Do file is ready please start your simulation and when it ends press any key"<<endl;
	waitKey();	

	ifstream file("out.mem");
	string line;
	bool start = 0;
	vector<string>vec;
	while (getline(file, line))
	{
		string s;
		stringstream ss;
		ss << line;
		ss >> s;
		if (s.size() < 6) continue;
		else if (s == "@10020")
		{
			start = 1;
			ss >> s;
		}
		else if (s == "@3ffff")
		{
			ss >> s;
			vec.push_back(s);
			break;
		}
		while (start && ss >> s) vec.push_back(s);
    }
	int cols = (256 - imageData.first + 1) / imageData.second;
	Mat out(cols, cols, CV_8UC1, 255);
	for (int i = 0, k = 0; i < cols; ++i)
		for (int j = 0; j < cols; ++j, ++k) out.at<uchar>(i, j) = toInt(vec[k]);
	imwrite("out.jpg" ,out);
}