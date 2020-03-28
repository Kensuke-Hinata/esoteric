import std.stdio, std.string, std.conv;

class DisjointSet
{
    protected:
        int[] p, h;

    public:
        this(int n)
        {
            p = new int[n];
            h = new int[n];
            foreach (i; 0 .. n)
            {
                p[i] = i;
                h[i] = 1;
            }
        }

        int find(int n)
        {
            if (p[n] == n) return n;
            p[n] = find(p[n]);
            return p[n];
        }

        void join(int n, int m)
        {
            int pn = find(n), pm = find(m);
            if (h[pn] > h[pm])
            {
                p[pm] = pn;
            }
            else
            {
                p[pn] = pm;
                if (h[pn] == h[pm]) ++ h[pm];
            }
        }
};

int main(string[] args)
{
    return 0;
}
