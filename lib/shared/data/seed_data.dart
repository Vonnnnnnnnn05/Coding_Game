import '../../features/challenges/domain/challenge.dart';
import '../../features/editor/data/language_config.dart';
import '../../features/profile/data/user_profile.dart';

final seedProfile = UserProfile(
  id: 'demo-user',
  email: 'demo@gamingcode.local',
  displayName: 'Demo Coder',
  xp: 170,
  level: 1,
  streak: 3,
  solvedChallengeIds: {'two-sum'},
);

final seedLeaderboard = [
  seedProfile,
  const UserProfile(
    id: 'u2',
    email: 'maya@example.com',
    displayName: 'Maya Stack',
    xp: 840,
    level: 3,
    streak: 8,
    solvedChallengeIds: {'two-sum', 'valid-parentheses', 'merge-intervals'},
  ),
  const UserProfile(
    id: 'u3',
    email: 'rio@example.com',
    displayName: 'Rio Runtime',
    xp: 520,
    level: 2,
    streak: 5,
    solvedChallengeIds: {'two-sum', 'valid-parentheses'},
  ),
  const UserProfile(
    id: 'u4',
    email: 'nina@example.com',
    displayName: 'Nina Null',
    xp: 250,
    level: 1,
    streak: 2,
    solvedChallengeIds: {'two-sum'},
  ),
];

final seedChallenges = [
  Challenge(
    id: 'two-sum',
    title: 'Two Sum',
    slug: 'two-sum',
    difficulty: Difficulty.easy,
    description:
        'Given an array of integers and a target, return the indices of the two numbers that add up to the target.',
    examples: const [
      ChallengeExample(
        input: '4\n2 7 11 15\n9',
        output: '0 1',
        explanation: 'nums[0] + nums[1] equals 9.',
      ),
    ],
    constraints: const [
      '2 <= nums.length <= 10,000',
      'Each input has exactly one valid answer.',
      'Return indices in ascending order.',
    ],
    tags: const ['array', 'hash map'],
    starterCode: _starter(
      python: '''
nums_len = int(input())
nums = list(map(int, input().split()))
target = int(input())

# print two indices separated by a space
''',
      cpp: '''
#include <bits/stdc++.h>
using namespace std;

int main() {
  int n; cin >> n;
  vector<int> nums(n);
  for (int &x : nums) cin >> x;
  int target; cin >> target;
  return 0;
}
''',
      java: '''
import java.util.*;

class Main {
  public static void main(String[] args) {
    Scanner sc = new Scanner(System.in);
    int n = sc.nextInt();
    int[] nums = new int[n];
    for (int i = 0; i < n; i++) nums[i] = sc.nextInt();
    int target = sc.nextInt();
  }
}
''',
      javascript: '''
const fs = require('fs');
const input = fs.readFileSync(0, 'utf8').trim().split(/\\s+/).map(Number);
const n = input[0];
const nums = input.slice(1, n + 1);
const target = input[n + 1];
''',
      csharp: '''
using System;
using System.Linq;

class Program {
  static void Main() {
    int n = int.Parse(Console.ReadLine()!);
    int[] nums = Console.ReadLine()!.Split().Select(int.Parse).ToArray();
    int target = int.Parse(Console.ReadLine()!);
  }
}
''',
    ),
    testCases: const [
      TestCase(input: '4\n2 7 11 15\n9', expectedOutput: '0 1', isPublic: true),
      TestCase(input: '3\n3 2 4\n6', expectedOutput: '1 2', isPublic: false),
    ],
  ),
  Challenge(
    id: 'valid-parentheses',
    title: 'Valid Parentheses',
    slug: 'valid-parentheses',
    difficulty: Difficulty.easy,
    description:
        'Given a string containing brackets, determine if every opening bracket is closed in the correct order.',
    examples: const [
      ChallengeExample(
        input: '()[]{}',
        output: 'true',
        explanation: 'Each bracket closes in the same order it opens.',
      ),
    ],
    constraints: const ['1 <= s.length <= 10,000', 'Input uses only ()[]{}'],
    tags: const ['stack', 'string'],
    starterCode: _starter(
      python: "s = input().strip()\n# print true or false\n",
      cpp:
          "#include <bits/stdc++.h>\nusing namespace std;\nint main(){ string s; cin >> s; }\n",
      java:
          "import java.util.*;\nclass Main { public static void main(String[] args){ Scanner sc = new Scanner(System.in); String s = sc.next(); } }\n",
      javascript: "const s = require('fs').readFileSync(0, 'utf8').trim();\n",
      csharp:
          "using System;\nclass Program { static void Main(){ string s = Console.ReadLine()!; } }\n",
    ),
    testCases: const [
      TestCase(input: '()[]{}', expectedOutput: 'true', isPublic: true),
      TestCase(input: '([)]', expectedOutput: 'false', isPublic: false),
    ],
  ),
  Challenge(
    id: 'merge-intervals',
    title: 'Merge Intervals',
    slug: 'merge-intervals',
    difficulty: Difficulty.intermediate,
    description:
        'Merge all overlapping intervals and print the resulting intervals in ascending order.',
    examples: const [
      ChallengeExample(
        input: '4\n1 3\n2 6\n8 10\n15 18',
        output: '1 6\n8 10\n15 18',
        explanation: 'The first two intervals overlap and become 1 6.',
      ),
    ],
    constraints: const ['1 <= intervals.length <= 10,000'],
    tags: const ['sorting', 'intervals'],
    starterCode: _starter(
      python:
          "n = int(input())\nintervals = [tuple(map(int, input().split())) for _ in range(n)]\n",
      cpp:
          "#include <bits/stdc++.h>\nusing namespace std;\nint main(){ int n; cin >> n; vector<pair<int,int>> a(n); for(auto &p:a) cin>>p.first>>p.second; }\n",
      java:
          "import java.util.*;\nclass Main { public static void main(String[] args){ Scanner sc = new Scanner(System.in); int n = sc.nextInt(); } }\n",
      javascript:
          "const data = require('fs').readFileSync(0, 'utf8').trim();\n",
      csharp:
          "using System;\nclass Program { static void Main(){ int n = int.Parse(Console.ReadLine()!); } }\n",
    ),
    testCases: const [
      TestCase(
        input: '4\n1 3\n2 6\n8 10\n15 18',
        expectedOutput: '1 6\n8 10\n15 18',
        isPublic: true,
      ),
      TestCase(input: '2\n1 4\n4 5', expectedOutput: '1 5', isPublic: false),
    ],
  ),
  Challenge(
    id: 'shortest-path-grid',
    title: 'Shortest Path in Grid',
    slug: 'shortest-path-grid',
    difficulty: Difficulty.hard,
    description:
        'Find the fewest moves from the top-left cell to the bottom-right cell in a binary grid where 1 means blocked.',
    examples: const [
      ChallengeExample(
        input: '3 3\n0 0 0\n1 1 0\n0 0 0',
        output: '4',
        explanation: 'A shortest path moves right, right, down, down.',
      ),
    ],
    constraints: const ['1 <= rows, cols <= 500'],
    tags: const ['graph', 'bfs'],
    starterCode: _starter(
      python:
          "r, c = map(int, input().split())\ngrid = [list(map(int, input().split())) for _ in range(r)]\n",
      cpp:
          "#include <bits/stdc++.h>\nusing namespace std;\nint main(){ int r,c; cin>>r>>c; }\n",
      java:
          "import java.util.*;\nclass Main { public static void main(String[] args){ Scanner sc = new Scanner(System.in); int r=sc.nextInt(), c=sc.nextInt(); } }\n",
      javascript:
          "const input = require('fs').readFileSync(0, 'utf8').trim();\n",
      csharp:
          "using System;\nclass Program { static void Main(){ var first = Console.ReadLine()!.Split(); } }\n",
    ),
    testCases: const [
      TestCase(
        input: '3 3\n0 0 0\n1 1 0\n0 0 0',
        expectedOutput: '4',
        isPublic: true,
      ),
      TestCase(input: '2 2\n0 1\n1 0', expectedOutput: '-1', isPublic: false),
    ],
  ),
];

Map<String, String> _starter({
  required String python,
  required String cpp,
  required String java,
  required String javascript,
  required String csharp,
}) {
  return {
    supportedLanguages[0].key: python.trimLeft(),
    supportedLanguages[1].key: cpp.trimLeft(),
    supportedLanguages[2].key: java.trimLeft(),
    supportedLanguages[3].key: javascript.trimLeft(),
    supportedLanguages[4].key: csharp.trimLeft(),
  };
}
