using System;
using System.Collections.Generic;

public class TheInteger
{
    static long Inf = 9223372036854775807;

    List<int> ToBits(long num)
    {
        List<int> res = new List<int>();
        while (num > 0)
        {
            res.Add((int)(num % 10));
            num /= 10;
        }
        res.Reverse();
        return res;
    }

    long Recur(int idx, int mask, int flag, int k, long[,,] dp, List<int> b, long[,] mul)
    {
        if (dp[idx, mask, flag] != -1) return dp[idx, mask, flag];
        if (idx == b.Count)
        {
            dp[idx, mask, flag] = (k == 0) ? 0 : Inf;
            return dp[idx, mask, flag];
        }
        long res = Inf;
        int start = (flag == 0) ? b[idx] : 0; 
        for (int i = start; i <= 9; ++ i)
        {
            int nflag = (i > b[idx]) ? 1 : flag;
            int nk = ((mask & (1 << i)) != 0) ? k : (k - 1);
            long ret = Recur(idx + 1, mask | (1 << i), nflag, nk, dp, b, mul);
            if (ret != Inf)
            {
                res = mul[i, b.Count - idx] + ret;
                break;
            }
        }
        dp[idx, mask, flag] = res;
        return res;
    }

    public long find(long n, int k)
    {
        long[,] mul = new long[10, 20];
        for (int i = 0; i <= 9; ++ i)
        {
            mul[i, 0] = 1;
            mul[i, 1] = i;
            for (int j = 2; j <= 19; ++ j) mul[i, j] = mul[i, j - 1] * 10;
        }
        List<int> b = ToBits(n);
        long[,,] dp = new long[b.Count + 1, 1024, 2];
        for (int i = 0; i < b.Count + 1; ++ i)
        {
            for (int j = 0; j < 1024; ++ j) dp[i, j, 0] = dp[i, j, 1] = -1;
        }
        long ret = Recur(0, 0, 0, k, dp, b, mul);
        if (ret != Inf) return ret;
        long res = 10;
        for (int i = 0; i < Math.Max(b.Count + 1, k) - k; ++ i) res *= 10;
        for (int d = 2; d < k; ++ d) res = res * 10 + d;
        return res;
    }

    static void Main()
    {
        TheInteger obj = new TheInteger();

        long n = 47;
        int k = 1;
        Console.WriteLine(obj.find(n, k));

        n = 7;
        k = 3;
        Console.WriteLine(obj.find(n, k));

        n = 69;
        k = 2;
        Console.WriteLine(obj.find(n, k));

        n = 12364;
        k = 3;
        Console.WriteLine(obj.find(n, k));

        n = 111;
        k = 3;
        Console.WriteLine(obj.find(n, k));

        n = 103;
        k = 4;
        Console.WriteLine(obj.find(n, k));

        n = 999;
        k = 1;
        Console.WriteLine(obj.find(n, k));

        n = 100;
        k = 10;
        Console.WriteLine(obj.find(n, k));

        n = 100;
        k = 3;
        Console.WriteLine(obj.find(n, k));

        n = 9876543210;
        k = 9;
        Console.WriteLine(obj.find(n, k));

        n = 8876543210123456789;
        k = 1;
        Console.WriteLine(obj.find(n, k));

        n = 8876543210123456789;
        k = 9;
        Console.WriteLine(obj.find(n, k));

        n = 8876543210123456789;
        k = 10;
        Console.WriteLine(obj.find(n, k));

        n = 1000000000000000000;
        k = 1;
        Console.WriteLine(obj.find(n, k));

        n = 1000000000000000000;
        k = 9;
        Console.WriteLine(obj.find(n, k));

        n = 1000000000000000000;
        k = 10;
        Console.WriteLine(obj.find(n, k));
    }
}
