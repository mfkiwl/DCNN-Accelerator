#include "utilities.h"
#include "input.h"
#include "jajankenImg.h"
#include "output.h"
#include "aspireOCR.h"
#include <vector>
#include <algorithm>
using namespace cv;
using namespace std;

input inp;
jajankenImg mainProc;
output out;
aspireOCR ocr;
Mat intro(int turn)
{
	if (turn == 1) out.say("hello my friend . my name is janken and now you are using my app . you have two choices.  first to take a photo from the laptop camera .  second to enter the name of the photo in this laptop .");
	out.say(" press 1 for the first choice .  press 2 for second choice ");
	int choice;
	cin >> choice;
	while (choice != 1 && choice != 2)
	{
		out.say("enter a valid number and stop kidding please");
		cin >> choice;
	}
	Mat img;
	if (choice == 2)
	{
		out.say("Please  enter  the path of the image");
		img = inp.readImage();
	}
	else
	{
		out.say("Please hold your photo in front of the laptop and select the window then press escape to capture it");
		VideoCapture cap;
		if (!cap.open(0))
			return img;
		while (1)
		{
			while (1)
			{
				cap >> img;
				imshow("hi dud", img);
				if (img.empty()) break; // end of video stream
				if (waitKey(10) == 27) break; // stop capturing by pressing ESC 
			}
			imshow("hi dud", img);
			out.say("if you  accept   this  photo  press  escape  else press anything");
			int x = waitKey();
			if (x == 27) break;
		}
		inp.setImagePath();
	}
	return img;
}

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
void gen(Mat img) {

	int k = 0;
	for (int i = 0; i < 256; ++i)
		for (int j = 0; j < 256; ++j)
		{
			vec.push_back(toBin(img.at < uchar >(i, j) /25));
			k++;
		}
	for (int i = 0; i < 5; ++i)
		for (int j = 0; j < 5; ++j)
			vec.push_back("00000001"), k++;


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

int main() {
	
	Mat img = imread("test.jpg", CV_LOAD_IMAGE_COLOR);
	Mat gray;
	cvtColor(img, gray, cv::COLOR_RGB2GRAY);
	//gen(gray);
	imshow("in", gray);
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
		else if (s == "@1f830")
		{
			ss >> s;
			vec.push_back(s);
			break;
		}
		while (start && ss >> s) vec.push_back(s);
    }

	Mat out(252, 252, CV_8UC1, 255);
	for (int i = 0, k = 0; i < 252; ++i)
		for (int j = 0; j < 252; ++j, ++k) out.at<uchar>(i, j) = toInt(vec[k]);
	imwrite("out.jpg" ,out);
}
